@tool
extends FKVariableUi
class_name FKNodeVariableUi

@export var value_field: LineEdit

func _toggle_subs(wants_subs_active: bool) -> void:
	if wants_subs_active and not _is_subbed:
		value_field.text_changed.connect(_on_path_changed)
	elif not wants_subs_active and _is_subbed:
		value_field.text_changed.disconnect(_on_path_changed)
	super._toggle_subs(wants_subs_active)

func _set_value(_value: Variant) -> void:
	var variable := get_variable() as FKNodeVariable
	value_field.text = str(variable.get_node_path()) if variable else ""

func _on_path_changed(new_path: String) -> void:
	if _is_refreshing:
		return
	var variable := get_variable() as FKNodeVariable
	if variable:
		variable.set_node_path(NodePath(new_path))