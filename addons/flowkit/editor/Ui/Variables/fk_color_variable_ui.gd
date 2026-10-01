@tool
extends FKVariableUi
class_name FKColorVariableUi

@export var value_field: ColorPickerButton

func _toggle_subs(wants_subs_active: bool) -> void:
	if wants_subs_active and not _is_subbed:
		value_field.popup_closed.connect(_on_picker_closed)
	elif not wants_subs_active and _is_subbed:
		value_field.popup_closed.disconnect(_on_picker_closed)
	super._toggle_subs(wants_subs_active)

func _on_picker_closed() -> void:
	_commit_value(value_field.color)

func _set_value(value: Variant) -> void:
	value_field.color = value
	if _variable:
		_variable.set_value(value, false)