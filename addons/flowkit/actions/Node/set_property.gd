extends FKAction

func get_id() -> String:
	return "set_property"

func get_name() -> String:
	return "Set Property"

func get_description() -> String:
	return "Sets a property on the node."

func get_inputs() -> Array[FKActionInput]:
	return [_prop_input, _val_input]

static var _prop_input: FKActionInput:
	get:
		return FKActionInput.new("Property", "String")
static var _val_input: FKActionInput:
	get:
		return FKActionInput.new("Value", "Variant")

func get_supported_types() -> Array[String]:
	return ["Node"]

func execute(node: Node, inputs: Dictionary, block_id: String = "") -> void:
	if not node is Node:
		return
	
	var property_name = inputs.get("Property", "")
	var value = inputs.get("Value", null)
	if property_name != "":
		node.set(property_name, value)
