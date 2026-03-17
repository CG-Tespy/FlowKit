extends Resource
class_name FKGroupChild

enum ChildType {
	NULL,
	EVENT,
	COMMENT,
	GROUP
}

func _init(type: ChildType = ChildType.NULL, data: Resource = null):
	self.type = type
	self.data = data
	
@export var type: ChildType
@export var data: Resource

static func from_dict(dict: Dictionary) -> FKGroupChild:
	var type_str: String = dict.get("type", "")
	var data_res: Resource = dict.get("data")

	var enum_type := FKGroupChild.ChildType.EVENT
	match type_str:
		"event":
			enum_type = FKGroupChild.ChildType.EVENT
		"comment":
			enum_type = FKGroupChild.ChildType.COMMENT
		"group":
			enum_type = FKGroupChild.ChildType.GROUP

	var fk_child := FKGroupChild.new(enum_type, data_res)
	return fk_child
