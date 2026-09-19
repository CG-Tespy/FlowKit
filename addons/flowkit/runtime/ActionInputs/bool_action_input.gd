extends FKActionInput

class_name FKBoolActionInput

func _init(init_name: String = "", init_desc: String = "", init_default: bool = false):
	super._init(init_name, "bool", init_desc, init_default)
	
# For Intellisense
func get_val(dict: Dictionary) -> bool:
	return super.get_val(dict)
	
func _convert(raw: Variant):
	if raw == null or (raw is String and raw == ""):
		return _default_value
	if raw is String:
		return raw.to_lower() == "true"
	return raw

func get_class() -> String:
	return "FKBoolActionInput"

func get_real_class() -> String:
	return "FKBoolActionInput"
