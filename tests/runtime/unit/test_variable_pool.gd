extends GutTest

var _pool: FKVariablePool

func before_each() -> void:
	_pool = FKVariablePool.new()

func test_acquire_makes_new_variable_when_pool_is_empty() -> void:
	var variable := _pool.acquire(FKBoolVariable)

	assert_is(variable, FKBoolVariable)
	assert_false(_pool.is_pooled(variable))

func test_acquire_returns_null_for_null_or_non_variable_script() -> void:
	assert_null(_pool.acquire(null))
	assert_null(_pool.acquire(FKIdAssigner))
	assert_push_error_count(1)

func test_release_then_acquire_reuses_the_instance() -> void:
	var variable := _pool.acquire(FKStringVariable)

	assert_true(_pool.release(variable))
	assert_true(_pool.is_pooled(variable))
	assert_eq(_pool.acquire(FKStringVariable), variable)
	assert_false(_pool.is_pooled(variable))

func test_pools_are_kept_per_variable_type() -> void:
	var bool_var := _pool.acquire(FKBoolVariable)
	_pool.release(bool_var)

	var string_var := _pool.acquire(FKStringVariable)

	assert_ne(string_var, bool_var)
	assert_eq(_pool.count_for(FKBoolVariable), 1)

func test_release_resets_variable_to_defaults() -> void:
	var variable := _pool.acquire(FKNumberVariable) as FKNumberVariable
	variable.key = "health"
	variable.id = 7
	variable.whole_nums_only = true
	variable.set_value(42)

	_pool.release(variable)

	assert_eq(variable.key, "")
	assert_eq(variable.id, 0)
	assert_false(variable.whole_nums_only)
	assert_eq(variable.get_value(), 0.0)

func test_release_resets_resource_values() -> void:
	var variable := _pool.acquire(FKAudioStreamVariable)
	variable.set_value(AudioStreamWAV.new())

	_pool.release(variable)

	assert_null(variable.get_value())

func test_release_rejects_null_owned_and_already_pooled() -> void:
	var variable := _pool.acquire(FKBoolVariable)
	variable.set_owner(RefCounted.new())

	assert_false(_pool.release(null))
	assert_false(_pool.release(variable))
	assert_push_warning_count(1)

	variable.set_owner(null)
	assert_true(_pool.release(variable))
	assert_false(_pool.release(variable))
	assert_eq(_pool.count_for(FKBoolVariable), 1)

func test_pool_size_is_bounded() -> void:
	for i in FKVariablePool.MAX_VARS_PER_TYPE + 5:
		_pool.release(FKBoolVariable.new())

	assert_eq(_pool.count_for(FKBoolVariable), FKVariablePool.MAX_VARS_PER_TYPE)

func test_registry_remove_var_from_pools_ownerless_variable() -> void:
	var registry := FKVariableRegistry.new()
	registry.load_types()
	var manager := FKVariableManager.new()
	var variable := registry.add_var_of_type(manager, "Bool")

	assert_true(registry.remove_var_from(manager, variable))
	assert_eq(manager.get_variables().size(), 0)
	assert_false(registry.remove_var_from(manager, variable))

	var reused := registry.add_var_of_type(manager, "Bool")
	assert_eq(reused, variable)
