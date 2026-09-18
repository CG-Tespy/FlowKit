@tool
extends FKActionInputUi
class_name FKVector2ActionInputUi

@export var x_spin_box: SpinBox
@export var y_spin_box: SpinBox

func get_value() -> Variant:
	return get_value_or_expression(Vector2(x_spin_box.value, y_spin_box.value))

func _can_hold_value(val: Variant) -> bool:
	return val is Vector2

func _set_value(value: Variant) -> void:
	x_spin_box.value = value.x
	y_spin_box.value = value.y

func get_class() -> String:
	return "FKVector2ActionInputUi"