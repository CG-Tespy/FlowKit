@tool
extends Control
class_name FKActionInputUi

@export var input_label: Label
@export var desc_label: RichTextLabel
@export var literal_control: Control
@export var expression_line_edit: LineEdit
@export var expression_toggle: Button

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
var _original_value: Variant = null
var _is_dirty := false
var _is_populating := false

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
	if is_instance_valid(expression_toggle) and not expression_toggle.toggled.is_connected(_on_expression_toggle_toggled):
		expression_toggle.toggled.connect(_on_expression_toggle_toggled)
	if is_instance_valid(literal_control) and not literal_control.gui_input.is_connected(_on_literal_control_gui_input):
		literal_control.gui_input.connect(_on_literal_control_gui_input)
	if is_instance_valid(expression_line_edit) and not expression_line_edit.text_changed.is_connected(_on_expression_text_changed):
		expression_line_edit.text_changed.connect(_on_expression_text_changed)
	_set_expression_mode(is_expression_mode)

func set_action_input(value: FKActionInput) -> void:
	if is_editor_preview:
		return
	self.action_input = value

func get_value() -> Variant:
	push_error("[FlowKit] FKActionInputUi subclasses must implement get_value().")
	return null

## Meant to be overridden by subclasses. Default implementation merely handles
## validation of the passed value.
func try_set_value(_value: Variant) -> void:
	_original_value = _value
	_is_dirty = false
	_is_populating = true
	if _is_expression(_value):
		if is_instance_valid(expression_line_edit):
			expression_line_edit.text = str(_value)
		_set_expression_mode(true)
		_is_populating = false
		return

	_set_expression_mode(false)
	var value := _get_literal_value(_value)
	if not _can_hold_value(value):
		push_error("[%s] Cannot hold %s as a value." % [self.get_class()])
		_is_populating = false
		return
	_set_value(value)
	_is_populating = false

func get_expression_value() -> String:
	return expression_line_edit.text if is_instance_valid(expression_line_edit) else ""

func get_value_or_expression(literal_value: Variant) -> Variant:
	if not _is_dirty:
		return _original_value
	return get_expression_value() if is_expression_mode else literal_value

var is_expression_mode := false

func _on_expression_toggle_toggled(pressed: bool) -> void:
	if not _is_populating:
		_is_dirty = true
	_set_expression_mode(pressed)

func _on_literal_control_gui_input(_event: InputEvent) -> void:
	if not _is_populating:
		_is_dirty = true

func _on_expression_text_changed(_text: String) -> void:
	if not _is_populating:
		_is_dirty = true

func _set_expression_mode(enabled: bool) -> void:
	is_expression_mode = enabled
	if is_instance_valid(expression_toggle):
		expression_toggle.button_pressed = enabled
	if is_instance_valid(literal_control):
		literal_control.visible = not enabled
	if is_instance_valid(expression_line_edit):
		expression_line_edit.visible = enabled

func _is_expression(value: Variant) -> bool:
	if not value is String:
		return false

	var text := String(value).strip_edges()
	if text.is_empty():
		return false
	if action_input is FKStringActionInput:
		return text.begins_with("node.") or text.begins_with("scene_root.") or \
		text.begins_with("system.") or text == "delta" or \
		text.begins_with("ProjectSettings.") or text.begins_with("n_")
	return not (text.is_valid_int() or text.is_valid_float() or \
	text.to_lower() in ["true", "false", "null"])

func _get_literal_value(value: Variant) -> Variant:
	if action_input == null:
		return value
	if action_input is FKStringActionInput and value is String:
		var text := String(value)
		if text.length() >= 2 and ((text.begins_with("\"") and text.ends_with("\"")) or \
		(text.begins_with("'") and text.ends_with("'"))):
			return text.substr(1, text.length() - 2)
	return action_input.get_val({action_input.name: value})

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
		desc_label.text = "[Invalid. Please report to FlowKit devs.]"
		return
	input_label.text = action_input.name
	desc_label.text = action_input.description

func release():
	_signals.action_input_ui_release_requested.emit(self)

var _signals: FKModalSignals:
	get:
		return _globals.modal_signals

var _editor_settings: EditorSettings:
	get:
		return _globals.editor_settings