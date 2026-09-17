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
	super._apply_input_state_to_ui()
	var target_color_input := _get_action_input("Target Color")
	var alpha_input := _get_action_input("Alpha")
	var alpha_only_input := _get_action_input("Alpha Only")
	var duration_input := _get_action_input("Duration")
	var wait_for_finish_input := _get_action_input("Wait For Finish")
	if not target_color_input or not alpha_input or not alpha_only_input or not duration_input or not wait_for_finish_input:
		return

	var color_input: String = _get_input_value(target_color_input)
	color_picker.color = _string_to_color(color_input)
	color_picker.color.a = _get_input_value(alpha_input) / 100.0

	alpha_only_checkbox.button_pressed = _get_input_value(alpha_only_input)
	duration_spin_box.value = _get_input_value(duration_input)
	wait_for_finish_checkbox.button_pressed = _get_input_value(wait_for_finish_input)

func _apply_ui_state_to_inputs():
	var target_color_input := _get_action_input("Target Color")
	var alpha_input := _get_action_input("Alpha")
	var alpha_only_input := _get_action_input("Alpha Only")
	var duration_input := _get_action_input("Duration")
	var wait_for_finish_input := _get_action_input("Wait For Finish")
	if not target_color_input or not alpha_input or not alpha_only_input or not duration_input or not wait_for_finish_input:
		return

	_set_input_value(target_color_input, _color_to_fk_rgb_string(color_picker.color))
	_set_input_value(alpha_input, color_picker.color.a * 100.0)
	_set_input_value(alpha_only_input, alpha_only_checkbox.button_pressed)
	_set_input_value(duration_input, duration_spin_box.value)
	_set_input_value(wait_for_finish_input, wait_for_finish_checkbox.button_pressed)

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

