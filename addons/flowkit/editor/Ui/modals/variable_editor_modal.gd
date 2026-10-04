@tool
extends FKModalWindow
class_name FKVariableEditorModal

@export var var_ui_holder: Control
@export var add_button: Button 
@export var save_button: Button 
@export var cancel_button: Button
@export var add_var_popup: PopupMenu

func _enter_tree() -> void:
	if _is_editor_preview:
		return 
	
	super._enter_tree()
	_register_type_names()
	transient = false
	exclusive = false
	always_on_top = true

func _ready() -> void:
	if _is_editor_preview:
		return
	_ensure_node_picker()

## A dedicated select-node modal, so picks made here don't go through the shared
## modal signals (which drive the main editor's add/edit workflows).
var _node_picker: FKSelectNodeModal

## The FKNodeVariableUi waiting on _node_picker.
var _pending_node_pick_ui: FKNodeVariableUi

func _ensure_node_picker():
	if _node_picker != null:
		return
	var scene: PackedScene = load(FKModalPaths.SELECT_NODE_MODAL)
	_node_picker = scene.instantiate() as FKSelectNodeModal
	_node_picker.editor_globals = editor_globals
	_node_picker.broadcast_selection = false
	_node_picker.include_system_option = false
	_node_picker.require_compatible_events = false
	_node_picker.visible = false
	add_child(_node_picker) # As a child of ours, it gets shown above us
	_node_picker.legitimize()
	_node_picker.node_chosen.connect(_on_node_picker_node_chosen)

func _on_node_pick_requested(requester: FKNodeVariableUi):
	var scene_root := _editor_interface.get_edited_scene_root()
	if scene_root == null:
		push_warning("[%s] Open a scene to select a node from." % get_class())
		return
	_ensure_node_picker()
	_pending_node_pick_ui = requester
	_node_picker.populate_from_scene(scene_root)
	_node_picker.popup_centered()

func _on_node_picker_node_chosen(node_path: String, _node_class: String):
	var requester := _pending_node_pick_ui
	_pending_node_pick_ui = null
	if requester != null and _active_var_uis.has(requester):
		requester.set_picked_path(NodePath(node_path))

func _set_subs(wants_subs_active: bool):
	if wants_subs_active and not _is_subbed:
		add_button.pressed.connect(_on_add_button_pressed)
		save_button.pressed.connect(_on_save_button_pressed)
		cancel_button.pressed.connect(_on_close_attempt)
		close_requested.connect(_on_close_attempt)
		add_var_popup.id_pressed.connect(_on_var_type_id_pressed)
		visibility_changed.connect(_on_visibility_changed)
	elif _is_subbed and not wants_subs_active:
		add_button.pressed.disconnect(_on_add_button_pressed)
		save_button.pressed.disconnect(_on_save_button_pressed)
		cancel_button.pressed.disconnect(_on_close_attempt)
		close_requested.disconnect(_on_close_attempt)
		add_var_popup.id_pressed.disconnect(_on_var_type_id_pressed)
		visibility_changed.disconnect(_on_visibility_changed)
	else:
		return

	_is_subbed = !_is_subbed

func _register_type_names():
	_type_names = editor_globals.var_registry.get_type_names()

var _type_names: Array[String]

func _on_add_button_pressed():
	_refresh_var_type_popup()
	_position_popup_at_mouse()
	add_var_popup.show()

func _refresh_var_type_popup():
	add_var_popup.clear()
	for elem in _type_names:
		add_var_popup.add_item(elem)

func _position_popup_at_mouse():
	var mouse_pos := add_button.get_global_mouse_position()
	mouse_pos.x += self.position.x
	mouse_pos.y += self.position.y
	add_var_popup.position = mouse_pos

func _on_save_button_pressed():
	if _var_manager == null:
		return

	# Names may still be uncommitted (e.g. typed but never confirmed). The ones
	# earlier in the list get to keep theirs.
	var taken := _get_names_of_undisplayed_vars()
	for var_ui in _active_var_uis:
		if not _pending_removals.has(var_ui.get_variable()):
			taken[_resolve_unique_name(var_ui, taken)] = true

	for var_ui in _active_var_uis:
		if _pending_removals.has(var_ui.get_variable()):
			continue
		if not var_ui.apply_to_variable():
			push_warning("[%s] Could not apply all of the edits for %s." % [get_class(), var_ui.get_variable()])

	for new_var in _new_vars:
		_var_manager.add_var(new_var)
	for removed_var in _pending_removals:
		_var_registry.remove_var_from(_var_manager, removed_var)

	# Those are all in their final places now, so they shouldn't be discarded on hide.
	_new_vars.clear()
	_pending_removals.clear()
	hide()

func _on_close_attempt():
	hide()

func _on_var_type_id_pressed(id: int):
	var type_we_want := add_var_popup.get_item_text(id)
	var new_var := _var_registry.get_variable_of_type(type_we_want)
	if new_var == null:
		return
	new_var.key = _make_unique_name(_default_name_for(new_var), _get_taken_names())
	_new_vars.append(new_var)
	_add_entry_for(new_var)

func _default_name_for(variable: FKVariable) -> String:
	var type_name := variable.type_display_name().strip_edges().to_snake_case()
	return "new_%s" % type_name if not type_name.is_empty() else "new_variable"

## Returns base if it isn't taken. Otherwise, base with the lowest numeric suffix (from 2) that is.
func _make_unique_name(base: String, taken: Dictionary) -> String:
	if not taken.has(base):
		return base

	var suffix := 2
	while taken.has("%s_%d" % [base, suffix]):
		suffix += 1
	return "%s_%d" % [base, suffix]

## The names that would be in the holder if the user saved right now, as a set.
## Anything the user typed counts, saved or not. Variables pending removal don't.
func _get_taken_names(excluding: FKVariableUi = null) -> Dictionary:
	var taken := _get_names_of_undisplayed_vars()
	for var_ui in _active_var_uis:
		if var_ui == excluding or _pending_removals.has(var_ui.get_variable()):
			continue
		taken[var_ui.name_field.text.strip_edges()] = true
	return taken

## For variables in the holder that have no editor to show them in.
func _get_names_of_undisplayed_vars() -> Dictionary:
	var names := {}
	if _var_manager == null:
		return names

	var displayed_vars: Array[FKVariable] = []
	for var_ui in _active_var_uis:
		displayed_vars.append(var_ui.get_variable())

	for variable in _var_manager.get_variables():
		if not displayed_vars.has(variable) and not _pending_removals.has(variable):
			names[variable.key] = true
	return names

## Makes the name in the ui's name field non-empty and not in taken, and returns it.
func _resolve_unique_name(var_ui: FKVariableUi, taken: Dictionary) -> String:
	var wanted := var_ui.name_field.text.strip_edges()
	if wanted.is_empty():
		wanted = _default_name_for(var_ui.get_variable())

	var result := _make_unique_name(wanted, taken)
	if result != var_ui.name_field.text:
		var_ui.name_field.text = result
	return result

func _on_var_ui_name_committed(var_ui: FKVariableUi):
	_resolve_unique_name(var_ui, _get_taken_names(var_ui))

var _var_registry: FKVariableRegistry:
	get:
		return editor_globals.var_registry

## Variables made here that aren't in the holder's manager yet (they are, once saved).
var _new_vars: Array[FKVariable] = []

## Variables in the holder that the user asked to remove, which happens on save.
var _pending_removals: Array[FKVariable] = []

func _add_entry_for(to_add_for: FKVariable):
	var ui_entry := var_ui_pool.acquire(to_add_for)
	if ui_entry == null:
		return
	ui_entry.removal_requested.connect(_on_var_ui_removal_requested)
	ui_entry.name_committed.connect(_on_var_ui_name_committed)
	if ui_entry is FKNodeVariableUi:
		(ui_entry as FKNodeVariableUi).node_pick_requested.connect(_on_node_pick_requested)
	var_ui_holder.add_child(ui_entry)
	_active_var_uis.append(ui_entry)

func _on_var_ui_removal_requested(requester: FKVariableUi):
	var to_remove := requester.get_variable()
	if _new_vars.has(to_remove):
		# It was never in the holder, so there's nothing to save or undo.
		_new_vars.erase(to_remove)
		_release_var_ui(requester)
		to_remove.release()
	else:
		_pending_removals.append(to_remove)
		requester.hide()

var var_ui_pool: FKVariableUiPool:
	get:
		return editor_globals.variable_ui_pool

## The FKVariableUis currently displayed in var_ui_holder.
var _active_var_uis: Array[FKVariableUi] = []

func _on_visibility_changed():
	if not visible:
		if _node_picker != null:
			_node_picker.hide()
		_pending_node_pick_ui = null
		_discard_unsaved_changes()
		return
	# Showing always starts from a clean slate of UIs, rebuilt from the holder
	# (set_for is typically called right before show()).
	_refresh_based_on_holder()

func _release_var_uis():
	for var_ui in _active_var_uis.duplicate():
		_release_var_ui(var_ui)

func _release_var_ui(var_ui: FKVariableUi):
	var_ui.removal_requested.disconnect(_on_var_ui_removal_requested)
	var_ui.name_committed.disconnect(_on_var_ui_name_committed)
	if var_ui is FKNodeVariableUi:
		(var_ui as FKNodeVariableUi).node_pick_requested.disconnect(_on_node_pick_requested)
		if _pending_node_pick_ui == var_ui:
			_pending_node_pick_ui = null
	var_ui.show() # It may have been hidden due to a pending removal
	var_ui_pool.release(var_ui)
	_active_var_uis.erase(var_ui)

# Edits live in the UIs' widgets, so releasing the UIs gets rid of those. What's left
# is what the modal itself is tracking.
func _discard_unsaved_changes():
	_release_var_uis()
	for new_var in _new_vars:
		new_var.release()
	_new_vars.clear()
	_pending_removals.clear()

func _populate_var_uis():
	if not _var_manager:
		return
	for elem in _var_manager.get_variables():
		if elem != null:
			_add_entry_for(elem)

func set_for(variable_holder):
	_last_holder = null
	if variable_holder == null:
		self.title = "[No Variable Holder Selected]"
	elif variable_holder is FKEventSheet:
		var sheet := variable_holder as FKEventSheet
		self.title = sheet.resource_name
		_last_holder = variable_holder
	else:
		push_warning("[%s] Unsupported variable holder: %s" % [get_class(), variable_holder])
		self.title = "[Unsupported Variable Holder]"

	_refresh_based_on_holder()

var _last_holder

var _var_manager: FKVariableManager:
	get:
		if _last_holder is FKEventSheet:
			return (_last_holder as FKEventSheet).variable_manager
		return null

func _refresh_based_on_holder():
	_discard_unsaved_changes()
	_populate_var_uis()

func get_class() -> String:
	return "FKVariableEditorModal"