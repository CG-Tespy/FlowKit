@tool
extends FKActionInputUi
class_name FKVector4ActionInputUi

@export var x_spin_box: SpinBox
@export var y_spin_box: SpinBox
@export var z_spin_box: SpinBox
@export var w_spin_box: SpinBox

func get_value() -> Variant:
	return get_value_or_expression(Vector4(x_spin_box.value, y_spin_box.value, z_spin_box.value, w_spin_box.value))

func _can_hold_value(val: Variant) -> bool:
	return val is Vector4

func _set_value(value: Variant) -> void:
	x_spin_box.value = value.x
	y_spin_box.value = value.y
	z_spin_box.value = value.z
	w_spin_box.value = value.w

func get_class() -> String:
	return "FKVector4ActionInputUi"

func get_real_class() -> String:
	return self.get_class()