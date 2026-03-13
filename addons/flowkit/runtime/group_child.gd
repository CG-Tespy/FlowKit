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
	
var type: ChildType
var data: Resource
