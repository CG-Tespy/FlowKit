@tool
extends FKActionInputModal
class_name FKFadeColorInputModal

@export var color_picker: ColorPickerButton
@export var alpha_spin_box: SpinBox
@export var alpha_only_checkbox: CheckBox
@export var duration_spin_box: SpinBox
@export var wait_for_finish_checkbox: CheckBox
@export var target_color_expression: LineEdit
@export var alpha_expression: LineEdit
@export var alpha_only_expression: LineEdit
@export var duration_expression: LineEdit
@export var wait_for_finish_expression: LineEdit
@export var target_color_toggle: Button
@export var alpha_toggle: Button
@export var alpha_only_toggle: Button
@export var duration_toggle: Button
@export var wait_for_finish_toggle: Button

var _expression_modes: Dictionary[String, bool] = {}

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

	_populate_target_color(target_color_input)
	_populate_alpha(alpha_input)
	_populate_alpha_only(alpha_only_input)
	_populate_duration(duration_input)
	_populate_wait_for_finish(wait_for_finish_input)
	_connect_expression_toggles()

func _apply_ui_state_to_inputs():
	var target_color_input := _get_action_input("Target Color")
	var alpha_input := _get_action_input("Alpha")
	var alpha_only_input := _get_action_input("Alpha Only")
	var duration_input := _get_action_input("Duration")
	var wait_for_finish_input := _get_action_input("Wait For Finish")
	if not target_color_input or not alpha_input or not alpha_only_input or not duration_input or not wait_for_finish_input:
		return

	_set_input_value(target_color_input, _get_field_value("Target Color", _color_to_fk_rgb_string(color_picker.color)))
	_set_input_value(alpha_input, _get_field_value("Alpha", alpha_spin_box.value))
	_set_input_value(alpha_only_input, _get_field_value("Alpha Only", alpha_only_checkbox.button_pressed))
	_set_input_value(duration_input, _get_field_value("Duration", duration_spin_box.value))
	_set_input_value(wait_for_finish_input, _get_field_value("Wait For Finish", wait_for_finish_checkbox.button_pressed))

func _populate_target_color(input: FKActionInput) -> void:
	var raw := input.get_raw_val(_inputs)
	var is_expression: bool = raw is String and not String(raw).begins_with("\"") and not String(raw).begins_with("(")
	if is_expression:
		target_color_expression.text = str(raw)
	else:
		color_picker.color = _string_to_color(str(raw))
	_set_field_expression_mode("Target Color", is_expression)

func _populate_alpha(input: FKActionInput) -> void:
	var raw := input.get_raw_val(_inputs)
	var is_expression: bool = raw is String and not String(raw).is_valid_float()
	if is_expression:
		alpha_expression.text = str(raw)
	else:
		alpha_spin_box.value = input.get_val(_inputs)
	_set_field_expression_mode("Alpha", is_expression)

func _populate_alpha_only(input: FKActionInput) -> void:
	var raw := input.get_raw_val(_inputs)
	var is_expression: bool = raw is String and raw.to_lower() not in ["true", "false"]
	if is_expression:
		alpha_only_expression.text = str(raw)
	else:
		alpha_only_checkbox.button_pressed = input.get_val(_inputs)
	_set_field_expression_mode("Alpha Only", is_expression)

func _populate_duration(input: FKActionInput) -> void:
	var raw := input.get_raw_val(_inputs)
	var is_expression: bool = raw is String and not String(raw).is_valid_float()
	if is_expression:
		duration_expression.text = str(raw)
	else:
		duration_spin_box.value = input.get_val(_inputs)
	_set_field_expression_mode("Duration", is_expression)

func _populate_wait_for_finish(input: FKActionInput) -> void:
	var raw := input.get_raw_val(_inputs)
	var is_expression: bool = raw is String and raw.to_lower() not in ["true", "false"]
	if is_expression:
		wait_for_finish_expression.text = str(raw)
	else:
		wait_for_finish_checkbox.button_pressed = input.get_val(_inputs)
	_set_field_expression_mode("Wait For Finish", is_expression)

func _connect_expression_toggles() -> void:
	_connect_expression_toggle(target_color_toggle, "Target Color")
	_connect_expression_toggle(alpha_toggle, "Alpha")
	_connect_expression_toggle(alpha_only_toggle, "Alpha Only")
	_connect_expression_toggle(duration_toggle, "Duration")
	_connect_expression_toggle(wait_for_finish_toggle, "Wait For Finish")

func _connect_expression_toggle(toggle: Button, field_name: String) -> void:
	if not toggle.toggled.is_connected(_on_expression_toggle_toggled.bind(field_name)):
		toggle.toggled.connect(_on_expression_toggle_toggled.bind(field_name))

func _on_expression_toggle_toggled(pressed: bool, field_name: String) -> void:
	_set_field_expression_mode(field_name, pressed)

func _set_field_expression_mode(field_name: String, enabled: bool) -> void:
	_expression_modes[field_name] = enabled
	var controls := _get_field_controls(field_name)
	controls[0].visible = not enabled
	controls[1].visible = enabled
	controls[2].button_pressed = enabled

func _get_field_value(field_name: String, literal_value: Variant) -> Variant:
	if _expression_modes.get(field_name, false):
		return _get_field_controls(field_name)[1].text
	return literal_value

func _get_field_controls(field_name: String) -> Array[Control]:
	match field_name:
		"Target Color": return [color_picker, target_color_expression, target_color_toggle]
		"Alpha": return [alpha_spin_box, alpha_expression, alpha_toggle]
		"Alpha Only": return [alpha_only_checkbox, alpha_only_expression, alpha_only_toggle]
		"Duration": return [duration_spin_box, duration_expression, duration_toggle]
		"Wait For Finish": return [wait_for_finish_checkbox, wait_for_finish_expression, wait_for_finish_toggle]
	return []

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

