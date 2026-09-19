extends RefCounted
class_name FKActionInputUiPool

func _init(editor_globals: FKEditorGlobals, factory: FKActionInputUiFactory) -> void:
	_factory = factory
	editor_globals.modal_signals.action_input_ui_release_requested.connect(_on_action_input_ui_release_requested)

var _factory: FKActionInputUiFactory
var _available_input_uis: Dictionary[String, Array] = {}

func acquire(action_input: FKActionInput) -> FKActionInputUi:
	var input_ui_class := "%s:%s" % [action_input.get_real_class(), action_input.type]

	if not _available_input_uis.has(input_ui_class):
		return _factory.create_from(action_input)

	var available_input_uis: Array = _available_input_uis[input_ui_class]
	if available_input_uis.is_empty():
		return _factory.create_from(action_input)

	var input_ui := available_input_uis.pop_back() as FKActionInputUi
	input_ui.set_action_input(action_input)
	return input_ui

func _on_action_input_ui_release_requested(input_ui: FKActionInputUi) -> void:
	var parent := input_ui.get_parent()
	if parent != null:
		parent.remove_child(input_ui)

	var input_ui_class := "%s:%s" % [input_ui.action_input.get_real_class(), input_ui.action_input.type]
	if not _available_input_uis.has(input_ui_class):
		_available_input_uis[input_ui_class] = []
	_available_input_uis[input_ui_class].append(input_ui)