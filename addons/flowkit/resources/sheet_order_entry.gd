extends Resource
class_name FKSheetOrderEntry

# Represents one entry in FKEventSheet.item_order.
# Points to an item by type + index, defining its position in the sheet's display order.

enum Category {
	NULL,
	EVENT,
	COMMENT,
	GROUP
}

@export var type: Category
@export var index: int = -1

func _init(cat: Category = Category.NULL, ind: int = -1) -> void:
	type = cat
	index = ind

static func from_dict(dict: Dictionary) -> FKSheetOrderEntry:
	var raw_type: String = dict.get("type", "")
	var raw_index: int = dict.get("index", -1)

	var enum_type: Category
	
	match raw_type:
		"event":
			enum_type = Category.EVENT
		"comment":
			enum_type = Category.COMMENT
		"group":
			enum_type = Category.GROUP
		_:
			# Unknown type → default to EVENT to avoid load crashes
			enum_type = Category.EVENT

	return FKSheetOrderEntry.new(enum_type, raw_index)

func to_dict() -> Dictionary:
	var category_str := ""

	match type:
		Category.EVENT:
			category_str = "event"
		Category.COMMENT:
			category_str = "comment"
		Category.GROUP:
			category_str = "group"

	return {
		"type": category_str,
		"index": index
	}
