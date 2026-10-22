extends GutTest

const ROOT := "user://test_sheet_migrator"
const ADDON_UID := 111
const PROJECT_UID := 222

var _migrator: FKEventSheetMigrator

func before_each() -> void:
	_migrator = FKEventSheetMigrator.new()
	_migrator.legacy_dir = ROOT + "/legacy"
	_migrator.local_dir = ROOT + "/local"
	_migrator.addon_dir = ROOT + "/addon"
	_migrator.editor_only = false
	_migrator.is_addon_scene_uid = func(uid: int) -> bool: return uid == ADDON_UID
	DirAccess.make_dir_recursive_absolute(_migrator.legacy_dir)
	DirAccess.make_dir_recursive_absolute(_migrator.local_dir)
	DirAccess.make_dir_recursive_absolute(_migrator.addon_dir)

func after_each() -> void:
	_remove_recursive(ROOT)

func _remove_recursive(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		return
	for file_name in DirAccess.get_files_at(path):
		DirAccess.remove_absolute(path.path_join(file_name))
	for dir_name in DirAccess.get_directories_at(path):
		_remove_recursive(path.path_join(dir_name))
	DirAccess.remove_absolute(path)

func _write(dir: String, file_name: String, content := "sheet") -> String:
	var path := dir.path_join(file_name)
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
	file.close()
	return path

func _read(path: String) -> String:
	return FileAccess.get_file_as_string(path)

func test_legacy_project_sheet_moves_to_local_dir() -> void:
	_write(_migrator.legacy_dir, "%d.tres" % PROJECT_UID)

	var moved := _migrator.migrate_legacy_sheets()

	assert_eq(moved, 1)
	assert_true(FileAccess.file_exists(_migrator.local_dir + "/%d.tres" % PROJECT_UID))
	assert_false(FileAccess.file_exists(_migrator.legacy_dir + "/%d.tres" % PROJECT_UID))

func test_legacy_addon_sheet_moves_to_addon_dir() -> void:
	_write(_migrator.legacy_dir, "%d.tres" % ADDON_UID)

	_migrator.migrate_legacy_sheets()

	assert_true(FileAccess.file_exists(_migrator.addon_dir + "/%d.tres" % ADDON_UID))
	assert_false(FileAccess.file_exists(_migrator.legacy_dir + "/%d.tres" % ADDON_UID))

func test_addon_sheet_misplaced_in_local_dir_moves_to_addon_dir() -> void:
	_write(_migrator.local_dir, "%d.tres" % ADDON_UID)

	_migrator.migrate_legacy_sheets()

	assert_true(FileAccess.file_exists(_migrator.addon_dir + "/%d.tres" % ADDON_UID))
	assert_false(FileAccess.file_exists(_migrator.local_dir + "/%d.tres" % ADDON_UID))

func test_project_sheet_misplaced_in_addon_dir_moves_to_local_dir() -> void:
	_write(_migrator.addon_dir, "%d.tres" % PROJECT_UID)

	_migrator.migrate_legacy_sheets()

	assert_true(FileAccess.file_exists(_migrator.local_dir + "/%d.tres" % PROJECT_UID))
	assert_false(FileAccess.file_exists(_migrator.addon_dir + "/%d.tres" % PROJECT_UID))

func test_correctly_placed_sheets_are_left_alone() -> void:
	_write(_migrator.local_dir, "%d.tres" % PROJECT_UID)
	_write(_migrator.addon_dir, "%d.tres" % ADDON_UID)

	var moved := _migrator.migrate_legacy_sheets()

	assert_eq(moved, 0)
	assert_true(FileAccess.file_exists(_migrator.local_dir + "/%d.tres" % PROJECT_UID))
	assert_true(FileAccess.file_exists(_migrator.addon_dir + "/%d.tres" % ADDON_UID))

func test_contents_survive_the_move() -> void:
	_write(_migrator.legacy_dir, "%d.tres" % PROJECT_UID, "precious")

	_migrator.migrate_legacy_sheets()

	assert_eq(_read(_migrator.local_dir + "/%d.tres" % PROJECT_UID), "precious")

func test_existing_destination_is_never_overwritten() -> void:
	var old_path := _write(_migrator.legacy_dir, "%d.tres" % PROJECT_UID, "old")
	var new_path := _write(_migrator.local_dir, "%d.tres" % PROJECT_UID, "new")

	var moved := _migrator.migrate_legacy_sheets()

	assert_eq(moved, 0)
	assert_eq(_read(new_path), "new")
	assert_eq(_read(old_path), "old")
	assert_push_warning_count(1)

func test_non_tres_files_are_ignored() -> void:
	var tmp_path := _write(_migrator.legacy_dir, "%d.tres123.tmp" % PROJECT_UID)

	var moved := _migrator.migrate_legacy_sheets()

	assert_eq(moved, 0)
	assert_true(FileAccess.file_exists(tmp_path))

func test_creates_target_dir_when_missing() -> void:
	_remove_recursive(_migrator.local_dir)
	_write(_migrator.legacy_dir, "%d.tres" % PROJECT_UID)

	_migrator.migrate_legacy_sheets()

	assert_true(FileAccess.file_exists(_migrator.local_dir + "/%d.tres" % PROJECT_UID))

func test_missing_source_dirs_are_harmless() -> void:
	_remove_recursive(ROOT)

	assert_eq(_migrator.migrate_legacy_sheets(), 0)

func test_second_run_moves_nothing() -> void:
	_write(_migrator.legacy_dir, "%d.tres" % PROJECT_UID)
	_write(_migrator.legacy_dir, "%d.tres" % ADDON_UID)

	assert_eq(_migrator.migrate_legacy_sheets(), 2)
	assert_eq(_migrator.migrate_legacy_sheets(), 0)

func test_does_nothing_outside_the_editor_when_editor_only() -> void:
	if Engine.is_editor_hint():
		pass_test("Only checkable when not running inside the editor.")
		return
	_migrator.editor_only = true
	var path := _write(_migrator.legacy_dir, "%d.tres" % PROJECT_UID)

	assert_eq(_migrator.migrate_legacy_sheets(), 0)
	assert_true(FileAccess.file_exists(path))

func test_save_dir_for_unresolvable_uid_is_the_local_dir() -> void:
	assert_eq(FKEventSheet.save_dir_for_uid(0), FKEventSheet.SAVE_DIR)
	assert_false(FKEventSheet.is_addon_scene_uid(0))
