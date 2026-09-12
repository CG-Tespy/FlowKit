@tool
extends Control

class_name FKProviderPathManager

@export var holds_path_fields: Control
@export var file_dialog: FileDialog
# ^ Meant to be shared between the path fields. Otherwise, they'd each
# need their own, meaning extra bloat.
@export var add_button: Button

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

	_find_path_fields()
	_toggle_subs(true)

func _find_path_fields():
	print("[FKProviderPathManager] Finding pickers")
	for child_el in holds_path_fields.get_children():
		if child_el is FKPathField:
			_path_fields.append(child_el)
			child_el.set_file_dialog(file_dialog)
			child_el.legitimize(_signals)

var _path_fields: Array[FKPathField] = []

func set_globals(new_globals: FKEditorGlobals):
	_globals = new_globals
	_signals = _globals.settings_window_signals

var _globals: FKEditorGlobals
var _signals: FKSettingsWindowSignals

func _toggle_subs(do_sub: bool):
	if do_sub and not _is_subbed:
		add_button.pressed.connect(_on_add_button_pressed)
		_signals.editor_path_removal_requested.connect(_on_editor_path_removal_requested)
	elif not do_sub and _is_subbed:
		add_button.pressed.disconnect(_on_add_button_pressed)
		_signals.editor_path_removal_requested.disconnect(_on_editor_path_removal_requested)
	else:
		return

	_is_subbed = !_is_subbed

var _is_subbed := false

func _on_add_button_pressed():
	_add_new_path_field()

func _on_editor_path_removal_requested(requested_for: FKPathField):
	if not _path_fields.has(requested_for):
		print("[FKProviderPathManager] Not responding to removal request for " + requested_for.name)
		return

	_path_fields.erase(requested_for)
	requested_for.queue_free()

func _exit_tree() -> void:
	if _is_editor_preview:
		var log_message := "[FlowKit]: FKProviderPathManager exiting the Scene View."
		print(log_message)
		return

## Returns all the non-empty paths among the fields this manages.
func provider_paths() -> Array[String]:
	var result: Array[String] = []

	for field in _path_fields:
		var chosen := field.path_chosen()
		if chosen.is_empty():
			continue
		result.append(chosen)

	return result

func set_provider_paths(new_paths: Array[String], trigger_signals: bool = true):
	_ensure_path_field_count_min(new_paths.size())
	for i in range(new_paths.size()):
		var path_to_apply := new_paths[i]
		if path_to_apply.is_empty():
			continue
		var to_apply_to := _path_fields[i]
		to_apply_to.set_path_chosen(path_to_apply, trigger_signals)

func _ensure_path_field_count_min(min_amount: int):
	while _path_fields.size() < min_amount:
		_add_new_path_field()

func _add_new_path_field():
	print("[FKProviderPathManager] Adding new path field")
	var first_registered := _path_fields[0]
	var copy := first_registered.duplicate()
	# We assume that the stuff NOT meant to be removed or browsed is already part of the scene, so...
	copy.set_removable(true, true)
	copy.set_browsable(true, true)
	copy.clear_path_chosen()
	copy.set_file_dialog(file_dialog)
	copy.legitimize(_signals)
	holds_path_fields.add_child(copy)
	_path_fields.append(copy)
	
