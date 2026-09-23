@tool
extends GutTest

class TestAction extends FKAction:
	var input_definitions: Array[FKActionInput] = [
		FKFloatActionInput.new("Duration", "", 1.0),
		FKBoolActionInput.new("Wait For Finish", "", true),
	]
	var action_description := "Test action description"

	func get_inputs() -> Array[FKActionInput]:
		return input_definitions

	func get_description() -> String:
		return action_description

class TestModal extends FKActionInputModal:
	var apply_count := 0

	func _init():
		desc_label = Label.new()
		add_child(desc_label)

	func get_input_value(input_name: String) -> Variant:
		return _get_input_value(_get_action_input(input_name))

	func set_input_value(input_name: String, value: Variant) -> void:
		_set_input_value(_get_action_input(input_name), value)

	func get_values() -> Dictionary:
		return _inputs

	func _apply_ui_state_to_inputs():
		apply_count += 1

func test_modal_visibility_updates_shared_drag_guard():
	var modal := TestModal.new()

	modal._on_visibility_changed()
	assert_true(FKEditorGlobals.is_action_input_modal_visible)

	modal.hide()
	modal._on_visibility_changed()
	assert_false(FKEditorGlobals.is_action_input_modal_visible)
	modal.free()

func test_modal_reads_values_through_action_input_definition():
	var action := TestAction.new()
	var args := FKActionInputPopulationArgs.new()
	args.action = action
	args.action_inputs = action.get_inputs()
	args.inputs = {"duration": "2.5"}
	var modal := TestModal.new()

	modal.populate_for_action(args)

	assert_eq(modal.get_input_value("Duration"), 2.5)
	assert_true(modal.get_input_value("Wait For Finish"))
	modal.free()

func test_modal_writes_values_through_action_input_definition():
	var action := TestAction.new()
	var args := FKActionInputPopulationArgs.new()
	args.action = action
	args.action_inputs = action.get_inputs()
	var modal := TestModal.new()

	modal.populate_for_action(args)
	modal.set_input_value("Duration", 4.0)
	modal.set_input_value("Wait For Finish", false)

	assert_eq(modal.get_values(), {"Duration": 4.0, "Wait For Finish": false})
	modal.free()

func test_confirmed_inputs_remain_intact_when_modal_is_repopulated():
	var action := TestAction.new()
	var editor_globals := FKEditorGlobals.new()
	var args := FKActionInputPopulationArgs.new()
	args.action = action
	args.action_inputs = action.get_inputs()
	var modal := TestModal.new()
	modal.editor_globals = editor_globals
	var received := {"inputs": {}}
	editor_globals.modal_signals.expressions_confirmed.connect(
		func(_node_path: String, _action_id: String, inputs: Dictionary) -> void:
			received["inputs"] = inputs
	)

	modal.populate_for_action(args)
	modal.set_input_value("Duration", 4.0)
	modal.set_input_value("Wait For Finish", false)
	modal.confirm_inputs("", "test_action", modal.get_values())

	args.inputs = received["inputs"]
	modal.populate_for_action(args)

	assert_eq(received["inputs"], {"Duration": 4.0, "Wait For Finish": false})
	assert_eq(modal.get_input_value("Duration"), 4.0)
	assert_false(modal.get_input_value("Wait For Finish"))
	modal.free()

func test_confirmed_inputs_are_a_deep_copy_of_modal_state():
	var action := TestAction.new()
	var args := FKActionInputPopulationArgs.new()
	args.action = action
	args.action_inputs = action.get_inputs()
	args.inputs = {"Duration": {"value": 2.0}}
	var modal := TestModal.new()
	modal.editor_globals = FKEditorGlobals.new()
	var received := {"inputs": {}}
	modal.editor_globals.modal_signals.expressions_confirmed.connect(
		func(_node_path: String, _action_id: String, inputs: Dictionary) -> void:
			received["inputs"] = inputs
	)

	modal.populate_for_action(args)
	modal.confirm_inputs("", "test_action", modal.get_values())
	modal.get_values()["Duration"]["value"] = 9.0

	assert_eq(received["inputs"], {"Duration": {"value": 2.0}})
	modal.free()

func test_population_copies_input_values_from_caller():
	var action := TestAction.new()
	var args := FKActionInputPopulationArgs.new()
	args.action = action
	args.action_inputs = action.get_inputs()
	args.inputs = {"Duration": 2.0}
	var modal := TestModal.new()

	modal.populate_for_action(args)
	args.inputs["Duration"] = 8.0

	assert_eq(modal.get_input_value("Duration"), 2.0)
	modal.free()

func test_confirm_pressed_applies_ui_state_before_emitting_inputs():
	var action := TestAction.new()
	var args := FKActionInputPopulationArgs.new()
	args.action = action
	args.action_id = "test_action"
	args.node_path = "Player"
	args.action_inputs = action.get_inputs()
	args.inputs = {"Duration": 3.0}
	var modal := TestModal.new()
	modal.editor_globals = FKEditorGlobals.new()
	var received := {"node_path": "", "action_id": "", "inputs": {}}
	modal.editor_globals.modal_signals.expressions_confirmed.connect(
		func(node_path: String, action_id: String, inputs: Dictionary) -> void:
			received["node_path"] = node_path
			received["action_id"] = action_id
			received["inputs"] = inputs
	)

	modal.populate_for_action(args)
	modal._on_confirm_pressed()

	assert_eq(modal.apply_count, 1)
	assert_eq(received["node_path"], "Player")
	assert_eq(received["action_id"], "test_action")
	assert_eq(received["inputs"], {"Duration": 3.0})
	modal.free()

func test_empty_action_description_uses_fallback_text():
	var action := TestAction.new()
	action.action_description = ""
	var args := FKActionInputPopulationArgs.new()
	args.action = action
	args.action_inputs = action.get_inputs()
	var modal := TestModal.new()

	modal.populate_for_action(args)

	assert_eq(modal.desc_label.text, "No desc here.")
	modal.free()