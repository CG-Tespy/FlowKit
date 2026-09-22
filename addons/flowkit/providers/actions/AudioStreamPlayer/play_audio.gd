extends FKAction

## For playing audio from all three AudioStreamPlayer types.
class_name FKPlayAudioGeneral

func get_description() -> String:
	return "Starts playing the selected Audio Stream."

func get_provider_id() -> String:
	return "play_audio_stream_general"
	
func get_display_name() -> String:
	return "Play Audio"

func get_inputs() -> Array[FKActionInput]:
	return [_audio_stream_input]

var _audio_stream_input := FKAudioStreamActionInput.new("What To Play")

func get_supported_types() -> Array[String]:
	return ["AudioStreamPlayer", "AudioStreamPlayer2D", "AudioStreamPlayer3D"]

func execute(node: Node, inputs: Dictionary, block_id: int = -1) -> void:
	var valid_node_type := node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D
	if not valid_node_type:
		return

	if node:
		var audio_stream := _audio_stream_input.get_val(inputs)
		if audio_stream == null:
			printerr("[%s] Cannot play null Audio Stream." % [self.get_class()])
			return
		node.stream = audio_stream
		node.play()


func get_class() -> String:
	return "FKPlayAudio"