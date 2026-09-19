@tool
extends FKActionInputUi
class_name FKStringActionInputUi

@export var line_edit: LineEdit

func get_value() -> Variant:
	var result := _enclosed_as_needed(line_edit.text)
	return get_value_or_expression(result)

func _enclosed_as_needed(str: String) -> String:
	if not _should_auto_enclose(str):
		print("[%s] Not auto-enclosing string." % [self.get_class()])
		return str

	var result := "%s%s%s" % [_enclosing_quote_mark, str, _enclosing_quote_mark]
	print("[%s] Enclosed string result: %s" % [self.get_class(), result])
	return result

func _should_auto_enclose(str: String) -> bool:
	var globals_ready := _globals != null and _globals.editor_interface != null
	if not globals_ready:
		return true

	var settings := _globals.editor_interface.get_editor_settings()
	if not settings.has_setting(_enclosure_setting_key()):
		return true

	var setting_on := settings.get_setting(_enclosure_setting_key())
	var enclosed_already := _is_enclosed_in_quotes(str)
	return setting_on and not enclosed_already

func _enclosure_setting_key() -> String:
	return FKEditorGlobals.AUTO_ENCLOSE_STRING_INPUTS_KEY

func _is_enclosed_in_quotes(str: String) -> bool:
	if str.length() < 2:
		return false 
	
	var result := str.begins_with(_enclosing_quote_mark) and str.ends_with(_enclosing_quote_mark)
	return result

static var _enclosing_quote_mark = "\""

func _can_hold_value(val: Variant) -> bool:
	return val is String or val is NodePath

func _set_value(value: Variant) -> void:
	line_edit.text = str(value)

func _apply_action_input_to_controls() -> void:
	super._apply_action_input_to_controls()

func get_class() -> String:
	return "FKStringActionInputUi"