@tool
extends EditorResourcePicker
## An EditorResourcePicker that shows the chosen resource's name, rather than the thumbnail
## the editor swaps it out for once one is generated (which, for audio, is a waveform).
##
## The name is shown by name_label, which this lines up with the picker's button. So that
## the label can be moved freely, the label and this picker should be children of a
## plain Control (not a Container). That Control gets sized to fit this picker.
class_name FKNamedResourcePicker

@export var name_label: Label

# The picker keeps these to itself, so we find them among its children.
var _assign_button: Button
var _preview_rect: TextureRect

# Thumbnails come in at the editor's pace, and each one overrides the button's text and
# size, so we have to keep checking rather than set things up once.
func _process(_delta: float) -> void:
	if _assign_button == null and not _find_internal_controls():
		return

	_preview_rect.visible = false
	if _assign_button.custom_minimum_size.y > MIN_BUTTON_HEIGHT:
		_assign_button.custom_minimum_size = Vector2(MIN_BUTTON_HEIGHT, MIN_BUTTON_HEIGHT)
	if not _assign_button.text.is_empty():
		_assign_button.text = "" # The label takes care of showing the name

	_fit_holder_to_self()
	_align_name_label()

## The button's height before a thumbnail raises it.
const MIN_BUTTON_HEIGHT := 1

func _find_internal_controls() -> bool:
	for child in get_children():
		var button := child as Button
		if button == null:
			continue
		for grandchild in button.get_children():
			if grandchild is TextureRect:
				_assign_button = button
				_preview_rect = grandchild
				return true
	return false

func _fit_holder_to_self() -> void:
	var holder := get_parent() as Control
	if holder == null or holder is Container:
		return

	var wanted_height := get_combined_minimum_size().y
	if not is_equal_approx(holder.custom_minimum_size.y, wanted_height):
		holder.custom_minimum_size.y = wanted_height

func _align_name_label() -> void:
	if name_label == null:
		return

	var style := _assign_button.get_theme_stylebox("normal")
	var left := style.get_margin(SIDE_LEFT)
	var right := style.get_margin(SIDE_RIGHT)
	var icon := _assign_button.icon
	if icon != null:
		left += icon.get_width() + _assign_button.get_theme_constant("h_separation")

	name_label.global_position = _assign_button.global_position + Vector2(left, 0)
	name_label.size = Vector2(maxf(_assign_button.size.x - left - right, 0.0), _assign_button.size.y)

	var display_name := _get_resource_display_name()
	if name_label.text != display_name:
		name_label.text = display_name
	name_label.tooltip_text = _assign_button.tooltip_text

func _get_resource_display_name() -> String:
	if edited_resource == null:
		return "<empty>"
	if not edited_resource.resource_name.is_empty():
		return edited_resource.resource_name

	var path := edited_resource.resource_path
	if not path.is_empty() and not path.contains("::"): # "::" means it's embedded in a scene
		return path.get_file()
	return edited_resource.get_class()
