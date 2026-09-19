@tool
extends Window
class_name FKSettingsWindow

@export var auto_save_toggle: CheckButton
@export var exp_text_color: ColorPickerButton
## Specifically for string action inputs as shown in the editor.
@export var auto_enclose_strings: CheckButton
## Saves the settings to a resource.
@export var save_button: Button
## So FlowKit knows where to look for custom providers outside its own folder.
@export var holds_prov_paths: FKProviderPathManager

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
	
	_ensure_settings_registered()
	_update_toggle()
	_update_sheet_auto_saver.call_deferred()
	_toggle_subs(true)
	_load_project_settings()
	if holds_prov_paths:
		print("[FKSettingsWindow] Legitimizing prov paths")
		holds_prov_paths.legitimize()
		holds_prov_paths.set_provider_paths(_project_settings.provider_paths, false)

func _ensure_settings_registered():
	if not editor_settings.has_setting(_auto_save_key):
		print("[%s]: Initializing auto save setting." % [self.get_class()])
		editor_settings.set_setting(_auto_save_key, auto_save_toggle.button_pressed)
	if not editor_settings.has_setting(_exp_text_color_key):
		print("[%s]: Initializing expression text color setting." % [self.get_class()])
		editor_settings.set_setting(_exp_text_color_key, exp_text_color.color)
	if not editor_settings.has_setting(_string_auto_enclose_key):
		print("[%s]: Initializing string auto enclosure setting." % [self.get_class()])
		editor_settings.set_setting(_string_auto_enclose_key, true)
	
var _auto_save_key: String:
	get:
		return FKEditorGlobals.AUTO_SAVE_TOGGLE_KEY

var _exp_text_color_key: String:
	get:
		return FKEditorGlobals.EXPRESSION_TEXT_COLOR_KEY

var _string_auto_enclose_key: String:
	get:
		return FKEditorGlobals.AUTO_ENCLOSE_STRING_INPUTS_KEY

func _load_project_settings():
	var should_create_new_file := not FileAccess.file_exists(_project_settings_path)
	var settings_to_load: FKProjectSettings
	if should_create_new_file:
		print("[FKSettingsWindow] Creating new settings file.")
		_project_settings = FKProjectSettings.new()

		var default_prov_path := FKProviderLoader.DEFAULT_PROVIDER_PATH
		DirAccess.make_dir_recursive_absolute(default_prov_path)
		_project_settings.add_provider_path(default_prov_path)

		ResourceSaver.save(_project_settings, _project_settings_path)
		
		var file_sys := EditorInterface.get_resource_filesystem()
		#file_sys.reimport_files([_project_settings_path])
		file_sys.scan()
	else:
		_project_settings = ResourceLoader.load(_project_settings_path, "FKProjectSettings")

static var _project_settings_path := "res://addons/flowkit/editor/_fk_project_settings.tres"
var _project_settings := FKProjectSettings.new()


		
func _update_toggle():
	var current: bool = _auto_save_toggle_setting
	auto_save_toggle.button_pressed = current
	exp_text_color.color = _expression_text_color_setting
	auto_enclose_strings.button_pressed = _auto_enclose_string_inputs_setting

var _auto_save_toggle_setting: bool:
	get:
		return editor_settings.get_setting(_auto_save_key)

var _expression_text_color_setting: Color:
	get:
		return editor_settings.get_setting(_exp_text_color_key)

var _auto_enclose_string_inputs_setting: bool:
	get:
		return editor_settings.get_setting(_string_auto_enclose_key)
		
var editor_settings: EditorSettings:
	get:
		return editor_interface.get_editor_settings()
		
var editor_interface: EditorInterface:
	get:
		return _globals.editor_interface

func set_globals(new_globals: FKEditorGlobals):
	_globals = new_globals
	if holds_prov_paths:
		holds_prov_paths.set_globals(_globals)

var _globals: FKEditorGlobals

func _update_sheet_auto_saver():
	var current: bool = _auto_save_toggle_setting
	if _globals and _globals.sheet_auto_saver:
		print("[FKSettingsWindow]: Updated auto sheet saver enabled to: " + str(current))
		_globals.sheet_auto_saver.enabled = current

func _toggle_subs(on: bool):
	if on && !_is_subbed:
		save_button.pressed.connect(_on_save_button_pressed)
		close_requested.connect(_on_close_requested)
		
	elif _is_subbed && !on:
		save_button.pressed.disconnect(_on_save_button_pressed)
		close_requested.disconnect(_on_close_requested)
		
	else:
		return
		
	_is_subbed = on

var _is_subbed := false

func _on_save_button_pressed() -> void:
	_save_and_apply_editor_settings()

	_apply_project_settings()
	_save_project_settings()

	print("[FKSettingsWindow]: Settings saved!")

func _save_and_apply_editor_settings():
	_apply_auto_save_setting()
	_apply_expression_text_color_setting()
	_apply_auto_enclose_string_inputs_setting()

func _apply_auto_save_setting():
	# This here goes into Editor settings, not proj ones. This way, 
	# different members of the same team won't have to be 
	# forced into going with the same auto-save setting.
	var should_auto_save := auto_save_toggle.button_pressed
	var name := FKEditorGlobals.AUTO_SAVE_TOGGLE_KEY
	editor_settings.set_setting(name, should_auto_save)
	_update_sheet_auto_saver()

func _apply_expression_text_color_setting():
	editor_settings.set_setting(_exp_text_color_key, exp_text_color.color)

func _apply_auto_enclose_string_inputs_setting():
	editor_settings.set_setting(_string_auto_enclose_key, auto_enclose_strings.button_pressed)

func _apply_project_settings():
	_apply_provider_paths()

func _apply_provider_paths():
	var paths_to_apply := holds_prov_paths.provider_paths()
	_project_settings.set_provider_paths(paths_to_apply)

func _save_project_settings():
	ResourceSaver.save(_project_settings, _project_settings_path)
	_globals.registry.load_providers()

func get_project_settings() -> FKProjectSettings:
	return _project_settings

func _on_close_requested():
	hide()
	
func _exit_tree() -> void:
	if _is_editor_preview:
		var log_message := "[FlowKit]: FKSettingsWindow exiting the Scene View."
		print(log_message)
		return
	_toggle_subs(false)

func get_class() -> String:
	return "FKSettingsWindow"