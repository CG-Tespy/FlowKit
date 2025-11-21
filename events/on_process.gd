extends FKEvent

func get_id() -> String:
	return "on_process"

func get_name() -> String:
	return "On Process"

func get_supported_types() -> Array[String]:
	return ["Node"]


func poll(node: Node) -> bool:
	if node == null:
		return false

	if node.is_inside_tree():
		return true

	return false
