@tool
extends MenuBar
class_name FKSheetEditorMenuBar

@export_category("Popups")
@export var file_menu: PopupMenu
@export var edit_menu: PopupMenu
@export var variable_menu: PopupMenu

@export_category("Buttons")
@export var add_comment_btn: Button 
@export var add_group_btn: Button




func _enter_tree() -> void:
	_set_subs(true)

func _set_subs(wants_subs_active: bool):
	if wants_subs_active and not _is_subbed:
		file_menu.id_pressed.connect(_on_file_id_pressed)
		edit_menu.id_pressed.connect(_on_edit_id_pressed)

		add_comment_btn.pressed.connect(_on_add_comment_btn_pressed)
		add_group_btn.pressed.connect(_on_add_group_btn_pressed)
	elif _is_subbed and not wants_subs_active:
		file_menu.id_pressed.disconnect(_on_file_id_pressed)
		edit_menu.id_pressed.disconnect(_on_edit_id_pressed)

		add_comment_btn.pressed.disconnect(_on_add_comment_btn_pressed)
		add_group_btn.pressed.disconnect(_on_add_group_btn_pressed)
	else:
		return

	_is_subbed = !_is_subbed

var _is_subbed := false 

func _on_file_id_pressed(id: int) -> void:
	match id:
		0:
			new_sheet_requested.emit()
		1:
			save_sheet_requested.emit()

signal new_sheet_requested
signal save_sheet_requested

func _on_edit_id_pressed(id: int) -> void:
	match id:
		0: # Undo
			undo_requested.emit()
		1: # Redo
			redo_requested.emit()
		2: # Generate Providers (separator above)
			provider_generation_requested.emit()
		3: # Generate Manifest (for export)
			manifest_generation_requested.emit()

signal provider_generation_requested
signal manifest_generation_requested
signal undo_requested
signal redo_requested

func _on_add_comment_btn_pressed():
	add_comment_requested.emit()

signal add_comment_requested

func _on_add_group_btn_pressed():
	add_group_requested.emit()

signal add_group_requested

func _exit_tree() -> void:
	_set_subs(false)