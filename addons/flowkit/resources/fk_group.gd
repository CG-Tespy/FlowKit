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
var normalized_children: Array[FKGroupEntry] = []
# ^For the sake of backwards compatibility, we have two separate arrays of 
# different types (yet basically the same contents)

## The old func for adding child items. Best use the typed version instead.
func add_child_item(type: String, data: Resource) -> void:
	"""Add a child item to this group."""
	var dict_child := {"type": type, "data": data}
	var typed_child := FKGroupEntry.from_dict(dict_child)
	add_typed_child_item(typed_child)


func add_typed_child_item(to_add: FKGroupEntry) -> void:
	children.append(to_add)
	normalized_children.append(to_add)

	
func remove_child_at(index: int) -> void:
	"""Remove child at the specified index."""
	var valid_index: bool = index >= 0 and index < children.size()
	if valid_index:
		children.remove_at(index)


func get_child_count() -> int:
	"""Get the number of children in this group."""
	return children.size()


func get_child_type(index: int) -> String:
	var result := ""
	var valid_index: bool = index >= 0 and index < children.size()
	
	if valid_index:
		var child = children[index]
		if child is not FKGroupEntry:
			_print_children_non_normalized_error("get_child_type")
		else:
			result = FKGroupEntry.Category.keys()[child.type].to_lower()
			
	return result

func _print_children_non_normalized_error(caller_func_name: String):
	var message_template := "FKGroupBlock %s: children not all " \
			+ "normalized even though they should"
	var error_message := message_template % [caller_func_name]
	printerr(error_message)

func get_child_data(index: int) -> Resource:
	var result: Resource = null
	var valid_index: bool = index >= 0 and index < children.size()
	
	if valid_index:
		var child = children[index]
		if child is not FKGroupEntry:
			_print_children_non_normalized_error("get_child_data")
		else:
			result = child.data
			
	return result

func find_child_index(data: Resource) -> int:
	"""Find the index of a child by its data resource."""
	var result: int = -1
	
	for i in range(children.size()):
		var current_child = children[i]
		if current_child is not FKGroupEntry:
			_print_children_non_normalized_error("find_child_index")
			
		var typed_child := normalized_children[i]
		if typed_child.data == data:
			result = i
			break
			
	return result

func copy_deep() -> FKGroupBlock:
	"""Create a deep copy of this group and all its children."""
	var result = FKGroupBlock.new()
	result.title = title
	result.collapsed = collapsed
	result.color = color
	result.children = []
	
	for child in normalized_children:
		var data_copy: Resource = null
		
		if child.data:
			var data_is_nested_group: bool = child.type == FKGroupEntry.Category.GROUP and \
			child.data is FKGroupBlock

			if data_is_nested_group:
				data_copy = child.data.copy_deep()
			else:
				data_copy = child.data.duplicate()
			
			var new_child := FKGroupEntry.new(child.type, data_copy)
			result.add_typed_child_item(new_child)
	
	return result


func exec_child_normalization() -> void:
	if self.children_are_normalized:
		return
		
	var new_children: Array = []

	for child in self.children:
		var fk_child: FKGroupEntry
		if child is FKGroupEntry:
			fk_child = child
		elif child is Dictionary:
			fk_child = FKGroupEntry.from_dict(child)
			
		new_children.append(fk_child)
	
	self.children = new_children
	
	# Recurse into nested groups
	for child in self.children:
		if child is FKGroupEntry and child.type == FKGroupEntry.Category.GROUP and \
		child.data is FKGroupBlock:
			var group_block: FKGroupBlock = child.data as FKGroupBlock
			group_block.exec_child_normalization()
		
		self.normalized_children.append(child)
	
	self.children_are_normalized = true

@export var children_are_normalized := false
