@tool
extends FKActionInputModal
class_name FKFadeColorInputModal

@export var target_color_input_ui: FKActionInputUi
@export var target_alpha_input_ui: FKActionInputUi
@export var alpha_only_input_ui: FKActionInputUi
@export var duration_input_ui: FKActionInputUi
@export var wait_for_finish_input_ui: FKActionInputUi

func get_class():
	return "FKFadeColorInputModal"

func _apply_input_state_to_ui():
	super._apply_input_state_to_ui()
	var uis := _get_uis()
	var inputs := _get_field_inputs()
	if inputs.size() != uis.size():
		return

	for ind in range(uis.size()):
		var input_ui: FKActionInputUi = uis[ind]
		var action_input: FKActionInput = inputs[ind]
		# The input uis in the scene are editor previews until given their inputs.
		input_ui.legitimize(action_input, editor_globals)
		input_ui.set_action_input(action_input)
		input_ui.try_set_value(action_input.get_raw_val(_inputs))

func _apply_ui_state_to_inputs():
	var uis := _get_uis()
	var inputs := _get_field_inputs()
	if inputs.size() != uis.size():
		return

	for ind in range(uis.size()):
		var input_ui: FKActionInputUi = uis[ind]
		if input_ui.is_editor_preview:
			return
		_set_input_value(inputs[ind], input_ui.get_value())

func _get_uis() -> Array:
	return [
		target_color_input_ui,
		target_alpha_input_ui,
		alpha_only_input_ui,
		duration_input_ui,
		wait_for_finish_input_ui,
	]

## The action inputs matching _get_uis() by index. Empty if any is missing.
func _get_field_inputs() -> Array:
	var result := []
	for input_name in ["Target Color", "Target Alpha", "Alpha Only", "Duration", "Wait For Finish"]:
		var action_input := _get_action_input(input_name)
		if action_input == null:
			return []
		result.append(action_input)
	return result
