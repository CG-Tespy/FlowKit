@tool
extends FKVariableUi
class_name FKNumberVariableUi

@export var value_field: SpinBox
@export var whole_nums_only: CheckBox

func _set_subs(wants_subs_active: bool):
	if wants_subs_active and not _is_subbed:
		value_field.value_changed.connect(_on_value_field_changed)
		whole_nums_only.pressed.connect(_on_whole_nums_only_pressed)
	elif _is_subbed and not wants_subs_active:
		value_field.value_changed.disconnect(_on_value_field_changed)
		whole_nums_only.pressed.disconnect(_on_whole_nums_only_pressed)

	super._set_subs(wants_subs_active)

func _on_value_field_changed(new_val: float):
	if whole_nums_only.button_pressed:
		new_val = floor(new_val)
		value_field.set_value_no_signal(new_val)

func _on_whole_nums_only_pressed():
	_set_value(value_field.value)


func _set_value(value: Variant) -> void:
	if whole_nums_only.button_pressed:
		value_field.value = int(value)
	else:
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