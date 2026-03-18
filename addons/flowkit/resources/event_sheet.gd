extends Resource
class_name FKEventSheet
## The main event sheet resource that stores all events, comments, and groups for a scene.
##
## The item_order array maintains the visual ordering of all items in the editor.
## Each entry is: {"type": "event"|"comment"|"group", "index": int}
## The index refers to the position within that type's array (events, comments, or groups).

@export var events: Array[FKEventBlock] = []
@export var standalone_conditions: Array[FKEventCondition] = []
@export var comments: Array[FKCommentBlock] = []
@export var groups: Array[FKGroupBlock] = []

## Stores the display order: [{"type": "event"|"comment"|"group", "index": int}, ...]
@export var item_order: Array = []
var normalized_item_order: Array[FKSheetOrderEntry] = []
@export var item_order_is_normalized := false


func on_loaded():
	normalize_group_children()
	normalize_item_order()
	
func normalize_group_children():
	for group in self.groups:
		_normalize_group_recursive(group)

func _normalize_group_recursive(group: FKGroupBlock):
	group.exec_child_normalization()

	for child in group.children:
		if child is FKGroupEntry and child.type == FKGroupEntry.Category.GROUP:
			_normalize_group_recursive(child.data)
			
func normalize_item_order() -> void:
	if item_order_is_normalized:
		return

	var new_entries: Array[FKSheetOrderEntry] = []

	for entry in item_order:
		var typed := _get_as_order_entry(entry)
		new_entries.append(typed)
	
	_set_item_order_cache(new_entries)
	item_order_is_normalized = true

func _get_as_order_entry(item) -> FKSheetOrderEntry:
	var result: FKSheetOrderEntry = null
	
	if item is FKSheetOrderEntry:
		result = item
	else: # Assume Dictionary
		result = FKSheetOrderEntry.from_dict(item)
		
	return result

func _set_item_order_cache(new_entries: Array[FKSheetOrderEntry]):
	item_order.clear()
	normalized_item_order.clear()
	item_order.append_array(new_entries)
	normalized_item_order.append_array(new_entries)
	
func get_all_events() -> Array:
	var events := []
	events.append_array(self.events)
	normalize_group_children()
	normalize_item_order()
	_collect_events_from_groups(self.groups, events)
	return events


func _collect_events_from_groups(groups: Array, out_events: Array) -> void:
	for group in groups:
		if group is not FKGroupBlock:
			continue
			
		if (group.children_are_normalized):
			if group.children.size() > 0 && group.children[0] is not FKGroupEntry:
				printerr("Main group children array should be normalized, but it ain't")
			_collect_events_from_group_children(group.normalized_children, out_events)
		else:
			printerr("The group children aren't normalized even though they should")
		

func _collect_events_from_group_children(group_children: Array[FKGroupEntry], out_events: Array):
	for child_item in group_children:
		var child_type := ""
		var enum_type := child_item.type
		var child_data = child_item.data
		
		if enum_type == FKGroupEntry.Category.EVENT && child_data is FKEventBlock:
			out_events.append(child_data)
		elif enum_type == FKGroupEntry.Category.GROUP && child_data is FKGroupBlock:
			_collect_events_from_groups([child_data], out_events)

func get_ordered_items() -> Array:
	"""Get all items in display order as an array of dictionaries with type and data."""
	var items = []
	
	for entry in normalized_item_order:
		
		var data = null
			
		match entry.type:
			
			FKSheetOrderEntry.Category.EVENT:
				if entry.index < events.size():
					data = events[entry.index]
			FKSheetOrderEntry.Category.COMMENT:
				if entry.index < comments.size():
					data = comments[entry.index]
			FKSheetOrderEntry.Category.GROUP:
				if entry.index < groups.size():
					data = groups[entry.index]
		
		if data:
			var type_str := ""
			match entry.type:
				FKSheetOrderEntry.Category.EVENT:
					type_str = "event"
				FKSheetOrderEntry.Category.COMMENT:
					type_str = "comment"
				FKSheetOrderEntry.Category.GROUP:
					type_str = "group"
		
			var old_format_item = {
				"type": type_str,
				"data": data
			}
			items.append(old_format_item)
	
	return items


func rebuild_order_from_items(ordered_items: Array) -> void:
	"""Rebuild the events, comments, groups arrays and item_order from an ordered list."""
	events = [] as Array[FKEventBlock]
	comments = [] as Array[FKCommentBlock]
	groups = [] as Array[FKGroupBlock]
	item_order.clear()
	normalized_item_order.clear()
	item_order_is_normalized = true

	for item in ordered_items:
		var item_type: String = item.get("type", "")
		var data: Variant = item.get("data")

		match item_type:
			"event":
				if data is FKEventBlock:
					var idx := events.size()
					events.append(data)

					var entry := FKSheetOrderEntry.new(
						FKSheetOrderEntry.Category.EVENT,
						idx
					)

					normalized_item_order.append(entry)
					item_order.append(entry.to_dict())

			"comment":
				if data is FKCommentBlock:
					var idx := comments.size()
					comments.append(data)

					var entry := FKSheetOrderEntry.new(FKSheetOrderEntry.Category.COMMENT,
						idx)

					normalized_item_order.append(entry)
					item_order.append(entry.to_dict())

			"group":
				if data is FKGroupBlock:
					var idx := groups.size()
					groups.append(data)

					var entry := FKSheetOrderEntry.new(FKSheetOrderEntry.Category.GROUP,
						idx)

					normalized_item_order.append(entry)
					item_order.append(entry.to_dict())

func _rebuild_order_from_typed_items(ordered_items: FKSheetOrderEntry):
	pass
