@tool
extends FKActionInputUi
class_name FKStringActionInputUi

@export var line_edit: LineEdit

func get_value() -> Variant:
	var result := _enclosed_as_needed(line_edit.text)
	return get_value_or_expression(result)

func _enclosed_as_needed(str: String) -> String:
	if is_expression_mode:
		return str

	var result := str
	
	var enclosed_already := _is_enclosed_in_quotes(result)
	if not enclosed_already:
		## Accounting for the parser here.
		result = "%s%s%s" % [_enclosing_quote_mark, result, _enclosing_quote_mark]
		
	return result

func _is_enclosed_in_quotes(str: String) -> bool:
	return str.begins_with(_enclosing_quote_mark) and str.ends_with(_enclosing_quote_mark)

static var _enclosing_quote_mark = "\""

var _ensure_enclose_quotes: bool:
	get:
		## We only want to ensure the enclosure when outside of expression mode.
		if is_expression_mode:
			return false
		if _globals == null or _globals.editor_interface == null:
			return true

		var key := FKEditorGlobals.AUTO_ENCLOSE_QUOTES_TOGGLE_KEY
		var as_per_editor_setting: bool = _editor_settings.get_setting(key)
		return as_per_editor_setting

func _can_hold_value(val: Variant) -> bool:
	return val is String or val is NodePath

func _set_value(value: Variant) -> void:
	line_edit.text = str(value)

func _apply_action_input() -> void:
	super._apply_action_input()

func get_class() -> String:
	return "FKStringActionInputUi"