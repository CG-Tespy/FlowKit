extends FKVariable
class_name FKIntVariable

@export var value: int = 0

func category() -> String:
	return "Numeric"

func get_value() -> int:
	return value

func hide_from_users() -> bool:
	return true

func compatible_with_type_of(new_val: Variant) -> bool:
	return new_val is int or new_val is float

func _set_for_our_type(new_val: Variant) -> void:
	value = int(new_val)

func _can_hold_of_type(type: String) -> bool:
	return type == "int" or type == "float"

func _convert_to_target_type(target_type: String) -> Variant:
	if target_type == "float":
		return float(value)
	return value

func get_class() -> String:
	return "FKIntVariable"