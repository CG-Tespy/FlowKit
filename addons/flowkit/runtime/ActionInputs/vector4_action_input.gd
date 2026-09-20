extends FKActionInput

class_name FKVector4ActionInput

func _init(init_name: String = "", init_desc: String = "", init_default: Vector4 = Vector4.ZERO):
	super._init(init_name, "Vector4", init_desc, init_default)

func get_val(dict: Dictionary) -> Vector4:
	return super.get_val(dict)

func _convert(raw: Variant) -> Vector4:
	if raw is Vector4:
		return raw
	return _default_value

func get_class() -> String:
	return "FKVector4ActionInput"

func get_real_class() -> String:
	return "FKVector4ActionInput"