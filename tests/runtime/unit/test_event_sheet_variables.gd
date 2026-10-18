extends GutTest

func test_each_sheet_has_its_own_variable_manager() -> void:
	var first := FKEventSheet.new()
	var second := FKEventSheet.new()

	assert_not_null(first.variable_manager)
	assert_ne(first.variable_manager, second.variable_manager)

func test_variables_added_through_the_manager_get_unique_ids() -> void:
	var sheet := FKEventSheet.new()
	var first := FKBoolVariable.new()
	var second := FKStringVariable.new()

	sheet.variable_manager.add_var(first)
	sheet.variable_manager.add_var(second)

	assert_eq(sheet.variable_manager.get_variables(), [first, second])
	assert_ne(first.id, second.id)
	assert_false([first.id, second.id].has(0))

func test_variables_survive_saving_and_loading() -> void:
	var path := "user://test_event_sheet_variables.tres"
	var sheet := FKEventSheet.new()
	var variable := FKStringVariable.new()
	variable.key = "greeting"
	variable.set_value("hello")
	sheet.variable_manager.add_var(variable)
	var saved_id := variable.id

	assert_eq(ResourceSaver.save(sheet, path), OK)
	var loaded := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as FKEventSheet
	DirAccess.remove_absolute(path)

	var loaded_vars := loaded.variable_manager.get_variables()
	assert_eq(loaded_vars.size(), 1)
	assert_eq(loaded_vars[0].key, "greeting")
	assert_eq(loaded_vars[0].get_value(), "hello")
	assert_eq(loaded_vars[0].id, saved_id)

	var added_after_load := FKBoolVariable.new()
	loaded.variable_manager.add_var(added_after_load)
	assert_ne(added_after_load.id, saved_id)

func test_sheet_rebuilt_from_units_keeps_the_variables_it_is_given() -> void:
	var path := "user://test_event_sheet_rebuilt.tres"
	var old_sheet := FKEventSheet.new()
	var variable := FKAudioStreamVariable.new()
	variable.key = "music"
	old_sheet.variable_manager.add_var(variable)

	var units: Array[FKUnit] = []
	var rebuilt := FKEventSheet.from_units(units, old_sheet.variable_manager)
	assert_eq(rebuilt.variable_manager, old_sheet.variable_manager)
	assert_eq(variable.get_owner(), rebuilt)

	assert_eq(ResourceSaver.save(rebuilt, path), OK)
	var loaded := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as FKEventSheet
	DirAccess.remove_absolute(path)

	var loaded_vars := loaded.variable_manager.get_variables()
	assert_eq(loaded_vars.size(), 1)
	assert_true(loaded_vars[0] is FKAudioStreamVariable)
	assert_eq(loaded_vars[0].key, "music")

func test_sheet_rebuilt_from_units_alone_has_no_variables() -> void:
	var units: Array[FKUnit] = []
	assert_true(FKEventSheet.from_units(units).variable_manager.get_variables().is_empty())
