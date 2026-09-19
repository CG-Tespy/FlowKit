extends FKActionInput

class_name FKStringActionInput

func _init(init_name: String = "", init_desc: String = "", init_default: String = ""):
	super._init(init_name, "String", init_desc, init_default)

# For Intellisense
func get_val(dict: Dictionary) -> String:
	return super.get_val(dict)
	
func _convert(raw):
	if raw == null:
		return _default_value
	return str(raw)
