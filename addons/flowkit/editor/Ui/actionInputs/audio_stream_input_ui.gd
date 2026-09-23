@tool
extends FKActionInputUi
class_name FKAudioStreamActionInputUi

@export var line_edit: LineEdit

func get_value() -> Variant:
	return get_value_or_expression(_get_audio_stream())

func _can_hold_value(val: Variant) -> bool:
	return val == null or val is AudioStream

func _set_value(value: Variant) -> void:
	line_edit.text = value.resource_path if value != null else ""

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return not _get_audio_stream_path_from_drop(data).is_empty()

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var path := _get_audio_stream_path_from_drop(data)
	if path.is_empty():
		return

	line_edit.text = path
	_is_dirty = true
	_set_expression_mode(false)

func _is_expression(value: Variant) -> bool:
	if value is String and ResourceLoader.exists(value, "AudioStream"):
		return false
	return super._is_expression(value)

func _get_audio_stream_path_from_drop(data: Variant) -> String:
	if not data is Dictionary:
		return ""

	var files: Variant = data.get("files", [])
	if not files is Array and not files is PackedStringArray:
		return ""

	for file_path: Variant in files:
		if not file_path is String:
			continue
		var resource := ResourceLoader.load(file_path)
		if resource is AudioStream:
			return file_path

	return ""

func _get_audio_stream() -> AudioStream:
	var path := line_edit.text.strip_edges()
	if path.is_empty() or not ResourceLoader.exists(path, "AudioStream"):
		return null
	return ResourceLoader.load(path, "AudioStream") as AudioStream

func get_class() -> String:
	return "FKAudioStreamActionInputUi"