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
		value_field.toggled.connect(_on_value_field_toggled)
	elif not wants_subs_active and _is_subbed:
		value_field.toggled.disconnect(_on_value_field_toggled)
	super._toggle_subs(wants_subs_active)

func _on_value_field_toggled(_is_on: bool) -> void:
	_update_value_field_text()

func _set_value(value: Variant) -> void:
	value_field.button_pressed = bool(value)
	_update_value_field_text()

func _apply_value_to_variable() -> bool:
	return _variable.set_value(value_field.button_pressed)