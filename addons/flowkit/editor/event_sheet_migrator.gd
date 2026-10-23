@tool
class_name FKEventSheetMigrator
extends RefCounted
## Editor-only. Moves event sheets to where they belong: sheets for scenes inside
## the addon go to addons/flowkit/saved/event_sheets, all others to
## flowkit_local/event_sheets.

const LEGACY_SHEET_DIR := "res://addons/flowkit/saved/event_sheet"

## The folders below, and the way scenes get classed, can be swapped out (tests do).
var legacy_dir := LEGACY_SHEET_DIR
var local_dir := FKEventSheet.SAVE_DIR
var addon_dir := FKEventSheet.ADDON_SAVE_DIR
var is_addon_scene_uid: Callable = FKEventSheet.is_addon_scene_uid
var editor_only := true

## Returns how many sheets were moved.
func migrate_legacy_sheets() -> int:
	if editor_only and not Engine.is_editor_hint():
		return 0

	var moved := 0
	for source_dir in [legacy_dir, local_dir, addon_dir]:
		if not DirAccess.dir_exists_absolute(source_dir):
			continue
		for file_name in DirAccess.get_files_at(source_dir):
			if file_name.get_extension() != "tres":
				continue
			if _move_if_misplaced(source_dir, file_name):
				moved += 1

	if moved == 0:
		return 0
	print("[FlowKit]: Moved %d event sheet(s) to their proper folders." % moved)
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()
	return moved

## Returns whether the sheet was moved.
func _move_if_misplaced(source_dir: String, file_name: String) -> bool:
	var scene_uid := file_name.get_basename().to_int()
	var target_dir := addon_dir if is_addon_scene_uid.call(scene_uid) else local_dir
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
