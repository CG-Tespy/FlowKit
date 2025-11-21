extends FKCondition

func get_id() -> String:
	return "get_key_down"

func get_name() -> String:
	return "Get Key Down"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "Action", "type": "String"},
	]

func get_supported_types() -> Array[String]:
	return ["Node"]

func check(node: Node, inputs: Dictionary) -> bool:
	var action: String = str(inputs.get("Action", ""))
	if action.is_empty():
		return false
	
	return Input.is_action_pressed(action)
