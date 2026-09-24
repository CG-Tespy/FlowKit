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
	
	if _variable:
		_variable.set_value(value)

	_ensure_proper_sync_with_var()

func _ensure_proper_sync_with_var():
	if not _variable:
		return

	# It might've integerized itself after we committed a value to it. To make sure 
	# we're representing it properly, we need to update our fields.
	var vec_var := _variable as FKVectorVariable

	x_field.set_value_no_signal(vec_var.x())
	y_field.set_value_no_signal(vec_var.y())
	z_field.set_value_no_signal(vec_var.z())
	w_field.set_value_no_signal(vec_var.w())

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
		whole_nums_only.toggled.connect(_on_whole_nums_toggled)
	elif _is_pre_subbed and not wants_subs_active:
		axis_count_field.value_changed.disconnect(_on_axis_count_changed)
		whole_nums_only.toggled.disconnect(_on_whole_nums_toggled)
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

func _on_whole_nums_toggled(is_on: bool):
	if not _variable:
		return
	var vec_var := _variable as FKVectorVariable
	vec_var.whole_nums_only = is_on

func _toggle_subs(wants_subs_active: bool) -> void:
	if wants_subs_active and not _is_subbed:
		x_field.value_changed.connect(_on_component_changed)
		y_field.value_changed.connect(_on_component_changed)
		z_field.value_changed.connect(_on_component_changed)
		w_field.value_changed.connect(_on_component_changed)
		
	elif not wants_subs_active and _is_subbed:
		x_field.value_changed.disconnect(_on_component_changed)
		y_field.value_changed.disconnect(_on_component_changed)
		z_field.value_changed.disconnect(_on_component_changed)
		w_field.value_changed.disconnect(_on_component_changed)
	super._toggle_subs(wants_subs_active)



func _on_component_changed(_component: float) -> void:
	var to_commit := Vector4(x_field.value, y_field.value, z_field.value, w_field.value)
	_commit_value(to_commit)

func _commit_value(value: Variant) -> void:
	super._commit_value(value) 
	_ensure_proper_sync_with_var()

