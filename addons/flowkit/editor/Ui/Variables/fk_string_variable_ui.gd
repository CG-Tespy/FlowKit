@tool
extends FKVariableUi
class_name FKStringVariableUi

@export var value_field: LineEdit

func _set_value(value: Variant) -> void:
	value_field.text = str(value)

func _apply_value_to_variable() -> bool:
	return _variable.set_value(value_field.text)