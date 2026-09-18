extends GutTest

const ACTION_INPUT_UI_FACTORY := preload("res://addons/flowkit/editor/Ui/actionInputs/action_input_ui_factory.gd")
const STRING_ACTION_INPUT_UI := preload("res://addons/flowkit/editor/Ui/actionInputs/string_input_ui.gd")
const VARIANT_ACTION_INPUT_UI := preload("res://addons/flowkit/editor/Ui/actionInputs/variant_input_ui.gd")
const VECTOR2_ACTION_INPUT := preload("res://addons/flowkit/runtime/ActionInputs/vector2_action_input.gd")
const VECTOR3_ACTION_INPUT := preload("res://addons/flowkit/runtime/ActionInputs/vector3_action_input.gd")
const VECTOR4_ACTION_INPUT := preload("res://addons/flowkit/runtime/ActionInputs/vector4_action_input.gd")

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

func test_factory_creates_vector2_input_ui():
	var input := VECTOR2_ACTION_INPUT.new("Velocity")
	var input_ui: Variant = factory.create_from(input)
	add_child(input_ui)

	assert_eq(input_ui.get_class(), "FKVector2ActionInputUi")
	assert_eq(input_ui.input_label.text, "Velocity")
	input_ui.free()

func test_factory_creates_vector3_input_ui():
	var input := VECTOR3_ACTION_INPUT.new("Position")
	var input_ui: Variant = factory.create_from(input)
	add_child(input_ui)

	assert_eq(input_ui.get_class(), "FKVector3ActionInputUi")
	assert_eq(input_ui.input_label.text, "Position")
	input_ui.free()

func test_factory_creates_vector4_input_ui():
	var input := VECTOR4_ACTION_INPUT.new("Quaternion Values")
	var input_ui: Variant = factory.create_from(input)
	add_child(input_ui)

	assert_eq(input_ui.get_class(), "FKVector4ActionInputUi")
	assert_eq(input_ui.input_label.text, "Quaternion Values")
	input_ui.free()

func test_factory_creates_string_input_ui():
	var input := FKStringActionInput.new("Message")
	var input_ui: Variant = factory.create_from(input)
	add_child(input_ui)

	assert_same(input_ui.get_script(), STRING_ACTION_INPUT_UI)
	assert_eq(input_ui.input_label.text, "Message")
	input_ui.free()

func test_factory_creates_variant_input_ui():
	var input := FKActionInput.new("Value", "Variant")
	var input_ui: Variant = factory.create_from(input)
	add_child(input_ui)

	assert_same(input_ui.get_script(), VARIANT_ACTION_INPUT_UI)
	assert_eq(input_ui.input_label.text, "Value")
	input_ui.free()