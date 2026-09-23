extends FKVariable
class_name FKFloatVariable

@export var value: float = 0.0

func get_value() -> float:
	return value

func compatible_with_type_of(new_val: Variant) -> bool:
	return new_val is int or new_val is float

func _set_for_our_type(new_val: Variant) -> void:
	value = float(new_val)

func _can_hold_of_type(type: String) -> bool:
	return type == "int" or type == "float"

func _convert_to_target_type(target_type: String) -> Variant:
	if target_type == "int":
		return int(value)
	return value

func get_class() -> String:
	return "FKFloatVariable"