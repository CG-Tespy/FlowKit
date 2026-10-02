@tool
extends FKVariableUi
class_name FKVectorVariableUi

@export var x_field: SpinBox
@export var y_field: SpinBox
@export var z_field: SpinBox
@export var w_field: SpinBox
@export var axis_count_field: SpinBox
@export var whole_nums_only: CheckBox

func _set_value(value: Variant) -> void:
	x_field.value = value.x
	y_field.value = value.y
	z_field.value = value.z
	w_field.value = value.w

func refresh() -> void:
	super.refresh()

	if _variable == null:
		return

	var vec_var := _variable as FKVectorVariable
	whole_nums_only.button_pressed = vec_var.whole_nums_only

func _apply_value_to_variable() -> bool:
	for field in _component_fields:
		field.apply() # In case text was typed in without being confirmed

	var vec_var := _variable as FKVectorVariable
	vec_var.whole_nums_only = whole_nums_only.button_pressed # Before the value, which it affects
	return vec_var.set_value(Vector4(x_field.value, y_field.value, z_field.value, w_field.value))

# We want to be able to see the changes in the axis-count-field display even in
# Scene View, so...
func _pre_legitimize_enter_tree():
	super._pre_legitimize_enter_tree()
	_refresh_component_fields()

func _refresh_component_fields():
	# We need this func in case the user removed or changed the fields
	_component_fields = [x_field, y_field, z_field, w_field]
	_hide_component_fields()
	_show_component_fields_for_axis_count()

var _component_fields: Array[SpinBox] = []

func _pre_legitimize_toggle_subs(wants_subs_active: bool):
	if wants_subs_active and not _is_pre_subbed:
		axis_count_field.value_changed.connect(_on_axis_count_changed)
	elif _is_pre_subbed and not wants_subs_active:
		axis_count_field.value_changed.disconnect(_on_axis_count_changed)
	else:
		return

	_is_pre_subbed = !_is_pre_subbed

var _is_pre_subbed := false 

func _on_axis_count_changed(new_count: float):
	_hide_component_fields()
	_show_component_fields_for_axis_count()

func _hide_component_fields():
	x_field.visible = false 
	y_field.visible = false 
	z_field.visible = false 
	w_field.visible = false

func _show_component_fields_for_axis_count():
	# This assumes that the fields are all hidden.
	for ind in range(int(axis_count_field.value)):
		var field := _component_fields[ind]
		if field:
			field.visible = true