## For managing the creation and access of the modal windows of FlowKit's editor.
extends Node
class_name FKModalManager

func initialize(editor_globals: FKEditorGlobals):
	name = "FKModalManager"
	self.editor_globals = editor_globals
	_prep_modals()

var editor_globals: FKEditorGlobals

func _prep_modals():
	_create_and_parent_all_our_modals()
	_refresh_modal_cache()
	_hide_modals()
	_legitimize_modals()

var modal_signals: FKModalSignals

func _create_and_parent_all_our_modals():
	var path: String
	path = FKModalPaths.SELECT_NODE_MODAL
	_select_node_modal = _create_and_parent_modal(path)
		
	path = FKModalPaths.SELECT_EVENT_MODAL
	_select_event_modal = _create_and_parent_modal(path)
	if not _select_event_modal:
		print("FKModalManager: Select event modal not properly set up")
	path = FKModalPaths.SELECT_CONDITION_MODAL
	_select_condition_modal = _create_and_parent_modal(path)
		
	path = FKModalPaths	.SELECT_ACTION_MODAL
	_select_action_modal = _create_and_parent_modal(path)
	
	path = FKModalPaths.EXPRESSION_EDITOR_MODAL
	_expression_modal = _create_and_parent_modal(path)

var _select_node_modal: FKSelectNodeModal
var _select_event_modal: FKSelectEventModal
var _select_condition_modal: FKSelectConditionModal
var _select_action_modal: FKSelectActionModal
var _expression_modal: FKExpressionEditorModal
var _action_input_modals: Dictionary[String, FKActionInputModal] = {}

func _create_and_parent_modal(path_to_scene: String) -> FKModalWindow:
	var scene: PackedScene = load(path_to_scene)
	var result: FKModalWindow = scene.instantiate()
	result.editor_globals = self.editor_globals
	add_child(result)
	return result
	
func _refresh_modal_cache():
	_modals.clear()
	for child in get_children():
		if child is FKModalWindow:
			_modals.append(child)
	
var _modals: Array[FKModalWindow] = [] 
# ^Saves us keystrokes for when we want to do something to all our 
# modals in the same frame

func _hide_modals():
	for child in _modals:
		child.visible = false
	
func _legitimize_modals():
	for child in _modals:
		child.legitimize()

func get_action_input_modal(action_provider: FKAction) -> FKActionInputModal:
	if action_provider == null:
		return null

	var scene := action_provider.get_input_modal_scene()
	if scene == null:
		return null

	var cache_key := scene.resource_path
	if cache_key.is_empty():
		cache_key = str(scene.get_instance_id())

	if _action_input_modals.has(cache_key):
		return _action_input_modals[cache_key]

	var instance := scene.instantiate()
	var modal := instance as FKActionInputModal
	if modal == null:
		instance.queue_free()
		printerr("FKModalManager: Action input modal for %s must extend FKActionInputModal" % \
			action_provider.get_provider_id())
		return null

	modal.editor_globals = editor_globals
	add_child(modal)
	modal.visible = false
	modal.legitimize()
	_action_input_modals[cache_key] = modal
	return modal

# Modal Accessors
var select_node_modal: FKSelectNodeModal:
	get:
		return _select_node_modal
		
var select_event_modal: FKSelectEventModal:
	get:
		return _select_event_modal
		
var select_condition_modal: FKSelectConditionModal:
	get:
		return _select_condition_modal
		
var select_action_modal: FKSelectActionModal:
	get:
		return _select_action_modal
		
var expression_modal: FKExpressionEditorModal:
	get:
		return _expression_modal
