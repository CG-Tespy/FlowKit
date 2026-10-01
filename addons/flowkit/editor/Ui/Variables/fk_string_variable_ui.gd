@tool
extends FKVariableUi
class_name FKStringVariableUi

@export var value_field: LineEdit

func _toggle_subs(wants_subs_active: bool) -> void:
	if wants_subs_active and not _is_subbed:
		value_field.text_submitted.connect(_commit_value)
		value_field.focus_exited.connect(_on_value_edit_finished)
	elif not wants_subs_active and _is_subbed:
		value_field.text_submitted.disconnect(_commit_value)
		value_field.focus_exited.disconnect(_on_value_edit_finished)
	super._toggle_subs(wants_subs_active)

func _on_value_edit_finished() -> void:
	_commit_value(value_field.text)

func _set_value(value: Variant) -> void:
	value_field.text = str(value)

	if _variable:
		_variable.set_value(value_field.text, false)