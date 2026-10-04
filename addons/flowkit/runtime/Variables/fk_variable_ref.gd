extends Resource
## Stands in for a value (e.g. of an action input) that should come from one of a sheet's
## FKVariables. It holds the variable's id rather than the variable itself, so renaming
## the variable doesn't break it and copies of units don't end up with copies of variables.
class_name FKVariableRef

const INVALID_ID := 0

@export var variable_id: int = INVALID_ID

static func to(variable: FKVariable) -> FKVariableRef:
	var result := FKVariableRef.new()
	result.variable_id = variable.id if variable != null else INVALID_ID
	return result

func is_valid() -> bool:
	return variable_id != INVALID_ID

func _to_string() -> String:
	return "FKVariableRef to variable %d" % variable_id

func get_class() -> String:
	return "FKVariableRef"
