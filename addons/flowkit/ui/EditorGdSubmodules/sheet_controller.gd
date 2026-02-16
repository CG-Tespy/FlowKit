@tool
extends RefCounted
class_name FKSheetController

var editor: Node
var serializer: FKEventSheetSerializer
var block_controller: FKBlockController

var current_scene_uid: int = 0
var sheet: FKEventSheet
var sheet_path: String

func _init(editor_ref: Node, serializer_ref: FKEventSheetSerializer, block_ctrl: FKBlockController) -> void:
	editor = editor_ref
	serializer = serializer_ref
	block_controller = block_ctrl

# ---------------------------------------------------------
# PUBLIC API
# ---------------------------------------------------------

func update_scene_state(editor_interface: EditorInterface) -> void:
	var scene_root = editor_interface.get_edited_scene_root()
	if not scene_root:
		_reset()
		return

	var scene_path = scene_root.scene_file_path
	if scene_path == "":
		_reset()
		return

	var uid = ResourceLoader.get_resource_uid(scene_path)
	if uid != current_scene_uid:
		current_scene_uid = uid
		load_sheet_for_current_scene()

func load_sheet_for_current_scene() -> void:
	block_controller.clear_all()

	sheet_path = _get_sheet_path()
	if sheet_path == "" or not FileAccess.file_exists(sheet_path):
		sheet = null
		editor._show_empty_blocks_state()
		return

	sheet = ResourceLoader.load(sheet_path, "FKEventSheet", ResourceLoader.CACHE_MODE_IGNORE)
	if not (sheet is FKEventSheet):
		sheet = null
		editor._show_empty_blocks_state()
		return

	_populate_blocks_from_sheet(sheet)
	editor._show_content_state()

func save_sheet_from_blocks() -> void:
	if current_scene_uid == 0:
		print_rich("[color=yellow][FlowKit] No scene open to save event sheet.[/color]")
		return

	sheet = _generate_sheet_from_blocks()
	DirAccess.make_dir_recursive_absolute(_event_sheet_folder_path)
	var error = ResourceSaver.save(sheet, sheet_path)
	if error != OK:
		printerr("Failed to save event sheet: " + str(error))
	else:
		print("✓ Event sheet saved: ", sheet_path)

var _event_sheet_folder_path := "res://addons/flowkit/saved/event_sheet"

func reload_sheet() -> void:
	save_sheet_from_blocks()
	load_sheet_for_current_scene()

func new_sheet() -> void:
	if current_scene_uid == 0:
		print_rich("[color=yellow][FlowKit]No scene open to create event sheet.[/color]")
		return

	block_controller.clear_all()
	editor._show_content_state()

# ---------------------------------------------------------
# INTERNAL HELPERS
# ---------------------------------------------------------

func _reset() -> void:
	current_scene_uid = 0
	block_controller.clear_all()
	editor._clear_undo_history()
	editor._show_empty_state()

func _get_sheet_path() -> String:
	if current_scene_uid == 0:
		return ""
	return _sheet_path_format % current_scene_uid

var _sheet_path_format := "res://addons/flowkit/saved/event_sheet/%d.tres"

func _populate_blocks_from_sheet(sheet: FKEventSheet) -> void:
	if sheet.item_order.size() > 0:
		for item in sheet.item_order:
			var type = item.get("type", "")
			var index = item.get("index", 0)

			match type:
				"event":
					if index < sheet.events.size():
						block_controller.add_event_block(sheet.events[index])
				"comment":
					if index < sheet.comments.size():
						block_controller.add_comment_block(sheet.comments[index])
				"group":
					if index < sheet.groups.size():
						block_controller.add_group_block(sheet.groups[index])
	else:
		for event_data in sheet.events:
			block_controller.add_event_block(event_data)

func _generate_sheet_from_blocks() -> FKEventSheet:
	var sheet = FKEventSheet.new()

	var events: Array[FKEventBlock] = []
	var comments: Array[FKCommentBlock] = []
	var groups: Array[FKGroupBlock] = []
	var item_order: Array[Dictionary] = []

	for block in block_controller.get_blocks():
		if not is_instance_valid(block) or block.is_queued_for_deletion():
			continue

		if block.has_method("get_event_data"):
			var data = block.get_event_data()
			if data:
				item_order.append({"type": "event", "index": events.size()})
				events.append(_copy_event_block(data))

		elif block.has_method("get_comment_data"):
			var data = block.get_comment_data()
			if data:
				var c = FKCommentBlock.new()
				c.text = data.text
				item_order.append({"type": "comment", "index": comments.size()})
				comments.append(c)

		elif block.has_method("get_group_data"):
			var data = block.get_group_data()
			if data:
				item_order.append({"type": "group", "index": groups.size()})
				groups.append(_copy_group_block(data))

	sheet.events = events
	sheet.comments = comments
	sheet.groups = groups
	sheet.item_order = item_order
	sheet.standalone_conditions.clear()

	return sheet

func _copy_event_block(data: FKEventBlock) -> FKEventBlock:
	var e = FKEventBlock.new(data.block_id, data.event_id, data.target_node)
	e.inputs = data.inputs.duplicate()
	e.conditions = [] as Array[FKEventCondition]
	e.actions = [] as Array[FKEventAction]

	for cond in data.conditions:
		var c = FKEventCondition.new()
		c.condition_id = cond.condition_id
		c.target_node = cond.target_node
		c.inputs = cond.inputs.duplicate()
		c.negated = cond.negated
		c.actions = [] as Array[FKEventAction]
		e.conditions.append(c)

	for act in data.actions:
		e.actions.append(_copy_action(act))

	return e

func _copy_action(act: FKEventAction) -> FKEventAction:
	var a = FKEventAction.new()
	a.action_id = act.action_id
	a.target_node = act.target_node
	a.inputs = act.inputs.duplicate()
	a.is_branch = act.is_branch
	a.branch_type = act.branch_type

	if act.branch_condition:
		var bc = FKEventCondition.new()
		bc.condition_id = act.branch_condition.condition_id
		bc.target_node = act.branch_condition.target_node
		bc.inputs = act.branch_condition.inputs.duplicate()
		bc.negated = act.branch_condition.negated
		bc.actions = [] as Array[FKEventAction]
		a.branch_condition = bc

	a.branch_actions = [] as Array[FKEventAction]
	for sub in act.branch_actions:
		a.branch_actions.append(_copy_action(sub))

	return a

func _copy_group_block(data: FKGroupBlock) -> FKGroupBlock:
	var g = FKGroupBlock.new()
	g.title = data.title
	g.collapsed = data.collapsed
	g.color = data.color
	g.children = []

	for child in data.children:
		var type = child.get("type", "")
		var d = child.get("data")

		match type:
			"event":
				g.children.append({"type": "event", "data": _copy_event_block(d)})
			"comment":
				var c = FKCommentBlock.new()
				c.text = d.text
				g.children.append({"type": "comment", "data": c})
			"group":
				g.children.append({"type": "group", "data": _copy_group_block(d)})

	return g
