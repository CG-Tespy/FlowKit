extends FKActionInput

class_name FKIntActionInput

func _init(init_name: String = "", init_desc: String = "", init_default: int = 0):
	super._init(init_name, "int", init_desc, init_default)

# For Intellisense
func get_val(dict: Dictionary) -> int:
	return super.get_val(dict)
	
func _convert(raw):
	if (raw is String and raw == ""):
		return _default_value
	return int(raw)

func get_class() -> String:
	return "FKIntActionInput"

func get_real_class() -> String:
	return "FKIntActionInput"