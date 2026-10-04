@tool
extends FKActionInputUi
class_name FKAudioStreamActionInputUi

@export var resource_picker: EditorResourcePicker

func _toggle_subs(on: bool):
	var was_subbed := _is_subbed
	super._toggle_subs(on)
	if was_subbed == _is_subbed:
		return

	if _is_subbed:
		resource_picker.resource_changed.connect(_on_resource_picker_resource_changed)
	
	else:
		resource_picker.resource_changed.disconnect(_on_resource_picker_resource_changed)

func _on_resource_picker_resource_changed(_resource: Resource) -> void:
	if not _is_populating:
		_is_dirty = true

func get_value() -> Variant:
	return get_value_or_expression(resource_picker.edited_resource)

func _can_hold_value(val: Variant) -> bool:
	return val == null or val is AudioStream

func _set_value(value: Variant) -> void:
	resource_picker.edited_resource = value

func _is_expression(value: Variant) -> bool:
	if value is String and ResourceLoader.exists(value, "AudioStream"):
		return false
	return super._is_expression(value)

func get_class() -> String:
	return "FKAudioStreamActionInputUi"