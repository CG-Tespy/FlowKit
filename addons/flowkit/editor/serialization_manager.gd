@tool
class_name FKSerializationManager
# Note: we serialize to Dictionaries (instead of Resources) for the sake of the undo/redo
# system. Of course, we _de_serialize to Resources since that's what we most
# want to use in RAM.

# Serialization #
func capture_state(blocks: Array[Node]) -> Array[Dictionary]:
	"""Capture the state of the passed block Nodes as serialized data."""
	#print("FKSerializationManager: blocks gotten: " + str(blocks))
	var state: Array[Dictionary] = []

	for block_el in blocks:
		# Double-check the block is still valid and not queued for deletion
		if not is_instance_valid(block_el) or block_el.is_queued_for_deletion():
			continue
		
		var serialized := serialize_block(block_el)
		state.append(serialized)
			
	return state
	
	
func serialize_block(block_node: Node) -> Dictionary:
	# At the time of this writing, all block node classes except group_ui implement FKUnitui
	var data: FKUnit = null
	if block_node.has_method("_to_string"):
		print("Serializing block node of type " + block_node.get_class())
		
	if block_node is FKUnitUi:
		data = block_node.get_block()
	else:
		printerr("FKSerializationManager serialize_block: Node does not expose block data.")
		return {}

	return data.serialize()


# Deserialization #
func restore_state(state: Array[Dictionary]) -> Array[FKUnit]:
	var result: Array[FKUnit] = []

	for dict in state:
		var block := deserialize_block(dict)
		if block:
			result.append(block)
			
	return result
	
	
func deserialize_block(dict: Dictionary) -> FKUnit:
	var block_type := dict.get("type", "")
	
	print("Deserializing dict with its type being " + block_type)
	var block := _instantiate_block(block_type)
	if block == null:
		printerr("FKSerializationManager deserialize_block: Unknown block type '%s'" % block_type)
		return null

	block.deserialize(dict)
	return block

func _instantiate_block(block_type: String) -> FKUnit:
	match block_type:
		"event":
			return FKEventBlock.new()
		"action": 
			return FKActionUnit.new()
		"comment":
			return FKComment.new()
		"group":
			return FKGroup.new()
		"condition": 
			return FKConditionUnit.new()
		_:
			return null


	
