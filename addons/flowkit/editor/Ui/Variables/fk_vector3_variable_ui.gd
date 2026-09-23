@tool
extends FKVariableUi
class_name FKVector3VariableUi

@export var x_field: SpinBox
@export var y_field: SpinBox
@export var z_field: SpinBox

func _toggle_subs(wants_subs_active: bool) -> void:
	if wants_subs_active and not _is_subbed:
		x_field.value_changed.connect(_on_component_changed)
		y_field.value_changed.connect(_on_component_changed)
		z_field.value_changed.connect(_on_component_changed)
	elif not wants_subs_active and _is_subbed:
		x_field.value_changed.disconnect(_on_component_changed)
		y_field.value_changed.disconnect(_on_component_changed)
		z_field.value_changed.disconnect(_on_component_changed)
	super._toggle_subs(wants_subs_active)

func _set_value(value: Variant) -> void:
	x_field.value = value.x
	y_field.value = value.y
	z_field.value = value.z

func _on_component_changed(_component: float) -> void:
	_commit_value(Vector3(x_field.value, y_field.value, z_field.value))