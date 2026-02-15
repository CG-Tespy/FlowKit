@tool
extends RefCounted
class_name FKBlockFactory

var event_row_scene: PackedScene
var comment_scene: PackedScene
var group_scene: PackedScene

func _init(event_row: PackedScene, comment: PackedScene, group: PackedScene) -> void:
	event_row_scene = event_row
	comment_scene = comment
	group_scene = group


# ---------------------------------------------------------
# PUBLIC API
# ---------------------------------------------------------

func create_event_row(data: FKEventBlock) -> Node:
	var row = event_row_scene.instantiate()
	if row.has_method("set_event_data"):
		row.set_event_data(data)
	return row


func create_comment_block(data: FKCommentBlock) -> Node:
	var comment = comment_scene.instantiate()
	if comment.has_method("set_comment_data"):
		comment.set_comment_data(data)
	return comment


func create_group_block(data: FKGroupBlock) -> Node:
	var group = group_scene.instantiate()
	if group.has_method("set_group_data"):
		group.set_group_data(data)
	return group
