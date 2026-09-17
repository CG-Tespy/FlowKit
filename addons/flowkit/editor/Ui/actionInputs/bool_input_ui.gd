@tool
extends FKActionInputUi
class_name FKBoolActionInputUi

@export var checkbox: CheckBox

func get_value() -> Variant:
	return checkbox.button_pressed

func set_value(value: Variant) -> void:
	checkbox.button_pressed = value