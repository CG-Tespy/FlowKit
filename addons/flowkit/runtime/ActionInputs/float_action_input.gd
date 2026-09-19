extends FKActionInput

class_name FKFloatActionInput

func _init(init_name: String = "", init_desc: String = "", init_default: float = 0):
	super._init(init_name, "float", init_desc, init_default)

# For Intellisense
func get_val(dict: Dictionary) -> float:
	return super.get_val(dict)
	
func _convert(raw: Variant):
	if (raw is String and raw == ""):
		return _default_value
	return float(raw)

func get_class() -> String:
	return "FKFloatActionInput"

func get_real_class() -> String:
	return "FKFloatActionInput"
