extends PopupMenu

func _enter_tree() -> void:
	_set_subs(true)

func _set_subs(wants_subs_active: bool):
	pass

var _is_subbed := false

func _exit_tree() -> void:
	_set_subs(false)