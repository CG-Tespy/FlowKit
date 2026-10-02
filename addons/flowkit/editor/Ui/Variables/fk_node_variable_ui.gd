@tool
extends FKVariableUi
class_name FKNodeVariableUi

@export var value_field: LineEdit

func _set_value(_value: Variant) -> void:
	var variable := get_variable() as FKNodeVariable
	value_field.text = str(variable.get_node_path()) if variable else ""

func _apply_value_to_variable() -> bool:
	var variable := _variable as FKNodeVariable
	if variable == null:
		return false

	variable.set_node_path(NodePath(value_field.text))
	return true