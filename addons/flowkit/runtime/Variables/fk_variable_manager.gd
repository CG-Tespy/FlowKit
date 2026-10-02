extends Resource
## Main container and manager of FKVariables. Runtime-safe: it knows nothing about
## the editor. Creating variables of a given type is the editor registry's job
## (see FKVariableRegistry.add_var_of_type); this just takes ownership of them.
class_name FKVariableManager

@export var fk_variables: Array[FKVariable] = []
@export_storage var id_assigner: FKIdAssigner = FKIdAssigner.new()

## Returns a defensive copy.
func get_variables() -> Array[FKVariable]:
	return fk_variables.duplicate()

func set_owner(new_owner):
	_owner = new_owner 
	for elem in fk_variables:
		elem.set_owner(new_owner)

var _owner 

## Takes ownership of the variable, giving it an id that's unique among ours.
## Returns false if the variable was null or already managed here.
func add_var(fk_var: FKVariable) -> bool:
	if fk_var == null or fk_variables.has(fk_var):
		return false

	fk_variables.append(fk_var)
	fk_var.set_owner(_owner)
	_refresh_ids()
	return true

## Returns false if the variable isn't managed here.
func remove_var(fk_var: FKVariable) -> bool:
	var ind := fk_variables.find(fk_var)
	if ind < 0:
		return false

	fk_variables.remove_at(ind)
	fk_var.set_owner(null)
	return true

func _refresh_ids() -> void:
	if not id_assigner:
		id_assigner = FKIdAssigner.new()

	# Set every time, since the default-constructed assigner starts with no prop name.
	id_assigner.prop_name = "id"
	id_assigner.reset_taken_caches()
	id_assigner.refresh_for(fk_variables)
