@tool
extends FKActionInputUi
class_name FKStringActionInputUi

@export var line_edit: TextEdit

const MAX_VISIBLE_LINES := 3
const LINE_EDIT_VERTICAL_PADDING := 8.0

var _base_min_height := 0.0
var _base_line_edit_height := 0.0

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
	var setting_on := _globals.should_auto_enclose_string_inputs()
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
	_fit_line_edit_to_text.call_deferred()

func _ready() -> void:
	super._ready()
	if is_editor_preview:
		return
	if _base_line_edit_height == 0.0:
		_base_min_height = custom_minimum_size.y
		_base_line_edit_height = line_edit.custom_minimum_size.y
		line_edit.text_changed.connect(_fit_line_edit_to_text)
		line_edit.resized.connect(_fit_line_edit_to_text)
	_fit_line_edit_to_text.call_deferred()

## Grows the text box up to MAX_VISIBLE_LINES, after which it scrolls.
func _fit_line_edit_to_text() -> void:
	if not is_instance_valid(line_edit):
		return
	var shown_lines := clampi(line_edit.get_total_visible_line_count(), 1, MAX_VISIBLE_LINES)
	var line_height := line_edit.get_line_height()
	var wanted := maxf(_base_line_edit_height, shown_lines * line_height + LINE_EDIT_VERTICAL_PADDING)
	line_edit.custom_minimum_size.y = wanted
	custom_minimum_size.y = _base_min_height + (wanted - _base_line_edit_height)

func _apply_action_input_to_controls() -> void:
	super._apply_action_input_to_controls()

func get_class() -> String:
	return "FKStringActionInputUi"

func get_real_class() -> String:
	return self.get_class()