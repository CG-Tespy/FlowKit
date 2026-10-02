@tool
extends FKVariableUi
class_name FKColorVariableUi

@export var value_field: ColorPickerButton

func _set_value(value: Variant) -> void:
	value_field.color = value

func _apply_value_to_variable() -> bool:
	return _variable.set_value(value_field.color)