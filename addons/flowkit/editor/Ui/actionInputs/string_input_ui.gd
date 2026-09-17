@tool
extends FKActionInputUi
class_name FKStringActionInputUi

@export var line_edit: LineEdit

func get_value() -> Variant:
	var result := line_edit.text
	
	if _enclose_quotes:
		## Accounting for the parser here.
		result = "\"%s\"" % [result]
	return result

var _enclose_quotes: bool:
	get:
		if _globals == null or _globals.editor_interface == null:
			return true
		return _globals.editor_settings.get_setting(
			FKEditorGlobals.AUTO_ENCLOSE_QUOTES_TOGGLE_KEY)

func _can_hold_value(val: Variant) -> bool:
	return val is String or val is NodePath

func _set_value(value: Variant) -> void:
	line_edit.text = str(value)

func _apply_action_input() -> void:
	super._apply_action_input()

func get_class() -> String:
	return "FKStringActionInputUi"