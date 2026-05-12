extends PopupPanel
class_name FKModalWindow

func _enter_tree() -> void:
	# For designer-friendliness, we want some things to proc
	# even in editor preview
	_ensure_export_fields_filled()
	_apply_styling()
	
	# From here on, we only act when we're a legit instance.
	if is_editor_preview:
		return
	_toggle_subs(true)

func _ensure_export_fields_filled():
	pass 
	
func _apply_styling():
	pass
	
var is_editor_preview: bool:
	get:
		return _is_editor_preview
		
var _is_editor_preview := true

func _toggle_subs(on: bool):
	pass # We expect subclasses to override this
	
var _is_subbed := false

func set_editor_interface(interface: EditorInterface):
	editor_interface = interface
	
var editor_interface: EditorInterface

func legitimize():
	if not is_editor_preview:
		return
	_is_editor_preview = false
	_enter_tree()
	_ready()
	
func _exit_tree() -> void:
	if is_editor_preview:
		return
	_toggle_subs(false)

func set_registry(reg: FKRegistry):
	_registry = reg
	
var _registry: FKRegistry

func _ready() -> void:
	pass
