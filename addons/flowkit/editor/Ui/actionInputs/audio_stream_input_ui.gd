@tool
extends FKActionInputUi
class_name FKAudioStreamActionInputUi

@export var resource_picker: EditorResourcePicker

func _ready() -> void:
	super._ready()
	if is_editor_preview:
		return
	# The general action input modal is always-on-top, so the windows the picker
	# opens (menu, quick load, file dialogs) would otherwise be hidden behind it.
	# It creates some of them lazily, so catch them as they're added.
	for child in resource_picker.get_children(true):
		_raise_if_window(child)
	
	_raise_editor_quick_open()

func _raise_if_window(node: Node) -> void:
	if node is Window:
		node.always_on_top = true
	if node is PopupMenu and not node.id_pressed.is_connected(_on_picker_menu_id_pressed):
		node.id_pressed.connect(_on_picker_menu_id_pressed)

func _on_picker_menu_id_pressed(_id: int) -> void:
	_raise_editor_quick_open()

## The "Quick Load" dialog belongs to the editor, not the picker, so it has to be
## found under the editor's base control.
func _raise_editor_quick_open() -> void:
	var base := EditorInterface.get_base_control()
	if base == null:
		return
	for dialog in base.find_children("*", "EditorQuickOpenDialog", true, false):
		dialog.always_on_top = true

func _set_subs(on: bool):
	var was_subbed := _is_subbed
	super._set_subs(on)
	if was_subbed == _is_subbed:
		return

	if _is_subbed:
		resource_picker.resource_changed.connect(_on_resource_picker_resource_changed)
		resource_picker.child_entered_tree.connect(_raise_if_window)
	else:
		resource_picker.resource_changed.disconnect(_on_resource_picker_resource_changed)
		resource_picker.child_entered_tree.disconnect(_raise_if_window)

func _on_resource_picker_resource_changed(_resource: Resource) -> void:
	if not _is_populating:
		_is_dirty = true

func get_value() -> Variant:
	return get_value_or_expression(resource_picker.edited_resource)

func _can_hold_value(val: Variant) -> bool:
	return val == null or val is AudioStream

func _set_value(value: Variant) -> void:
	resource_picker.edited_resource = value

func _is_expression(value: Variant) -> bool:
	if value is String and ResourceLoader.exists(value, "AudioStream"):
		return false
	return super._is_expression(value)

func get_class() -> String:
	return "FKAudioStreamActionInputUi"