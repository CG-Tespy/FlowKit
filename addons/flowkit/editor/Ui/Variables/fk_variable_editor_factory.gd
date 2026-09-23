@tool
extends RefCounted
class_name FKVariableEditorFactory

func _init(registry: FKVariableEditorRegistry) -> void:
	_registry = registry

var _registry: FKVariableEditorRegistry

func create_from(variable: FKVariable) -> FKVariableUi:
	var provider := _registry.get_provider_for(variable)
	if provider == null:
		push_warning("[FlowKit] No variable editor is available for '%s'." % variable.get_class())
		return null
	var editor_ui := provider.get_editor_scene().instantiate() as FKVariableUi
	if editor_ui == null:
		push_warning("[FlowKit] Variable editor provider '%s' returned an invalid scene." % provider.get_id())
		return null
	editor_ui.set_variable(variable)
	editor_ui.legitimize()
	return editor_ui