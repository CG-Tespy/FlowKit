@tool
extends FKUnit
class_name FKGroup
## A group container for organizing events, comments, and nested groups in FlowKit.
##
## Groups provide visual organization and can be collapsed/expanded.
## Children used to be stored as dictionaries with "type" and "data" keys.
## Now, they are stored as FKUnit subresources.

@export var title: String = "Group"
@export var collapsed: bool = false
@export var color: Color = Color(0.25, 0.22, 0.35, 1.0)

## Child items stored as: [{"type": "event"|"comment"|"group", "data": Resource}, ...]
@export var children: Array = []

func _init() -> void:
	block_type = "group"


func add_child_item(type: String, data: FKUnit) -> void:
	children.append({"type": type, "data": data})


func remove_child_at(index: int) -> void:
	var valid_index: bool = index >= 0 and index < children.size()
	if valid_index:
		children.remove_at(index)


func get_child_count() -> int:
	return children.size()


func get_child_type(index: int) -> String:
	var valid_index: bool = index >= 0 and index < children.size()
	if valid_index:
		return children[index].get("type", "")
	return ""


func get_child_data(index: int) -> FKUnit:
	var valid_index: bool = index >= 0 and index < children.size()
	if valid_index:
		return children[index].get("data")
	return null


func find_child_index(data: FKUnit) -> int:
	for i in range(children.size()):
		if children[i].get("data") == data:
			return i
	return -1


func serialize() -> Dictionary:
	var result := {
		"type": block_type,
		"title": title,
		"collapsed": collapsed,
		"color": color,
		"children": _get_serialized_children(self)
	}
	
	return result

static func _get_serialized_children(block: FKGroup) -> Array:
	var result: Array = []
	
	for child in block.children:
		var unit: FKUnit = null
		
		if child is Dictionary:
			unit = child.get("data")
		else:
			unit = child

		if unit:
			var serialized = unit.serialize()
			result.append(serialized)
			
	return result
	
func deserialize(dict: Dictionary) -> void:
	title = dict.get("title", "Group")
	collapsed = dict.get("collapsed", false)
	color = dict.get("color", Color(0.25, 0.22, 0.35, 1.0))

	children = []
	for child_dict in dict.get("children", []):
		var child_block := FKSerializationManager.new().deserialize_block(child_dict)
		if child_block:
			children.append({
				"type": child_block.block_type,
				"data": child_block
			})
			
	normalize_children()

func normalize_children() -> void:
	if _is_normalized:
		return
		
	var normalized: Array = []

	for child in children:
		var unit: FKUnit = null
		if child is Dictionary:
			var data: FKUnit = child.get("data")
			if data is FKUnit:
				unit = data
		elif child is FKUnit:
			unit = child
			
		if unit:
			normalized.append(unit)

	children.clear()
	children.append_array(normalized)
	_is_normalized = true

var _is_normalized := false

func copy_deep() -> FKGroup:
	"""Create a deep copy of this group and all its children."""
	var copy = FKGroup.new()
	copy.title = title
	copy.collapsed = collapsed
	copy.color = color
	
	# We don't have a guarantee that all our children are FKUnits, so we have to inspect
	# each element carefully.
	for child in children:
		if child is FKUnit:
			copy.children.append(child)
		elif child is Dictionary:
			var child_data: FKUnit = child.get("data")
			copy.children.append(child_data)
			
	copy.normalize_children()
	
	return copy
	
func duplicate_block() -> FKGroup:
	var copy := FKGroup.new()
	copy.block_type = block_type
	copy.title = title
	copy.collapsed = collapsed
	copy.color = color

	copy.children = []

	for child in children:
		var unit: FKUnit = null
		# Legacy format: { "type": String, "data": FKUnit }
		if child is Dictionary:
			unit = child.get("data")
		else:
			unit = child

		if unit != null:
			var unit_copy := unit.duplicate_block()
			copy.children.append(unit_copy)

	return copy

func get_class() -> String:
	return "FKGroup"
