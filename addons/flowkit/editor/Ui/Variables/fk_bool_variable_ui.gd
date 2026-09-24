@tool
extends FKVariableUi
class_name FKBoolVariableUi

@export var value_field: CheckBox

func _enter_tree() -> void:
	super._enter_tree()
	_update_value_field_text()

func _update_value_field_text():
	value_field.text = "On" if value_field.button_pressed else "Off"

func _toggle_subs(wants_subs_active: bool) -> void:
	if wants_subs_active and not _is_subbed:
		value_field.toggled.connect(_commit_value)
	elif not wants_subs_active and _is_subbed:
		value_field.toggled.disconnect(_commit_value)
	super._toggle_subs(wants_subs_active)

func _set_value(value: Variant) -> void:
	value_field.button_pressed = bool(value)
	_update_value_field_text()
	