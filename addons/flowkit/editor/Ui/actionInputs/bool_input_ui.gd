@tool
extends FKActionInputUi
class_name FKBoolActionInputUi

@export var checkbox: CheckBox

func get_value() -> Variant:
	return get_value_or_expression(checkbox.button_pressed)

func _can_hold_value(val: Variant) -> bool:
	return val is bool

func _set_value(_value) -> void:
	checkbox.button_pressed = _value

func get_class() -> String:
	return "FKBoolActionInputUi"

func get_real_class() -> String:
	return self.get_class()