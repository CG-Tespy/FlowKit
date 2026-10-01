extends GutTest

func _make_ui(scene_path: String, variable: FKVariable) -> FKVariableUi:
	var ui := load(scene_path).instantiate() as FKVariableUi
	add_child(ui)
	ui.set_variable(variable)
	ui.legitimize()
	return ui

func test_string_value_and_name_commit_on_finish() -> void:
	var variable := FKStringVariable.new()
	variable.key = "Old"
	variable.set_value("Hello")
	var ui := _make_ui("res://addons/flowkit/editor/scenes/variableEditors/string_variable_editor.tscn", variable) as FKStringVariableUi

	ui.name_field.text = "New"
	assert_eq(variable.key, "Old")
	ui.name_field.focus_exited.emit()

	ui.value_field.text = "Hello world"
	assert_eq(variable.get_value(), "Hello")
	ui.value_field.text_submitted.emit(ui.value_field.text)
	assert_eq(variable.get_value(), "Hello world")
	assert_eq(variable.key, "New")
	ui.free()

func test_string_value_commits_on_focus_loss() -> void:
	var variable := FKStringVariable.new()
	variable.set_value("Before")
	var ui := _make_ui("res://addons/flowkit/editor/scenes/variableEditors/string_variable_editor.tscn", variable) as FKStringVariableUi

	ui.value_field.text = "After"
	assert_eq(variable.get_value(), "Before")
	ui.value_field.focus_exited.emit()
	assert_eq(variable.get_value(), "After")
	ui.free()

func test_number_commits_after_edit_or_mouse_release() -> void:
	var variable := FKNumberVariable.new()
	var ui := _make_ui("res://addons/flowkit/editor/scenes/variableEditors/number_variable_editor.tscn", variable) as FKNumberVariableUi

	ui.value_field.get_line_edit().text = "12.5"
	assert_eq(variable.get_value(), 0.0)
	ui.value_field.get_line_edit().focus_exited.emit()
	assert_eq(variable.get_value(), 12.5)

	ui.value_field.value = 20.0
	assert_eq(variable.get_value(), 12.5)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	ui.value_field.gui_input.emit(release)
	assert_eq(variable.get_value(), 20.0)

	ui.value_field.get_line_edit().text = "32"
	ui.value_field.get_line_edit().text_submitted.emit("32")
	assert_eq(ui.value_field.value, 32.0)
	assert_eq(variable.get_value(), 32.0)

	ui.value_field.value = 33.0
	var key_release := InputEventKey.new()
	key_release.keycode = KEY_UP
	key_release.pressed = false
	ui.value_field.get_line_edit().gui_input.emit(key_release)
	assert_eq(variable.get_value(), 33.0)
	ui.free()

func test_vector_commits_after_component_edit_finishes() -> void:
	var variable := FKVectorVariable.new()
	var ui := _make_ui("res://addons/flowkit/editor/scenes/variableEditors/vector_variable_editor.tscn", variable) as FKVectorVariableUi

	ui.x_field.get_line_edit().text = "3"
	assert_eq(variable.get_value(), Vector4.ZERO)
	ui.x_field.get_line_edit().focus_exited.emit()
	assert_eq(variable.get_value(), Vector4(3.0, 0.0, 0.0, 0.0))
	ui.free()

func test_color_commits_when_picker_closes() -> void:
	var variable := FKColorVariable.new()
	var ui := _make_ui("res://addons/flowkit/editor/scenes/variableEditors/color_variable_editor.tscn", variable) as FKColorVariableUi
	var original: Color = variable.get_value()

	ui.value_field.color = Color.RED
	assert_eq(variable.get_value(), original)
	ui.value_field.popup_closed.emit()
	assert_eq(variable.get_value(), Color.RED)
	ui.free()

func test_node_path_commits_on_focus_loss() -> void:
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
	var ui := _make_ui("res://addons/flowkit/editor/scenes/variableEditors/node_variable_editor.tscn", variable) as FKNodeVariableUi

	ui.value_field.text = "Other"
	assert_eq(variable.get_node_path(), NodePath("Target"))
	ui.value_field.focus_exited.emit()
	assert_eq(variable.get_node_path(), NodePath("Other"))
	ui.free()
	owner.free()
