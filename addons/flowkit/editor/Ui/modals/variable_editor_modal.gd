extends Window

@export var var_ui_holder: Control
@export var add_button: Button 
@export var save_button: Button 
@export var cancel_button: Button

func legitimize():
	if not _is_editor_preview:
		return

	_is_editor_preview = false
	pass

var _is_editor_preview := true

func _enter_tree() -> void:
	if _is_editor_preview:
		return 
	
	_toggle_subs(true)

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

var _is_subbed := false

func _on_add_button_pressed():
	
	pass

func _on_save_button_pressed():
	pass

func _on_cancel_button_pressed():
	pass


func _exit_tree() -> void:
	if _is_editor_preview:
		return
	_toggle_subs(false)