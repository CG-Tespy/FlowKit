@tool
extends FKActionInputUi
class_name FKColorActionInputUi

@export var color_picker_button: ColorPickerButton

func get_value() -> Variant:
	return get_value_or_expression(color_picker_button.color)

func _can_hold_value(val: Variant) -> bool:
	return val is Color

## Older sheets store colors as "" or an "(r, g, b)" string instead of a Color.
func _get_literal_value(value: Variant) -> Variant:
	if value is Color:
		return value
	var fallback: Color = action_input.default_value if action_input != null \
	and action_input.default_value is Color else Color.WHITE
	if not value is String:
		return fallback
	var parts := String(value).replace("\"", "").replace("(", "").replace(")", "").split(",")
	if parts.size() < 3:
		return fallback
	return Color8(int(parts[0]), int(parts[1]), int(parts[2]))

func _set_value(_value) -> void:
	color_picker_button.color = _value

func get_class() -> String:
	return "FKColorActionInputUi"

func get_real_class() -> String:
	return self.get_class()