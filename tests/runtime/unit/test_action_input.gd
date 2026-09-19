extends GutTest

const AUDIO_STREAM_ACTION_INPUT := preload("res://addons/flowkit/runtime/ActionInputs/audio_stream_action_input.gd")

func test_get_val_converts_lowercase_stored_value():
	var input := FKFloatActionInput.new("Duration", "", 1.0)

	assert_eq(input.get_val({"duration": "2.5"}), 2.5)
	assert_eq(input.get_raw_val({"duration": "node.position.x + 10"}), "node.position.x + 10")

func test_get_val_uses_default_when_value_is_missing():
	var input := FKBoolActionInput.new("Wait For Finish", "", true)

	assert_true(input.get_val({}))

func test_set_val_stores_value_under_definition_name():
	var input := FKStringActionInput.new("Target Color")
	var values := {}

	input.set_val(values, "\"(20, 40, 60)\"")

	assert_eq(values, {"Target Color": "\"(20, 40, 60)\""})

func test_audio_stream_input_loads_resource_path():
	var input := AUDIO_STREAM_ACTION_INPUT.new("Audio Stream")
	var stream := input.get_val({"Audio Stream": "res://addons/flowkit/assets/correct.ogg"})

	assert_not_null(stream)
	assert_true(stream is AudioStream)