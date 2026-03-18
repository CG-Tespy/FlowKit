extends Resource
class_name FKGroupEntry

enum Category {
	NULL,
	EVENT,
	COMMENT,
	GROUP
}

func _init(type: Category = Category.NULL, data: Resource = null):
	self.type = type
	self.data = data
	
@export var type: Category
@export var data: Resource

static func from_dict(dict: Dictionary) -> FKGroupEntry:
	var type_str: String = dict.get("type", "")
	var data_res: Resource = dict.get("data")
	var enum_type := FKGroupEntry.Category.EVENT
	
	match type_str:
		"event":
			enum_type = FKGroupEntry.Category.EVENT
		"comment":
			enum_type = FKGroupEntry.Category.COMMENT
		"group":
			enum_type = FKGroupEntry.Category.GROUP

	var fk_child := FKGroupEntry.new(enum_type, data_res)
	return fk_child
