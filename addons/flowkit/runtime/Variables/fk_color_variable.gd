extends FKVariable
class_name FKColorVariable

@export var value: Color = Color.WHITE

func get_value() -> Color:
	return value

func compatible_with_type_of(new_val: Variant) -> bool:
	return new_val is Color

func _set_for_our_type(new_val: Variant) -> void:
	value = new_val

func _can_hold_of_type(type: String) -> bool:
	return type == "color"

func _convert_to_target_type(_target_type: String) -> Variant:
	return value

func get_class() -> String:
	return "FKColorVariable"