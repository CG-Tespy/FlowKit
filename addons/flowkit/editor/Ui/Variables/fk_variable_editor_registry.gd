@tool
extends RefCounted
class_name FKVariableEditorRegistry

var _providers: Array[FKVariableEditorProvider] = []
var _project_settings: FKProjectSettings

func set_project_settings(project_settings: FKProjectSettings) -> void:
	_project_settings = project_settings

func load_providers() -> void:
	_providers = _create_builtin_providers()
	var loader := FKVariableEditorProviderLoader.new()
	loader.project_settings = _project_settings
	for provider in loader.load_all():
		_register_provider(provider)

func get_provider_for(variable: FKVariable) -> FKVariableEditorProvider:
	var best_provider: FKVariableEditorProvider
	for provider in _providers:
		if provider.supports(variable) and (best_provider == null or provider.get_priority() > best_provider.get_priority()):
			best_provider = provider
	return best_provider

func _register_provider(provider: FKVariableEditorProvider) -> void:
	if provider == null or provider.get_id().strip_edges().is_empty() or provider.get_editor_scene() == null:
		push_warning("[FlowKit] Ignoring invalid variable editor provider.")
		return
	_providers.append(provider)

func _create_builtin_providers() -> Array[FKVariableEditorProvider]:
	return [
		FKTypedVariableEditorProvider.new("int", preload("res://addons/flowkit/runtime/Variables/fk_int_variable.gd"), preload("res://addons/flowkit/editor/scenes/variableEditors/int_variable_editor.tscn")),
		FKTypedVariableEditorProvider.new("float", preload("res://addons/flowkit/runtime/Variables/fk_float_variable.gd"), preload("res://addons/flowkit/editor/scenes/variableEditors/float_variable_editor.tscn")),
		FKTypedVariableEditorProvider.new("bool", preload("res://addons/flowkit/runtime/Variables/fk_bool_variable.gd"), preload("res://addons/flowkit/editor/scenes/variableEditors/bool_variable_editor.tscn")),
		FKTypedVariableEditorProvider.new("string", preload("res://addons/flowkit/runtime/Variables/fk_string_variable.gd"), preload("res://addons/flowkit/editor/scenes/variableEditors/string_variable_editor.tscn")),
		FKTypedVariableEditorProvider.new("vector2", preload("res://addons/flowkit/runtime/Variables/fk_vector2_variable.gd"), preload("res://addons/flowkit/editor/scenes/variableEditors/vector2_variable_editor.tscn")),
		FKTypedVariableEditorProvider.new("vector3", preload("res://addons/flowkit/runtime/Variables/fk_vector3_variable.gd"), preload("res://addons/flowkit/editor/scenes/variableEditors/vector3_variable_editor.tscn")),
		FKTypedVariableEditorProvider.new("vector4", preload("res://addons/flowkit/runtime/Variables/fk_vector4_variable.gd"), preload("res://addons/flowkit/editor/scenes/variableEditors/vector4_variable_editor.tscn")),
		FKTypedVariableEditorProvider.new("color", preload("res://addons/flowkit/runtime/Variables/fk_color_variable.gd"), preload("res://addons/flowkit/editor/scenes/variableEditors/color_variable_editor.tscn")),
		FKTypedVariableEditorProvider.new("audio_stream", preload("res://addons/flowkit/runtime/Variables/fk_audio_stream_variable.gd"), preload("res://addons/flowkit/editor/scenes/variableEditors/audio_stream_variable_editor.tscn")),
		FKTypedVariableEditorProvider.new("node", preload("res://addons/flowkit/runtime/Variables/fk_node_variable.gd"), preload("res://addons/flowkit/editor/scenes/variableEditors/node_variable_editor.tscn"))
	]