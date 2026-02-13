extends FKAction

func get_inputs() -> Array:
	return [
		{
			"name": "New Text",
			"type": "String",
			"description": "The text that the target will hold."
		},
	]
	
func get_supported_types() -> Array:
	return ["Label", "RichTextLabel", "Button"]

func execute(target_node: Node, inputs: Dictionary, _str := "") -> void:
	var new_text = inputs.get("New Text", "")
	var has_text = target_node
	has_text.text = new_text
