@tool
extends Control
class_name FKActionInputUi

@export var input_label: Label

var action_input: FKActionInput:
	set(value):
		action_input = value
		_apply_action_input()

func _ready() -> void:
	_apply_action_input()

func set_action_input(value: FKActionInput) -> void:
	action_input = value

func get_value() -> Variant:
	push_error("[FlowKit] FKActionInputUi subclasses must implement get_value().")
	return null

func set_value(_value: Variant) -> void:
	push_error("[FlowKit] FKActionInputUi subclasses must implement set_value().")

func _apply_action_input() -> void:
	if not is_instance_valid(input_label) or action_input == null:
		return
	input_label.text = action_input.name