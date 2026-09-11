@tool
extends Control

class_name FKProviderPathManager

@export var holds_path_fields: Control
@export var file_dialog: FileDialog
# ^ Meant to be shared between the path fields. Otherwise, they'd each
# need their own, meaning extra bloat.

func legitimize():
	if not _is_editor_preview:
		return
	_is_editor_preview = false
	_enter_tree()

var _is_editor_preview := true

func _enter_tree() -> void:
	if _is_editor_preview:
		var log_message := "[FlowKit]: Viewing FKProviderPathManager in the Scene View."
		print(log_message)
		return

	_find_pickers()

func _find_pickers():
	print("[FKProviderPathManager] Finding pickers")
	for child_el in holds_path_fields.get_children():
		if child_el is FKPathField:
			_pickers.append(child_el)
			print("[FKProviderPathManager] Giving file dialog [" + file_dialog.name + "] to child " + child_el.name)
			child_el.set_file_dialog(file_dialog)
			print("[FKProviderPathManager] Legitimizing path field " + child_el.name)
			child_el.legitimize(_signals)
	pass

var _pickers: Array[FKPathField] = []

func set_globals(new_globals: FKEditorGlobals):
	_globals = new_globals
	_signals = _globals.settings_window_signals

var _globals: FKEditorGlobals
var _signals: FKSettingsWindowSignals

func _toggle_subs(do_sub: bool):

	pass

func _exit_tree() -> void:
	if _is_editor_preview:
		var log_message := "[FlowKit]: FKProviderPathManager exiting the Scene View."
		print(log_message)
		return