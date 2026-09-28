extends RefCounted
class_name FKVariableTypeLoader

const DEFAULT_MANIFEST_PATH := "res://addons/flowkit/saved/variable_type_manifest.tres"
const DEFAULT_VARIABLE_PATH := "res://addons/flowkit/runtime/Variables/Types"
const DEFAULT_TEST_VARIABLE_PATH := "res://tests/variable_types"
var manifest_path: String = DEFAULT_MANIFEST_PATH
var default_variable_path: String = DEFAULT_VARIABLE_PATH
var default_test_path := DEFAULT_TEST_VARIABLE_PATH
var project_settings: FKProjectSettings

func load_all() -> FKVariableTypeLoadResult:
	var result := FKVariableTypeLoadResult.new()
	
	if OS.has_feature("editor"):
		for variable_path in _get_variable_paths():
			_scan_directory_recursive(variable_path, result)
		result.source = "directory"
	else:
		result.source = "unavailable"
		result.errors.append("No variable type manifest found and directory scanning is not available " +\
		"in exported builds. Generate the manifest in the editor.")

	# Check for duplicate type names
	_collect_duplicate_name_diagnostics(result.variable_types, result)
	return result

func _get_variable_paths() -> Array[String]:
	var result: Array[String] = []
	var paths_to_check: Array[String] = _default_paths.duplicate()
	if project_settings:
		paths_to_check.append_array(project_settings.variable_type_paths)

	for path in paths_to_check:
		if not path.is_empty() and not result.has(path):
			result.append(path)

	return result

var _default_paths: Array[String] = [default_variable_path, default_test_path]

func _load_from_manifest(result: FKVariableTypeLoadResult) -> bool:
	if not ResourceLoader.exists(manifest_path):
		return false

	var manifest: Resource = load(manifest_path)
	if not manifest:
		return false

	_load_manifest_scripts(manifest.get("variable_type_scripts"), result)
	var any_var_types_found: bool = result.variable_types.size() > 0
	return any_var_types_found

func _load_manifest_scripts(scripts: Variant, result: FKVariableTypeLoadResult) -> void:
	if scripts == null:
		return
	for script_el in scripts:
		if script_el is GDScript:
			_try_add_variable_type(script_el, result)

func _try_add_variable_type(script: GDScript, result: FKVariableTypeLoadResult) -> void:
	var diagnostics := result.diagnostics
	if not _script_extends_variable(script):
		diagnostics.append("[FKVariableTypeLoader] Skipping script that does not " +\
		"extend FKVariable: %s" % script.resource_path)
		return

	# Create a temporary instance to check display name
	var instance: FKVariable = script.new()
	if instance == null:
		diagnostics.append("[FKVariableTypeLoader] Skipping script that returned " +\
		"null on new(): %s" % script.resource_path)
		return

	var type_name := instance.type_display_name()
	if type_name.is_empty():
		diagnostics.append("[FKVariableTypeLoader] Skipping variable type with empty display name: " +\
		"%s" % script.resource_path)
		return

	# Register the script for this type name
	result.variable_type_scripts[type_name] = script
	result.variable_types.append(type_name)

func _script_extends_variable(script: GDScript) -> bool:
	var current: GDScript = script
	while current != null:
		if current.get_global_name() == &"FKVariable":
			return true
		current = current.get_base_script()
	return false

func _scan_directory_recursive(path: String, result: FKVariableTypeLoadResult) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if not dir:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		var file_path := path.path_join(file_name)
		var found_subdir: bool = dir.current_is_dir() and not file_name.begins_with(".")
		var found_script: bool = not found_subdir and (file_name.ends_with(".gd") and not \
		file_name.ends_with(".gd.uid"))
		if found_subdir:
			_scan_directory_recursive(file_path, result)
		elif found_script:
			var script: Variant = load(file_path)
			if script is GDScript:
				_try_add_variable_type(script, result)
		file_name = dir.get_next()
	dir.list_dir_end()

func _collect_duplicate_name_diagnostics(variable_types: Array, result: FKVariableTypeLoadResult) -> void:
	var sources_by_name: Dictionary[String, String] = {}
	for type_name in variable_types:
		var script: GDScript = result.variable_type_scripts[type_name]
		var source: String = script.resource_path
		if sources_by_name.has(type_name):
			result.diagnostics.append("Duplicate variable type name '%s' in %s and %s" % \
			[type_name, sources_by_name[type_name], source])
		else:
			sources_by_name[type_name] = source

