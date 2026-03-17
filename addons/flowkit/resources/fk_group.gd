@tool
extends Resource
class_name FKGroupBlock
## A group container for organizing events, comments, and nested groups in FlowKit.
##
## Groups provide visual organization and can be collapsed/expanded.
## Children are stored as dictionaries with "type" and "data" keys.

@export var title: String = "Group"
@export var collapsed: bool = false
@export var color: Color = Color(0.25, 0.22, 0.35, 1.0)

## Child items stored as: [{"type": "event"|"comment"|"group", "data": Resource}, ...]
@export var children: Array = []


func add_child_item(type: String, data: Resource) -> void:
	"""Add a child item to this group."""
	children.append({"type": type, "data": data})


func remove_child_at(index: int) -> void:
	"""Remove child at the specified index."""
	if index >= 0 and index < children.size():
		children.remove_at(index)


func get_child_count() -> int:
	"""Get the number of children in this group."""
	return children.size()


func get_child_type(index: int) -> String:
	if index >= 0 and index < children.size():
		var child = children[index]
		if child is FKGroupChild:
			return FKGroupChild.ChildType.keys()[child.type].to_lower()
		elif child is Dictionary:
			return child.get("type", "")
	return ""



func get_child_data(index: int) -> Resource:
	if index >= 0 and index < children.size():
		var child = children[index]
		if child is FKGroupChild:
			return child.data
		elif child is Dictionary:
			return child.get("data")
	return null

func find_child_index(data: Resource) -> int:
	"""Find the index of a child by its data resource."""
	for i in range(children.size()):
		if children[i].get("data") == data:
			return i
	return -1

func copy_deep() -> FKGroupBlock:
	"""Create a deep copy of this group and all its children."""
	var copy = FKGroupBlock.new()
	copy.title = title
	copy.collapsed = collapsed
	copy.color = color
	copy.children = []
	var as_group_children : Array[FKGroupChild] = children as Array[FKGroupChild]
	for child_dict in as_group_children:
		if child_dict is FKGroupChild:
			var child_type := child_dict.type
			var child_data := child_dict.data
			
			if child_data and child_data.has_method("duplicate"):
				var child_copy = child_data.duplicate()
				# Deep copy for nested groups
				if child_type == FKGroupChild.ChildType.GROUP and child_data is FKGroupBlock:
					child_copy = child_data.copy_deep()
				
				var new_child := FKGroupChild.new(child_type, child_copy)
				copy.children.append(new_child)
	
	return copy

var normalized_children: Array[FKGroupChild] = []

func exec_child_normalization() -> void:
	if self.children_are_normalized:
		return
		
	var new_children: Array = []

	for child in self.children:
		var fk_child: FKGroupChild
		if child is FKGroupChild:
			fk_child = child
		elif child is Dictionary:
			fk_child = FKGroupChild.from_dict(child)
			
		new_children.append(fk_child)
	
	self.children = new_children
	
	# Recurse into nested groups
	for child in self.children:
		if child is FKGroupChild and child.type == FKGroupChild.ChildType.GROUP and \
		child.data is FKGroupBlock:
			var group_block: FKGroupBlock = child.data as FKGroupBlock
			group_block.exec_child_normalization()
		
		self.normalized_children.append(child)
	
	self.children_are_normalized = true

@export var children_are_normalized := false
