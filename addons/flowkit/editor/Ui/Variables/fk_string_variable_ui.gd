@tool
extends FKVariableUi
class_name FKStringVariableUi

@export var value_field: LineEdit

func _toggle_subs(wants_subs_active: bool) -> void:
	if wants_subs_active and not _is_subbed:
		value_field.text_changed.connect(_commit_value)
	elif not wants_subs_active and _is_subbed:
		value_field.text_changed.disconnect(_commit_value)
	super._toggle_subs(wants_subs_active)

func _set_value(value: Variant) -> void:
	value_field.text = str(value)
	if _variable:
		_variable.set_value(value)