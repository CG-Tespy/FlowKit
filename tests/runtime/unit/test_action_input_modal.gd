@tool
extends GutTest

class TestAction extends FKAction:
	var input_definitions: Array[FKActionInput] = [
		FKFloatActionInput.new("Duration", "", 1.0),
		FKBoolActionInput.new("Wait For Finish", "", true),
	]

	func get_inputs() -> Array[FKActionInput]:
		return input_definitions

class TestModal extends FKActionInputModal:
	func get_input_value(input_name: String) -> Variant:
		return _get_input_value(_get_action_input(input_name))

	func set_input_value(input_name: String, value: Variant) -> void:
		_set_input_value(_get_action_input(input_name), value)

	func get_values() -> Dictionary:
		return _inputs

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
	var confirmed_inputs: Dictionary = {}
	editor_globals.modal_signals.expressions_confirmed.connect(
		func(_node_path: String, _action_id: String, inputs: Dictionary) -> void:
			confirmed_inputs = inputs
	)

	modal.populate_for_action(args)
	modal.set_input_value("Duration", 4.0)
	modal.set_input_value("Wait For Finish", false)
	modal.confirm_inputs("", "test_action", modal.get_values())

	args.inputs = confirmed_inputs
	modal.populate_for_action(args)

	assert_eq(confirmed_inputs, {"Duration": 4.0, "Wait For Finish": false})
	assert_eq(modal.get_input_value("Duration"), 4.0)
	assert_false(modal.get_input_value("Wait For Finish"))
	modal.free()