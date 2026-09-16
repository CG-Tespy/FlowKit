@tool
extends FKActionInputModal
class_name FKFadeColorInputModal

@export var color_picker: ColorPickerButton
@export var alpha_only_checkbox: CheckBox
@export var duration_spin_box: SpinBox
@export var wait_for_finish_checkbox: CheckBox

func get_class():
	return "FKFadeColorInputModal"

func _apply_input_state_to_ui():
	var color_input := _get_string_input("Target Color", "\"(255, 255, 255)\"")
	color_picker.color = _string_to_color(color_input)
	color_picker.color.a = _get_float_input("Alpha", 100.0) / 100.0

	alpha_only_checkbox.button_pressed = _get_bool_input("Alpha Only", false)
	duration_spin_box.value = _get_float_input("Duration", 1.0)
	wait_for_finish_checkbox.button_pressed = _get_bool_input("Wait For Finish", true)

func _apply_ui_state_to_inputs():
	_inputs["Target Color"] = _color_to_fk_rgb_string(color_picker.color)
	_inputs["Alpha"] = color_picker.color.a * 100.0
	_inputs["Alpha Only"] = alpha_only_checkbox.button_pressed
	_inputs["Duration"] = duration_spin_box.value
	_inputs["Wait For Finish"] = wait_for_finish_checkbox.button_pressed

func _string_to_color(raw: String) -> Color:
	var cleaned := raw.replace("\"", "").replace("(", "").replace(")", "")
	var values := cleaned.split(",")

	if values.size() != 3:
		return Color.WHITE

	for ind in range(values.size()):
		var val_found := values[ind]
		values[ind] = val_found.strip_edges()

	var r := float(values[0]) / 255.0
	var g := float(values[1]) / 255.0
	var b := float(values[2]) / 255.0
	return Color(r, g, b)

func _color_to_fk_rgb_string(color: Color) -> String:
	var r := roundi(color.r * 255.0)
	var g := roundi(color.g * 255.0)
	var b := roundi(color.b * 255.0)
	return "\"(%d, %d, %d)\"" % [r, g, b]

