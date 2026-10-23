@tool
class_name FKLocalFolderSetup
extends RefCounted
## Editor-only. Makes sure the project-local FlowKit folders exist.

const ROOT_DIR := "res://flowkit_local"
const REQUIRED_DIRS: Array[String] = [
	"res://flowkit_local/providers",
	"res://flowkit_local/providers/actions",
	"res://flowkit_local/providers/behaviors",
	"res://flowkit_local/providers/branches",
	"res://flowkit_local/providers/conditions",
	"res://flowkit_local/providers/events",

	"res://flowkit_local/event_sheets/",

	"res://flowkit_local/variables",
	"res://flowkit_local/config",
]

const LEGACY_SETTINGS_PATH := "res://addons/flowkit/editor/_fk_project_settings.tres"

## Moves the project settings file from its old home in the addon folder into
## flowkit_local/config, unless one is already there.
func migrate_legacy_settings() -> void:
	if not Engine.is_editor_hint():
		return
	if not FileAccess.file_exists(LEGACY_SETTINGS_PATH):
		return

	ensure_dirs_exist()
	var new_path := FKProjectSettings.FILE_PATH
	if FileAccess.file_exists(new_path):
		push_warning("[FlowKit]: Both '%s' and '%s' exist; leaving the old one alone." % [LEGACY_SETTINGS_PATH, new_path])
		return

	var err := DirAccess.rename_absolute(LEGACY_SETTINGS_PATH, new_path)
	if err != OK:
		push_error("[FlowKit]: Couldn't move '%s' to '%s' (error %d)" % [LEGACY_SETTINGS_PATH, new_path, err])
		return
	print("[FlowKit]: Moved project settings to ", new_path)
	EditorInterface.get_resource_filesystem().scan()

func ensure_dirs_exist() -> void:
	if not Engine.is_editor_hint():
		return

	for dir_path in REQUIRED_DIRS:
		if DirAccess.dir_exists_absolute(dir_path):
			continue
		var err := DirAccess.make_dir_recursive_absolute(dir_path)
		if err != OK:
			push_error("[FlowKit]: Couldn't create '%s' (error %d)" % [dir_path, err])
