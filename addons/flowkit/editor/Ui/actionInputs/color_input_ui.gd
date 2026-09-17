@tool
extends FKActionInputUi
class_name FKColorActionInputUi

@export var color_picker_button: ColorPickerButton

func get_value() -> Variant:
	return color_picker_button.color

func set_value(value: Variant) -> void:
	if value is Color:
		color_picker_button.color = value