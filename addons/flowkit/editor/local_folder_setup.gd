@tool
class_name FKLocalFolderSetup
extends RefCounted
## Editor-only. Makes sure the project-local FlowKit folders exist.

const ROOT_DIR := "res://flowkit_local"
const REQUIRED_DIRS: Array[String] = [
	"res://flowkit_local/providers",
	"res://flowkit_local/variables",
	"res://flowkit_local/config",
]

func ensure_dirs_exist() -> void:
	if not Engine.is_editor_hint():
		return

	for dir_path in REQUIRED_DIRS:
		if DirAccess.dir_exists_absolute(dir_path):
			continue
		var err := DirAccess.make_dir_recursive_absolute(dir_path)
		if err != OK:
			push_error("[FlowKit]: Couldn't create '%s' (error %d)" % [dir_path, err])
