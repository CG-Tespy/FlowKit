## For managing the modal windows of FlowKit's editor.
extends RefCounted
class_name FKModalManager

func _init(modal_holder: Control) -> void:
	self._modal_holder = modal_holder
	pass
	
var _modal_holder: Control
var _select_node_modal: FKSelectNodeModal
var _select_event_modal: FKSelectEventModal
var _select_condition_modal: FKSelectConditionModal
var _select_action_modal: FKSelectActionModal
var _expression_modal: FKExpressionEditorModal

func _prep_modals():
	_create_modals()
	_refresh_modal_cache()
	_hide_modals()
	_legitimize_modals()
	
func _create_modals():
	var path: String
	var scene: PackedScene = null
	
	path = FKModalPaths.SELECT_NODE_MODAL
	scene = load(path)
	_select_node_modal = scene.instantiate()
	add_child(_select_node_modal)
		
	path = FKModalPaths.SELECT_EVENT_MODAL
	scene = load(path)
	_select_event_modal = scene.instantiate()
	add_child(_select_event_modal)
		
	path = FKModalPaths.SELECT_CONDITION_MODAL
	scene = load(path)
	_select_condition_modal = scene.instantiate()
	add_child(_select_condition_modal)
		
	path = FKModalPaths	.SELECT_ACTION_MODAL
	scene = load(path)
	_select_action_modal = scene.instantiate()
	add_child(_select_action_modal)
	
	path = FKModalPaths.EXPRESSION_EDITOR_MODAL
	scene = load(path)
	_expression_modal = scene.instantiate()
	add_child(_expression_modal)
	
func add_child(node: Node):
	_modal_holder.add_child(node, true)

func _refresh_modal_cache():
	_modals.clear()
	for child in get_children():
		if child is FKModalWindow:
			_modals.append(child)
	
var _modals: Array[FKModalWindow] = []

func get_children() -> Array[Node]:
	if not _modal_holder:
		var error_message := "[FKModalManager]: Can't get children. Got no anchor."
		printerr(error_message)
		return []
	
	var result := _modal_holder.get_children()
	return result
	
func _hide_modals():
	for child in _modals:
		child.visible = false
	
func _legitimize_modals():
	for child in _modals:
		child.legitimize()
	
