extends FKVariable
class_name FKAudioStreamVariable

@export var value: AudioStream

func get_value() -> AudioStream:
	return value

func compatible_with_type_of(new_val: Variant) -> bool:
	return new_val == null or new_val is AudioStream

func _set_for_our_type(new_val: Variant) -> void:
	value = new_val

func _can_hold_of_type(type: String) -> bool:
	return type == "audiostream"

func _convert_to_target_type(_target_type: String) -> Variant:
	return value

func get_class() -> String:
	return "FKAudioStreamVariable"