extends FKAction

func get_description() -> String:
	return "Starts playing the audio already assigned to the AudioStreamPlayer2D node.\n" +\
	"Best use the updated Play Audio Action."

func get_id() -> String:
	return "play"

func get_provider_id() -> String:
	return "audio_stream_player_2d_play"
	
func get_display_name() -> String:
	return "Play (Legacy)"

func get_supported_types() -> Array[String]:
	return ["AudioStreamPlayer2D"]

func execute(node: Node, inputs: Dictionary, block_id: int = -1) -> void:
	if node and (node is AudioStreamPlayer2D):
		node.play()
