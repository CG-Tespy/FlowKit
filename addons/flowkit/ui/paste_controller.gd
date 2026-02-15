@tool
extends RefCounted
class_name FKPasteController

var _editor: Node
var _block_controller: FKBlockController
var _serializer: FKEventSheetSerializer
var _undo: FKUndoManager

func _init(editor: Node, block_controller: FKBlockController, serializer: FKEventSheetSerializer, undo: FKUndoManager) -> void:
	_editor = editor
	_block_controller = block_controller
	_serializer = serializer
	_undo = undo

# ---------------------------------------------------------
# PUBLIC API
# ---------------------------------------------------------

func paste_events(event_dicts: Array, selected_row: Node) -> void:
	if event_dicts.is_empty():
		return

	_undo.push_state()

	# Determine if pasting into a group
	var target_group = _find_target_group(selected_row)

	if target_group:
		_paste_events_into_group(event_dicts, target_group)
		return

	_paste_events_top_level(event_dicts, selected_row)


func paste_actions(action_dicts: Array, selected_row: Node, selected_item: Node) -> void:
	if action_dicts.is_empty():
		return

	var target_row = selected_row
	var target_branch = null

	if selected_item and is_instance_valid(selected_item):
		target_branch = _editor._find_parent_branch(selected_item)
		if not target_row:
			target_row = _block_controller.find_parent_event_row(selected_item)

	if not target_row:
		target_row = _editor._find_event_row_at_mouse()

	if not target_row:
		print("Cannot paste actions: no event row found")
		return

	_undo.push_state()

	if target_branch:
		_paste_actions_into_branch(action_dicts, target_branch, target_row)
		return

	_paste_actions_into_row(action_dicts, target_row)


func paste_conditions(cond_dicts: Array, selected_row: Node, selected_item: Node) -> void:
	if cond_dicts.is_empty():
		return

	var target_row = selected_row

	if not target_row and selected_item:
		target_row = _block_controller.find_parent_event_row(selected_item)

	if not target_row:
		target_row = _editor._find_event_row_at_mouse()

	if not target_row:
		print("Cannot paste conditions: no event row found")
		return

	_undo.push_state()
	_paste_conditions_into_row(cond_dicts, target_row)


func paste_group(group_dict: Dictionary, selected_row: Node) -> void:
	if group_dict.is_empty():
		return

	_undo.push_state()

	var target_group = _find_target_group(selected_row)
	var group_data = _serializer._deserialize_group_block(group_dict)

	if target_group:
		_paste_group_nested(group_data, target_group)
		return

	_paste_group_top_level(group_data, selected_row)


# ---------------------------------------------------------
# INTERNAL HELPERS
# ---------------------------------------------------------

func _find_target_group(selected_row: Node) -> Node:
	if not selected_row:
		return null

	if selected_row.has_method("get_group_data"):
		return selected_row

	var parent = selected_row.get_parent()
	while parent:
		if parent.has_method("get_group_data"):
			return parent
		parent = parent.get_parent()

	return null


# ---------------------------------------------------------
# EVENT PASTING
# ---------------------------------------------------------

func _paste_events_into_group(event_dicts: Array, target_group: Node) -> void:
	for event_data_dict in event_dicts:
		var data = _build_event_data(event_data_dict)
		if target_group.has_method("add_event_to_group"):
			target_group.add_event_to_group(data)

	_editor._save_sheet()
	_editor._on_row_selected(target_group)
	print("Pasted %d event(s) into group" % event_dicts.size())


func _paste_events_top_level(event_dicts: Array, selected_row: Node) -> void:
	var insert_idx = _editor.blocks_container.get_child_count()
	if selected_row:
		insert_idx = selected_row.get_index() + 1

	var first_new_row = null

	for event_data_dict in event_dicts:
		var data = _build_event_data(event_data_dict)
		var new_row = _block_controller.add_event_block(data)
		_editor.blocks_container.move_child(new_row, insert_idx)
		insert_idx += 1

		if not first_new_row:
			first_new_row = new_row

	_editor._show_content_state()
	_editor._save_sheet()

	if first_new_row:
		_editor._on_row_selected(first_new_row)

	print("Pasted %d event(s) from clipboard" % event_dicts.size())


func _build_event_data(dict: Dictionary) -> FKEventBlock:
	var data = FKEventBlock.new("", dict["event_id"], dict["target_node"])
	data.inputs = dict["inputs"].duplicate()
	data.conditions = []
	data.actions = []

	for cond_dict in dict["conditions"]:
		var cond = FKEventCondition.new()
		cond.condition_id = cond_dict["condition_id"]
		cond.target_node = cond_dict["target_node"]
		cond.inputs = cond_dict["inputs"].duplicate()
		cond.negated = cond_dict["negated"]
		data.conditions.append(cond)

	for act_dict in dict["actions"]:
		var act = FKEventAction.new()
		act.action_id = act_dict["action_id"]
		act.target_node = act_dict["target_node"]
		act.inputs = act_dict["inputs"].duplicate()
		data.actions.append(act)

	return data


# ---------------------------------------------------------
# ACTION PASTING
# ---------------------------------------------------------

func _paste_actions_into_branch(action_dicts: Array, branch_item: Node, target_row: Node) -> void:
	var branch_data = branch_item.get_action_data()
	for action_dict in action_dicts:
		var action = FKEventAction.new()
		action.action_id = action_dict["action_id"]
		action.target_node = action_dict["target_node"]
		action.inputs = action_dict["inputs"].duplicate()
		branch_data.branch_actions.append(action)

	target_row.update_display()
	_editor._save_sheet()
	print("Pasted %d action(s) into branch" % action_dicts.size())


func _paste_actions_into_row(action_dicts: Array, target_row: Node) -> void:
	var event_data = target_row.get_event_data()
	for action_dict in action_dicts:
		var action = FKEventAction.new()
		action.action_id = action_dict["action_id"]
		action.target_node = action_dict["target_node"]
		action.inputs = action_dict["inputs"].duplicate()
		event_data.actions.append(action)

	target_row.update_display()
	_editor._save_sheet()
	print("Pasted %d action(s) from clipboard" % action_dicts.size())


# ---------------------------------------------------------
# CONDITION PASTING
# ---------------------------------------------------------

func _paste_conditions_into_row(cond_dicts: Array, target_row: Node) -> void:
	var event_data = target_row.get_event_data()

	for condition_dict in cond_dicts:
		var condition = FKEventCondition.new()
		condition.condition_id = condition_dict["condition_id"]
		condition.target_node = condition_dict["target_node"]
		condition.inputs = condition_dict["inputs"].duplicate()
		condition.negated = condition_dict["negated"]
		condition.actions = []
		event_data.conditions.append(condition)

	target_row.update_display()
	_editor._save_sheet()
	print("Pasted %d condition(s) from clipboard" % cond_dicts.size())


# ---------------------------------------------------------
# GROUP PASTING
# ---------------------------------------------------------

func _paste_group_nested(group_data: FKGroupBlock, target_group: Node) -> void:
	var target_group_data = target_group.get_group_data()
	target_group_data.children.append({"type": "group", "data": group_data})

	if target_group.has_method("_rebuild_child_nodes"):
		target_group._rebuild_child_nodes()

	_editor._save_sheet()
	print("Pasted group as nested group")


func _paste_group_top_level(group_data: FKGroupBlock, selected_row: Node) -> void:
	var group = _block_controller.add_group_block(group_data)

	var insert_idx = _editor.blocks_container.get_child_count()
	if selected_row:
		insert_idx = selected_row.get_index() + 1

	_editor.blocks_container.move_child(group, insert_idx)
	_editor._save_sheet()
	print("Pasted group at top level")
