@tool
extends RefCounted
class_name FKVariableEditorProvider

func get_id() -> String:
	return ""

func get_priority() -> int:
	return 0

func supports(_variable: FKVariable) -> bool:
	return false

func get_editor_scene() -> PackedScene:
	return null