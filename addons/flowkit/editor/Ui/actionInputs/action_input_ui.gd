@tool
extends Control
class_name FKActionInputUi

@export var input_label: Label
@export var desc_label: RichTextLabel

@export_category("Input Value Controls")
@export var literal_control: Control
@export var expression_line_edit: LineEdit
@export var expression_toggle: Button

const DEFAULT_EXPRESSION_TEXT_COLOR := Color(0.55, 0.85, 0.7, 1)

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

var action_input: FKActionInput:
	set(value):
		action_input = value
		_apply_action_input_to_controls()

func _apply_action_input_to_controls() -> void:
	if action_input == null:
		desc_label.text = "[Invalid. Please report to FlowKit devs.]"
		return
	input_label.text = action_input.name
	desc_label.text = action_input.description

func _enter_tree() -> void:
	if is_editor_preview:
		return
	_toggle_subs(true)

func _toggle_subs(on: bool):
	if on and not _is_subbed:
		expression_toggle.toggled.connect(_on_expression_toggle_toggled)
		literal_control.gui_input.connect(_on_literal_control_gui_input)
		expression_line_edit.text_changed.connect(_on_expression_text_changed)
	elif _is_subbed and not on:
		expression_toggle.toggled.disconnect(_on_expression_toggle_toggled)
		literal_control.gui_input.disconnect(_on_literal_control_gui_input)
		expression_line_edit.text_changed.disconnect(_on_expression_text_changed)
	else:
		return

	_is_subbed = !_is_subbed

var _is_subbed := false 

func _on_expression_toggle_toggled(pressed: bool) -> void:
	if not _is_populating:
		_is_dirty = true
	_set_expression_mode(pressed)

func _set_expression_mode(enabled: bool) -> void:
	is_expression_mode = enabled
	_show_correct_input_controls()

var is_expression_mode := false

func _show_correct_input_controls():
	## Since we need to decide based on whether we're in expression mode or not.
	expression_toggle.button_pressed = is_expression_mode
	expression_line_edit.visible = is_expression_mode

	literal_control.visible = not is_expression_mode

func _on_literal_control_gui_input(_event: InputEvent) -> void:
	if not _is_populating:
		_is_dirty = true

func _on_expression_text_changed(_text: String) -> void:
	if not _is_populating:
		_is_dirty = true

func _ready() -> void:
	if is_editor_preview:
		return
	
	_apply_styling()
	_apply_action_input_to_controls()
	_set_expression_mode(is_expression_mode)

func _apply_styling():
	expression_line_edit.add_theme_color_override("font_color", _expression_text_color)

var _expression_text_color: Color:
	get:
		if _globals == null or _globals.editor_interface == null:
			return DEFAULT_EXPRESSION_TEXT_COLOR
		if not _editor_settings.has_setting(FKEditorGlobals.EXPRESSION_TEXT_COLOR_KEY):
			return DEFAULT_EXPRESSION_TEXT_COLOR
		return _editor_settings.get_setting(FKEditorGlobals.EXPRESSION_TEXT_COLOR_KEY)

func set_action_input(value: FKActionInput) -> void:
	if is_editor_preview:
		return
	self.action_input = value

func get_value() -> Variant:
	push_error("[FlowKit] FKActionInputUi subclasses must implement get_value().")
	return null

## Meant to be overridden by subclasses. The default implementation updates
## shared value state and expression mode.
func try_set_value(_value: Variant) -> void:
	_original_value = _value
	_is_dirty = false
	_is_populating = true
	expression_line_edit.text = str(_value)
	if _is_expression(_value):
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
	return expression_line_edit.text

func get_value_or_expression(literal_value: Variant) -> Variant:
	if not _is_dirty:
		return _original_value
	return get_expression_value() if is_expression_mode else literal_value

func _is_expression(value: Variant) -> bool:
	if not value is String:
		return false

	var text := str(value).strip_edges()
	if text.is_empty():
		return false
	if action_input is FKStringActionInput:
		return text.begins_with("node.") or text.begins_with("scene_root.") or \
		text.begins_with("system.") or text == "delta" or \
		text.begins_with("ProjectSettings.") or text.begins_with("n_")

	var is_numeric_literal := text.is_valid_int() or text.is_valid_float()
	var is_bool_or_null_literal := text.to_lower() in _bool_or_null
	var result := not is_numeric_literal and not is_bool_or_null_literal
	return result

static var _bool_or_null := ["true", "false", "null"]

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

func release():
	_signals.action_input_ui_release_requested.emit(self)

var _signals: FKModalSignals:
	get:
		return _globals.modal_signals

var _editor_settings: EditorSettings:
	get:
		return _globals.editor_settings

func _exit_tree() -> void:
	if is_editor_preview:
		return
	_toggle_subs(false)