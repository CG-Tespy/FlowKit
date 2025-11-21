extends FKAction

func get_id() -> String:
	return "print"

func get_name() -> String:
	return "Print"

func get_inputs() -> Array[Dictionary]:
	return [
		{"name": "Message", "type": "String"},
	]

func get_supported_types() -> Array[String]:
	return ["Node"]

func execute(node: Node, inputs: Dictionary) -> void:
	var message: String = str(inputs.get("Message", ""))
	
	print("[%s]: %s" % [node.name, message])
