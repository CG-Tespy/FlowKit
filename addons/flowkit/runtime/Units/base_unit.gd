@tool
extends Resource
class_name FKUnit

const INVALID_ID := 0

@export var block_type: String = ""   # "event", "comment", "group": 

## This is meant to be relative to the Event Sheet it belongs to, as opposed
## to being globally exclusive.
@export var personal_id: int = INVALID_ID:
	set(value):
		if personal_id == null: # This is expected after reading older FKUnits from disk
			personal_id = INVALID_ID

		if value < INVALID_ID:
			print("[FKUnit] I was passed a negative personal_id. It may be a sign of an "+\
			"issue elsewhere.")
			personal_id = INVALID_ID
			return

		personal_id = value
	get:
		return personal_id

# Editor-friendly name for menus, debugging, etc.
func get_display_name() -> String:
	return block_type.capitalize()

# Subclasses override this to return a Dictionary representation.
func serialize() -> Dictionary:
	print("Serializing an FKUnit")
	var result: Dictionary = {
		"type": block_type,
		"personal_id": personal_id
	}
	return result

## Subclasses override this to populate themselves from a Dictionary.
func deserialize(dict: Dictionary) -> void:
	print("Deserializing fk unit base")
	personal_id = dict.get("personal_id")

# Deep-copy contract for undo/redo and clipboard.
func duplicate_block() -> FKUnit:
	print("Duplicating an fkunit")
	var copy := self.duplicate(true)
	return copy
	
func get_id() -> String:
	return ""

static func _duplicate_blocks(to_duplicate: Array[FKUnit]) -> Array[FKUnit]:
	var result: Array[FKUnit] = []
	for elem in to_duplicate:
		if elem:
			var elem_copy := elem.duplicate_block()
			result.append(elem)
	return result

static func _to_base_unit_arr(arr: Array) -> Array[FKUnit]:
	var result: Array[FKUnit] = []
	
	for child in arr:
		if child is FKUnit:
			result.append(child)
			
	return result

func get_class() -> String:
	return "FKUnit"

func _to_string() -> String:
	var self_serialized: Dictionary = self.serialize()
	var result = "(" + self.get_display_name() + ")" + "\n" + JSON.stringify(self_serialized, "\t")
	return result