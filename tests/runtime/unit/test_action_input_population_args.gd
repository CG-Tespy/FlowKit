extends GutTest

func test_set_to_copies_input_definitions_and_values():
	var action_input := FKFloatActionInput.new("Duration", "", 1.0)
	var source := FKActionInputPopulationArgs.new()
	source.action_inputs = [action_input]
	source.inputs = {"Duration": 2.5}
	var destination := FKActionInputPopulationArgs.new()

	destination.set_to(source)
	source.inputs["Duration"] = 4.0

	assert_eq(destination.action_inputs, [action_input])
	assert_eq(destination.inputs, {"Duration": 2.5})

func test_clear_removes_input_definitions_and_values():
	var args := FKActionInputPopulationArgs.new()
	args.action_inputs = [FKBoolActionInput.new("Wait For Finish", "", true)]
	args.inputs = {"Wait For Finish": false}

	args.clear()

	assert_eq(args.action_inputs, [])
	assert_eq(args.inputs, {})