@tool
extends FKVariableUi
class_name FKStringVariableUi

@export var value_field: TextEdit

const MAX_VISIBLE_LINES := 3
const VALUE_FIELD_VERTICAL_PADDING := 8.0

var _base_holder_height := 0.0

func _ready() -> void:
	_base_holder_height = _value_holder().custom_minimum_size.y
	value_field.text_changed.connect(_fit_value_field_to_text)
	value_field.resized.connect(_fit_value_field_to_text)
	_fit_value_field_to_text.call_deferred()

func _set_value(value: Variant) -> void:
	value_field.text = str(value)
	_fit_value_field_to_text.call_deferred()

func _apply_value_to_variable() -> bool:
	return _variable.set_value(value_field.text)

## The value field is anchored inside a plain Control, which doesn't size itself
## to its child, so the holder is what has to grow (this node is a VBox,
## so the row grows along with it).
func _value_holder() -> Control:
	return value_field.get_parent() as Control

## Grows the text box up to MAX_VISIBLE_LINES, after which it scrolls.
func _fit_value_field_to_text() -> void:
	if not is_instance_valid(value_field):
		return
	var shown_lines := clampi(value_field.get_total_visible_line_count(), 1, MAX_VISIBLE_LINES)
	var wanted := maxf(_base_holder_height, shown_lines * value_field.get_line_height() + VALUE_FIELD_VERTICAL_PADDING)
	_value_holder().custom_minimum_size.y = wanted
