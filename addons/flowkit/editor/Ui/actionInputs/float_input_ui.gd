@tool
extends FKActionInputUi
class_name FKFloatActionInputUi

@export var spin_box: SpinBox

func get_value() -> Variant:
	return spin_box.value

func set_value(value: Variant) -> void:
	spin_box.value = float(value)