@tool
extends FKVariable
class_name FKNumberVariable

@export var value: float = 0.0 # Floats can hold higher values than ints, so...
@export var whole_nums_only := false

func category() -> String:
	return "Numeric"

func type_display_name() -> String:
	return "Number"

func get_value() -> float:
	return value

func hide_from_users() -> bool:
	return true

func compatible_with_type_of(new_val: Variant) -> bool:
	return new_val is int or new_val is float

func _set_for_our_type(new_val: Variant) -> void:
	if whole_nums_only:
		value = int(new_val)
	else:
		value = float(new_val)

func _can_hold_of_type(type: String) -> bool:
	return type == "int" or type == "float"

func _convert_to_target_type(target_type: String) -> Variant:
	if target_type == "int":
		return int(value)
	return value

func create_value_action_input(input_name: String = "Value", input_desc: String = "") -> FKActionInput:
	if whole_nums_only:
		return FKIntActionInput.new(input_name, input_desc)
	return FKFloatActionInput.new(input_name, input_desc)

func _prepare_operand(operand: Variant) -> Variant:
	return float(operand)

func _is_divide_by_zero(op: SetOperator, operand: Variant) -> bool:
	return op == SetOperator.DIVIDE and is_zero_approx(operand)

func get_class() -> String:
	return "FKNumberVariable"

func arithmetic_compatible() -> bool:
	return true