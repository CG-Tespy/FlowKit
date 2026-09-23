@tool
extends RefCounted
class_name FKVariableEditorProviderLoader

const DEFAULT_PROVIDER_PATH := "res://addons/flowkit/providers"
const DEFAULT_TEST_PROVIDER_PATH := "res://tests/providers"

var project_settings: FKProjectSettings

func load_all() -> Array[FKVariableEditorProvider]:
	var providers: Array[FKVariableEditorProvider] = []
	for provider_path in get_provider_paths():
		_scan_directory_recursive(provider_path, providers)
	return providers

func get_provider_paths() -> Array[String]:
	var paths: Array[String] = []
	for provider_path in [DEFAULT_PROVIDER_PATH, DEFAULT_TEST_PROVIDER_PATH]:
		if not provider_path.is_empty() and not paths.has(provider_path):
			paths.append(provider_path)
	if project_settings:
		for provider_path in project_settings.provider_paths:
			if not provider_path.is_empty() and not paths.has(provider_path):
				paths.append(provider_path)
	return paths

func _scan_directory_recursive(path: String, providers: Array[FKVariableEditorProvider]) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		return

	directory.list_dir_begin()
	var file_name := directory.get_next()
	while not file_name.is_empty():
		var file_path := path.path_join(file_name)
		if directory.current_is_dir() and not file_name.begins_with("."):
			_scan_directory_recursive(file_path, providers)
		elif file_name.ends_with(".gd") and not file_name.ends_with(".gd.uid"):
			_try_add_provider(load(file_path), providers)
		file_name = directory.get_next()
	directory.list_dir_end()

func _try_add_provider(script: GDScript, providers: Array[FKVariableEditorProvider]) -> void:
	if not script is GDScript or not _script_extends_variable_editor_provider(script):
		return
	var instance := script.new()
	if instance is FKVariableEditorProvider:
		providers.append(instance)

func _script_extends_variable_editor_provider(script: GDScript) -> bool:
	var current: GDScript = script
	while current != null:
		if current.get_global_name() == &"FKVariableEditorProvider":
			return true
		current = current.get_base_script()
	return false