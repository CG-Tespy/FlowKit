@tool
extends FKModalWindow
class_name FKVariableEditorModal

@export var var_ui_holder: Control
@export var add_button: Button 
@export var save_button: Button 
@export var cancel_button: Button
@export var var_type_popup: PopupMenu

func _enter_tree() -> void:
	if _is_editor_preview:
		return 
	
	super._enter_tree()
	_register_type_names()
	# transient = false
	# exclusive = false
	# always_on_top = true

func _toggle_subs(wants_subs_active: bool):
	if wants_subs_active and not _is_subbed:
		add_button.pressed.connect(_on_add_button_pressed)
		save_button.pressed.connect(_on_save_button_pressed)
		cancel_button.pressed.connect(_on_cancel_button_pressed)
		pass
	elif _is_subbed and not wants_subs_active:
		add_button.pressed.disconnect(_on_add_button_pressed)
		save_button.pressed.disconnect(_on_save_button_pressed)
		cancel_button.pressed.disconnect(_on_cancel_button_pressed)
	else:
		return

	_is_subbed = !_is_subbed

func _register_type_names():
	_type_names = editor_globals.var_type_registry.get_type_names()

var _type_names: Array[String]

func _on_add_button_pressed():
	_refresh_var_type_popup()
	_position_popup_at_mouse()
	var_type_popup.show()

func _refresh_var_type_popup():
	var_type_popup.clear()
	for elem in _type_names:
		var_type_popup.add_item(elem)

func _position_popup_at_mouse():
	var mouse_pos := add_button.get_global_mouse_position()
	mouse_pos.x += self.position.x
	mouse_pos.y += self.position.y
	var_type_popup.position = mouse_pos

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

func get_class() -> String:
	return "FKVariableEditorModal"
