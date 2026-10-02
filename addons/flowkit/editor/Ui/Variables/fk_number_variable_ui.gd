@tool
extends FKVariableUi
class_name FKNumberVariableUi

@export var value_field: SpinBox
@export var whole_nums_only: CheckBox

func _set_value(value: Variant) -> void:
	value_field.value = float(value)

func refresh() -> void:
	super.refresh()

	if _variable == null:
		return

	var num_var := _variable as FKNumberVariable
	whole_nums_only.button_pressed = num_var.whole_nums_only

func _apply_value_to_variable() -> bool:
	value_field.apply() # In case text was typed in without being confirmed
	var num_var := _variable as FKNumberVariable
	num_var.whole_nums_only = whole_nums_only.button_pressed # Before the value, which it affects
	return num_var.set_value(value_field.value)