extends GutTest

const STRING_EDITOR := "res://addons/flowkit/editor/scenes/variableEditors/string_variable_editor.tscn"

var _modal: FKVariableEditorModal

func before_each() -> void:
	_modal = FKVariableEditorModal.new()

func after_each() -> void:
	_modal.free()

func _add_ui(key: String) -> FKVariableUi:
	var variable := FKStringVariable.new()
	variable.key = key
	var ui := load(STRING_EDITOR).instantiate() as FKVariableUi
	add_child_autofree(ui)
	ui.set_variable(variable)
	ui.legitimize()
	ui.name_committed.connect(_modal._on_var_ui_name_committed)
	_modal._active_var_uis.append(ui)
	return ui

func test_unique_name_is_kept_as_is() -> void:
	assert_eq(_modal._make_unique_name("health", {"mana": true}), "health")

func test_taken_name_gets_the_lowest_free_suffix() -> void:
	var taken := {"health": true, "health_2": true, "health_4": true}
	assert_eq(_modal._make_unique_name("health", taken), "health_3")

func test_default_name_comes_from_the_type() -> void:
	assert_eq(_modal._default_name_for(FKStringVariable.new()), "new_string")

func test_committing_a_duplicate_name_renames_the_one_edited() -> void:
	var first := _add_ui("health")
	var second := _add_ui("mana")

	second.name_field.text = "health"
	second.name_field.focus_exited.emit()

	assert_eq(first.name_field.text, "health")
	assert_eq(second.name_field.text, "health_2")

func test_committing_an_empty_name_gets_a_default_one() -> void:
	var ui := _add_ui("health")

	ui.name_field.text = "  "
	ui.name_field.text_submitted.emit(ui.name_field.text)

	assert_eq(ui.name_field.text, "new_string")

func test_keeping_your_own_name_is_not_a_conflict() -> void:
	var ui := _add_ui("health")
	ui.name_field.focus_exited.emit()
	assert_eq(ui.name_field.text, "health")

func test_pending_removals_free_up_their_names() -> void:
	var first := _add_ui("health")
	var second := _add_ui("mana")
	_modal._pending_removals.append(first.get_variable())

	second.name_field.text = "health"
	second.name_field.focus_exited.emit()

	assert_eq(second.name_field.text, "health")
