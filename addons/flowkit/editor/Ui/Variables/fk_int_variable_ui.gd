@tool
extends FKVariableUi
class_name FKIntVariableUi

@export var value_field: SpinBox

func _on_value_field_changed(new_val: float) -> void:
	_commit_value(int(new_val))

func _toggle_subs(wants_subs_active: bool):
	if wants_subs_active and not _is_subbed:
		value_field.value_changed.connect(_on_value_field_changed)
	elif _is_subbed and not wants_subs_active:
		value_field.value_changed.disconnect(_on_value_field_changed)

	super._toggle_subs(wants_subs_active)

func _set_value(value: Variant) -> void:
	value_field.value = int(value)