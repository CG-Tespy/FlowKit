extends Resource

## Separate from the System variables FlowKit used before. These are meant to be more 
## visual-scripting-friendly.
class_name FKVariable

## Name of the variable.
@export var key: String = ""

## Helps control what can access this.
@export var scope := FKAccessScope.Keys.PRIVATE

## Helps uniquely identify this FKVariable relative to the others owned
## by the same owner.
@export var id: int

## Class-specific metadata for the editor.

## Helps sort this in the var-type-selection menu.
func category() -> String:
	return ""

## For variable types that are outdated, test-only, or that otherwise shouldn't be 
## used in projects outside FK's repo.
func hide_from_users() -> bool:
	return false

func type_display_name() -> String:
	printerr("[%s] Needs to override type_display_name." % self.get_class())
	return ""

## Alias for the key
func var_name() -> String:
	return key

## Meant to be overridden by subclasses.
func get_value() -> Variant:
	return null

func set_value(new_val: Variant) -> bool:
	if not compatible_with_type_of(new_val):
		_report_val_incompatibility(new_val)
		return false

	_set_for_our_type(new_val)
	emit_changed()
	return true

## Meant to be overridden.
func compatible_with_type_of(value: Variant) -> bool:
	return false

func _report_val_incompatibility(val: Variant) -> void:
	var log_message := "[%s %s] Cannot have %s as value." % [self.get_class(), key, str(val)]
	printerr(log_message)

## This here assumes that the new val is valid for this variable type.
## We have this func to reduce boilerplate in the normal set_value func.
## Meant to be overridden by subclasses.
func _set_for_our_type(new_val: Variant) -> void:
	pass

## If null is returned, the type is not supported by this variable type.
func get_value_as(target_type: String) -> Variant:
	var normalized_type := _normalize_type(target_type)
	var result: Variant = null
	if not _can_hold_of_type(normalized_type):
		_report_type_incompatibility(normalized_type)
	else:
		result = _convert_to_target_type(normalized_type)

	return result

func _normalize_type(type: String) -> String:
	var normalized_type := type.strip_edges().to_lower()
	if normalized_type == "integer":
		return "int"
	return normalized_type

## Meant to be overridden. Helper for get_value_as. 
func _can_hold_of_type(type: String) -> bool:
	return false

func _report_type_incompatibility(type: String) -> void:
	var log_message := "[%s] Cannot hold a value of type %s" % [self.get_class(), type]
	printerr(log_message)

## Returns a version of our value that is the passed type (assumed to be compatible with this FKVariable).
## Meant to be overridden. Assumes the target type is valid for 
## this FKVariable type.
func _convert_to_target_type(target_type: String) -> Variant:
	return null

func get_owner() -> Variant:
	return _owner

var _owner: Variant

func set_owner(new_owner: Variant) -> void:
	_owner = new_owner
	emit_changed()

func _to_string() -> String:
	return "%s named %s, w/value %s" % [self.get_class(), key, str(get_value())]

func get_class() -> String:
	return "FKVariable"

func get_real_class():
	return self.get_class()