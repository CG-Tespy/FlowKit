extends RefCounted
class_name FKVariableTypeLoadResult

var variable_types: Array[String] = []
var variable_type_scripts: Dictionary[String, GDScript] = {}
var source: String = "unavailable"
var errors: Array[String] = []
var diagnostics: Array[String] = []

func get_total_variable_type_count() -> int:
	return variable_types.size()