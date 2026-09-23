extends GutTest

const AUDIO_STREAM_ACTION_INPUT := preload("res://addons/flowkit/runtime/ActionInputs/audio_stream_action_input.gd")
const VECTOR2_ACTION_INPUT := preload("res://addons/flowkit/runtime/ActionInputs/vector2_action_input.gd")
const VECTOR3_ACTION_INPUT := preload("res://addons/flowkit/runtime/ActionInputs/vector3_action_input.gd")
const VECTOR4_ACTION_INPUT := preload("res://addons/flowkit/runtime/ActionInputs/vector4_action_input.gd")

func test_action_inputs_report_their_real_class_names():
	var action_inputs: Array[FKActionInput] = [
		FKActionInput.new(),
		FKBoolActionInput.new(),
		FKIntActionInput.new(),
		FKFloatActionInput.new(),
		FKStringActionInput.new(),
		VECTOR2_ACTION_INPUT.new(),
		VECTOR3_ACTION_INPUT.new(),
		VECTOR4_ACTION_INPUT.new(),
		AUDIO_STREAM_ACTION_INPUT.new(),
	]

	for action_input in action_inputs:
		assert_ne(action_input.get_real_class(), "RefCounted")

func test_get_val_converts_lowercase_stored_value():
	var input := FKFloatActionInput.new("Duration", "", 1.0)

	assert_eq(input.get_val({"duration": "2.5"}), 2.5)
	assert_eq(input.get_raw_val({"duration": "node.position.x + 10"}), "node.position.x + 10")

func test_get_val_prefers_the_definition_name_over_lowercase_fallback():
	var input := FKFloatActionInput.new("Duration", "", 1.0)

	assert_eq(input.get_val({"Duration": 3.0, "duration": "2.5"}), 3.0)

func test_get_val_uses_default_when_value_is_missing():
	var input := FKBoolActionInput.new("Wait For Finish", "", true)

	assert_true(input.get_val({}))

func test_described_input_uses_default_when_value_is_missing():
	var input := FKFloatActionInput.new("Duration", "Time in seconds", 1.5)

	assert_eq(input.get_val({}), 1.5)

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