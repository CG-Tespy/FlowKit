@tool
extends RefCounted
class_name FKEventSheetSerializer

# ---------------------------------------------------------
# PUBLIC API
# ---------------------------------------------------------

func serialize_blocks(blocks: Array) -> Array:
	var result: Array = []
	for block in blocks:
		if not is_instance_valid(block) or block.is_queued_for_deletion():
			continue

		if block.has_method("get_event_data"):
			var data = block.get_event_data()
			if data:
				result.append(_serialize_event_block(data))

		elif block.has_method("get_comment_data"):
			var data = block.get_comment_data()
			if data:
				result.append(_serialize_comment_block(data))

		elif block.has_method("get_group_data"):
			var data = block.get_group_data()
			if data:
				result.append(_serialize_group_block(data))

	return result


func deserialize_blocks(state: Array) -> Array:
	var result: Array = []
	for item_dict in state:
		var item_type = item_dict.get("type", "event")

		match item_type:
			"comment":
				result.append(_deserialize_comment_block(item_dict))

			"group":
				result.append(_deserialize_group_block(item_dict))

			"event":
				result.append(_deserialize_event_block(item_dict))

	return result


# ---------------------------------------------------------
# SERIALIZATION
# ---------------------------------------------------------

func _serialize_comment_block(data: FKCommentBlock) -> Dictionary:
	return {
		"type": "comment",
		"text": data.text
	}


func _serialize_event_block(data: FKEventBlock) -> Dictionary:
	var result = {
		"type": "event",
		"block_id": data.block_id,
		"event_id": data.event_id,
		"target_node": str(data.target_node),
		"inputs": data.inputs.duplicate(),
		"conditions": [],
		"actions": []
	}

	for cond in data.conditions:
		result["conditions"].append({
			"condition_id": cond.condition_id,
			"target_node": str(cond.target_node),
			"inputs": cond.inputs.duplicate(),
			"negated": cond.negated
		})

	for act in data.actions:
		result["actions"].append(_serialize_action(act))

	return result


func _serialize_action(act: FKEventAction) -> Dictionary:
	var act_dict = {
		"action_id": act.action_id,
		"target_node": str(act.target_node),
		"inputs": act.inputs.duplicate(),
		"is_branch": act.is_branch,
		"branch_type": act.branch_type
	}

	if act.is_branch:
		if act.branch_condition:
			act_dict["branch_condition"] = {
				"condition_id": act.branch_condition.condition_id,
				"target_node": str(act.branch_condition.target_node),
				"inputs": act.branch_condition.inputs.duplicate(),
				"negated": act.branch_condition.negated
			}

		act_dict["branch_actions"] = []
		for sub_act in act.branch_actions:
			act_dict["branch_actions"].append(_serialize_action(sub_act))

	return act_dict


func _serialize_group_block(data: FKGroupBlock) -> Dictionary:
	var result = {
		"type": "group",
		"title": data.title,
		"collapsed": data.collapsed,
		"color": data.color,
		"children": []
	}

	for child_dict in data.children:
		var child_type = child_dict.get("type", "")
		var child_data = child_dict.get("data")

		match child_type:
			"event":
				result["children"].append(_serialize_event_block(child_data))
			"comment":
				result["children"].append(_serialize_comment_block(child_data))
			"group":
				result["children"].append(_serialize_group_block(child_data))

	return result


# ---------------------------------------------------------
# DESERIALIZATION
# ---------------------------------------------------------

func _deserialize_comment_block(dict: Dictionary) -> FKCommentBlock:
	var data = FKCommentBlock.new()
	data.text = dict.get("text", "")
	return data


func _deserialize_event_block(dict: Dictionary) -> FKEventBlock:
	var block_id = dict.get("block_id", "")
	var event_id = dict.get("event_id", "")
	var target_node = NodePath(dict.get("target_node", ""))

	var data = FKEventBlock.new(block_id, event_id, target_node)
	data.inputs = dict.get("inputs", {}).duplicate()

	data.conditions = [] as Array[FKEventCondition]
	for cond_dict in dict.get("conditions", []):
		var cond = FKEventCondition.new()
		cond.condition_id = cond_dict.get("condition_id", "")
		cond.target_node = NodePath(cond_dict.get("target_node", ""))
		cond.inputs = cond_dict.get("inputs", {}).duplicate()
		cond.negated = cond_dict.get("negated", false)
		cond.actions = [] as Array[FKEventAction]
		data.conditions.append(cond)

	data.actions = [] as Array[FKEventAction]
	for act_dict in dict.get("actions", []):
		data.actions.append(_deserialize_action(act_dict))

	return data


func _deserialize_action(act_dict: Dictionary) -> FKEventAction:
	var act = FKEventAction.new()
	act.action_id = act_dict.get("action_id", "")
	act.target_node = NodePath(act_dict.get("target_node", ""))
	act.inputs = act_dict.get("inputs", {}).duplicate()
	act.is_branch = act_dict.get("is_branch", false)
	act.branch_type = act_dict.get("branch_type", "")

	if act.is_branch:
		var cond_dict = act_dict.get("branch_condition", null)
		if cond_dict:
			var cond = FKEventCondition.new()
			cond.condition_id = cond_dict.get("condition_id", "")
			cond.target_node = NodePath(cond_dict.get("target_node", ""))
			cond.inputs = cond_dict.get("inputs", {}).duplicate()
			cond.negated = cond_dict.get("negated", false)
			cond.actions = [] as Array[FKEventAction]
			act.branch_condition = cond

		act.branch_actions = [] as Array[FKEventAction]
		for sub_dict in act_dict.get("branch_actions", []):
			act.branch_actions.append(_deserialize_action(sub_dict))

	return act


func _deserialize_group_block(dict: Dictionary) -> FKGroupBlock:
	var data = FKGroupBlock.new()
	data.title = dict.get("title", "Group")
	data.collapsed = dict.get("collapsed", false)
	data.color = dict.get("color", Color(0.25, 0.22, 0.35, 1.0))
	data.children = []

	for child_dict in dict.get("children", []):
		var child_type = child_dict.get("type", "event")

		match child_type:
			"event":
				data.children.append({"type": "event", "data": _deserialize_event_block(child_dict)})
			"comment":
				data.children.append({"type": "comment", "data": _deserialize_comment_block(child_dict)})
			"group":
				data.children.append({"type": "group", "data": _deserialize_group_block(child_dict)})

	return data
