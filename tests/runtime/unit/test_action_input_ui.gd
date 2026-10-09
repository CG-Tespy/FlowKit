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

const NEEDS_EDITOR_CLASSES := "EditorResourcePicker only exists in the editor."

class TestEditorGlobals extends FKEditorGlobals:
	var auto_enclose_strings := false

	func should_auto_enclose_string_inputs() -> bool:
		return auto_enclose_strings

func _new_editor_globals(auto_enclose_strings := false) -> FKEditorGlobals:
	var editor_globals := TestEditorGlobals.new()
	editor_globals.auto_enclose_strings = auto_enclose_strings
	return editor_globals

func test_float_input_ui_uses_input_name_and_value():
	var input_ui: FKActionInputUi = FLOAT_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKFloatActionInput.new("Speed", "", 1.0), _new_editor_globals())
	add_child(input_ui)

	input_ui.try_set_value(2.5)

	assert_eq(input_ui.input_label.text, "Speed")
	assert_eq(input_ui.get_value(), 2.5)
	input_ui.free()

func test_integer_input_ui_uses_input_name_and_value():
	var input_ui: Variant = INTEGER_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKIntActionInput.new("Lives", "", 3), _new_editor_globals())
	add_child(input_ui)

	input_ui.try_set_value(7.9)

	assert_eq(input_ui.input_label.text, "Lives")
	assert_eq(input_ui.spin_box.value, 7.0)
	assert_eq(input_ui.get_value(), 7.9)
	input_ui.free()

func test_integer_input_ui_preserves_expression_text():
	var input_ui: FKActionInputUi = INTEGER_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKIntActionInput.new("Lives", "", 3), _new_editor_globals())
	add_child(input_ui)

	input_ui.try_set_value("node.position.x + 10")

	assert_true(input_ui.is_expression_mode)
	assert_eq(input_ui.expression_line_edit.text, "node.position.x + 10")
	assert_eq(input_ui.get_value(), "node.position.x + 10")
	input_ui.free()

func test_bool_input_ui_uses_input_name_and_value():
	var input_ui: FKActionInputUi = BOOL_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKBoolActionInput.new("Enabled", "", false), _new_editor_globals())
	add_child(input_ui)

	input_ui.try_set_value(true)

	assert_eq(input_ui.input_label.text, "Enabled")
	assert_true(input_ui.get_value())
	input_ui.free()

func test_color_input_ui_uses_input_name_and_value():
	var input_ui: FKActionInputUi = COLOR_INPUT_SCENE.instantiate()
	var expected_color := Color(0.2, 0.4, 0.6, 0.8)
	input_ui.legitimize(FKActionInput.new("Tint", "Color"), _new_editor_globals())
	add_child(input_ui)

	input_ui.try_set_value(expected_color)

	assert_eq(input_ui.input_label.text, "Tint")
	assert_eq(input_ui.get_value(), expected_color)
	input_ui.free()

func test_vector2_input_ui_uses_input_name_and_value():
	var input_ui: FKActionInputUi = VECTOR2_INPUT_SCENE.instantiate()
	var expected_vector := Vector2(2.5, -7.0)
	input_ui.legitimize(VECTOR2_ACTION_INPUT.new("Velocity"), _new_editor_globals())
	add_child(input_ui)

	input_ui.try_set_value(expected_vector)

	assert_eq(input_ui.input_label.text, "Velocity")
	assert_eq(input_ui.get_value(), expected_vector)
	input_ui.free()

func test_vector3_input_ui_preserves_expression_text():
	var input_ui: FKActionInputUi = VECTOR3_INPUT_SCENE.instantiate()
	input_ui.legitimize(VECTOR3_ACTION_INPUT.new("Position"), _new_editor_globals())
	add_child(input_ui)

	input_ui.try_set_value("node.global_position + Vector3.UP")

	assert_true(input_ui.is_expression_mode)
	assert_eq(input_ui.get_value(), "node.global_position + Vector3.UP")
	input_ui.free()

func test_vector4_input_ui_uses_input_name_and_value():
	var input_ui: FKActionInputUi = VECTOR4_INPUT_SCENE.instantiate()
	var expected_vector := Vector4(1.0, 2.5, -3.0, 4.25)
	input_ui.legitimize(VECTOR4_ACTION_INPUT.new("Quaternion Values"), _new_editor_globals())
	add_child(input_ui)

	input_ui.try_set_value(expected_vector)

	assert_eq(input_ui.input_label.text, "Quaternion Values")
	assert_eq(input_ui.get_value(), expected_vector)
	input_ui.free()

func test_audio_stream_input_ui_uses_input_name_and_value():
	if not ClassDB.can_instantiate("EditorResourcePicker"):
		pending(NEEDS_EDITOR_CLASSES)
		return
	var input_ui: FKActionInputUi = AUDIO_STREAM_INPUT_SCENE.instantiate()
	var expected_stream := load("res://addons/flowkit/assets/correct.ogg") as AudioStream
	input_ui.legitimize(AUDIO_STREAM_ACTION_INPUT.new("Correct Answer"), _new_editor_globals())
	add_child(input_ui)

	input_ui.try_set_value(expected_stream)

	assert_eq(input_ui.input_label.text, "Correct Answer")
	assert_same(input_ui.resource_picker.edited_resource, expected_stream)
	assert_same(input_ui.get_value(), expected_stream)
	input_ui.free()

func test_audio_stream_input_ui_returns_the_picked_stream():
	if not ClassDB.can_instantiate("EditorResourcePicker"):
		pending(NEEDS_EDITOR_CLASSES)
		return
	var input_ui: FKActionInputUi = AUDIO_STREAM_INPUT_SCENE.instantiate()
	var picked_stream := load("res://addons/flowkit/assets/correct.ogg") as AudioStream
	input_ui.legitimize(AUDIO_STREAM_ACTION_INPUT.new("Correct Answer"), _new_editor_globals())
	add_child(input_ui)
	input_ui.try_set_value(null)

	input_ui.resource_picker.edited_resource = picked_stream
	input_ui.resource_picker.resource_changed.emit(picked_stream)

	assert_same(input_ui.get_value(), picked_stream)
	input_ui.free()

func test_audio_stream_input_ui_loads_stream_from_saved_path():
	if not ClassDB.can_instantiate("EditorResourcePicker"):
		pending(NEEDS_EDITOR_CLASSES)
		return
	var input_ui: FKActionInputUi = AUDIO_STREAM_INPUT_SCENE.instantiate()
	var path := "res://addons/flowkit/assets/correct.ogg"
	input_ui.legitimize(AUDIO_STREAM_ACTION_INPUT.new("Correct Answer"), _new_editor_globals())
	add_child(input_ui)

	input_ui.try_set_value(path)

	assert_false(input_ui.is_expression_mode)
	assert_eq(input_ui.resource_picker.edited_resource.resource_path, path)
	input_ui.free()

func test_string_input_ui_uses_input_name_and_value():
	var input_ui: FKActionInputUi = STRING_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKStringActionInput.new("Message", "", "Hello"), _new_editor_globals())
	add_child(input_ui)

	input_ui.try_set_value("Updated message")

	assert_eq(input_ui.input_label.text, "Message")
	assert_eq(input_ui.get_value(), "Updated message")
	input_ui.free()

func test_string_input_ui_auto_encloses_when_enabled():
	var input_ui: FKActionInputUi = STRING_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKStringActionInput.new("Message", "", "Hello"), _new_editor_globals(true))
	add_child(input_ui)

	input_ui.try_set_value("Original")
	input_ui.line_edit.text = "Updated message"
	input_ui._on_literal_control_gui_input(null)

	assert_eq(input_ui.get_value(), "\"Updated message\"")
	input_ui.free()

func test_string_input_ui_preserves_untouched_quoted_literal():
	var input_ui: FKActionInputUi = STRING_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKStringActionInput.new("Message", "", "Hello"), _new_editor_globals())
	add_child(input_ui)

	input_ui.try_set_value("\"Saved message\"")

	assert_eq(input_ui.line_edit.text, "Saved message")
	assert_eq(input_ui.get_value(), "\"Saved message\"")
	input_ui.free()

func test_string_input_ui_does_not_double_enclose_edited_quoted_literal():
	var input_ui: FKActionInputUi = STRING_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKStringActionInput.new("Message", "", "Hello"), _new_editor_globals())
	add_child(input_ui)

	input_ui.try_set_value("Original")
	input_ui.line_edit.text = "\"Updated message\""
	input_ui._on_literal_control_gui_input(null)

	assert_eq(input_ui.get_value(), "\"Updated message\"")
	input_ui.free()

func test_variant_input_ui_preserves_expression_text():
	var input_ui: FKActionInputUi = VARIANT_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKActionInput.new("Value", "Variant"), _new_editor_globals())
	add_child(input_ui)

	input_ui.try_set_value("node.position.x + 10")

	assert_eq(input_ui.input_label.text, "Value")
	assert_eq(input_ui.get_value(), "node.position.x + 10")
	input_ui.free()

func test_variant_input_ui_encloses_literal_text():
	var input_ui: FKActionInputUi = VARIANT_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKActionInput.new("Value", "Variant"), _new_editor_globals(true))
	add_child(input_ui)

	input_ui.try_set_value(1)
	input_ui.line_edit.text = "Updated value"
	input_ui._on_literal_control_gui_input(null)

	assert_eq(input_ui.get_value(), "\"Updated value\"")
	input_ui.free()

func test_variant_input_ui_does_not_double_enclose_literal_text():
	var input_ui: FKActionInputUi = VARIANT_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKActionInput.new("Value", "Variant"), _new_editor_globals(true))
	add_child(input_ui)

	input_ui.try_set_value(1)
	input_ui.line_edit.text = "\"Updated value\""
	input_ui._on_literal_control_gui_input(null)

	assert_eq(input_ui.get_value(), "\"Updated value\"")
	input_ui.free()
func _make_float_input_ui(sheet: FKEventSheet) -> FKActionInputUi:
	var editor_globals := _new_editor_globals()
	editor_globals.current_sheet = sheet
	var input_ui: FKActionInputUi = FLOAT_INPUT_SCENE.instantiate()
	input_ui.legitimize(FKFloatActionInput.new("Speed", "", 1.0), editor_globals)
	add_child(input_ui)
	return input_ui

func _make_sheet_with_vars() -> FKEventSheet:
	var sheet := FKEventSheet.new()
	for variable in [FKNumberVariable.new(), FKStringVariable.new(), FKBoolVariable.new()]:
		sheet.variable_manager.add_var(variable)
	sheet.variable_manager.get_variables()[0].key = "speed"
	sheet.variable_manager.get_variables()[1].key = "title"
	return sheet

func test_toggle_cycles_through_literal_variable_and_expression_modes():
	var input_ui := _make_float_input_ui(null)
	assert_eq(input_ui.input_mode, FKActionInputUi.InputMode.LITERAL)
	assert_true(input_ui.literal_control.visible)

	input_ui.expression_toggle.pressed.emit()
	assert_eq(input_ui.input_mode, FKActionInputUi.InputMode.VARIABLE)
	assert_true(input_ui.variable_menu.visible)
	assert_false(input_ui.literal_control.visible)
	assert_false(input_ui.expression_line_edit.visible)

	input_ui.expression_toggle.pressed.emit()
	assert_eq(input_ui.input_mode, FKActionInputUi.InputMode.EXPRESSION)
	assert_true(input_ui.expression_line_edit.visible)
	assert_false(input_ui.variable_menu.visible)

	input_ui.expression_toggle.pressed.emit()
	assert_eq(input_ui.input_mode, FKActionInputUi.InputMode.LITERAL)
	assert_true(input_ui.literal_control.visible)
	input_ui.free()

func test_variable_mode_lists_only_variables_matching_the_input_type():
	var input_ui := _make_float_input_ui(_make_sheet_with_vars())

	input_ui.expression_toggle.pressed.emit()

	var popup := input_ui.variable_menu.get_popup()
	assert_eq(popup.item_count, 1)
	assert_eq(popup.get_item_text(0), "speed")
	assert_false(input_ui.variable_menu.disabled)
	assert_eq(input_ui.variable_menu.text, FKActionInputUi.PICK_VARIABLE_TEXT)
	input_ui.free()

func test_variable_mode_warns_when_no_variable_matches():
	var sheet := FKEventSheet.new()
	sheet.variable_manager.add_var(FKStringVariable.new())
	var input_ui := _make_float_input_ui(sheet)

	input_ui.expression_toggle.pressed.emit()

	assert_eq(input_ui.variable_menu.get_popup().item_count, 0)
	assert_true(input_ui.variable_menu.disabled)
	assert_eq(input_ui.variable_menu.text, "No valid vars in sheet!")
	input_ui.free()

func test_variable_mode_warns_when_there_is_no_sheet():
	var input_ui := _make_float_input_ui(null)

	input_ui.expression_toggle.pressed.emit()

	assert_true(input_ui.variable_menu.disabled)
	assert_eq(input_ui.variable_menu.text, FKActionInputUi.NO_VARIABLES_TEXT)
	input_ui.free()

func test_picked_variable_becomes_a_reference_to_it():
	var sheet := _make_sheet_with_vars()
	var speed: FKVariable = sheet.variable_manager.get_variables()[0]
	var input_ui := _make_float_input_ui(sheet)
	input_ui.try_set_value(2.0)

	input_ui.expression_toggle.pressed.emit()
	var popup := input_ui.variable_menu.get_popup()
	popup.id_pressed.emit(popup.get_item_id(0))

	var value: Variant = input_ui.get_value()
	assert_true(value is FKVariableRef)
	assert_eq(value.variable_id, speed.id)
	input_ui.free()

func test_variable_mode_without_a_pick_falls_back_to_the_literal():
	var input_ui := _make_float_input_ui(_make_sheet_with_vars())
	input_ui.try_set_value(2.0)

	input_ui.expression_toggle.pressed.emit()

	assert_eq(input_ui.get_value(), input_ui.spin_box.value)
	input_ui.free()

func test_existing_variable_reference_is_shown_in_variable_mode():
	var sheet := _make_sheet_with_vars()
	var speed: FKVariable = sheet.variable_manager.get_variables()[0]
	var input_ui := _make_float_input_ui(sheet)

	input_ui.try_set_value(FKVariableRef.to(speed))

	assert_true(input_ui.is_variable_mode)
	assert_true(input_ui.variable_menu.visible)
	assert_eq(input_ui.variable_menu.text, "speed")
	assert_eq(input_ui.get_value().variable_id, speed.id)
	input_ui.free()

func test_reference_to_a_missing_variable_is_kept_and_flagged():
	var ref := FKVariableRef.new()
	ref.variable_id = 99
	var input_ui := _make_float_input_ui(_make_sheet_with_vars())

	input_ui.try_set_value(ref)

	assert_eq(input_ui.variable_menu.text, FKActionInputUi.MISSING_VARIABLE_TEXT)
	assert_eq(input_ui.get_value().variable_id, 99)
	input_ui.free()
