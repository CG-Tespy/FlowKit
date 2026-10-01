@tool
extends RefCounted
## Recycles FKVariableUi instances so the variable editor doesn't have to
## instantiate (and free) a scene every time a variable shows up.
class_name FKVariableUiPool

func _init(factory: FKVariableEditorFactory) -> void:
	_factory = factory

var _factory: FKVariableEditorFactory
var _available_var_uis: Dictionary[String, Array] = {}

func acquire(variable: FKVariable) -> FKVariableUi:
	if variable == null:
		return null

	var pool_key := _get_pool_key(variable)
	if not _available_var_uis.has(pool_key):
		return _factory.create_from(variable)

	var available_var_uis: Array = _available_var_uis[pool_key]
	if available_var_uis.is_empty():
		return _factory.create_from(variable)

	var var_ui := available_var_uis.pop_back() as FKVariableUi
	var_ui.set_variable(variable)
	return var_ui

func release(var_ui: FKVariableUi) -> void:
	if var_ui == null:
		return

	var variable := var_ui.get_variable()
	if variable == null:
		return

	var parent := var_ui.get_parent()
	if parent != null:
		parent.remove_child(var_ui)

	var pool_key := _get_pool_key(variable)
	if not _available_var_uis.has(pool_key):
		_available_var_uis[pool_key] = []
	if not _available_var_uis[pool_key].has(var_ui):
		_available_var_uis[pool_key].append(var_ui)

func release_all(var_uis: Array) -> void:
	for elem in var_uis:
		release(elem as FKVariableUi)

func _get_pool_key(variable: FKVariable) -> String:
	return "%s:%s" % [variable.get_real_class(), variable.type_display_name()]

func get_class() -> String:
	return "FKVariableUiPool"
