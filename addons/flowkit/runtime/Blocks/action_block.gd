extends FKBaseBlock
class_name FKActionBlock

@export var action_id: String = ""
@export var target_node: NodePath
@export var inputs: Dictionary = {}

# Branch support
@export var is_branch: bool = false
@export var branch_type: String = ""              # "if", "elseif", "else", etc.
@export var branch_id: String = ""                # Branch provider ID
@export var branch_condition: FKEventCondition = null
@export var branch_inputs: Dictionary = {}
@export var branch_actions: Array[FKActionBlock] = []

func _init() -> void:
	block_type = "action"

func serialize() -> Dictionary:
	var result := {
		"type": block_type,
		"action_id": action_id,
		"target_node": str(target_node),
		"inputs": inputs.duplicate(),
		"is_branch": is_branch,
		"branch_type": branch_type,
		"branch_id": branch_id,
		"branch_inputs": branch_inputs.duplicate()
	}

	_serialize_branch_conds_and_actions(result)

	return result

func _serialize_branch_conds_and_actions(result: Dictionary):
	if is_branch and branch_condition != null:
		result["branch_condition"] = branch_condition.serialize()

		var copied_actions: Array = []
		for act in branch_actions:
			var copy := act.serialize()
			copied_actions.append(copy)
			
		result["branch_actions"] = copied_actions
		
func deserialize(dict: Dictionary) -> void:
	action_id = dict.get("action_id", "")
	target_node = NodePath(dict.get("target_node", ""))
	inputs = dict.get("inputs", {}).duplicate()
	
	is_branch = dict.get("is_branch", false)
	branch_type = dict.get("branch_type", "")
	branch_id = dict.get("branch_id", "")
	branch_inputs = dict.get("branch_inputs", {}).duplicate()

	_deserialize_branch_conds_and_actions(dict)

func _deserialize_branch_conds_and_actions(dict: Dictionary):
	branch_condition = null
	
	if dict.has("branch_condition"):
		var cond := FKEventCondition.new()
		cond.deserialize(dict["branch_condition"])
		branch_condition = cond

	branch_actions.clear()
	for act_dict in dict.get("branch_actions", []):
		var act := FKActionBlock.new()
		act.deserialize(act_dict)
		branch_actions.append(act)
	
func get_id() -> String:
	return action_id
