extends FKActionInput

class_name FKVector3ActionInput

func _init(init_name: String = "", init_desc: String = "", init_default: Vector3 = Vector3.ZERO):
	super._init(init_name, "Vector3", init_desc, init_default)

func get_val(dict: Dictionary) -> Vector3:
	return super.get_val(dict)

func _convert(raw: Variant) -> Vector3:
	if raw is Vector3:
		return raw
	return _default_value

func get_class() -> String:
	return "FKVector3ActionInput"

func get_real_class() -> String:
	return "FKVector3ActionInput"