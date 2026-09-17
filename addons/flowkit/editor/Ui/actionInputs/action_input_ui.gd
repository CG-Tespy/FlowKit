@tool
extends Control
class_name FKActionInputUi

@export var input_label: Label
@export var desc_label: RichTextLabel

func legitimize(input: FKActionInput, editor_globals: FKEditorGlobals) -> void:
	if not is_editor_preview:
		return
	is_editor_preview = false
	_globals = editor_globals
	set_action_input(input)
	_enter_tree()
	_ready()

var _globals: FKEditorGlobals
var is_editor_preview := true

func _enter_tree() -> void:
	if is_editor_preview:
		return

var action_input: FKActionInput:
	set(value):
		action_input = value
		_apply_action_input()

func _ready() -> void:
	if is_editor_preview:
		return
	_apply_action_input()

func set_action_input(value: FKActionInput) -> void:
	if is_editor_preview:
		return
	action_input = value

func get_value() -> Variant:
	push_error("[FlowKit] FKActionInputUi subclasses must implement get_value().")
	return null

## Meant to be overridden by subclasses. Default implementation merely handles
## validation of the passed value.
func try_set_value(_value: Variant) -> void:
	if not _can_hold_value(_value):
		push_error("[%s] Cannot hold %s as a value." % [self.get_class()])

func _can_hold_value(val: Variant) -> bool:
	return false 

func get_class() -> String:
	return "FKActionInputUi"

## This should be executed with the assumption that the value passed
## is valid for this input ui.
func _set_value(_value) -> void:
	push_error("[%s] Needs _set_value overridden!")

func _apply_action_input() -> void:
	if not is_instance_valid(input_label) or action_input == null:
		desc_label.text = ""
		return
	input_label.text = action_input.name
	desc_label.text = action_input.description

func release():
	_signals.action_input_ui_release_requested.emit(self)

var _signals: FKModalSignals:
	get:
		return _globals.modal_signals