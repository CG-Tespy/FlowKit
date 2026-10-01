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
		cancel_button.pressed.connect(_on_cancel_button_pressed)
		close_requested.connect(_on_cancel_button_pressed)
		add_var_popup.id_pressed.connect(_on_var_type_id_pressed)
	elif _is_subbed and not wants_subs_active:
		add_button.pressed.disconnect(_on_add_button_pressed)
		save_button.pressed.disconnect(_on_save_button_pressed)
		cancel_button.pressed.disconnect(_on_cancel_button_pressed)
		close_requested.disconnect(_on_cancel_button_pressed)
		add_var_popup.id_pressed.disconnect(_on_var_type_id_pressed)
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

func _on_var_type_popup_id_pressed(id: int):
	push_warning("[%s] Variable-adding not yet implemented." % self.get_class())

func _on_save_button_pressed():
	push_warning("[%s] Variable-saving not yet implemented." % self.get_class())


func _on_cancel_button_pressed():
	hide()

func set_for(variable_holder):
	if variable_holder == null:
		self.title = "[No Variable Holder Selected]"
	elif variable_holder is FKEventSheet:
		var sheet := variable_holder as FKEventSheet
		self.title = sheet.resource_name
		_last_holder = variable_holder
		_refresh_var_cache()

var _last_holder

func _refresh_var_cache():
	if not _last_holder:
		return
	_var_cache.clear()
	var holder_vars: Array[FKVariable] = _last_holder.variables
	for elem in holder_vars:
		var dupe := elem.duplicate_deep()
		_var_cache.append(dupe)

## Stores copies of the vars to make it easier to only change the 
## real stuff when appropriate.
var _var_cache: Array[FKVariable] = []

func _on_var_type_id_pressed(id: int):
	var type_we_want := add_var_popup.get_item_text(id)
	var new_var := _var_registry.get_variable_of_type(type_we_want)
	_var_cache.append(new_var)
	_add_entry_for(new_var)
	pass

var _var_registry: FKVariableRegistry:
	get:
		return editor_globals.var_registry

func _add_entry_for(to_add_for: FKVariable):
	var ui_entry := var_ui_pool.acquire(to_add_for)
	if ui_entry == null:
		return
	var_ui_holder.add_child(ui_entry)

var var_ui_pool: FKVariableUiPool:
	get:
		return editor_globals.variable_ui_pool
func get_class() -> String:
	return "FKVariableEditorModal"
