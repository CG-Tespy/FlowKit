@tool
extends FKVariableUi
class_name FKAudioStreamVariableUi

@export var value_field: EditorResourcePicker

func _set_value(value: Variant) -> void:
	value_field.edited_resource = value

func _apply_value_to_variable() -> bool:
	return _variable.set_value(value_field.edited_resource)