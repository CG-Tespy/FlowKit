extends FKActionInput

class_name FKAudioStreamActionInput

func _init(init_name: String = "", init_desc: String = "As it says on the tin.", init_default: AudioStream = null):
	super._init(init_name, "AudioStream", init_desc, init_default)

func get_val(dict: Dictionary) -> AudioStream:
	return super.get_val(dict)

## Works with paths to AudioStream resources as well.
func _convert(raw: Variant) -> AudioStream:
	if raw is AudioStream:
		return raw
	if raw is String and ResourceLoader.exists(raw, "AudioStream"):
		return ResourceLoader.load(raw, "AudioStream") as AudioStream
	return _default_value

func get_class() -> String:
	return "FKAudioStreamActionInput"

func get_real_class() -> String:
	return "FKAudioStreamActionInput"