@tool
extends Control
class_name FKVariableUi

@export var name_field: LineEdit
@export var access_scope_field: MenuButton

func legitimize() -> void:
	if not _is_editor_preview:
		return

	_is_editor_preview = false
	_prep_access_scope_field()
	_enter_tree()
	refresh()

func _enter_tree() -> void:
	if _is_editor_preview:
		return
	_toggle_subs(true)

func _prep_access_scope_field() -> void:
	var popup = access_scope_field.get_popup()
	popup.clear(false)
	popup.add_item("Public", FKAccessScope.Keys.PUBLIC)
	popup.add_item("Read-Only", FKAccessScope.Keys.READONLY)
	popup.add_item("Private", FKAccessScope.Keys.PRIVATE)
var _is_editor_preview := true 

func _toggle_subs(wants_subs_active: bool):
	if wants_subs_active and not _is_subbed:
		name_field.text_changed.connect(_on_name_changed)
		access_scope_field.get_popup().id_pressed.connect(_on_access_scope_selected)
		_toggle_var_subs(wants_subs_active)
	elif _is_subbed and not wants_subs_active:
		name_field.text_changed.disconnect(_on_name_changed)
		access_scope_field.get_popup().id_pressed.disconnect(_on_access_scope_selected)
		_toggle_var_subs(wants_subs_active)
	else:
		return

	_is_subbed = !_is_subbed

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
var _is_refreshing := false

func set_variable(new_var: FKVariable) -> void:
	if _variable == new_var:
		return

	_toggle_subs(false) # Making sure to unsub to whatever var we were already repping
	_variable = new_var
	_toggle_subs(true)
	refresh()

func refresh() -> void:
	if _variable == null:
		name_field.text = "[Null]"
		return

	_is_refreshing = true
	name_field.text = _variable.key
	access_scope_field.text = _access_scope_name(_variable.scope)
	_set_value(_variable.get_value())
	_is_refreshing = false

func _exit_tree() -> void:
	if _is_editor_preview:
		return
	_toggle_subs(false)

func _on_name_changed(new_name: String) -> void:
	if _variable == null or _is_refreshing:
		return
	_variable.key = new_name
	_variable.emit_changed()

func _on_access_scope_selected(scope_id: int) -> void:
	if _variable == null or _is_refreshing:
		return
	_variable.scope = scope_id as FKAccessScope.Keys
	_variable.emit_changed()

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

func _set_value(_value: Variant) -> void:
	push_error("[FlowKit] FKVariableUi subclasses must implement _set_value().")

func _commit_value(value: Variant) -> void:
	if _variable != null and not _is_refreshing:
		_variable.set_value(value)