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
	return variable != null and variable.get_script() == _variable_script

func get_editor_scene() -> PackedScene:
	return _editor_scene