extends GutTest

const ACTION_INPUT_UI_FACTORY := preload("res://addons/flowkit/editor/Ui/actionInputs/action_input_ui_factory.gd")
const STRING_ACTION_INPUT_UI := preload("res://addons/flowkit/editor/Ui/actionInputs/string_input_ui.gd")

var factory = ACTION_INPUT_UI_FACTORY.new(FKEditorGlobals.new())

func test_factory_creates_bool_input_ui():
	var input := FKBoolActionInput.new("Enabled", "", false)
	var input_ui: Variant = factory.create_from(input)
	add_child(input_ui)

	assert_true(input_ui is FKBoolActionInputUi)
	assert_same(input_ui.action_input, input)
	assert_eq(input_ui.input_label.text, "Enabled")
	input_ui.free()

func test_factory_creates_integer_input_ui():
	var input := FKIntActionInput.new("Lives", "", 3)
	var input_ui: Variant = factory.create_from(input)
	add_child(input_ui)

	assert_true(input_ui is FKIntActionInputUi)
	assert_eq(input_ui.input_label.text, "Lives")
	input_ui.free()

func test_factory_creates_float_input_ui():
	var input := FKFloatActionInput.new("Speed", "", 1.0)
	var input_ui: Variant = factory.create_from(input)
	add_child(input_ui)

	assert_true(input_ui is FKFloatActionInputUi)
	assert_eq(input_ui.input_label.text, "Speed")
	input_ui.free()

func test_factory_creates_color_input_ui():
	var input := FKActionInput.new("Tint", "Color")
	var input_ui: Variant = factory.create_from(input)
	add_child(input_ui)

	assert_true(input_ui is FKColorActionInputUi)
	assert_eq(input_ui.input_label.text, "Tint")
	input_ui.free()

func test_factory_creates_string_input_ui():
	var input := FKStringActionInput.new("Message")
	var input_ui: Variant = factory.create_from(input)
	add_child(input_ui)

	assert_same(input_ui.get_script(), STRING_ACTION_INPUT_UI)
	assert_eq(input_ui.input_label.text, "Message")
	input_ui.free()