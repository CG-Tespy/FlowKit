extends GutTest

const SetOperator := FKVariable.SetOperator
const ENGINE_NAME := "FlowKit"

var _action: FKSetVariable
var _engine: FlowKitEngine
var _made_engine := false
var _saved_sheets: Array[FlowKitEngine.SheetEntry] = []
var _scene_root: Node
var _manager: FKVariableManager

func before_each() -> void:
	_action = FKSetVariable.new()

	_engine = get_tree().root.get_node_or_null(ENGINE_NAME) as FlowKitEngine
	if _engine == null:
		_engine = FlowKitEngine.new()
		_engine.name = ENGINE_NAME
		get_tree().root.add_child(_engine)
		_made_engine = true
	_saved_sheets = _engine.active_sheets.duplicate()

	_scene_root = Node.new()
	add_child(_scene_root)

	var sheet := FKEventSheet.new()
	_manager = FKVariableManager.new()
	sheet.variable_manager = _manager
	_engine.active_sheets = [FlowKitEngine.SheetEntry.new(sheet, _scene_root, "test_scene", 1)]

func after_each() -> void:
	_engine.active_sheets = _saved_sheets
	if _made_engine:
		_engine.free()
	_made_engine = false
	_scene_root.free()

func _add_number(start: float) -> FKNumberVariable:
	var variable := FKNumberVariable.new()
	variable.key = "n"
	variable.value = start
	_manager.add_var(variable)
	return variable

func _inputs(variable: FKVariable, symbol: String, value: Variant) -> Dictionary:
	var ref := FKVariableRef.to(variable)
	ref.is_target = true
	return {"Variable": ref, "Operator": "\"%s\"" % symbol, "Value": value}

func _symbol(op: SetOperator) -> String:
	return FKVariable.operator_symbol(op)

func test_metadata() -> void:
	assert_eq(_action.get_id(), "set_fk_variable")
	assert_eq(_action.get_supported_types(), ["System"] as Array[String])
	assert_eq(_action.get_inputs().size(), 3)

func test_assign_sets_the_value() -> void:
	var variable := _add_number(1.0)

	_action.execute(_scene_root, _inputs(variable, _symbol(SetOperator.ASSIGN), 9))

	assert_eq(variable.get_value(), 9.0)

func test_operators_combine_with_current_value() -> void:
	var variable := _add_number(10.0)

	_action.execute(_scene_root, _inputs(variable, _symbol(SetOperator.ADD), 5))
	assert_eq(variable.get_value(), 15.0)
	_action.execute(_scene_root, _inputs(variable, _symbol(SetOperator.SUBTRACT), 3))
	assert_eq(variable.get_value(), 12.0)
	_action.execute(_scene_root, _inputs(variable, _symbol(SetOperator.MULTIPLY), 2))
	assert_eq(variable.get_value(), 24.0)
	_action.execute(_scene_root, _inputs(variable, _symbol(SetOperator.DIVIDE), 4))
	assert_eq(variable.get_value(), 6.0)

func test_unquoted_operator_symbol_works() -> void:
	var variable := _add_number(1.0)
	var inputs := _inputs(variable, _symbol(SetOperator.ADD), 2)
	inputs["Operator"] = _symbol(SetOperator.ADD)

	_action.execute(_scene_root, inputs)

	assert_eq(variable.get_value(), 3.0)

func test_missing_operator_defaults_to_assign() -> void:
	var variable := _add_number(1.0)
	var inputs := _inputs(variable, "", 4)
	inputs.erase("Operator")

	_action.execute(_scene_root, inputs)

	assert_eq(variable.get_value(), 4.0)

func test_works_when_executed_from_a_descendant_of_the_scene_root() -> void:
	var variable := _add_number(1.0)
	var child := Node.new()
	_scene_root.add_child(child)

	_action.execute(child, _inputs(variable, _symbol(SetOperator.ASSIGN), 5))

	assert_eq(variable.get_value(), 5.0)

func test_dividing_by_zero_leaves_value_alone() -> void:
	var variable := _add_number(10.0)

	_action.execute(_scene_root, _inputs(variable, _symbol(SetOperator.DIVIDE), 0))

	assert_eq(variable.get_value(), 10.0)

func test_changing_the_value_emits_value_changed() -> void:
	var variable := _add_number(1.0)
	watch_signals(variable)

	_action.execute(_scene_root, _inputs(variable, _symbol(SetOperator.ASSIGN), 2))

	assert_signal_emitted(variable, "value_changed")

func test_missing_variable_input_pushes_error() -> void:
	var variable := _add_number(1.0)

	_action.execute(_scene_root, {"Operator": "\"=\"", "Value": 2})

	assert_push_error("No variable was chosen")
	assert_eq(variable.get_value(), 1.0)

func test_ref_to_unknown_variable_pushes_error() -> void:
	var variable := _add_number(1.0)
	var inputs := _inputs(variable, _symbol(SetOperator.ASSIGN), 2)
	(inputs["Variable"] as FKVariableRef).variable_id = 9999

	_action.execute(_scene_root, inputs)

	assert_push_error("No variable with id")
	assert_eq(variable.get_value(), 1.0)

func test_invalid_operator_pushes_error() -> void:
	var variable := _add_number(1.0)

	_action.execute(_scene_root, _inputs(variable, "nonsense", 2))

	assert_push_error("isn't a valid operator")
	assert_eq(variable.get_value(), 1.0)

func test_missing_value_pushes_error() -> void:
	var variable := _add_number(1.0)
	var inputs := _inputs(variable, _symbol(SetOperator.ASSIGN), 2)
	inputs.erase("Value")

	_action.execute(_scene_root, inputs)

	assert_push_error("No value was given")
	assert_eq(variable.get_value(), 1.0)

func test_node_variable_gets_path_relative_to_scene_root() -> void:
	var variable := FKNodeVariable.new()
	variable.key = "target"
	_manager.add_var(variable)
	var target := Node.new()
	target.name = "Target"
	_scene_root.add_child(target)

	_action.execute(_scene_root, _inputs(variable, _symbol(SetOperator.ASSIGN), target))

	assert_eq(variable.get_node_path(), NodePath("Target"))

func test_node_variable_rejects_non_node_value() -> void:
	var variable := FKNodeVariable.new()
	variable.key = "target"
	_manager.add_var(variable)

	_action.execute(_scene_root, _inputs(variable, _symbol(SetOperator.ASSIGN), 5))

	assert_push_error("needs a Node")
	assert_true(variable.get_node_path().is_empty())
