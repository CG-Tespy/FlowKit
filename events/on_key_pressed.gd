extends FKEvent

func get_id() -> String:
	return "on_key_pressed"

func get_name() -> String:
	return "On Key Pressed"

func get_supported_types() -> Array[String]:
	return ["Node"]

func poll(node: Node) -> bool:
	if node == null:
		return false

	if not node.is_inside_tree():
		return false
	
	# Check if any action in the InputMap is currently pressed
	for action in InputMap.get_actions():
		if Input.is_action_pressed(action):
			return true
	
	return false
