extends GutTest

var _editor_globals: FKEditorGlobals

func before_each():
	_editor_globals = FKEditorGlobals.new()
	_editor_globals.variable_editor_registry.load_providers()

func _pool() -> FKVariableUiPool:
	return _editor_globals.variable_ui_pool

func _make_string_var(key: String, value: String) -> FKStringVariable:
	var result := FKStringVariable.new()
	result.key = key
	result.set_value(value)
	return result

func _make_bool_var(key: String, value: bool) -> FKBoolVariable:
	var result := FKBoolVariable.new()
	result.key = key
	result.set_value(value)
	return result

func test_acquire_returns_a_ui_bound_to_the_variable():
	var string_var := _make_string_var("Greeting", "Hello")

	var var_ui := _pool().acquire(string_var)
	add_child(var_ui)

	assert_not_null(var_ui)
	assert_true(var_ui is FKVariableUi)
	assert_same(var_ui.get_variable(), string_var)
	assert_eq(var_ui.name_field.text, "Greeting")
	var_ui.free()

func test_acquire_returns_null_for_a_null_variable():
	assert_null(_pool().acquire(null))

func test_pool_reuses_released_var_ui_of_the_same_type():
	var first_var := _make_string_var("First", "First value")
	var var_ui := _pool().acquire(first_var)
	add_child(var_ui)

	_pool().release(var_ui)

	var second_var := _make_string_var("Second", "Second value")
	var reused_var_ui := _pool().acquire(second_var)
	add_child(reused_var_ui)

	assert_same(reused_var_ui, var_ui)
	assert_same(reused_var_ui.get_variable(), second_var)
	assert_eq(reused_var_ui.name_field.text, "Second")
	reused_var_ui.free()

func test_pool_creates_a_different_ui_type_when_needed():
	var string_ui := _pool().acquire(_make_string_var("Message", "Hi"))
	add_child(string_ui)
	_pool().release(string_ui)

	var bool_ui := _pool().acquire(_make_bool_var("Enabled", true))
	add_child(bool_ui)

	assert_ne(bool_ui, string_ui)
	bool_ui.free()
	string_ui.free()

func test_pool_keeps_separate_buckets_per_variable_type():
	var string_ui := _pool().acquire(_make_string_var("Message", "Hi"))
	add_child(string_ui)
	_pool().release(string_ui)

	var bool_ui := _pool().acquire(_make_bool_var("Enabled", true))
	add_child(bool_ui)
	_pool().release(bool_ui)

	var reused_string_ui := _pool().acquire(_make_string_var("Other", "Bye"))
	add_child(reused_string_ui)
	var reused_bool_ui := _pool().acquire(_make_bool_var("Other Flag", false))
	add_child(reused_bool_ui)

	assert_same(reused_string_ui, string_ui)
	assert_same(reused_bool_ui, bool_ui)
	reused_string_ui.free()
	reused_bool_ui.free()

func test_release_detaches_the_ui_from_its_parent():
	var holder := Control.new()
	add_child(holder)
	var var_ui := _pool().acquire(_make_string_var("Greeting", "Hello"))
	holder.add_child(var_ui)

	_pool().release(var_ui)

	assert_eq(holder.get_child_count(), 0)
	assert_null(var_ui.get_parent())
	var_ui.free()
	holder.free()

func test_release_ignores_null():
	_pool().release(null)
	pass_test("Releasing null should not error out.")

func test_release_does_not_pool_the_same_ui_twice():
	var var_ui := _pool().acquire(_make_string_var("Greeting", "Hello"))
	add_child(var_ui)

	_pool().release(var_ui)
	_pool().release(var_ui)

	var first_reuse := _pool().acquire(_make_string_var("A", "a"))
	add_child(first_reuse)
	var second_reuse := _pool().acquire(_make_string_var("B", "b"))
	add_child(second_reuse)

	assert_same(first_reuse, var_ui)
	assert_ne(second_reuse, first_reuse)
	first_reuse.free()
	second_reuse.free()

func test_release_all_returns_every_ui_to_the_pool():
	var first_ui := _pool().acquire(_make_string_var("First", "1"))
	var second_ui := _pool().acquire(_make_string_var("Second", "2"))
	add_child(first_ui)
	add_child(second_ui)

	_pool().release_all([first_ui, second_ui])

	var first_reuse := _pool().acquire(_make_string_var("Third", "3"))
	add_child(first_reuse)
	var second_reuse := _pool().acquire(_make_string_var("Fourth", "4"))
	add_child(second_reuse)

	assert_ne(first_reuse, second_reuse)
	assert_true(first_reuse == first_ui or first_reuse == second_ui)
	assert_true(second_reuse == first_ui or second_reuse == second_ui)
	first_reuse.free()
	second_reuse.free()

func test_reacquiring_the_same_variable_drops_unapplied_widget_edits():
	var string_var := _make_string_var("Greeting", "Hello")
	var var_ui := _pool().acquire(string_var) as FKStringVariableUi
	add_child(var_ui)
	var_ui.name_field.text = "Edited"
	var_ui.value_field.text = "Edited value"

	_pool().release(var_ui)
	var reused := _pool().acquire(string_var) as FKStringVariableUi
	add_child(reused)

	assert_same(reused, var_ui)
	assert_eq(reused.name_field.text, "Greeting")
	assert_eq(reused.value_field.text, "Hello")
	reused.free()
