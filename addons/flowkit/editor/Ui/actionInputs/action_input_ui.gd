@tool
extends Control
class_name FKActionInputUi

@export var input_label: Label
@export var desc_label: RichTextLabel

@export_category("Input Value Controls")
@export var literal_control: Control
@export var expression_line_edit: LineEdit
## Cycles through the input modes (see InputMode) when pressed.
@export var expression_toggle: Button

@export_category("Variable Mode Controls")
## Shown in variable mode. Its popup lists the variables that can be picked, and its
## text shows what's picked.
@export var variable_menu: MenuButton

## How the value of an input gets decided. The toggle cycles through these in order.
enum InputMode {
	LITERAL, ## The value in the literal control
	VARIABLE, ## One of the sheet's local variables, picked from variable_menu
	EXPRESSION, ## What's typed in expression_line_edit
}

const MODE_TOGGLE_TEXTS := {
	InputMode.LITERAL: "Lit",
	InputMode.VARIABLE: "Var",
	InputMode.EXPRESSION: "fx",
}

const MODE_TOGGLE_TOOLTIPS := {
	InputMode.LITERAL: "Using a literal value. Click to use a variable.",
	InputMode.VARIABLE: "Using a variable. Click to use an expression.",
	InputMode.EXPRESSION: "Using an expression. Click to use a literal value.",
}

const NO_VARIABLES_TEXT := "No valid vars in sheet!"
const PICK_VARIABLE_TEXT := "Select a variable"
const MISSING_VARIABLE_TEXT := "[Missing variable]"

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
		expression_toggle.pressed.connect(_on_expression_toggle_pressed)
		literal_control.gui_input.connect(_on_literal_control_gui_input)
		expression_line_edit.text_changed.connect(_on_expression_text_changed)
		variable_menu.get_popup().id_pressed.connect(_on_variable_menu_id_pressed)
	elif _is_subbed and not on:
		expression_toggle.pressed.disconnect(_on_expression_toggle_pressed)
		literal_control.gui_input.disconnect(_on_literal_control_gui_input)
		expression_line_edit.text_changed.disconnect(_on_expression_text_changed)
		variable_menu.get_popup().id_pressed.disconnect(_on_variable_menu_id_pressed)
	else:
		return

	_is_subbed = !_is_subbed

var _is_subbed := false 

func _on_expression_toggle_pressed() -> void:
	if not _is_populating:
		_is_dirty = true
	_set_input_mode(_next_input_mode(input_mode))

func _next_input_mode(mode: InputMode) -> InputMode:
	return ((mode + 1) % InputMode.size()) as InputMode

func _set_input_mode(mode: InputMode) -> void:
	input_mode = mode
	if mode == InputMode.VARIABLE:
		_refresh_variable_menu()
	_show_correct_input_controls()

func _set_expression_mode(enabled: bool) -> void:
	_set_input_mode(InputMode.EXPRESSION if enabled else InputMode.LITERAL)

var input_mode := InputMode.LITERAL

var is_expression_mode: bool:
	get:
		return input_mode == InputMode.EXPRESSION

var is_variable_mode: bool:
	get:
		return input_mode == InputMode.VARIABLE

func _show_correct_input_controls():
	expression_toggle.text = MODE_TOGGLE_TEXTS[input_mode]
	expression_toggle.tooltip_text = MODE_TOGGLE_TOOLTIPS[input_mode]

	literal_control.visible = input_mode == InputMode.LITERAL
	variable_menu.visible = input_mode == InputMode.VARIABLE
	expression_line_edit.visible = input_mode == InputMode.EXPRESSION

## The ids of the popup's items are the ids of the variables they stand for.
func _on_variable_menu_id_pressed(variable_id: int) -> void:
	_selected_variable_id = variable_id
	_update_variable_menu_text()
	if not _is_populating:
		_is_dirty = true

## The id of the variable picked in variable mode (FKVariableRef.INVALID_ID if none).
var _selected_variable_id := FKVariableRef.INVALID_ID

## Lists the sheet's variables that can be used as a value for this input.
func _refresh_variable_menu() -> void:
	var popup := variable_menu.get_popup()
	popup.clear()

	var sheet: FKEventSheet = null
	if _globals != null:
		sheet = _globals.current_sheet
	var variables: Array[FKVariable] = []
	if sheet != null:
		variables = sheet.variable_manager.get_variables()

	for variable in variables:
		if variable != null and _can_use_variable(variable):
			popup.add_item(variable.key if not variable.key.is_empty() else "[Unnamed]", variable.id)

	variable_menu.disabled = popup.item_count == 0
	_update_variable_menu_text()

func _update_variable_menu_text() -> void:
	var popup := variable_menu.get_popup()
	if _selected_variable_id != FKVariableRef.INVALID_ID:
		var index := popup.get_item_index(_selected_variable_id)
		# No such item means the variable was removed or isn't valid for this input, but
		# it's still what's picked.
		variable_menu.text = popup.get_item_text(index) if index >= 0 else MISSING_VARIABLE_TEXT
	elif popup.item_count == 0:
		variable_menu.text = NO_VARIABLES_TEXT
	else:
		variable_menu.text = PICK_VARIABLE_TEXT

func _can_use_variable(variable: FKVariable) -> bool:
	var type := action_input.type if action_input != null else ""
	return type.is_empty() or type == "Variant" or variable.can_hold_type(type)

## What goes into the input in variable mode, or null if no variable is picked.
func get_variable_reference() -> FKVariableRef:
	if _selected_variable_id == FKVariableRef.INVALID_ID:
		return null
	var result := FKVariableRef.new()
	result.variable_id = _selected_variable_id
	result.target_type = action_input.type if action_input != null else ""
	return result

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
	_set_input_mode(input_mode)

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
	_selected_variable_id = FKVariableRef.INVALID_ID

	if _value is FKVariableRef:
		_selected_variable_id = (_value as FKVariableRef).variable_id
		expression_line_edit.text = ""
		_set_input_mode(InputMode.VARIABLE)
		_is_populating = false
		return

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

	match input_mode:
		InputMode.EXPRESSION:
			return get_expression_value()
		InputMode.VARIABLE:
			var variable_ref := get_variable_reference()
			# With no variable picked, there's nothing to refer to
			return variable_ref if variable_ref != null else literal_value
		_:
			return literal_value

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