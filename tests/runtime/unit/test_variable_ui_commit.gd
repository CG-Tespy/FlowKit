extends GutTest

const STRING_EDITOR := "res://addons/flowkit/editor/scenes/variableEditors/string_variable_editor.tscn"
const NUMBER_EDITOR := "res://addons/flowkit/editor/scenes/variableEditors/number_variable_editor.tscn"
const VECTOR_EDITOR := "res://addons/flowkit/editor/scenes/variableEditors/vector_variable_editor.tscn"
const COLOR_EDITOR := "res://addons/flowkit/editor/scenes/variableEditors/color_variable_editor.tscn"
const BOOL_EDITOR := "res://addons/flowkit/editor/scenes/variableEditors/bool_variable_editor.tscn"
const NODE_EDITOR := "res://addons/flowkit/editor/scenes/variableEditors/node_variable_editor.tscn"

func _make_ui(scene_path: String, variable: FKVariable) -> FKVariableUi:
	var ui := load(scene_path).instantiate() as FKVariableUi
	add_child(ui)
	ui.set_variable(variable)
	ui.legitimize()
	return ui

func test_string_edits_only_reach_the_variable_on_apply() -> void:
	var variable := FKStringVariable.new()
	variable.key = "Old"
	variable.set_value("Hello")
	var ui := _make_ui(STRING_EDITOR, variable) as FKStringVariableUi

	ui.name_field.text = "New"
	ui.name_field.focus_exited.emit()
	ui.value_field.text = "Hello world"
	ui.value_field.text_submitted.emit(ui.value_field.text)
	ui.value_field.focus_exited.emit()
	assert_eq(variable.key, "Old")
	assert_eq(variable.get_value(), "Hello")

	assert_true(ui.apply_to_variable())
	assert_eq(variable.key, "New")
	assert_eq(variable.get_value(), "Hello world")
	ui.free()

func test_refresh_reverts_unapplied_edits() -> void:
	var variable := FKStringVariable.new()
	variable.key = "Name"
	variable.set_value("Value")
	var ui := _make_ui(STRING_EDITOR, variable) as FKStringVariableUi

	ui.name_field.text = "Other"
	ui.value_field.text = "Other value"
	ui.refresh()

	assert_eq(ui.name_field.text, "Name")
	assert_eq(ui.value_field.text, "Value")
	ui.free()

func test_scope_is_applied_only_on_apply() -> void:
	var variable := FKStringVariable.new()
	var ui := _make_ui(STRING_EDITOR, variable) as FKStringVariableUi

	ui.access_scope_field.get_popup().id_pressed.emit(FKAccessScope.Keys.PUBLIC)
	assert_eq(ui.access_scope_field.text, "Public")
	assert_eq(variable.scope, FKAccessScope.Keys.PRIVATE)

	ui.apply_to_variable()
	assert_eq(variable.scope, FKAccessScope.Keys.PUBLIC)
	ui.free()

func test_unapplied_scope_is_reverted_by_refresh() -> void:
	var variable := FKStringVariable.new()
	var ui := _make_ui(STRING_EDITOR, variable) as FKStringVariableUi

	ui.access_scope_field.get_popup().id_pressed.emit(FKAccessScope.Keys.READONLY)
	ui.refresh()
	ui.apply_to_variable()

	assert_eq(variable.scope, FKAccessScope.Keys.PRIVATE)
	ui.free()

func test_apply_without_a_variable_returns_false() -> void:
	var ui := _make_ui(STRING_EDITOR, FKStringVariable.new()) as FKStringVariableUi
	ui.set_variable(null)

	assert_false(ui.apply_to_variable())
	ui.free()

func test_apply_emits_changed_on_the_variable() -> void:
	var variable := FKStringVariable.new()
	var ui := _make_ui(STRING_EDITOR, variable) as FKStringVariableUi
	watch_signals(variable)

	ui.apply_to_variable()

	assert_signal_emitted(variable, "changed")
	ui.free()

func test_number_applies_typed_text_and_whole_nums_setting() -> void:
	var variable := FKNumberVariable.new()
	var ui := _make_ui(NUMBER_EDITOR, variable) as FKNumberVariableUi

	ui.value_field.get_line_edit().text = "12.5"
	ui.whole_nums_only.button_pressed = true
	assert_eq(variable.get_value(), 0.0)
	assert_false(variable.whole_nums_only)

	assert_true(ui.apply_to_variable())
	assert_true(variable.whole_nums_only)
	assert_eq(variable.get_value(), 12.0)
	assert_eq(ui.value_field.value, 12.0)
	ui.free()

func test_vector_applies_all_components() -> void:
	var variable := FKVectorVariable.new()
	var ui := _make_ui(VECTOR_EDITOR, variable) as FKVectorVariableUi

	ui.x_field.get_line_edit().text = "3"
	ui.y_field.get_line_edit().text = "4"
	assert_eq(variable.get_value(), Vector4.ZERO)

	assert_true(ui.apply_to_variable())
	assert_eq(variable.get_value(), Vector4(3.0, 4.0, 0.0, 0.0))
	ui.free()

func test_vector_whole_nums_setting_is_applied_before_the_value() -> void:
	var variable := FKVectorVariable.new()
	var ui := _make_ui(VECTOR_EDITOR, variable) as FKVectorVariableUi

	ui.whole_nums_only.button_pressed = true
	ui.x_field.step = 0.01
	ui.x_field.get_line_edit().text = "2.7"
	assert_false(variable.whole_nums_only)

	ui.apply_to_variable()
	assert_true(variable.whole_nums_only)
	assert_eq(variable.get_value().x, 2.0)
	assert_eq(ui.x_field.value, 2.0)
	ui.free()

func test_color_applies_picked_color() -> void:
	var variable := FKColorVariable.new()
	var ui := _make_ui(COLOR_EDITOR, variable) as FKColorVariableUi
	var original: Color = variable.get_value()

	ui.value_field.color = Color.RED
	ui.value_field.popup_closed.emit()
	assert_eq(variable.get_value(), original)

	ui.apply_to_variable()
	assert_eq(variable.get_value(), Color.RED)
	ui.free()

func test_bool_applies_toggle_and_updates_its_label() -> void:
	var variable := FKBoolVariable.new()
	var ui := _make_ui(BOOL_EDITOR, variable) as FKBoolVariableUi

	ui.value_field.button_pressed = true
	assert_eq(ui.value_field.text, "On")
	assert_false(variable.get_value())

	ui.apply_to_variable()
	assert_true(variable.get_value())
	ui.free()

func test_node_path_applies_on_apply() -> void:
	var owner := Node.new()
	add_child(owner)
	var target := Node.new()
	target.name = "Target"
	owner.add_child(target)
	var other := Node.new()
	other.name = "Other"
	owner.add_child(other)
	var variable := FKNodeVariable.new()
	variable.set_owner(owner)
	variable.set_node_path(NodePath("Target"))
	var ui := _make_ui(NODE_EDITOR, variable) as FKNodeVariableUi

	assert_eq(ui.value_field.text, "Target")
	ui.set_picked_path(NodePath("Other"))
	assert_eq(variable.get_node_path(), NodePath("Target"))

	assert_true(ui.apply_to_variable())
	assert_eq(variable.get_node_path(), NodePath("Other"))

	ui.clear_button.pressed.emit()
	assert_eq(ui.value_field.text, FKNodeVariableUi.NO_NODE_TEXT)
	assert_eq(variable.get_node_path(), NodePath("Other"))
	ui.free()
	owner.free()
