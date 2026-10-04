@tool
extends FKVariableUi
class_name FKNodeVariableUi

## Shows the picked node's path. Pressing it requests a node to be picked.
@export var value_field: Button
@export var clear_button: Button

## Whoever handles this is expected to call set_picked_path once the user picks a node.
signal node_pick_requested(requester: FKNodeVariableUi)

const NO_NODE_TEXT := "[Select Node]"

## Relative to the edited scene's root. Only reaches the variable on apply.
var _picked_path := NodePath()

func get_picked_path() -> NodePath:
	return _picked_path

func set_picked_path(new_path: NodePath) -> void:
	_picked_path = new_path
	_update_value_field()

func _update_value_field() -> void:
	if _picked_path.is_empty():
		value_field.text = NO_NODE_TEXT
		value_field.tooltip_text = "Click to select a node from the edited scene."
	else:
		value_field.text = str(_picked_path)
		value_field.tooltip_text = "%s\nClick to select a different node." % _picked_path

func _set_value(_value: Variant) -> void:
	var variable := get_variable() as FKNodeVariable
	set_picked_path(variable.get_node_path() if variable else NodePath())

func _apply_value_to_variable() -> bool:
	var variable := _variable as FKNodeVariable
	if variable == null:
		return false

	variable.set_node_path(_picked_path)
	return true

func _toggle_subs(wants_subs_active: bool):
	var was_subbed := _is_subbed
	super._toggle_subs(wants_subs_active)
	if was_subbed == _is_subbed:
		return

	if _is_subbed:
		value_field.pressed.connect(_on_value_field_pressed)
		clear_button.pressed.connect(_on_clear_button_pressed)
	else:
		value_field.pressed.disconnect(_on_value_field_pressed)
		clear_button.pressed.disconnect(_on_clear_button_pressed)

func _on_value_field_pressed() -> void:
	node_pick_requested.emit(self)

func _on_clear_button_pressed() -> void:
	set_picked_path(NodePath())