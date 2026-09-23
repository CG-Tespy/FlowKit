extends FKVariable
class_name FKVector2Variable

@export var value: Vector2 = Vector2.ZERO

func get_value() -> Vector2:
	return value

func compatible_with_type_of(new_val: Variant) -> bool:
	return new_val is Vector2

func _set_for_our_type(new_val: Variant) -> void:
	value = new_val

func _can_hold_of_type(type: String) -> bool:
	return type == "vector2"

func _convert_to_target_type(_target_type: String) -> Variant:
	return value

func get_class() -> String:
	return "FKVector2Variable"