@tool
extends FKActionInputUi
class_name FKIntActionInputUi

@export var spin_box: SpinBox

func get_value() -> Variant:
	return get_value_or_expression(int(spin_box.value))

func _can_hold_value(val: Variant) -> bool:
	return val is int or val is float

func _set_value(_value) -> void:
	spin_box.value = int(_value)

func get_class() -> String:
	return "FKIntActionInputUi"

func get_real_class() -> String:
	return self.get_class()