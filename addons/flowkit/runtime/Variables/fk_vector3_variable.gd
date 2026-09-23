extends FKVariable
class_name FKVector3Variable

@export var value: Vector3 = Vector3.ZERO

func get_value() -> Vector3:
	return value

func compatible_with_type_of(new_val: Variant) -> bool:
	return new_val is Vector3

func _set_for_our_type(new_val: Variant) -> void:
	value = new_val

func _can_hold_of_type(type: String) -> bool:
	return type == "vector3"

func _convert_to_target_type(_target_type: String) -> Variant:
	return value

func get_class() -> String:
	return "FKVector3Variable"