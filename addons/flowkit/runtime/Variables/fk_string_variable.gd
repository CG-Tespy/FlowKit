extends FKVariable
class_name FKStringVariable

@export var value: String = ""

func get_value() -> String:
	return value

func compatible_with_type_of(new_val: Variant) -> bool:
	return new_val is String

func _set_for_our_type(new_val: Variant) -> void:
	value = new_val

func _can_hold_of_type(type: String) -> bool:
	return type == "string"

func _convert_to_target_type(_target_type: String) -> Variant:
	return value

func get_class() -> String:
	return "FKStringVariable"