extends Resource
## Main container and manager of FKVariables.
class_name FKVariableManager

@export var vars: Array[FKVariable]

func _init() -> void:

	pass

var _content_type_to_creation_func: Dictionary[String, Callable] = {
	"int": Callable(self, "_add_number_var"),
	"float": Callable(self, "_add_number_var"),
	"number": Callable(self, "_add_number_var"),
	"bool": Callable(self, "_add_bool_var"),

	"vector2": Callable(self, "_add_vector_var"),
	"vector3": Callable(self, "_add_vector_var"),
	"vector4": Callable(self, "_add_vector_var"),
	"vector": Callable(self, "_add_vector_var"),

	"string": Callable(self, "_add_string_var"),
	"color": Callable(self, "_add_color_var"),

}

func _add_number_var() -> FKNumberVariable:
	var to_add := FKNumberVariable.new()
	to_add._owner = self._owner
	return to_add

func _add_bool_var() -> FKBoolVariable:
	var to_add := FKBoolVariable.new()
	to_add._owner = self._owner 
	return to_add

func _add_vector_var() -> FKVectorVariable:
	var vec_var := FKVectorVariable.new()
	vec_var._owner = self._owner
	return vec_var

func _add_string_var():
	var to_add := FKStringVariable.new()
	to_add._owner = self._owner

func _add_color_var():
	var to_add := FKStringVariable.new()
	to_add._owner = self._owner

func set_owner(new_owner):
	_owner = new_owner 
	for elem in vars:
		elem.set_owner(new_owner)

var _owner 

func _add_audio_stream_var():
	pass

func _add_node_var():
	pass 

func add_var_of_content_type(content_type: String):
	pass