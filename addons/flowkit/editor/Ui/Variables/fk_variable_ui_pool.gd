@tool
extends RefCounted
## Recycles FKVariableUi instances so the variable editor doesn't have to
## instantiate (and free) a scene every time a variable shows up.
class_name FKVariableUiPool

func _init(factory: FKVariableEditorFactory) -> void:
	_factory = factory

var _factory: FKVariableEditorFactory
## Each key is basically a formatted string of the FKVariable's subtype
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
	var_ui.refresh() # set_variable skips refreshing when the variable is the same, which could leave stale widget edits
	return var_ui

func _get_pool_key(variable: FKVariable) -> String:
	_ensure_pool_key(variable)
	var result := pool_keys.get(variable.get_real_class())
	return result

func _ensure_pool_key(variable: FKVariable):
	var var_class := variable.get_real_class()
	var key_found := pool_keys.get(var_class, INVALID_POOL_KEY)
	if key_found == INVALID_POOL_KEY:
		pool_keys[var_class] = POOL_KEY_FORMAT % [var_class, variable.type_display_name()]
		
var pool_keys: Dictionary[String, String] = {}

const INVALID_POOL_KEY := "INVALID"
const POOL_KEY_FORMAT := "%s:%s"

func release(var_ui: FKVariableUi) -> void:
	if not _is_valid(var_ui):
		return

	_ensure_unparented(var_ui)

	var variable = var_ui.get_variable()
	var to_release_into := _get_pool_for(variable)
	
	var in_pool_already := to_release_into.has(var_ui)
	if in_pool_already:
		return

	to_release_into.append(var_ui)

	_keep_within_size_bounds(to_release_into)

func _is_valid(var_ui: FKVariableUi) -> bool:
	return var_ui != null and var_ui.get_variable() != null

func _ensure_unparented(var_ui: FKVariableUi):
	var parent := var_ui.get_parent()
	if parent != null:
		parent.remove_child(var_ui)

func _get_pool_for(variable: FKVariable) -> Array:
	var pool_key := _get_pool_key(variable)
	_ensure_pool_for(variable, pool_key)
	
	var result: Array = _available_var_uis[pool_key]
	return result

func _ensure_pool_for(variable: FKVariable, pool_key: String):
	var pool_is_ready = _available_var_uis.has(pool_key)
	if not pool_is_ready:
		_available_var_uis[pool_key] = []

func _keep_within_size_bounds(to_constrain: Array):
	while to_constrain.size() >= MAX_VAR_UIS_PER_POOL_KEY:
		var to_get_rid_of := to_constrain.pop_front() as FKVariableUi
		to_get_rid_of.queue_free()

const MAX_VAR_UIS_PER_POOL_KEY := 10

func release_all(var_uis: Array) -> void:
	for elem in var_uis:
		release(elem as FKVariableUi)

func get_class() -> String:
	return "FKVariableUiPool"

func get_real_class() -> String:
	return self.get_class()
