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
	_new_vars.append(new_var)
	_add_entry_for(new_var)

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