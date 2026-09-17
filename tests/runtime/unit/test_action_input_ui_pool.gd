extends GutTest

func test_pool_reuses_released_input_ui_of_the_same_type():
	var editor_globals := FKEditorGlobals.new()
	var first_input := FKStringActionInput.new("First")
	var input_ui := editor_globals.action_input_ui_pool.acquire(first_input)
	add_child(input_ui)

	input_ui.release()

	var second_input := FKStringActionInput.new("Second")
	var reused_input_ui := editor_globals.action_input_ui_pool.acquire(second_input)
	add_child(reused_input_ui)

	assert_same(reused_input_ui, input_ui)
	assert_same(reused_input_ui.action_input, second_input)
	reused_input_ui.free()

func test_pool_creates_a_different_ui_type_when_needed():
	var editor_globals := FKEditorGlobals.new()
	var string_input_ui := editor_globals.action_input_ui_pool.acquire(FKStringActionInput.new("Message"))
	add_child(string_input_ui)
	string_input_ui.release()

	var bool_input_ui := editor_globals.action_input_ui_pool.acquire(FKBoolActionInput.new("Enabled", "", false))
	add_child(bool_input_ui)

	assert_true(bool_input_ui is FKBoolActionInputUi)
	assert_ne(bool_input_ui, string_input_ui)
	bool_input_ui.free()
	string_input_ui.free()