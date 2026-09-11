@tool
extends Control

class_name FKPathField 

@export var path_text_field: LineEdit
@export var browse_button: Button
@export var removal_button: Button 

@export var removable: bool = true

func legitimize(signals: FKSettingsWindowSignals):
	if not _is_editor_preview:
		return 

	_is_editor_preview = false
	_window_signals = signals
	_enter_tree()

var _is_editor_preview := true

var _window_signals: FKSettingsWindowSignals

func _enter_tree() -> void:
	if _is_editor_preview:
		var log_message := "[FlowKit]: Viewing FKPathField in the Scene View."
		print(log_message)
		return

	var inputs_are_fine := _validate_inputs()
	if inputs_are_fine:
		_toggle_subs(true)

	_toggle_button_enabled(true)

## If any are missing, this reports them.
## This returns true if there are no errors, false otherwise.
func _validate_inputs() -> bool:
	var error_message := _decide_error_message_for_inputs()
	var something_went_wrong := error_message.length() > 0
	if something_went_wrong:
		printerr(error_message)

	return error_message.length() == 0

func _decide_error_message_for_inputs() -> String:
	var error_message := ""

	if not path_text_field:
		error_message += "[FKPathField] Missing a path_chosen text field!"
	if not browse_button:
		if error_message.length() > 0:
			error_message += "\n"
		error_message += "[FKPathField] Missing a browse button!"
	if not removal_button:
		if error_message.length() > 0:
			error_message += "\n"
		error_message += "[FKPathField] Missing a removal button!"
	if not _file_dialog:
		if error_message.length() > 0:
			error_message += "\n"
		error_message += "[FKPathField] Missing a file dialog!"

	return error_message

func set_file_dialog(new_dialog: FileDialog):
	_file_dialog = new_dialog

var _file_dialog: FileDialog

func _toggle_subs(do_sub: bool):
	if not _window_signals:
		return

	if do_sub and not _is_subbed:
		browse_button.pressed.connect(_on_browse_button_pressed)
		removal_button.pressed.connect(_on_removal_button_pressed)

		_file_dialog.confirmed.connect(_on_file_dialog_confirmed)
		_file_dialog.canceled.connect(_on_file_dialog_canceled)

		_window_signals.editor_path_browse_start.connect(_on_editor_path_browse_start)
		_window_signals.editor_path_browse_end.connect(_on_editor_path_browse_end)

		path_text_field.focus_exited.connect(_on_focus_exited)

	elif _is_subbed and not do_sub:
		browse_button.pressed.disconnect(_on_browse_button_pressed)
		removal_button.pressed.disconnect(_on_removal_button_pressed)

		_file_dialog.confirmed.disconnect(_on_file_dialog_confirmed)
		_file_dialog.canceled.disconnect(_on_file_dialog_canceled)

		_window_signals.editor_path_browse_start.disconnect(_on_editor_path_browse_start)
		_window_signals.editor_path_browse_end.disconnect(_on_editor_path_browse_end)

		path_text_field.focus_exited.disconnect(_on_focus_exited)

	else:
		return

	_is_subbed = !_is_subbed


var _is_subbed := false

func _on_editor_path_browse_start():
	_toggle_button_enabled(false) # So we can't have 2+ file dialogs open at once 

func _on_editor_path_browse_end():
	_toggle_button_enabled(true)

func _on_browse_button_pressed():
	_toggle_button_enabled(false)
	_awaiting_selection = true
	_file_dialog.visible = true

var _awaiting_selection := false

func _toggle_button_enabled(enablement: bool):
	browse_button.disabled = !enablement

	if not removable:
		removal_button.disabled = true
		removal_button.visible = false
	else:
		removal_button.disabled = !enablement

func _on_removal_button_pressed():
	_toggle_button_enabled(false)
	_window_signals.editor_path_removal_requested.emit(self)

func _on_file_dialog_confirmed():
	if not _awaiting_selection:
		return
	path_text_field.text = _file_dialog.current_dir
	_refresh_path_choices()
	_toggle_button_enabled(true)
	_awaiting_selection = false
	_window_signals.editor_path_browse_end.emit()

func _on_file_dialog_canceled():
	var confirmed_for_something_else: bool = not self.browse_button.disabled
	if confirmed_for_something_else:
		return
	_toggle_button_enabled(true)
	_window_signals.editor_path_browse_end.emit()

func _on_focus_exited():
	_refresh_path_choices()

func _refresh_path_choices():
	var new_path := path_text_field.text.strip_edges()
	if new_path.is_empty():
		clear_path_chosen()
	else:
		set_path_chosen(new_path)

var _prev_path: String = ""

func _is_path_valid(path: String) -> bool:
	var normalized_path := path.strip_edges()

	if normalized_path.is_empty():
		return false

	var relative_to_project: bool = normalized_path.begins_with("res://")
	if not relative_to_project:
		normalized_path = "res://" + normalized_path

	var dir_exists = DirAccess.dir_exists_absolute(normalized_path)
	return dir_exists

func _report_invalid_path(to_report: String):
	var log_message := "Path %s is not a valid path_chosen." % [to_report]
	printerr(log_message)

func _exit_tree() -> void:
	if _is_editor_preview:
		var log_message := "[FlowKit]: FKPathField exiting the Scene View."
		print(log_message)
		return

	var inputs_are_fine := _validate_inputs()
	if inputs_are_fine:
		_toggle_subs(false)
	
## Path chosen for this field.
func path_chosen() -> String:
	var result: String = ""
	if path_text_field == null:
		var error_message := "[FKPathField] Cannot find path_chosen picked when no text field is set."
		printerr(error_message)
	else:
		result = path_text_field.text
	return result

func set_path_chosen(new_path: String, trigger_signals: bool = true):
	if _prev_path == new_path:
		return

	if not _is_path_valid(new_path):
		_report_invalid_path(new_path)
		path_text_field.text = ""
		return

	if trigger_signals:
		_window_signals.editor_path_choice_changed.emit(_prev_path, new_path)

	_prev_path = new_path
	pass

func clear_path_chosen():
	_prev_path = path_text_field.text
	path_text_field.text = ""