extends Resource
## Stands in for a value (e.g. of an action input) that should come from one of a sheet's
## FKVariables. It holds the variable's id rather than the variable itself, so renaming
## the variable doesn't break it and copies of units don't end up with copies of variables.
## Takes the place of a value that should come from one of a sheet's FKVariables.
## It holds the variable's id rather than the variable itself, so renaming the variable
## doesn't break it and copies of units don't end up with copies of variables.
class_name FKVariableRef

const INVALID_ID := 0

@export var variable_id: int = INVALID_ID

## The type of value that the ref is wanted for (e.g. "float", "Vector2"), as
## FKActionInput names them. The variable's value gets converted to it where it can.
@export var target_type: String = ""

static func to(variable: FKVariable, wanted_type: String = "") -> FKVariableRef:
	var result := FKVariableRef.new()
	result.variable_id = variable.id if variable != null else INVALID_ID
	result.target_type = wanted_type
	return result

func is_valid() -> bool:
	return variable_id != INVALID_ID

## Gets the value of the variable this points to out of the manager, or null if there
## isn't such a variable. Node variables are looked up from scene_root, since their paths
## are relative to the root of the scene that the sheet is for.
func resolve(manager: FKVariableManager, scene_root: Node = null) -> Variant:
	var variable: FKVariable = null
	if manager != null:
		variable = manager.get_var_by_id(variable_id)
	if variable == null:
		_warn_once("[FlowKit] No variable with id %d to get the value of." % variable_id)
		return null

	if variable is FKNodeVariable and scene_root != null:
		return scene_root.get_node_or_null((variable as FKNodeVariable).get_node_path())

	var wants_conversion := not target_type.is_empty() and target_type.to_lower() != "variant" \
	and variable.can_hold_type(target_type)
	return variable.get_value_as(target_type) if wants_conversion else variable.get_value()

# Resolving happens every frame, so a missing variable shouldn't spam the log.
static var _warned: Dictionary = {}

static func _warn_once(message: String) -> void:
	if _warned.has(message):
		return
	_warned[message] = true
	push_warning(message)

func _to_string() -> String:
	return "FKVariableRef to variable %d" % variable_id

func get_class() -> String:
	return "FKVariableRef"
