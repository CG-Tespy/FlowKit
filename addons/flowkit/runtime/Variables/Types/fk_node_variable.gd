extends FKVariable
class_name FKNodeVariable

@export var value: NodePath = NodePath()

func category() -> String:
	return "General"

func type_display_name() -> String:
	return "Node"

func get_value() -> Node:
	var owner := get_owner() as Node
	if owner == null or value.is_empty():
		return null
	return owner.get_node_or_null(value)

func get_node_path() -> NodePath:
	return value

func set_node_path(new_path: NodePath) -> void:
	value = new_path
	emit_changed()

func compatible_with_type_of(new_val: Variant) -> bool:
	return new_val is Node and get_owner() is Node

func _set_for_our_type(new_val: Variant) -> void:
	value = (get_owner() as Node).get_path_to(new_val)

func _can_hold_of_type(type: String) -> bool:
	return type == "node"

func _convert_to_target_type(_target_type: String) -> Variant:
	return get_value()

func get_class() -> String:
	return "FKNodeVariable"