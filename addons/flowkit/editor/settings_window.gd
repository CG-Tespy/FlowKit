extends Window
class_name FKSettingsWindow

@export var auto_save_toggle: CheckBox
## Saves the settings to a json file
@export var save_button: Button

func _legitimize():
	if not _is_editor_preview:
		return
	_is_editor_preview = false
	_enter_tree()
	
var _is_editor_preview := true

func _enter_tree() -> void:
	if _is_editor_preview:
		var log_message := "[FlowKit]: Viewing FKSettingsWindow in the Scene View."
		print(log_message)
		return
	_toggle_subs(true)
	
func _toggle_subs(on: bool):
	if on && !_is_subbed:
		auto_save_toggle.toggled.connect(_on_auto_save_toggled)
		save_button.pressed.connect(_on_save_button_pressed)
		
	elif _is_subbed && !on:
		auto_save_toggle.toggled.disconnect(_on_auto_save_toggled)
		save_button.pressed.disconnect(_on_save_button_pressed)
		
	else:
		return
		
	_is_subbed = on

var _is_subbed := false

func _on_auto_save_toggled(value: bool) -> void:
	var editor_settings := editor_interface.get_editor_settings()
	editor_settings.set_setting(FKEditorGlobals.AUTO_SAVE_TOGGLE_KEY, value)
	editor_settings.save()
	# If your FKEditorGlobals holds the auto-saver:
	if globals and globals.auto_saver:
		globals.auto_saver.enabled = value

var editor_interface: EditorInterface:
	get:
		return globals.editor_interface
		
var globals: FKEditorGlobals


func _on_save_button_pressed() -> void:
	hide()

func _exit_tree() -> void:
	if _is_editor_preview:
		var log_message := "[FlowKit]: FKSettingsWindow exiting the Scene View."
		print(log_message)
		return
	_toggle_subs(false)
