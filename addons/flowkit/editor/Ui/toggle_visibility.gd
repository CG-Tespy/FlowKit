@tool
extends Node
class_name FKToggleVisibility

@export var clickable: Button
@export var to_toggle_for: Array[Control]

func _enter_tree() -> void:
	_toggle_subs(true)

func _toggle_subs(wants_subs_active: bool):
	if wants_subs_active and not _is_subbed:
		clickable.pressed.connect(_on_click)
	elif _is_subbed and not wants_subs_active:
		clickable.pressed.disconnect(_on_click)
	else:
		return

	_is_subbed = !_is_subbed

var _is_subbed := false

func _on_click():
	for ind in range(to_toggle_for.size()):
		var item := to_toggle_for[ind]
		print("Toggling for item " + str(item))
		item.visible = !item.visible

func _exit_tree() -> void:
	_toggle_subs(false)