@tool
extends FKActionInputUi
class_name FKIntegerActionInputUi

@export var spin_box: SpinBox

func get_value() -> Variant:
	return int(spin_box.value)

func set_value(value: Variant) -> void:
	spin_box.value = int(value)