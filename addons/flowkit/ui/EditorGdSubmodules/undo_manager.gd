@tool
extends RefCounted
class_name FKUndoManager

const MAX_UNDO_STATES: int = 50

var _owner: Node
var _undo_stack: Array = []
var _redo_stack: Array = []

func _init(owner: Node) -> void:
	_owner = owner

func clear_history() -> void:
	_undo_stack.clear()
	_redo_stack.clear()

func push_state() -> void:
	var state: Array = _owner._capture_sheet_state()
	_undo_stack.append(state)
	while _undo_stack.size() > MAX_UNDO_STATES:
		_undo_stack.pop_front()
	_redo_stack.clear()

func undo() -> void:
	if _undo_stack.is_empty():
		return
	var current_state: Array = _owner._capture_sheet_state()
	_redo_stack.append(current_state)
	var previous_state: Array = _undo_stack.pop_back()
	_owner._restore_sheet_state(previous_state)
	_owner._save_sheet()
	print("[FlowKit] Undo performed")

func redo() -> void:
	if _redo_stack.is_empty():
		return
	var current_state: Array = _owner._capture_sheet_state()
	_undo_stack.append(current_state)
	var next_state: Array = _redo_stack.pop_back()
	_owner._restore_sheet_state(next_state)
	_owner._save_sheet()
	print("[FlowKit] Redo performed")
