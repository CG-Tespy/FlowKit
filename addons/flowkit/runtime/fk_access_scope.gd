extends RefCounted
class_name FKAccessScope

@export var value: Keys = Keys.NULL

enum Keys 
{
	NULL = 0,
	PUBLIC = 1,
	READONLY = 2,
	PRIVATE = 3,
	GLOBAL = 4
}