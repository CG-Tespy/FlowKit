extends GutTest

var _engine: Node
var _entry: FlowKitEngine.SheetEntry

func before_each() -> void:
	_engine = get_tree().root.get_node_or_null("/root/FlowKit")

func after_each() -> void:
	if _engine != null and _entry != null:
		_engine.active_sheets.erase(_entry)
	_entry = null

func _make_sheet_with_vars() -> FKEventSheet:
	var sheet := FKEventSheet.new()
	var number := FKNumberVariable.new()
	number.set_value(7.9)
	var vector := FKVectorVariable.new()
	vector.set_value(Vector3(1, 2, 3))
	var text := FKStringVariable.new()
	text.set_value("Target")
	for variable in [number, vector, text]:
		sheet.variable_manager.add_var(variable)
	return sheet

func _vars_of(sheet: FKEventSheet) -> Array[FKVariable]:
	return sheet.variable_manager.get_variables()

func _run_sheet_on(sheet: FKEventSheet, root: Node) -> void:
	_entry = FlowKitEngine.SheetEntry.new(sheet, root, "test", 1)
	_engine.active_sheets.append(_entry)

func test_manager_finds_variables_by_id() -> void:
	var sheet := _make_sheet_with_vars()
	var number := _vars_of(sheet)[0]

	assert_eq(sheet.variable_manager.get_var_by_id(number.id), number)
	assert_null(sheet.variable_manager.get_var_by_id(9999))

func test_ref_gives_the_variables_value() -> void:
	var sheet := _make_sheet_with_vars()
	var ref := FKVariableRef.to(_vars_of(sheet)[2])

	assert_eq(ref.resolve(sheet.variable_manager), "Target")

func test_ref_converts_to_the_type_it_is_wanted_for() -> void:
	var sheet := _make_sheet_with_vars()
	var number := _vars_of(sheet)[0]
	var vector := _vars_of(sheet)[1]

	assert_eq(FKVariableRef.to(number, "int").resolve(sheet.variable_manager), 7)
	assert_eq(FKVariableRef.to(number, "float").resolve(sheet.variable_manager), 7.9)
	assert_eq(FKVariableRef.to(vector, "Vector2").resolve(sheet.variable_manager), Vector2(1, 2))
	assert_eq(FKVariableRef.to(vector, "Vector3").resolve(sheet.variable_manager), Vector3(1, 2, 3))
	assert_eq(FKVariableRef.to(vector, "Variant").resolve(sheet.variable_manager), Vector4(1, 2, 3, 0))

func test_ref_to_a_missing_variable_gives_null() -> void:
	var sheet := _make_sheet_with_vars()
	var ref := FKVariableRef.new()
	ref.variable_id = 9999

	assert_null(ref.resolve(sheet.variable_manager))
	assert_null(ref.resolve(null))

func test_node_variable_is_looked_up_from_the_scene_root() -> void:
	var root := Node.new()
	add_child_autofree(root)
	var target := Node.new()
	target.name = "Target"
	root.add_child(target)
	var sheet := FKEventSheet.new()
	var node_var := FKNodeVariable.new()
	node_var.set_node_path(NodePath("Target"))
	sheet.variable_manager.add_var(node_var)

	assert_eq(FKVariableRef.to(node_var, "Node").resolve(sheet.variable_manager, root), target)

func test_evaluating_inputs_resolves_refs_with_the_sheet_running_on_the_root() -> void:
	assert_not_null(_engine, "The FlowKit autoload should be running")
	var root := Node.new()
	add_child_autofree(root)
	var sheet := _make_sheet_with_vars()
	_run_sheet_on(sheet, root)
	var number := _vars_of(sheet)[0]
	var text := _vars_of(sheet)[2]

	var inputs := {
		"Speed": FKVariableRef.to(number, "int"),
		"Name": FKVariableRef.to(text, "String"),
		"Plain": "1 + 1",
	}
	var evaluated := FKExpressionEvaluator.evaluate_inputs(inputs, root, root)

	assert_eq(evaluated["Speed"], 7)
	# The value of a String variable must not be evaluated as if it were an expression
	assert_eq(evaluated["Name"], "Target")
	assert_eq(evaluated["Plain"], 2)

func test_evaluating_inputs_leaves_out_refs_that_cannot_be_resolved() -> void:
	var root := Node.new()
	add_child_autofree(root)
	var sheet := _make_sheet_with_vars()
	_run_sheet_on(sheet, root)
	var missing := FKVariableRef.new()
	missing.variable_id = 9999

	var evaluated := FKExpressionEvaluator.evaluate_inputs({"Speed": missing}, root, root)

	assert_false(evaluated.has("Speed"))

func test_refs_are_resolved_against_the_sheet_of_their_own_root() -> void:
	var root := Node.new()
	add_child_autofree(root)
	var other_root := Node.new()
	add_child_autofree(other_root)
	var sheet := _make_sheet_with_vars()
	_run_sheet_on(sheet, root)
	var ref := FKVariableRef.to(_vars_of(sheet)[2], "String")

	assert_eq(_engine.get_variable_manager_for(root), sheet.variable_manager)
	assert_null(_engine.get_variable_manager_for(other_root))
	assert_false(FKExpressionEvaluator.evaluate_inputs({"Name": ref}, other_root, other_root).has("Name"))

func test_a_ref_survives_saving_and_loading() -> void:
	var path := "user://test_variable_ref.tres"
	var sheet := _make_sheet_with_vars()
	var unit := FKEventUnit.new()
	unit.inputs = {"Speed": FKVariableRef.to(_vars_of(sheet)[0], "float")}

	assert_eq(ResourceSaver.save(unit, path), OK)
	var loaded := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as FKEventUnit
	DirAccess.remove_absolute(path)

	var loaded_ref := loaded.inputs["Speed"] as FKVariableRef
	assert_not_null(loaded_ref)
	assert_eq(loaded_ref.variable_id, _vars_of(sheet)[0].id)
	assert_eq(loaded_ref.target_type, "float")
