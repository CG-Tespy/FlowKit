extends RefCounted
class_name FKActionInputUiPool

func _init(editor_globals: FKEditorGlobals, factory: FKActionInputUiFactory) -> void:
	_factory = factory
	editor_globals.modal_signals.action_input_ui_release_requested.connect(_on_action_input_ui_release_requested)

var _factory: FKActionInputUiFactory
var _available_input_uis: Dictionary[String, Array] = {}

func acquire(action_input: FKActionInput) -> FKActionInputUi:
	var input_ui_class := _get_input_ui_class(action_input)
	if input_ui_class.is_empty():
		return _factory.create_from(action_input)

	if not _available_input_uis.has(input_ui_class):
		return _factory.create_from(action_input)

	var available_input_uis: Array[FKActionInputUi] = _available_input_uis[input_ui_class]
	if available_input_uis.is_empty():
		return _factory.create_from(action_input)

	var input_ui := available_input_uis.pop_back()
	input_ui.set_action_input(action_input)
	return input_ui

func _get_input_ui_class(action_input: FKActionInput) -> String:
	if action_input is FKBoolActionInput:
		return "FKBoolActionInputUi"
	if action_input is FKIntActionInput:
		return "FKIntActionInputUi"
	if action_input is FKFloatActionInput:
		return "FKFloatActionInputUi"
	if action_input is FKStringActionInput:
		return "FKStringActionInputUi"
	if action_input.type == "Color":
		return "FKColorActionInputUi"
	return "FKVariantActionInputUi"

func _on_action_input_ui_release_requested(input_ui: FKActionInputUi) -> void:
	var parent := input_ui.get_parent()
	if parent != null:
		parent.remove_child(input_ui)

	var input_ui_class := input_ui.get_class()
	if not _available_input_uis.has(input_ui_class):
		_available_input_uis[input_ui_class] = []
	_available_input_uis[input_ui_class].append(input_ui)