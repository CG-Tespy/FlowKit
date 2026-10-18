@tool
extends RefCounted

## For getting the right editor scene for displaying a variable in FK's
## editor controls.
class_name FKVariableEditorProvider

func get_id() -> String:
	return ""

func get_priority() -> int:
	return 0

func supports(_variable: FKVariable) -> bool:
	return false

func get_editor_scene() -> PackedScene:
	return null

func get_class() -> String:
	return "FKEditorProvider"

func get_real_class() -> String:
	return self.get_class()