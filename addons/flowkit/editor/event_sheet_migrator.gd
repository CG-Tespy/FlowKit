@tool
class_name FKEventSheetMigrator
extends RefCounted
## Editor-only. Moves event sheets to where they belong: sheets for scenes inside
## the addon go to addons/flowkit/saved/event_sheets, all others to
## flowkit_local/event_sheets.

const LEGACY_SHEET_DIR := "res://addons/flowkit/saved/event_sheet"

func migrate_legacy_sheets() -> void:
	if not Engine.is_editor_hint():
		return

	var source_dirs: Array[String] = [LEGACY_SHEET_DIR]
	source_dirs.append_array(FKEventSheet.all_save_dirs())

	var moved := 0
	for source_dir in source_dirs:
		for file_name in DirAccess.get_files_at(source_dir):
			if file_name.get_extension() != "tres":
				continue
			if _move_if_misplaced(source_dir, file_name):
				moved += 1

	if moved == 0:
		return
	print("[FlowKit]: Moved %d event sheet(s) to their proper folders." % moved)
	EditorInterface.get_resource_filesystem().scan()

## Returns whether the sheet was moved.
func _move_if_misplaced(source_dir: String, file_name: String) -> bool:
	var scene_uid := file_name.get_basename().to_int()
	var target_dir := FKEventSheet.save_dir_for_uid(scene_uid)
	if source_dir == target_dir:
		return false

	var old_path := source_dir.path_join(file_name)
	var new_path := target_dir.path_join(file_name)
	if FileAccess.file_exists(new_path):
		push_warning("[FlowKit]: '%s' already exists; leaving '%s' alone." % [new_path, old_path])
		return false

	DirAccess.make_dir_recursive_absolute(target_dir)
	var err := DirAccess.rename_absolute(old_path, new_path)
	if err != OK:
		push_error("[FlowKit]: Couldn't move '%s' to '%s' (error %d)" % [old_path, new_path, err])
		return false
	return true
