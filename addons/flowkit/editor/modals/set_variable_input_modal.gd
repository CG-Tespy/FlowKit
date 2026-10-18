@tool
extends FKActionInputModal
## The input modal for FKSetVariable. From top to bottom: a menu that only lets the user pick
## one of the current sheet's variables, the operators that variable is compatible with,
## and an input for the value, made to suit the variable's type.
class_name FKSetVariableInputModal

## Its popup lists the sheet's variables, and its text shows which one is picked.
@export var variable_menu: MenuButton
@export var error_label: Label
@export var operator_selector: FKSetOperatorSelector

const VARIABLE_INPUT_NAME := FKSetVariable.VARIABLE_INPUT_NAME
const OPERATOR_INPUT_NAME := FKSetVariable.OPERATOR_INPUT_NAME
const VALUE_INPUT_NAME := FKSetVariable.VALUE_INPUT_NAME

const NO_SHEET_TEXT := "No sheet is open, so there are no variables to pick from."
const NO_VARIABLES_TEXT := "This sheet has no variables yet. Add some in the variable editor."
const PICK_VARIABLE_TEXT := "Select a variable"

## The variable picked in the menu. Null if none is.
var _chosen_variable: FKVariable
## What the value UI is for. Made to suit the chosen variable.
var _value_input: FKActionInput
var _value_ui: FKActionInputUi

func get_class() -> String:
	return "FKSetVariableInputModal"

func _enter_tree() -> void:
	super._enter_tree()
	if is_editor_preview:
		return

	# Same reasoning as FKGeneralActionInputModal: a transient child window can't be
	# always-on-top on Windows, and this needs to stay above the editor for the value UIs'
	# popups and for FileSystem dock drags.
	transient = false
	exclusive = false
	always_on_top = true

func _set_subs(do_sub: bool):
	var was_subbed := _is_subbed
	super._set_subs(do_sub)

	if do_sub and not was_subbed:
		variable_menu.get_popup().id_pressed.connect(_on_variable_menu_id_pressed)
		# The modal is always-on-top, which would otherwise keep the popup hidden behind it.
		variable_menu.get_popup().always_on_top = true
	elif not do_sub and was_subbed:
		variable_menu.get_popup().id_pressed.disconnect(_on_variable_menu_id_pressed)

var _ui_pool: FKActionInputUiPool:
	get:
		return editor_globals.action_input_ui_pool

var _variables: Array[FKVariable]:
	get:
		var sheet: FKEventSheet = editor_globals.current_sheet if editor_globals != null else null
		if sheet == null or sheet.variable_manager == null:
			return []
		return sheet.variable_manager.get_variables()

func _apply_input_state_to_ui():
	super._apply_input_state_to_ui()

	var variable_ref := _get_input_value(_get_action_input(VARIABLE_INPUT_NAME)) as FKVariableRef
	var variable: FKVariable = null
	if variable_ref != null and variable_ref.is_valid():
		variable = _find_variable_by_id(variable_ref.variable_id)

	var op := FKVariable.operator_from_symbol(str(_get_input_value(_get_action_input(OPERATOR_INPUT_NAME))))
	_refresh_variable_menu()
	_choose_variable(variable, op, true)
	_update_error_text()

func _apply_ui_state_to_inputs():
	if _chosen_variable == null or _value_ui == null:
		return

	var variable_ref := FKVariableRef.to(_chosen_variable)
	variable_ref.is_target = true
	_set_input_value(_get_action_input(VARIABLE_INPUT_NAME), variable_ref)

	var symbol := FKVariable.operator_symbol(operator_selector.selected_operator)
	_set_input_value(_get_action_input(OPERATOR_INPUT_NAME), "\"%s\"" % symbol)
	_set_input_value(_value_input, _value_ui.get_value())

## The ids of the popup's items are the ids of the variables they stand for.
func _on_variable_menu_id_pressed(variable_id: int) -> void:
	var variable := _find_variable_by_id(variable_id)
	# Picking the variable that's already chosen shouldn't reset anything
	if variable != _chosen_variable:
		_choose_variable(variable, FKVariable.SetOperator.ASSIGN, false)

## Makes the operator selector and value UI suit the variable. They're hidden if
## it's null. If use_saved_value is true, the value UI shows the value that's in the
## inputs, and the default one otherwise.
func _choose_variable(variable: FKVariable, op: FKVariable.SetOperator, use_saved_value: bool) -> void:
	_clear_value_ui()
	_chosen_variable = variable
	_update_variable_menu_text()

	var has_variable := variable != null
	operator_selector.visible = has_variable
	input_holder.visible = has_variable
	confirm_button.disabled = not has_variable
	if not has_variable:
		return

	operator_selector.display_operators(variable.compatible_operators(), op)

	_value_input = variable.create_value_action_input(VALUE_INPUT_NAME,
	"The value to apply to the variable. It has to be a %s." % variable.type_display_name())
	_value_ui = _ui_pool.acquire(_value_input)
	if _value_ui == null:
		return

	input_holder.add_child(_value_ui)
	var value: Variant = _value_input.get_raw_val(_inputs if use_saved_value else {})
	# Variant-typed inputs have no default to show, and the UI doesn't want a null.
	_value_ui.try_set_value("" if value == null else value)

func _clear_value_ui() -> void:
	if _value_ui != null:
		_value_ui.release()
	_value_ui = null
	_value_input = null

## Lists the sheet's variables.
func _refresh_variable_menu() -> void:
	var popup := variable_menu.get_popup()
	popup.clear()
	for variable in _variables:
		if variable != null:
			popup.add_item(variable.key if not variable.key.is_empty() else "[Unnamed]", variable.id)
	variable_menu.disabled = popup.item_count == 0

func _update_variable_menu_text() -> void:
	if _chosen_variable != null:
		var index := variable_menu.get_popup().get_item_index(_chosen_variable.id)
		variable_menu.text = variable_menu.get_popup().get_item_text(index) if index >= 0 		else _chosen_variable.key
	elif variable_menu.get_popup().item_count == 0:
		variable_menu.text = NO_VARIABLES_TEXT
	else:
		variable_menu.text = PICK_VARIABLE_TEXT

func _update_error_text() -> void:
	var message := ""
	if _variables.is_empty() and editor_globals != null and editor_globals.current_sheet == null:
		message = NO_SHEET_TEXT
	elif _variables.is_empty():
		message = NO_VARIABLES_TEXT

	error_label.text = message
	error_label.visible = not message.is_empty()

func _find_variable_by_id(id: int) -> FKVariable:
	for variable in _variables:
		if variable != null and variable.id == id:
			return variable
	return null
