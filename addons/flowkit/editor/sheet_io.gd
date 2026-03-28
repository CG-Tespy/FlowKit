extends RefCounted
class_name FKSheetIO

const SHEET_DIR := "res://addons/flowkit/saved/event_sheet"

func get_sheet_path(scene_uid: int) -> String:
	if scene_uid == 0:
		return ""
	return "%s/%d.tres" % [SHEET_DIR, scene_uid]


func load_sheet(scene_uid: int) -> FKEventSheet:
	var sheet_path := get_sheet_path(scene_uid)
	if sheet_path == "" or not FileAccess.file_exists(sheet_path):
		return null

	var sheet := ResourceLoader.load(sheet_path)
	if sheet is FKEventSheet:
		return sheet

	return null


func save_sheet(scene_uid: int, sheet: FKEventSheet) -> int:
	var sheet_path := get_sheet_path(scene_uid)
	if sheet_path == "":
		return ERR_INVALID_PARAMETER

	DirAccess.make_dir_recursive_absolute(SHEET_DIR)
	return ResourceSaver.save(sheet, sheet_path)


func new_sheet() -> FKEventSheet:
	return FKEventSheet.new()


func copy_event_block(data: FKEventBlock) -> FKEventBlock:
	if data == null:
		return null

	var event_copy := FKEventBlock.new(data.block_id, data.event_id, data.target_node)
	event_copy.inputs = data.inputs.duplicate()
	event_copy.conditions = [] as Array[FKEventCondition]
	event_copy.actions = [] as Array[FKActionBlock]

	for cond in data.conditions:
		var cond_copy := FKEventCondition.new()
		cond_copy.condition_id = cond.condition_id
		cond_copy.target_node = cond.target_node
		cond_copy.inputs = cond.inputs.duplicate()
		cond_copy.negated = cond.negated
		cond_copy.actions = [] as Array[FKActionBlock]
		event_copy.conditions.append(cond_copy)

	for act in data.actions:
		var act_copy := copy_action(act)
		event_copy.actions.append(act_copy)

	return event_copy


func copy_action(act: FKActionBlock) -> FKActionBlock:
	if act == null:
		return null

	var act_copy := FKActionBlock.new()
	act_copy.action_id = act.action_id
	act_copy.target_node = act.target_node
	act_copy.inputs = act.inputs.duplicate()
	act_copy.is_branch = act.is_branch
	act_copy.branch_type = act.branch_type
	act_copy.branch_id = act.branch_id
	act_copy.branch_inputs = act.branch_inputs.duplicate()

	if act.branch_condition:
		var cond_copy := FKEventCondition.new()
		cond_copy.condition_id = act.branch_condition.condition_id
		cond_copy.target_node = act.branch_condition.target_node
		cond_copy.inputs = act.branch_condition.inputs.duplicate()
		cond_copy.negated = act.branch_condition.negated
		cond_copy.actions = [] as Array[FKActionBlock]
		act_copy.branch_condition = cond_copy

	act_copy.branch_actions = [] as Array[FKActionBlock]
	for sub_act in act.branch_actions:
		act_copy.branch_actions.append(copy_action(sub_act))

	return act_copy


func copy_group_block(data: FKGroupBlock) -> FKGroupBlock:
	if data == null:
		return null

	var group_copy := FKGroupBlock.new()
	group_copy.title = data.title
	group_copy.collapsed = data.collapsed
	group_copy.color = data.color
	group_copy.children = []

	for child_dict in data.children:
		var child_type = child_dict.get("type", "")
		var child_data = child_dict.get("data")

		match child_type:
			"event":
				if child_data is FKEventBlock:
					group_copy.children.append({
						"type": "event",
						"data": copy_event_block(child_data)
					})
			"comment":
				if child_data is FKCommentBlock:
					var comment_copy := FKCommentBlock.new()
					comment_copy.text = child_data.text
					group_copy.children.append({
						"type": "comment",
						"data": comment_copy
					})
			"group":
				if child_data is FKGroupBlock:
					group_copy.children.append({
						"type": "group",
						"data": copy_group_block(child_data)
					})

	return group_copy
