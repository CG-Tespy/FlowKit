@tool
extends FKBaseBlockNode
class_name FKActionBlockNode

signal edit_requested(node)
signal delete_requested(node)
signal reorder_requested(source_item, target_item, drop_above: bool)

@export_category("Controls")
@export var panel: PanelContainer
@export var label: Label
@export var icon_label: Label
@export var context_menu: PopupMenu
@export var drop_indicator: ColorRect

@export_category("Styles")
@export var normal_stylebox: StyleBox
@export var selected_stylebox: StyleBox

var is_drop_target := false
var drop_above := true

# ---------------------------------------------------------
# Block Handling
# ---------------------------------------------------------

func _validate_block(to_set: FKBaseBlock) -> bool:
	return to_set == null or to_set is FKEventAction

func get_action() -> FKEventAction:
	return _block as FKEventAction

func _on_block_changed() -> void:
	update_display()

# ---------------------------------------------------------
# Registry Handling
# ---------------------------------------------------------

func _on_registry_set() -> void:
	_update_label()

# ---------------------------------------------------------
# Display / Styling
# ---------------------------------------------------------

func update_display() -> void:
	_update_label()
	_update_styling()

func _update_styling() -> void:
	if not panel:
		return

	var style := selected_stylebox if is_selected else normal_stylebox
	panel.add_theme_stylebox_override("panel", style)

func _update_label() -> void:
	var a := get_action()
	if not a or not label:
		return

	# Resolve display name from registry
	var display_name := a.action_id
	if registry:
		for provider in registry.action_providers:
			if provider.has_method("get_id") and provider.get_id() == a.action_id:
				if provider.has_method("get_name"):
					display_name = provider.get_name()
				break

	# Node name
	var node_name := String(a.target_node).get_file()

	# Parameters
	var params_text := ""
	if not a.inputs.is_empty():
		var param_pairs := []
		for key in a.inputs:
			param_pairs.append(str(a.inputs[key]))
		params_text = ": " + ", ".join(param_pairs)

	label.text = "%s on %s%s" % [display_name, node_name, params_text]
	name = "%s on %s" % [display_name, node_name]

# ---------------------------------------------------------
# Context Menu
# ---------------------------------------------------------

func show_context_menu(global_pos: Vector2) -> void:
	if not context_menu:
		return

	context_menu.position = global_pos
	context_menu.popup()

func _on_context_menu_id_pressed(id: int) -> void:
	match id:
		0: edit_requested.emit(self)
		1: delete_requested.emit(self)

# ---------------------------------------------------------
# Input Handling
# ---------------------------------------------------------

func _toggle_subs(on: bool) -> void:
	super._toggle_subs(on)

	if on:
		gui_input.connect(_on_gui_input)
		mouse_exited.connect(_on_mouse_exited)
		context_menu.id_pressed.connect(_on_context_menu_id_pressed)
	else:
		gui_input.disconnect(_on_gui_input)
		mouse_exited.disconnect(_on_mouse_exited)
		context_menu.id_pressed.disconnect(_on_context_menu_id_pressed)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				edit_requested.emit(self)
			else:
				set_selected(true)
			get_viewport().set_input_as_handled()

		elif event.button_index == MOUSE_BUTTON_RIGHT:
			set_selected(true)
			show_context_menu(DisplayServer.mouse_get_position())
			get_viewport().set_input_as_handled()

func _on_mouse_exited() -> void:
	_hide_drop_indicator()

# ---------------------------------------------------------
# Drag & Drop
# ---------------------------------------------------------

func _get_drag_data(at_position: Vector2) -> FKDragData:
	var a := get_action()
	if not a:
		return null

	var preview := _create_drag_preview()
	set_drag_preview(preview)

	return FKDragData.new(DragTarget.Type.action_item, self, a)

func _create_drag_preview() -> Control:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 4)

	var preview_label := Label.new()
	preview_label.text = label.text if label else "Action"
	preview_label.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0, 0.9))

	margin.add_child(preview_label)
	return margin

func _can_drop_data(at_position: Vector2, data) -> bool:
	var drag_data := data as FKDragData
	if not drag_data or drag_data.type != DragTarget.Type.action_item:
		_hide_drop_indicator()
		return false

	var source_node := drag_data.node
	if source_node == self:
		_hide_drop_indicator()
		return false

	# Prevent dropping a parent onto its own descendant
	if _is_descendant_of(source_node):
		_hide_drop_indicator()
		return false

	var above := at_position.y < size.y / 2.0
	if _is_adjacent_to_source(source_node, above):
		_hide_drop_indicator()
		return false

	_show_drop_indicator(above)
	return true

func _is_descendant_of(node: Node) -> bool:
	var current := get_parent()
	while current:
		if current == node:
			return true
		current = current.get_parent()
	return false

func _is_adjacent_to_source(source_node: Node, drop_above: bool) -> bool:
	var parent := get_parent()
	if not parent:
		return false

	var my_index := get_index()
	var source_index := parent.get_children().find(source_node)

	if source_index < 0:
		return false

	if drop_above and source_index == my_index - 1:
		return true
	if not drop_above and source_index == my_index + 1:
		return true

	return false

func _drop_data(at_position: Vector2, data) -> void:
	_hide_drop_indicator()

	var drag_data := data as FKDragData
	if not drag_data or drag_data.type != DragTarget.Type.action_item:
		return

	var source_node := drag_data.node
	if not source_node or source_node == self:
		return

	var above := at_position.y < size.y / 2.0
	reorder_requested.emit(source_node, self, above)

func _show_drop_indicator(above: bool) -> void:
	if not drop_indicator:
		return

	drop_above = above
	is_drop_target = true
	drop_indicator.visible = true
	drop_indicator.size = Vector2(size.x, 2)
	drop_indicator.position = Vector2(0, 0 if above else size.y - 2)

func _hide_drop_indicator() -> void:
	if drop_indicator:
		drop_indicator.visible = false
	is_drop_target = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		_hide_drop_indicator()
