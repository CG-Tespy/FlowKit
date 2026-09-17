@tool
extends FKActionInputUi
class_name FKFloatActionInputUi

@export var spin_box: SpinBox

func get_value() -> Variant:
	return spin_box.value

func _can_hold_value(val: Variant) -> bool:
	return val is float or val is int

func _set_value(_value) -> void:
	spin_box.value = float(_value)

func get_class() -> String:
	return "FKFloatActionInputUi"