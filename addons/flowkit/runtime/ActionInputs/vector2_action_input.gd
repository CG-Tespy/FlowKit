extends FKActionInput

class_name FKVector2ActionInput

func _init(init_name: String = "", init_desc: String = "", init_default: Vector2 = Vector2.ZERO):
	name = init_name
	_type = "Vector2"
	description = init_desc
	_default_value = init_default

func get_val(dict: Dictionary) -> Vector2:
	return super.get_val(dict)

func _convert(raw: Variant) -> Vector2:
	if raw is Vector2:
		return raw
	return _default_value

func get_class() -> String:
	return "FKVector2ActionInput"