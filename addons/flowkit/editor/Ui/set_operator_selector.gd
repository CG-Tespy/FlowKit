@tool
extends HBoxContainer
## Shows the SetOperators that a variable is compatible with, as the items of a menu that
## the user picks one from.
class_name FKSetOperatorSelector

signal operator_selected(op: FKVariable.SetOperator)

@export var label: Label
## Its popup lists the operators, and its text shows which one is picked.
@export var operator_menu: MenuButton

func _enter_tree() -> void:
	_set_subs(true)

func _set_subs(wants_subs_active: bool):
	var id_pressed := popup().id_pressed
	if wants_subs_active and not _is_subbed:
		id_pressed.connect(_on_menu_id_pressed)
	elif _is_subbed and not wants_subs_active:
		id_pressed.disconnect(_on_menu_id_pressed)
	else:
		return

	_is_subbed = !_is_subbed

func popup() -> PopupMenu:
	return operator_menu.get_popup()

var _is_subbed := false 

## The ids of the popup's items are the operators they stand for.
func _on_menu_id_pressed(id: int) -> void:
	select_operator(id as FKVariable.SetOperator)

## Returns false if the operator isn't one of those on display.
func select_operator(op: FKVariable.SetOperator, send_signal: bool = true) -> bool:
	var index := popup().get_item_index(op)
	if index < 0:
		return false

	selected_operator = op
	operator_menu.text = popup().get_item_text(index)
	if send_signal:
		operator_selected.emit(op)
	return true

func _ready() -> void:
	# The modal this goes in is always-on-top, which would otherwise keep the popup hidden.
	popup().always_on_top = true

## Shows only the operators passed. The preferred one gets selected if it's among them;
## otherwise, the first one does.
func display_operators(operators: Array[FKVariable.SetOperator], \
preferred: FKVariable.SetOperator = FKVariable.SetOperator.ASSIGN) -> void:
	popup().clear()

	for op in operators:
		var item := FKVariable.operator_symbol(op)
		popup().add_item(item, op)

	operator_menu.disabled = operators.is_empty()
	if operators.is_empty():
		selected_operator = FKVariable.SetOperator.NULL
		operator_menu.text = NO_OPERATORS_TEXT
		return
	
	var op_to_select := preferred if operators.has(preferred) else operators[0]
	select_operator(op_to_select, false)

var selected_operator := FKVariable.SetOperator.NULL
const NO_OPERATORS_TEXT := "No operators"

func displayed_operators() -> Array[FKVariable.SetOperator]:
	var result: Array[FKVariable.SetOperator] = []
	for index in popup().item_count:
		var id := popup().get_item_id(index)
		result.append(id)
	return result

func _name_of(op: FKVariable.SetOperator) -> String:
	return String(FKVariable.SetOperator.find_key(op)).capitalize()

func _exit_tree() -> void:
	_set_subs(false)

func get_class() -> String:
	return "FKSetOperatorSelector"

