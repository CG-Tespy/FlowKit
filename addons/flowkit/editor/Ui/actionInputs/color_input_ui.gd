@tool
extends FKActionInputUi
class_name FKColorActionInputUi

@export var color_picker_button: ColorPickerButton

func get_value() -> Variant:
	return get_value_or_expression(color_picker_button.color)

func _can_hold_value(val: Variant) -> bool:
	return val is Color

func _set_value(_value) -> void:
	color_picker_button.color = _value

func get_class() -> String:
	return "FKColorActionInputUi"