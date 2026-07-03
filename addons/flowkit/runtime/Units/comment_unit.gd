@tool
extends FKUnit
class_name FKComment

@export var text: String = ""

func _init() -> void:
	block_type = "comment"

func serialize() -> Dictionary:
	var result := super.serialize()
	result["text"] = text
	return result

func deserialize(dict: Dictionary) -> void:
	super.deserialize(dict)
	text = dict.get("text", "")
	
func duplicate_block() -> FKUnit:
	var copy := FKComment.new()
	copy.block_type = block_type
	copy.text = text
	return copy

func get_class() -> String:
	return "FKComment"
