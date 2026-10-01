@tool
extends RefCounted

## Keeps track of the var-editor providers in a way that allows users 
## to set up their own outside of FK's own folder.
class_name FKVariableEditorRegistry

var _providers: Array[FKVariableEditorProvider] = []
var _project_settings: FKProjectSettings

func set_project_settings(project_settings: FKProjectSettings) -> void:
	_project_settings = project_settings

func load_providers() -> void:
	_providers = _create_builtin_providers()
	var loader := FKVariableEditorProviderLoader.new()
	loader.project_settings = _project_settings
	var third_party_providers := loader.load_all()
	for elem in third_party_providers:
		_register_provider(elem)

func _create_builtin_providers() -> Array[FKVariableEditorProvider]:
	var node_ed_scene: PackedScene = preload("res://addons/flowkit/editor/scenes/variableEditors/node_variable_editor.tscn")
	var node_var_script: Script = preload("res://addons/flowkit/runtime/Variables/Types/fk_node_variable.gd")
	var node_provider := FKTypedVariableEditorProvider.new("node", node_var_script , node_ed_scene)
	var builtin_numerics := _create_builtin_numeric_providers()
	var builtin_graphics := _create_builtin_graphical_providers()
	var builtin_audio := _create_builtin_audio_providers()
	
	var result: Array[FKVariableEditorProvider] = []
	result.append_array(builtin_numerics)
	result.append_array(builtin_graphics)
	result.append_array(builtin_audio)

	for elem in result:
		print("[%s] Created provider %s" % [self.get_class(), elem.get_id()])
	
	return result

func _create_builtin_numeric_providers() -> Array[FKVariableEditorProvider]:
	var number_scene: PackedScene = preload("res://addons/flowkit/editor/scenes/variableEditors/number_variable_editor.tscn")
	var vec_scene: PackedScene = preload("res://addons/flowkit/editor/scenes/variableEditors/vector_variable_editor.tscn")
	var bool_scene: PackedScene = preload("res://addons/flowkit/editor/scenes/variableEditors/bool_variable_editor.tscn")
	return [
		FKTypedVariableEditorProvider.new("int", preload("res://addons/flowkit/runtime/Variables/Types/fk_number_variable.gd"), number_scene),
		FKTypedVariableEditorProvider.new("float", preload("res://addons/flowkit/runtime/Variables/Types/fk_number_variable.gd"), number_scene),
		FKTypedVariableEditorProvider.new("number", preload("res://addons/flowkit/runtime/Variables/Types/fk_number_variable.gd"), number_scene),

		FKTypedVariableEditorProvider.new("bool", preload("res://addons/flowkit/runtime/Variables/Types/fk_bool_variable.gd"), bool_scene),

		FKTypedVariableEditorProvider.new("vector", preload("res://addons/flowkit/runtime/Variables/Types/fk_vector_variable.gd"), vec_scene),
		FKTypedVariableEditorProvider.new("vector2", preload("res://addons/flowkit/runtime/Variables/Types/fk_vector_variable.gd"), vec_scene),
		FKTypedVariableEditorProvider.new("vector3", preload("res://addons/flowkit/runtime/Variables/Types/fk_vector_variable.gd"), vec_scene),
		FKTypedVariableEditorProvider.new("vector4", preload("res://addons/flowkit/runtime/Variables/Types/fk_vector_variable.gd"), vec_scene),
	]

func _create_builtin_graphical_providers() -> Array[FKVariableEditorProvider]:
	var str_ed_scene: PackedScene = preload("res://addons/flowkit/editor/scenes/variableEditors/string_variable_editor.tscn")
	var str_var_script: Script = preload("res://addons/flowkit/runtime/Variables/Types/fk_string_variable.gd")

	var color_ed_scene: PackedScene = preload("res://addons/flowkit/editor/scenes/variableEditors/color_variable_editor.tscn")
	var color_var_script: Script = preload("res://addons/flowkit/runtime/Variables/Types/fk_color_variable.gd")
	
	return [
		FKTypedVariableEditorProvider.new("string", str_var_script, str_ed_scene),
		FKTypedVariableEditorProvider.new("color", color_var_script , color_ed_scene),
	]

func _create_builtin_audio_providers() -> Array[FKVariableEditorProvider]:
	var audio_stream_ed_scene: PackedScene = preload("res://addons/flowkit/editor/scenes/variableEditors/audio_stream_variable_editor.tscn")
	var audio_stream_var_script: Script = preload("res://addons/flowkit/runtime/Variables/Types/fk_audio_stream_variable.gd")
	return [
		FKTypedVariableEditorProvider.new("audio_stream", audio_stream_var_script, audio_stream_ed_scene),
	]

func get_provider_for(variable: FKVariable) -> FKVariableEditorProvider:
	print("Seeking provider for %s. Our registered prov count: %s" % [variable.get_real_class(), str(_providers.size())])
	var best_provider: FKVariableEditorProvider
	for provider in _providers:
		if not provider.supports(variable):
			print("Provider does not support var of type %s" % [variable.type_display_name()])
			continue
		if (best_provider == null or provider.get_priority() > best_provider.get_priority()):
			best_provider = provider
	return best_provider

func _register_provider(to_register: FKVariableEditorProvider) -> void:
	var is_invalid := to_register == null
	if is_invalid:
		push_warning(_invalid_editor_provider_message)
		return 

	var prov_id := to_register.get_id().strip_edges()
	var prov_ed_scene := to_register.get_editor_scene()
	is_invalid = prov_id.is_empty() or prov_ed_scene == null
	if is_invalid:
		push_warning(_invalid_editor_provider_message)
		return 
	
	if not _providers.has(to_register):
		return

	_providers.append(to_register)

static var _invalid_editor_provider_message := "[FlowKit] Ignoring invalid variable editor provider."

func get_class() -> String:
	return "FKVariableEditorRegistry"