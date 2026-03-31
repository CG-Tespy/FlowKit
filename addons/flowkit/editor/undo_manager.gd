# FKUndoManager.gd
extends RefCounted
class_name FKUndoManager

const MAX_UNDO_STATES := 50

var _undo_stack: Array = []
var _redo_stack: Array = []

func clear() -> void:
	_undo_stack.clear()
	_redo_stack.clear()

func can_undo() -> bool:
	return not _undo_stack.is_empty()

func can_redo() -> bool:
	return not _redo_stack.is_empty()

func _deep_copy_units(units: Array) -> Array:
	var result: Array = []
	for u in units:
		if u == null:
			result.append(null)
		elif u is FKUnit:
			result.append(u.duplicate_block())
		elif u is Resource:
			result.append(u.duplicate(true))
		else:
			if u is Array or u is Dictionary:
				result.append(u.duplicate(true))
			else:
				result.append(u)
	return result

func push_state(units: Array) -> void:
	var snapshot := _deep_copy_units(units)
	_undo_stack.append(snapshot)

	while _undo_stack.size() > MAX_UNDO_STATES:
		_undo_stack.pop_front()

	_redo_stack.clear()

func undo(current_units: Array) -> Array:
	if _undo_stack.is_empty():
		return current_units

	var current_snapshot := _deep_copy_units(current_units)
	_redo_stack.append(current_snapshot)

	return _undo_stack.pop_back()

func redo(current_units: Array) -> Array:
	if _redo_stack.is_empty():
		return current_units

	var current_snapshot := _deep_copy_units(current_units)
	_undo_stack.append(current_snapshot)

	return _redo_stack.pop_back()
	
