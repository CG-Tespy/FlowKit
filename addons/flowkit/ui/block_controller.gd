@tool
extends RefCounted
class_name FKBlockController

var _editor: Node
var _container: Node
var _factory: FKBlockFactory

func _init(editor: Node, container: Node, factory: FKBlockFactory) -> void:
	_editor = editor
	_container = container
	_factory = factory

# ---------------------------------------------------------
# PUBLIC API
# ---------------------------------------------------------

func get_blocks() -> Array:
	var result: Array = []
	for child in _container.get_children():
		if is_instance_valid(child) and not child.is_queued_for_deletion():
			result.append(child)
	return result


func clear_all() -> void:
	for child in _container.get_children():
		if is_instance_valid(child):
			child.queue_free()


func add_event_block(data: FKEventBlock, index: int = -1) -> Node:
	var row = _factory.create_event_row(data)
	_add_block(row, index)
	return row

func add_comment_block(data: FKCommentBlock, index: int = -1) -> Node:
	var comment = _factory.create_comment_block(data)
	_add_block(comment, index)
	return comment


func add_group_block(data: FKGroupBlock, index: int = -1) -> Node:
	var group = _factory.create_group_block(data)
	_add_block(group, index)
	return group


func remove_block(block: Node) -> void:
	if not block or not is_instance_valid(block):
		return
	if block.get_parent() == _container:
		_container.remove_child(block)
		block.queue_free()
	else:
		# Nested inside a group — let the group handle it
		if block.has_signal("delete_event_requested"):
			block.delete_event_requested.emit(block)


func find_parent_event_row(node: Node) -> Node:
	var current = node.get_parent()
	while current:
		if current.has_method("get_event_data"):
			return current
		current = current.get_parent()
	return null


func find_parent_group(node: Node) -> Node:
	var current = node.get_parent()
	while current:
		if current.has_method("get_group_data"):
			return current
		current = current.get_parent()
	return null


# ---------------------------------------------------------
# INTERNAL HELPERS
# ---------------------------------------------------------

func _add_block(block: Node, index: int) -> void:
	_container.add_child(block)
	if index >= 0:
		_container.move_child(block, index)
