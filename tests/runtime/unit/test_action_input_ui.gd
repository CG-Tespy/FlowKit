extends GutTest

const FLOAT_INPUT_SCENE := preload("res://addons/flowkit/editor/scenes/actionInputs/float_input.tscn")
const INTEGER_INPUT_SCENE := preload("res://addons/flowkit/editor/scenes/actionInputs/integer_input.tscn")
const BOOL_INPUT_SCENE := preload("res://addons/flowkit/editor/scenes/actionInputs/bool_input.tscn")
const COLOR_INPUT_SCENE := preload("res://addons/flowkit/editor/scenes/actionInputs/color_input.tscn")
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

func test_string_input_ui_uses_input_name_and_value():
	var input_ui: Variant = STRING_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKStringActionInput.new("Message", "", "Hello"), FKEditorGlobals.new())
	add_child(input_ui)

	input_ui.try_set_value("Updated message")

	assert_eq(input_ui.input_label.text, "Message")
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