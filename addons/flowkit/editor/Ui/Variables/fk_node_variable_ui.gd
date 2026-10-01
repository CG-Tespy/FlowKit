@tool
extends FKVariableUi
class_name FKNodeVariableUi

@export var value_field: LineEdit

func _toggle_subs(wants_subs_active: bool) -> void:
	if wants_subs_active and not _is_subbed:
		value_field.text_submitted.connect(_on_path_changed)
		value_field.focus_exited.connect(_on_path_edit_finished)
	elif not wants_subs_active and _is_subbed:
		value_field.text_submitted.disconnect(_on_path_changed)
		value_field.focus_exited.disconnect(_on_path_edit_finished)
	super._toggle_subs(wants_subs_active)

func _on_path_edit_finished() -> void:
	_on_path_changed(value_field.text)

func _set_value(value: Variant) -> void:
	var variable := get_variable() as FKNodeVariable
	value_field.text = str(variable.get_node_path()) if variable else ""

	if _variable:
		_variable.set_value(value, false)

func _on_path_changed(new_path: String) -> void:
	if _is_refreshing:
		return
	var variable := get_variable() as FKNodeVariable
	if variable:
		variable.set_node_path(NodePath(new_path))