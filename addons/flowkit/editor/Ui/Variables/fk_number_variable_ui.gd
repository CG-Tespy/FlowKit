@tool
extends FKVariableUi
class_name FKNumberVariableUi

@export var value_field: SpinBox
@export var whole_nums_only: CheckBox

func _on_value_edit_finished() -> void:
	_commit_value(value_field.value)

func _toggle_subs(wants_subs_active: bool) -> void:
	if wants_subs_active and not _is_subbed:
		_toggle_spinbox_commit(value_field, _on_value_edit_finished, true)
	elif not wants_subs_active and _is_subbed:
		_toggle_spinbox_commit(value_field, _on_value_edit_finished, false)
	super._toggle_subs(wants_subs_active)

func _set_value(value: Variant) -> void:
	value_field.value = float(value)
	if _variable:
		_variable.set_value(value_field.value, false)

func refresh() -> void:
	super.refresh()

	if _variable == null:
		return

	var num_var := _variable as FKNumberVariable
	whole_nums_only.button_pressed = num_var.whole_nums_only