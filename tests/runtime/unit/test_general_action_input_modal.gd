@tool
extends GutTest

const GENERAL_INPUT_MODAL_SCENE := preload(
	"res://addons/flowkit/editor/scenes/modals/FKActionCustom/general_action_input_modal.tscn"
)

class TestAction extends FKAction:
	var display_name := "Configure Movement"
	var action_description := "Configures the movement action."
	var input_definitions: Array[FKActionInput] = []

	func get_display_name() -> String:
		return display_name

	func get_description() -> String:
		return action_description

	func get_inputs() -> Array[FKActionInput]:
		return input_definitions

func _create_modal() -> FKGeneralActionInputModal:
	var modal := GENERAL_INPUT_MODAL_SCENE.instantiate() as FKGeneralActionInputModal
	modal.editor_globals = FKEditorGlobals.new()
	modal.legitimize()
	add_child(modal)
	return modal

func _create_args(action: TestAction, inputs: Dictionary) -> FKActionInputPopulationArgs:
	var args := FKActionInputPopulationArgs.new()
	args.action = action
	args.node_path = "Player"
	args.action_id = "move"
	args.action_inputs = action.get_inputs()
	args.inputs = inputs
	return args

func _free_modal(modal: FKGeneralActionInputModal) -> void:
	for input_ui in modal.input_holder.get_children():
		input_ui.free()
	modal.free()

func test_populate_for_action_creates_controls_with_saved_values():
	var action := TestAction.new()
	action.input_definitions = [
		FKFloatActionInput.new("Speed", "Movement speed", 1.0),
		FKStringActionInput.new("Message", "Text to show", "Ready"),
		FKBoolActionInput.new("Enabled", "Whether movement is enabled", true),
	]
	var modal := _create_modal()

	modal.populate_for_action(_create_args(action, {
		"Speed": 2.5,
		"Message": "\"Move now\"",
		"Enabled": false,
	}))

	var speed_ui := modal.input_holder.get_child(0) as FKFloatActionInputUi
	var message_ui := modal.input_holder.get_child(1) as FKStringActionInputUi
	var enabled_ui := modal.input_holder.get_child(2) as FKBoolActionInputUi
	assert_eq(modal.title, "Configure Movement")
	assert_eq(modal.desc_label.text, "Configures the movement action.")
	assert_eq(modal.input_holder.get_child_count(), 3)
	assert_eq(speed_ui.input_label.text, "Speed")
	assert_eq(speed_ui.spin_box.value, 2.5)
	assert_eq(message_ui.line_edit.text, "Move now")
	assert_false(enabled_ui.checkbox.button_pressed)
	_free_modal(modal)

func test_repopulate_reuses_compatible_control_and_refreshes_its_state():
	var first_action := TestAction.new()
	first_action.input_definitions = [FKFloatActionInput.new("Speed", "Initial speed", 1.0)]
	var second_action := TestAction.new()
	second_action.input_definitions = [FKFloatActionInput.new("Acceleration", "New acceleration", 0.0)]
	var modal := _create_modal()

	modal.populate_for_action(_create_args(first_action, {"Speed": 4.0}))
	var first_input_ui := modal.input_holder.get_child(0) as FKFloatActionInputUi
	modal.populate_for_action(_create_args(second_action, {"Acceleration": 9.0}))
	var second_input_ui := modal.input_holder.get_child(0) as FKFloatActionInputUi

	assert_same(second_input_ui, first_input_ui)
	assert_eq(second_input_ui.input_label.text, "Acceleration")
	assert_eq(second_input_ui.desc_label.text, "New acceleration")
	assert_eq(second_input_ui.spin_box.value, 9.0)
	_free_modal(modal)

func test_confirm_emits_edited_values_and_hides_modal():
	var action := TestAction.new()
	action.input_definitions = [
		FKFloatActionInput.new("Speed", "Movement speed", 1.0),
		FKBoolActionInput.new("Enabled", "Whether movement is enabled", true),
	]
	var modal := _create_modal()
	var received := {"node_path": "", "action_id": "", "inputs": {}}
	modal.editor_globals.modal_signals.expressions_confirmed.connect(
		func(node_path: String, action_id: String, inputs: Dictionary) -> void:
			received["node_path"] = node_path
			received["action_id"] = action_id
			received["inputs"] = inputs
	)
	modal.populate_for_action(_create_args(action, {"Speed": 1.5, "Enabled": true}))
	var speed_ui := modal.input_holder.get_child(0) as FKFloatActionInputUi
	var enabled_ui := modal.input_holder.get_child(1) as FKBoolActionInputUi
	speed_ui.spin_box.value = 3.0
	speed_ui._on_literal_control_gui_input(null)
	enabled_ui.checkbox.button_pressed = false
	enabled_ui._on_literal_control_gui_input(null)
	modal.show()

	modal._on_confirm_pressed()

	assert_eq(received["node_path"], "Player")
	assert_eq(received["action_id"], "move")
	assert_eq(received["inputs"], {"Speed": 3.0, "Enabled": false})
	assert_false(modal.visible)
	_free_modal(modal)

func test_cancel_hides_modal_without_confirming_inputs():
	var modal := _create_modal()
	var confirmation_count := 0
	modal.editor_globals.modal_signals.expressions_confirmed.connect(
		func(_node_path: String, _action_id: String, _inputs: Dictionary) -> void:
			confirmation_count += 1
	)
	modal.show()

	modal._on_cancel_pressed()

	assert_false(modal.visible)
	assert_eq(confirmation_count, 0)
	_free_modal(modal)
