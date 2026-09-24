extends FKVariable
class_name FKVectorVariable

@export var value: Vector4 = Vector4.ZERO
@export var whole_nums_only := false 

func category() -> String:
	return "Numeric"
	
func get_value() -> Vector4:
	return value

func compatible_with_type_of(new_val: Variant) -> bool:
	return new_val is Vector4 or new_val is Vector3 or new_val is Vector2

func _set_for_our_type(new_val: Variant) -> void:
	value.x = new_val.x 
	value.y = new_val.y 
	# ^Since at this point, we know that the val is a VecTwo, Three or Four
	
	if new_val is Vector3 or new_val is Vector4:
		value.z = new_val.z 
	if new_val is Vector4:
		value.w = new_val.w
	
	if whole_nums_only:
		value.x = int(value.x)
		value.y = int(value.y)
		value.z = int(value.z)
		value.w = int(value.w)

func _can_hold_of_type(type: String) -> bool:
	return type == "vector4" or type == "vector3" or type == "vector2"

func _convert_to_target_type(_target_type: String) -> Variant:
	return value

func get_class() -> String:
	return "FKVectorVariable"

func as_vec_two() -> Vector2:
	var result := Vector2(value.x, value.y)
	return result

func as_vec_three() -> Vector3:
	var result = Vector3(value.x, value.y, value.z)
	return result