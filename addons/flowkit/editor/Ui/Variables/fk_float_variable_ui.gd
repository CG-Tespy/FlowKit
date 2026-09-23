@tool
extends FKVariableUi
class_name FKFloatVariableUi

@export var value_field: SpinBox

func _on_value_field_changed(new_value: float) -> void:
	_commit_value(new_value)

func _toggle_subs(wants_subs_active: bool) -> void:
	if wants_subs_active and not _is_subbed:
		value_field.value_changed.connect(_on_value_field_changed)
	elif not wants_subs_active and _is_subbed:
		value_field.value_changed.disconnect(_on_value_field_changed)
	super._toggle_subs(wants_subs_active)

func _set_value(value: Variant) -> void:
	value_field.value = float(value)