extends GutTest

var _manager: FKVariableManager

func before_each() -> void:
	_manager = FKVariableManager.new()

func test_add_var_stores_variable_and_sets_owner() -> void:
	var owner_obj := RefCounted.new()
	_manager.set_owner(owner_obj)
	var variable := FKBoolVariable.new()

	assert_true(_manager.add_var(variable))
	assert_eq(_manager.get_variables(), [variable])
	assert_eq(variable.get_owner(), owner_obj)

func test_add_var_assigns_unique_ids() -> void:
	var first := FKBoolVariable.new()
	var second := FKStringVariable.new()
	var third := FKNumberVariable.new()

	_manager.add_var(first)
	_manager.add_var(second)
	_manager.add_var(third)

	var ids := [first.id, second.id, third.id]
	for id in ids:
		assert_gt(id, 0)
	assert_eq(ids.size(), _unique_count(ids))

func test_add_var_keeps_existing_ids_stable() -> void:
	var first := FKBoolVariable.new()
	var second := FKStringVariable.new()
	_manager.add_var(first)
	_manager.add_var(second)
	var first_id := first.id
	var second_id := second.id

	_manager.add_var(FKNumberVariable.new())

	assert_eq(first.id, first_id)
	assert_eq(second.id, second_id)

func test_add_var_rejects_null_and_duplicates() -> void:
	var variable := FKBoolVariable.new()
	assert_true(_manager.add_var(variable))

	assert_false(_manager.add_var(variable))
	assert_false(_manager.add_var(null))
	assert_eq(_manager.get_variables().size(), 1)

func test_remove_var_clears_owner() -> void:
	var variable := FKBoolVariable.new()
	_manager.set_owner(RefCounted.new())
	_manager.add_var(variable)

	assert_true(_manager.remove_var(variable))
	assert_eq(_manager.get_variables().size(), 0)
	assert_null(variable.get_owner())
	assert_false(_manager.remove_var(variable))

func test_registry_add_var_of_type_creates_managed_variable() -> void:
	var registry := FKVariableRegistry.new()
	registry.load_types()

	var created := registry.add_var_of_type(_manager, "Bool")

	assert_not_null(created)
	assert_is(created, FKBoolVariable)
	assert_eq(_manager.get_variables(), [created])

func test_registry_add_var_of_type_rejects_unknown_type() -> void:
	var registry := FKVariableRegistry.new()
	registry.load_types()

	assert_null(registry.add_var_of_type(_manager, "NotARealType"))
	assert_eq(_manager.get_variables().size(), 0)

func _unique_count(items: Array) -> int:
	var seen := {}
	for item in items:
		seen[item] = true
	return seen.size()
