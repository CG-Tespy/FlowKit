extends RefCounted

class_name FKActionInput

func _init(init_name: String = "", init_type: String = "", init_desc: String = ""):
	name = init_name
	type = init_type
	description = init_desc
	
@export var name: String = ""
@export var type: String = ""
@export var description: String = ""
