extends GutTest

const SetOperator := FKVariable.SetOperator

func _number(start: float) -> FKNumberVariable:
	var result := FKNumberVariable.new()
	result.key = "n"
	result.value = start
	return result

func test_assign_replaces_the_value():
	var variable := _number(1.0)

	assert_true(variable.apply_operator(SetOperator.ASSIGN, 7))
	assert_eq(variable.get_value(), 7.0)

func test_arithmetic_operators_combine_with_the_current_value():
	var variable := _number(10.0)

	variable.apply_operator(SetOperator.ADD, 5)
	assert_eq(variable.get_value(), 15.0)
	variable.apply_operator(SetOperator.SUBTRACT, 3)
	assert_eq(variable.get_value(), 12.0)
	variable.apply_operator(SetOperator.MULTIPLY, 2)
	assert_eq(variable.get_value(), 24.0)
	variable.apply_operator(SetOperator.DIVIDE, 4)
	assert_eq(variable.get_value(), 6.0)

func test_dividing_by_zero_is_rejected():
	var variable := _number(10.0)

	assert_false(variable.apply_operator(SetOperator.DIVIDE, 0))
	assert_eq(variable.get_value(), 10.0)

func test_variables_without_arithmetic_only_allow_assign():
	var variable := FKStringVariable.new()

	assert_eq(variable.compatible_operators(), [SetOperator.ASSIGN] as Array[SetOperator])
	assert_false(variable.apply_operator(SetOperator.ADD, "a"))

func test_vector_operands_of_lower_dimensions_are_widened():
	var variable := FKVectorVariable.new()
	variable.value = Vector4(1, 2, 3, 4)

	variable.apply_operator(SetOperator.ADD, Vector2(10, 20))

	assert_eq(variable.get_value(), Vector4(11, 22, 3, 4))

func test_vector_division_by_a_vector_with_a_zero_component_is_rejected():
	var variable := FKVectorVariable.new()
	variable.value = Vector4(1, 2, 3, 4)

	assert_false(variable.apply_operator(SetOperator.DIVIDE, Vector4(1, 1, 0, 1)))
	assert_eq(variable.get_value(), Vector4(1, 2, 3, 4))

func test_symbols_round_trip_through_the_operators():
	for op in [SetOperator.ASSIGN, SetOperator.ADD, SetOperator.SUBTRACT, \
	SetOperator.MULTIPLY, SetOperator.DIVIDE]:
		assert_eq(FKVariable.operator_from_symbol(FKVariable.operator_symbol(op)), op)

func test_symbols_stored_with_quotes_still_parse():
	assert_eq(FKVariable.operator_from_symbol("\"+=\""), SetOperator.ADD)
	assert_eq(FKVariable.operator_from_symbol("nonsense"), SetOperator.NULL)

func test_every_variable_type_makes_a_value_input_that_matches_what_it_holds():
	var variables: Array[FKVariable] = [_number(0), FKVectorVariable.new(), FKBoolVariable.new(), \
	FKStringVariable.new(), FKColorVariable.new(), FKAudioStreamVariable.new()]

	for variable in variables:
		var input := variable.create_value_action_input("Value")
		assert_true(variable.can_hold_type(input.type), "%s vs %s" % [variable.get_class(), input.type])

func test_target_refs_survive_input_evaluation_untouched():
	var ref := FKVariableRef.new()
	ref.variable_id = 3
	ref.is_target = true

	var evaluated := FKExpressionEvaluator.evaluate_inputs({"Variable": ref})

	assert_eq(evaluated["Variable"], ref)
