extends FKEvent

func get_description() -> String:
	return "Triggers when the specified key or input action was just pressed."

func get_id() -> String:
	return "on_action_pressed"

func get_name() -> String:
	return "On Action Pressed"

func get_supported_types() -> Array[String]:
	return ["System"]

func get_inputs() -> Array:
	return [
		{"name": "key", "type": "string", "description": "The name of the key (defined in InputMap)"}
	]

func poll(node: Node, inputs: Dictionary = {}, block_id: String = "") -> bool:
	if not node or not node.is_inside_tree():
		return false
	
	# Check if any action in the InputMap is currently pressed
	for action in InputMap.get_actions():
		if Input.is_action_just_pressed(action):
			return true
	
	return false
