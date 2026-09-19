@tool
extends FKModalWindow
class_name FKActionInputModal

@export var confirm_button: Button
@export var cancel_button: Button
@export var desc_label: Label
@export var input_holder: Control

func _toggle_subs(do_sub: bool):
	super._toggle_subs(do_sub)

	var should_add_subs := do_sub and not _is_subbed
	var should_remove_subs := not do_sub and _is_subbed

	if should_add_subs:
		confirm_button.pressed.connect(_on_confirm_pressed)
		cancel_button.pressed.connect(_on_cancel_pressed)
		close_requested.connect(_on_close_requested)
		visibility_changed.connect(_on_visibility_changed)
		_on_visibility_changed()
	elif should_remove_subs:
		confirm_button.pressed.disconnect(_on_confirm_pressed)
		cancel_button.pressed.disconnect(_on_cancel_pressed)
		close_requested.disconnect(_on_close_requested)
		visibility_changed.disconnect(_on_visibility_changed)
		FKEditorGlobals.is_action_input_modal_visible = false
	else:
		return

	_is_subbed = !_is_subbed

func _on_visibility_changed() -> void:
	FKEditorGlobals.is_action_input_modal_visible = visible

func _on_confirm_pressed():
	_apply_ui_state_to_inputs()
	confirm_inputs(_node_path, _action_id, _inputs)

## Meant to be overridden by subclasses.
func _apply_ui_state_to_inputs():
	pass

func _on_cancel_pressed():
	hide()

func _on_close_requested():
	_on_cancel_pressed()

## Sets this modal's ui fields based on the args passed.
func populate_for_action(pop_args: FKActionInputPopulationArgs) -> void:
	_last_pop_args.set_to(pop_args)
	_update_desc_label()
	_apply_input_state_to_ui()

var _last_pop_args := FKActionInputPopulationArgs.new()

func _update_desc_label():
	var desc := _last_pop_args.action.get_description().strip_edges()
	if desc.is_empty():
		desc = "No desc here."

	desc_label.text = desc

## Meant to be overridden by subclasses.
func _apply_input_state_to_ui():
	title = _last_pop_args.action.get_display_name()

func confirm_inputs(node_path: String, action_id: String, inputs: Dictionary) -> void:
	_modal_signals.expressions_confirmed.emit(node_path, action_id, inputs.duplicate(true))
	hide()

# Shorthands
var _inputs: Dictionary:
	get:
		return _last_pop_args.inputs

var _action_id: String:
	get:
		return _last_pop_args.action_id

var _node_path: String:
	get:
		return _last_pop_args.node_path

func _get_action_input(input_name: String) -> FKActionInput:
	for action_input in _last_pop_args.action_inputs:
		if action_input.name == input_name:
			return action_input
	push_error("[%s] Custom input modal for '%s' requires undefined input '%s'." % \
	[self.get_class(), _action_id, input_name])
	return null

func _get_input_value(action_input: FKActionInput) -> Variant:
	if action_input == null:
		return null
	return action_input.get_val(_inputs)

func _set_input_value(action_input: FKActionInput, value: Variant) -> void:
	if action_input == null:
		return
	action_input.set_val(_inputs, value)


