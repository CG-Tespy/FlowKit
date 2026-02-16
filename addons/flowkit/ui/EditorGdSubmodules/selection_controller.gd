@tool
extends RefCounted
class_name FKSelectionController

var _editor: Node
var _block_controller: FKBlockController
var _blocks_container: Control

var _selected_row: Node = null
var _selected_item: Node = null


func _init(editor: Node, block_controller: FKBlockController, blocks_container: Control) -> void:
	_editor = editor
	_block_controller = block_controller
	_blocks_container = blocks_container


# ---------------------------------------------------------
# PUBLIC API
# ---------------------------------------------------------

func get_selected_row() -> Node:
	return _selected_row

func get_selected_item() -> Node:
	return _selected_item


func select_row(row: Node) -> void:
	_clear_item_selection()

	if _selected_row and is_instance_valid(_selected_row) and _selected_row.has_method("set_selected"):
		_selected_row.set_selected(false)

	_selected_row = row

	if _selected_row and _selected_row.has_method("set_selected"):
		_selected_row.set_selected(true)


func select_item(item: Node) -> void:
	_clear_row_selection()

	_selected_item = item

	if _selected_item and _selected_item.has_method("set_selected"):
		_selected_item.set_selected(true)


func clear_selection() -> void:
	_clear_row_selection()
	_clear_item_selection()


func handle_click(mouse_pos: Vector2) -> void:
	# If click is outside all event rows, clear selection
	if not _is_click_on_event_row(mouse_pos):
		clear_selection()


func handle_delete() -> void:
	# Called when Delete key is pressed
	if _selected_item:
		_editor._delete_selected_item()
	elif _selected_row:
		_block_controller.remove_block(_selected_row)
		_editor.sheet_controller.save_sheet_from_blocks()


# ---------------------------------------------------------
# INTERNAL HELPERS
# ---------------------------------------------------------

func _clear_row_selection() -> void:
	if _selected_row and is_instance_valid(_selected_row) and _selected_row.has_method("set_selected"):
		_selected_row.set_selected(false)
	_selected_row = null


func _clear_item_selection() -> void:
	if _selected_item and is_instance_valid(_selected_item) and _selected_item.has_method("set_selected"):
		_selected_item.set_selected(false)
	_selected_item = null


func _is_click_on_event_row(mouse_pos: Vector2) -> bool:
	for block in _block_controller.get_blocks():
		if block.get_global_rect().has_point(mouse_pos):
			return true
	return false


func find_event_row_at_mouse(mouse_pos: Vector2) -> Node:
	for row in _block_controller.get_blocks():
		if row.get_global_rect().has_point(mouse_pos):
			return row
	return null


func is_mouse_in_blocks_area(mouse_pos: Vector2) -> bool:
	return _blocks_container.get_global_rect().has_point(mouse_pos)


func is_mouse_in_editor_area(mouse_pos: Vector2) -> bool:
	return _editor.get_global_rect().has_point(mouse_pos)


func has_focus_in_subtree() -> bool:
	var focused = _editor.get_viewport().gui_get_focus_owner()
	if focused == null:
		return false
	return focused == _editor or _editor.is_ancestor_of(focused)
