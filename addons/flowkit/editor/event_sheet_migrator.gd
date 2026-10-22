@tool
class_name FKEventSheetMigrator
extends RefCounted
## Editor-only. Moves event sheets from their old home in the addon folder
## into flowkit_local/event_sheets.

const LEGACY_SHEET_DIR := "res://addons/flowkit/saved/event_sheet"

func migrate_legacy_sheets() -> void:
	if not Engine.is_editor_hint():
		return
	if not DirAccess.dir_exists_absolute(LEGACY_SHEET_DIR):
		return

	var new_dir := FKEventSheet.SAVE_DIR
	DirAccess.make_dir_recursive_absolute(new_dir)

	var moved := 0
	for file_name in DirAccess.get_files_at(LEGACY_SHEET_DIR):
		if file_name.get_extension() != "tres":
			continue
		var old_path := LEGACY_SHEET_DIR.path_join(file_name)
		var new_path := new_dir.path_join(file_name)
		if FileAccess.file_exists(new_path):
			push_warning("[FlowKit]: '%s' already exists; leaving '%s' alone." % [new_path, old_path])
			continue
		var err := DirAccess.rename_absolute(old_path, new_path)
		if err != OK:
			push_error("[FlowKit]: Couldn't move '%s' to '%s' (error %d)" % [old_path, new_path, err])
			continue
		moved += 1

	if moved == 0:
		return
	print("[FlowKit]: Moved %d event sheet(s) to %s" % [moved, new_dir])
	EditorInterface.get_resource_filesystem().scan()
