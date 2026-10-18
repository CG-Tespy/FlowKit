extends RefCounted
## The main lower-level interface for adding or removing variables in the editor.
class_name FKVariableRegistry

func set_editor_globals(ed_globals: FKEditorGlobals):
	_globals = ed_globals

var _globals: FKEditorGlobals

func load_types():
	var load_result := _type_loader.load_all()
	_var_types_to_scripts = load_result.variable_type_scripts
	_report_var_types_loaded()

var _type_loader := FKVariableTypeLoader.new()

## These map variable type strings to the GDScripts for the appropriate FKVariables
var _var_types_to_scripts: Dictionary[String, GDScript]

# Holds variables made in the editor, or rendered ownerless, for reuse.
var _var_pool := FKVariablePool.new()

func _report_var_types_loaded():
	var log_message := "[%s] Variable types loaded:" % self.get_class()
	for elem in _var_types_to_scripts.keys():
		log_message += "\n%s" % elem
	print(log_message)

# This holds a copy of a variable of each type. The idea is to make it easier
# to do things like making new ones of specific types.
var _var_bases: Array[FKVariable] = []

func get_class() -> String:
	return "FKVariableRegistry"

func get_variable_of_type(type_name: String) -> FKVariable:
	var valid_type_name := _var_types_to_scripts.has(type_name)
	if not valid_type_name:
		var log_message := "[%s] Type name %s is not a valid one for the var types registered." % \
		[self.get_class(), type_name]
		printerr(log_message)
		return

	var new_var := _var_pool.acquire(_var_types_to_scripts[type_name])
	if new_var == null:
		return null

	_set_subs_for(new_var, true)
	return new_var

## Creates a variable of the given type and hands it to the manager, which assigns
## its id and owner. Returns null if the type is invalid or the manager rejects it.
func add_var_of_type(manager: FKVariableManager, type_name: String) -> FKVariable:
	if manager == null:
		push_error("[%s] Cannot add a variable without a manager." % self.get_class())
		return null

	var new_var := get_variable_of_type(type_name)
	if new_var == null:
		return null

	if not manager.add_var(new_var):
		_release_to_pool(new_var)
		return null
	return new_var

## Takes the variable out of the manager and, now that it's ownerless, pools it.
## Returns false if the manager didn't have it.
func remove_var_from(manager: FKVariableManager, fk_var: FKVariable) -> bool:
	if manager == null or not manager.remove_var(fk_var):
		return false

	_release_to_pool(fk_var)
	return true

func _set_subs_for(fk_var: FKVariable, wants_subs_active: bool):
	var already_connected = fk_var.value_changed.is_connected(_on_var_value_changed)

	if wants_subs_active and not already_connected:
		fk_var.value_changed.connect(_on_var_value_changed)
		fk_var.release_requested.connect(_on_var_release_requested)
	elif already_connected and not wants_subs_active:
		fk_var.value_changed.disconnect(_on_var_value_changed)
		fk_var.release_requested.disconnect(_on_var_release_requested)

func _on_var_value_changed(the_var: FKVariable):
	_var_signals.value_changed.emit(the_var)

var _var_signals: FKEditorVariableSignals:
	get:
		if not _globals:
			push_error("[%s] Cannot access var signals without globals registered." % self.get_class())
			return null
		return _globals.variable_signals

func _on_var_release_requested(the_var: FKVariable):
	_release_to_pool(the_var)

func _release_to_pool(the_var: FKVariable):
	_set_subs_for(the_var, false)
	if _var_pool.release(the_var) and _globals:
		_globals.variable_signals.released.emit(the_var)

func get_type_names() -> Array[String]:
	return _var_types_to_scripts.keys()

