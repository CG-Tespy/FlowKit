extends FKVariable
class_name FKVector4Variable

@export var value: Vector4 = Vector4.ZERO

func category() -> String:
	return "Numeric/Structured"
	
func get_value() -> Vector4:
	return value

func compatible_with_type_of(new_val: Variant) -> bool:
	return new_val is Vector4

func _set_for_our_type(new_val: Variant) -> void:
	value = new_val

func _can_hold_of_type(type: String) -> bool:
	return type == "vector4"

func _convert_to_target_type(_target_type: String) -> Variant:
	return value

func get_class() -> String:
	return "FKVector4Variable"