@tool
extends Control
## Meant to represent individual FKVariables in the Variable Editor Modal, accessible
## through the Event Sheet editor.
class_name FKVariableUi

@export_category("Controls")
@export var name_field: LineEdit
@export var access_scope_field: MenuButton
@export var removal_button: Button

@export_category("Metadata")
## Shown when selecting a var type to add to a holder
@export var type_display_name: String = ""

func legitimize() -> void:
	if not _is_editor_preview:
		return

	_is_editor_preview = false
	_prep_access_scope_field()
	_enter_tree()
	refresh()

func _pre_legitimize_enter_tree():
	_pre_legitimize_toggle_subs(true)

func _enter_tree() -> void:
	_pre_legitimize_enter_tree()
	if _is_editor_preview:
		return
	_toggle_subs(true)

## These apply regardless of legitimization.
func _pre_legitimize_toggle_subs(wants_subs_active: bool):
	pass

func _prep_access_scope_field() -> void:
	var popup = access_scope_field.get_popup()
	popup.clear(false)
	popup.add_item("Public", FKAccessScope.Keys.PUBLIC)
	popup.add_item("Read-Only", FKAccessScope.Keys.READONLY)
	popup.add_item("Private", FKAccessScope.Keys.PRIVATE)
var _is_editor_preview := true 

func _toggle_subs(wants_subs_active: bool):
	if wants_subs_active and not _is_subbed:
		access_scope_field.get_popup().id_pressed.connect(_on_access_scope_selected)
		removal_button.pressed.connect(_on_removal_button_pressed)
		name_field.text_submitted.connect(_on_name_field_text_submitted)
		name_field.focus_exited.connect(_on_name_field_focus_exited)

		_toggle_var_subs(wants_subs_active)
	elif _is_subbed and not wants_subs_active:
		access_scope_field.get_popup().id_pressed.disconnect(_on_access_scope_selected)
		removal_button.pressed.disconnect(_on_removal_button_pressed)
		name_field.text_submitted.disconnect(_on_name_field_text_submitted)
		name_field.focus_exited.disconnect(_on_name_field_focus_exited)

		_toggle_var_subs(wants_subs_active)
	else:
		return

	_is_subbed = !_is_subbed

func _on_name_field_text_submitted(_new_text: String):
	name_committed.emit(self)

func _on_name_field_focus_exited():
	name_committed.emit(self)

## The user is done typing in name_field. Whatever shows this is the one that knows
## about the other variables, so it's the one that decides whether the name is okay.
signal name_committed(var_ui: FKVariableUi)

func _on_removal_button_pressed():
	removal_requested.emit(self)

signal removal_requested(requester: FKVariableUi)

func _toggle_var_subs(wants_subs_active: bool):
	if _variable == null:
		return 
	
	## At this point, we assume that the connection status is appropriate
	## (hence why we don't repeat as many of the checks in _toggle_subs)
	if wants_subs_active:
		_variable.changed.connect(refresh)
	else:
		_variable.changed.disconnect(refresh)

var _is_subbed := false 

func get_variable() -> FKVariable:
	return _variable

## The one that this ui represents.
var _variable: FKVariable

## The scope picked in access_scope_field, which only shows its name.
var _selected_scope := FKAccessScope.Keys.PRIVATE

func set_variable(new_var: FKVariable) -> void:
	if _variable == new_var:
		return

	_toggle_subs(false) # Making sure to unsub to whatever var we were already repping
	_variable = new_var
	_toggle_subs(true)
	refresh()

## Resets the widgets to match the variable, discarding any edits not yet applied.
func refresh() -> void:
	if _variable == null:
		name_field.text = "[Null]"
		return

	name_field.text = _variable.key
	_selected_scope = _variable.scope
	access_scope_field.text = _access_scope_name(_selected_scope)
	_set_value(_variable.get_value())

func _exit_tree() -> void:
	_pre_legitimize_exit_tree()
	if _is_editor_preview:
		return
	_toggle_subs(false)

func _pre_legitimize_exit_tree():
	_pre_legitimize_toggle_subs(false)

func _on_access_scope_selected(scope_id: int) -> void:
	_selected_scope = scope_id as FKAccessScope.Keys
	access_scope_field.text = _access_scope_name(_selected_scope)

func _access_scope_name(scope: FKAccessScope.Keys) -> String:
	match scope:
		FKAccessScope.Keys.PUBLIC:
			return "Public"
		FKAccessScope.Keys.READONLY:
			return "Read-Only"
		FKAccessScope.Keys.PRIVATE:
			return "Private"
		_:
			return "Scope"

## Shows the value in the widgets. Must not write to the variable.
func _set_value(_value: Variant) -> void:
	push_error("[FlowKit] FKVariableUi subclasses must implement _set_value().")

## Writes what the widgets currently hold into the variable this ui represents.
## Edits only reach the variable through this (e.g. when the modal's Save is pressed).
## Returns false if there's no variable or it rejected the value.
func apply_to_variable() -> bool:
	if _variable == null:
		return false

	_variable.key = name_field.text
	_variable.scope = _selected_scope
	var value_accepted := _apply_value_to_variable()
	_variable.emit_changed() # Also makes us refresh, to show what the variable settled on
	return value_accepted

## Meant to be overridden. Reads the value widgets and sets them on _variable,
## returning whether the variable accepted it.
func _apply_value_to_variable() -> bool:
	push_error("[FlowKit] FKVariableUi subclasses must implement _apply_value_to_variable().")
	return false