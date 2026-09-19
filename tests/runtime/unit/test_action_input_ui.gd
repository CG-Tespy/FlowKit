extends GutTest

const FLOAT_INPUT_SCENE := preload("res://addons/flowkit/editor/scenes/actionInputs/float_input.tscn")
const INTEGER_INPUT_SCENE := preload("res://addons/flowkit/editor/scenes/actionInputs/integer_input.tscn")
const BOOL_INPUT_SCENE := preload("res://addons/flowkit/editor/scenes/actionInputs/bool_input.tscn")
const COLOR_INPUT_SCENE := preload("res://addons/flowkit/editor/scenes/actionInputs/color_input.tscn")
const VECTOR2_INPUT_SCENE := preload("res://addons/flowkit/editor/scenes/actionInputs/vector2_input.tscn")
const VECTOR3_INPUT_SCENE := preload("res://addons/flowkit/editor/scenes/actionInputs/vector3_input.tscn")
const VECTOR4_INPUT_SCENE := preload("res://addons/flowkit/editor/scenes/actionInputs/vector4_input.tscn")
const AUDIO_STREAM_INPUT_SCENE := preload("res://addons/flowkit/editor/scenes/actionInputs/audio_stream_input.tscn")
const VECTOR2_ACTION_INPUT := preload("res://addons/flowkit/runtime/ActionInputs/vector2_action_input.gd")
const VECTOR3_ACTION_INPUT := preload("res://addons/flowkit/runtime/ActionInputs/vector3_action_input.gd")
const VECTOR4_ACTION_INPUT := preload("res://addons/flowkit/runtime/ActionInputs/vector4_action_input.gd")
const AUDIO_STREAM_ACTION_INPUT := preload("res://addons/flowkit/runtime/ActionInputs/audio_stream_action_input.gd")
const STRING_INPUT_SCENE := preload("res://addons/flowkit/editor/scenes/actionInputs/string_input.tscn")
const VARIANT_INPUT_SCENE := preload("res://addons/flowkit/editor/scenes/actionInputs/variant_input.tscn")

func test_float_input_ui_uses_input_name_and_value():
	var input_ui: Variant = FLOAT_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKFloatActionInput.new("Speed", "", 1.0), FKEditorGlobals.new())
	add_child(input_ui)

	input_ui.try_set_value(2.5)

	assert_eq(input_ui.input_label.text, "Speed")
	assert_eq(input_ui.get_value(), 2.5)
	input_ui.free()

func test_integer_input_ui_uses_input_name_and_value():
	var input_ui: Variant = INTEGER_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKIntActionInput.new("Lives", "", 3), FKEditorGlobals.new())
	add_child(input_ui)

	input_ui.try_set_value(7.9)

	assert_eq(input_ui.input_label.text, "Lives")
	assert_eq(input_ui.get_value(), 7)
	input_ui.free()

func test_integer_input_ui_preserves_expression_text():
	var input_ui: Variant = INTEGER_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKIntActionInput.new("Lives", "", 3), FKEditorGlobals.new())
	add_child(input_ui)

	input_ui.try_set_value("node.position.x + 10")

	assert_true(input_ui.is_expression_mode)
	assert_eq(input_ui.expression_line_edit.text, "node.position.x + 10")
	assert_eq(input_ui.get_value(), "node.position.x + 10")
	input_ui.free()

func test_bool_input_ui_uses_input_name_and_value():
	var input_ui: Variant = BOOL_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKBoolActionInput.new("Enabled", "", false), FKEditorGlobals.new())
	add_child(input_ui)

	input_ui.try_set_value(true)

	assert_eq(input_ui.input_label.text, "Enabled")
	assert_true(input_ui.get_value())
	input_ui.free()

func test_color_input_ui_uses_input_name_and_value():
	var input_ui: Variant = COLOR_INPUT_SCENE.instantiate()
	var expected_color := Color(0.2, 0.4, 0.6, 0.8)
	input_ui.legitimize(FKActionInput.new("Tint", "Color"), FKEditorGlobals.new())
	add_child(input_ui)

	input_ui.try_set_value(expected_color)

	assert_eq(input_ui.input_label.text, "Tint")
	assert_eq(input_ui.get_value(), expected_color)
	input_ui.free()

func test_vector2_input_ui_uses_input_name_and_value():
	var input_ui: Variant = VECTOR2_INPUT_SCENE.instantiate()
	var expected_vector := Vector2(2.5, -7.0)
	input_ui.legitimize(VECTOR2_ACTION_INPUT.new("Velocity"), FKEditorGlobals.new())
	add_child(input_ui)

	input_ui.try_set_value(expected_vector)

	assert_eq(input_ui.input_label.text, "Velocity")
	assert_eq(input_ui.get_value(), expected_vector)
	input_ui.free()

func test_vector3_input_ui_preserves_expression_text():
	var input_ui: Variant = VECTOR3_INPUT_SCENE.instantiate()
	input_ui.legitimize(VECTOR3_ACTION_INPUT.new("Position"), FKEditorGlobals.new())
	add_child(input_ui)

	input_ui.try_set_value("node.global_position + Vector3.UP")

	assert_true(input_ui.is_expression_mode)
	assert_eq(input_ui.get_value(), "node.global_position + Vector3.UP")
	input_ui.free()

func test_vector4_input_ui_uses_input_name_and_value():
	var input_ui: Variant = VECTOR4_INPUT_SCENE.instantiate()
	var expected_vector := Vector4(1.0, 2.5, -3.0, 4.25)
	input_ui.legitimize(VECTOR4_ACTION_INPUT.new("Quaternion Values"), FKEditorGlobals.new())
	add_child(input_ui)

	input_ui.try_set_value(expected_vector)

	assert_eq(input_ui.input_label.text, "Quaternion Values")
	assert_eq(input_ui.get_value(), expected_vector)
	input_ui.free()

func test_audio_stream_input_ui_uses_input_name_and_value():
	var input_ui: Variant = AUDIO_STREAM_INPUT_SCENE.instantiate()
	var expected_stream := load("res://addons/flowkit/assets/correct.ogg") as AudioStream
	input_ui.legitimize(AUDIO_STREAM_ACTION_INPUT.new("Correct Answer"), FKEditorGlobals.new())
	add_child(input_ui)

	input_ui.try_set_value(expected_stream)

	assert_eq(input_ui.input_label.text, "Correct Answer")
	assert_eq(input_ui.line_edit.text, expected_stream.resource_path)
	assert_same(input_ui.get_value(), expected_stream)
	input_ui.free()

func test_audio_stream_input_ui_accepts_file_system_audio_stream_drops():
	var input_ui: Variant = AUDIO_STREAM_INPUT_SCENE.instantiate()
	input_ui.legitimize(AUDIO_STREAM_ACTION_INPUT.new("Correct Answer"), FKEditorGlobals.new())
	add_child(input_ui)
	var drop_data := {"files": PackedStringArray(["res://addons/flowkit/assets/correct.ogg"])}

	assert_true(input_ui._can_drop_data(Vector2.ZERO, drop_data))
	input_ui._drop_data(Vector2.ZERO, drop_data)

	assert_eq(input_ui.line_edit.text, "res://addons/flowkit/assets/correct.ogg")
	assert_true(input_ui.get_value() is AudioStream)
	input_ui.free()

func test_audio_stream_input_ui_rejects_non_audio_file_drops():
	var input_ui: Variant = AUDIO_STREAM_INPUT_SCENE.instantiate()
	input_ui.legitimize(AUDIO_STREAM_ACTION_INPUT.new("Correct Answer"), FKEditorGlobals.new())
	add_child(input_ui)
	var drop_data := {"files": PackedStringArray(["res://addons/flowkit/assets/icon.svg"])}

	assert_false(input_ui._can_drop_data(Vector2.ZERO, drop_data))
	input_ui.free()

func test_string_input_ui_uses_input_name_and_value():
	var input_ui: Variant = STRING_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKStringActionInput.new("Message", "", "Hello"), FKEditorGlobals.new())
	add_child(input_ui)

	input_ui.try_set_value("Updated message")

	assert_eq(input_ui.input_label.text, "Message")
	assert_eq(input_ui.get_value(), "\"Updated message\"")
	input_ui.free()

func test_string_input_ui_preserves_untouched_quoted_literal():
	var input_ui: Variant = STRING_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKStringActionInput.new("Message", "", "Hello"), FKEditorGlobals.new())
	add_child(input_ui)

	input_ui.try_set_value("\"Saved message\"")

	assert_eq(input_ui.line_edit.text, "Saved message")
	assert_eq(input_ui.get_value(), "\"Saved message\"")
	input_ui.free()

func test_string_input_ui_does_not_double_enclose_edited_quoted_literal():
	var input_ui: Variant = STRING_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKStringActionInput.new("Message", "", "Hello"), FKEditorGlobals.new())
	add_child(input_ui)

	input_ui.try_set_value("Original")
	input_ui.line_edit.text = "\"Updated message\""

	assert_eq(input_ui.get_value(), "\"Updated message\"")
	input_ui.free()

func test_variant_input_ui_preserves_expression_text():
	var input_ui: Variant = VARIANT_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKActionInput.new("Value", "Variant"), FKEditorGlobals.new())
	add_child(input_ui)

	input_ui.try_set_value("node.position.x + 10")

	assert_eq(input_ui.input_label.text, "Value")
	assert_eq(input_ui.get_value(), "node.position.x + 10")
	input_ui.free()

func test_variant_input_ui_encloses_literal_text():
	var input_ui: Variant = VARIANT_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKActionInput.new("Value", "Variant"), FKEditorGlobals.new())
	add_child(input_ui)

	input_ui.try_set_value("Original")
	input_ui.line_edit.text = "Updated value"

	assert_eq(input_ui.get_value(), "\"Updated value\"")
	input_ui.free()

func test_variant_input_ui_does_not_double_enclose_literal_text():
	var input_ui: Variant = VARIANT_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKActionInput.new("Value", "Variant"), FKEditorGlobals.new())
	add_child(input_ui)

	input_ui.try_set_value("Original")
	input_ui.line_edit.text = "\"Updated value\""

	assert_eq(input_ui.get_value(), "\"Updated value\"")
	input_ui.free()