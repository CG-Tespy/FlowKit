@tool
extends RefCounted
class_name FKClipboardManager

var _editor: Node

# Clipboard state
var clipboard_type: String = "" # "event", "action", "condition", "group"
var clipboard_events: Array = []
var clipboard_actions: Array = []
var clipboard_conditions: Array = []
var clipboard_group: Dictionary = {}
const MAX_UNDO_STATES: int = 50  # Maximum number of undo states to keep

func _init(editor: Node) -> void:
	_editor = editor

# ---------------------------------------------------------
# COPY
# ---------------------------------------------------------

func copy_row(row: Node) -> void:
	if not row or not is_instance_valid(row):
		return

	# Copy group
	if row.has_method("get_group_data"):
		var group_data = row.get_group_data()
		if group_data:
			clipboard_type = "group"
			clipboard_group = _editor._serialize_group_block(group_data)
			print("Copied 1 group to clipboard")
		return

	# Copy event row
	if row.has_method("get_event_data"):
		var data = row.get_event_data()
		if data:
			clipboard_type = "event"
			clipboard_events.clear()
			clipboard_events.append({
				"event_id": data.event_id,
				"target_node": data.target_node,
				"inputs": data.inputs.duplicate(),
				"conditions": _duplicate_conditions(data.conditions),
				"actions": _duplicate_actions(data.actions)
			})
			print("Copied %d event(s) to clipboard" % clipboard_events.size())

func copy_item(item: Node) -> void:
	if not item or not is_instance_valid(item):
		return

	# Copy action
	if item.has_method("get_action_data"):
		var action_data = item.get_action_data()
		if action_data:
			clipboard_type = "action"
			clipboard_actions.clear()
			clipboard_actions.append({
				"action_id": action_data.action_id,
				"target_node": action_data.target_node,
				"inputs": action_data.inputs.duplicate()
			})
			print("Copied 1 action to clipboard")
		return

	# Copy condition
	if item.has_method("get_condition_data"):
		var condition_data = item.get_condition_data()
		if condition_data:
			clipboard_type = "condition"
			clipboard_conditions.clear()
			clipboard_conditions.append({
				"condition_id": condition_data.condition_id,
				"target_node": condition_data.target_node,
				"inputs": condition_data.inputs.duplicate(),
				"negated": condition_data.negated
			})
			print("Copied 1 condition to clipboard")
		return

# ---------------------------------------------------------
# PASTE (delegates to editor for actual creation)
# ---------------------------------------------------------

func paste(paste_controller: FKPasteController, selected_row: Node, selected_item: Node) -> void:
	match clipboard_type:
		"event":
			paste_controller.paste_events(clipboard_events, selected_row)
		"action":
			paste_controller.paste_actions(clipboard_actions, selected_row, selected_item)
		"condition":
			paste_controller.paste_conditions(clipboard_conditions, selected_row, selected_item)
		"group":
			paste_controller.paste_group(clipboard_group, selected_row)

# ---------------------------------------------------------
# Helpers (pure data duplication)
# ---------------------------------------------------------

func _duplicate_conditions(conditions: Array) -> Array:
	var result = []
	for cond in conditions:
		result.append({
			"condition_id": cond.condition_id,
			"target_node": cond.target_node,
			"inputs": cond.inputs.duplicate(),
			"negated": cond.negated
		})
	return result


func _duplicate_actions(actions: Array) -> Array:
	var result = []
	for act in actions:
		var act_dict = {
			"action_id": act.action_id,
			"target_node": act.target_node,
			"inputs": act.inputs.duplicate(),
			"is_branch": act.is_branch,
			"branch_type": act.branch_type
		}

		if act.is_branch:
			if act.branch_condition:
				act_dict["branch_condition"] = {
					"condition_id": act.branch_condition.condition_id,
					"target_node": act.branch_condition.target_node,
					"inputs": act.branch_condition.inputs.duplicate(),
					"negated": act.branch_condition.negated
				}
			act_dict["branch_actions"] = _duplicate_actions(act.branch_actions)

		result.append(act_dict)

	return result
