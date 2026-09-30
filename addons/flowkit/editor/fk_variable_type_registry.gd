extends RefCounted
class_name FKVariableTypeRegistry

var _type_loader := FKVariableTypeLoader.new()

func load_types():
	var load_result := _type_loader.load_all()
	_var_types_to_scripts = load_result.variable_type_scripts
	_report_var_types_loaded()

## These map variable type strings to the GDScripts for the appropriate FKVariables
var _var_types_to_scripts: Dictionary[String, GDScript]

var _var_pool: Array[FKVariable] = []

func _report_var_types_loaded():
	var log_message := "[%s] Variable types loaded:" % self.get_class()
	for elem in _var_types_to_scripts.keys():
		log_message += "\n%s" % elem
	print(log_message)

func get_class() -> String:
	return "FKVariableTypeRegistry"

func get_variable_of_type(type_name: String) -> FKVariable:
	var valid_type_name := _var_types_to_scripts.has(type_name)
	if not valid_type_name:
		var log_message := "[%s] Type name %s is not a valid one for the var types registered." % \
		[self.get_class(), type_name]
		printerr(log_message)
		return

	var script := _var_types_to_scripts[type_name]
	var new_var: FKVariable = script.new()
	return new_var

func get_type_names() -> Array[String]:
	return _var_types_to_scripts.keys()