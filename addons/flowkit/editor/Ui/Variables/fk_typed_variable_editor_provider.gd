@tool
extends FKVariableEditorProvider
class_name FKTypedVariableEditorProvider

func _init(provider_id: String, variable_script: Script, editor_scene: PackedScene) -> void:
	_id = provider_id
	_variable_script = variable_script
	_editor_scene = editor_scene

var _id: String
var _variable_script: Script
var _editor_scene: PackedScene

func get_id() -> String:
	return _id

func supports(variable: FKVariable) -> bool:
	var log_message := ""
	if variable == null:
		log_message = "[%s] Cannot support a null FKVariable." % self.get_class()
		push_error(log_message)
		return false

	var their_var_script := variable.get_script()
	log_message = "Editor provider with script %s checking compatibility with %s" %\
	[str(_variable_script), their_var_script]
	
	return variable.get_script() == _variable_script

func get_editor_scene() -> PackedScene:
	return _editor_scene