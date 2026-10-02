@tool
extends RefCounted
## Recycles FKVariable instances that were made in the editor, or that were
## rendered ownerless (e.g. removed from their FKVariableManager), so we don't
## have to instantiate new ones every time a variable gets added.
class_name FKVariablePool

## Maps each FKVariable GDScript to the released instances of it.
var _available_vars: Dictionary[GDScript, Array] = {}

## Returns a pooled instance of the script's type if there is one. Otherwise,
## makes a new one. Either way, the result has default values and no owner.
## Returns null if the script isn't a valid FKVariable one.
func acquire(script: GDScript) -> FKVariable:
	if script == null:
		return null

	var available_vars := _get_pool_for(script)
	while not available_vars.is_empty():
		var pooled := available_vars.pop_back() as FKVariable
		if pooled != null:
			return pooled

	var new_var: Variant = script.new()
	if not new_var is FKVariable:
		push_error("[%s] %s does not extend FKVariable." % [get_class(), script.resource_path])
		return null
	return new_var

## Returns false if the variable could not be pooled: null, still owned, or
## already pooled.
func release(variable: FKVariable) -> bool:
	if variable == null:
		return false

	if variable.get_owner() != null:
		push_warning("[%s] Cannot pool a variable that still has an owner: %s" % \
		[get_class(), variable])
		return false

	var script := variable.get_script() as GDScript
	var pool := _get_pool_for(script)
	if pool.has(variable):
		return false

	_reset(variable, script)
	pool.append(variable)
	_keep_within_size_bounds(pool)
	return true

func is_pooled(variable: FKVariable) -> bool:
	if variable == null:
		return false
	var script := variable.get_script() as GDScript
	return _available_vars.has(script) and _available_vars[script].has(variable)

func count_for(script: GDScript) -> int:
	if not _available_vars.has(script):
		return 0
	return _available_vars[script].size()

func clear() -> void:
	_available_vars.clear()

func _get_pool_for(script: GDScript) -> Array:
	if not _available_vars.has(script):
		_available_vars[script] = []
	return _available_vars[script]

# Sets the stored properties back to their declared defaults, without sending signals.
func _reset(variable: FKVariable, script: GDScript) -> void:
	for prop in script.get_script_property_list():
		var is_stored: bool = prop["usage"] & PROPERTY_USAGE_STORAGE != 0
		if is_stored:
			variable.set(prop["name"], script.get_property_default_value(prop["name"]))

func _keep_within_size_bounds(pool: Array) -> void:
	while pool.size() > MAX_VARS_PER_TYPE:
		pool.pop_front()

const MAX_VARS_PER_TYPE := 50

func get_class() -> String:
	return "FKVariablePool"

func get_real_class() -> String:
	return self.get_class()
