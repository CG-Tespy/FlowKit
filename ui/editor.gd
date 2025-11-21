@tool
extends Control

var scene_name: String
var editor_interface: EditorInterface

var event_action = load("res://addons/flowkit/resources/event_action.gd")
var event_block = load("res://addons/flowkit/resources/event_block.gd")
var event_condition = load("res://addons/flowkit/resources/event_condition.gd")

@onready var menubar := $ScrollContainer/MarginContainer/VBoxContainer/MenuBar
@onready var add_event_button := $ScrollContainer/MarginContainer/VBoxContainer/AddEventButton
@onready var select_modal := $SelectModal

func _ready() -> void:
	# Connect when running inside the editor
	if menubar and menubar.has_signal("new_sheet"):
		menubar.new_sheet.connect(_generate_new_project)

func _process(_delta: float) -> void:
	if editor_interface:
		update_scene_name()

func _generate_new_project():
	print("Generating new FlowKit project...")
	var new_sheet = FKEventSheet.new()
	
	# Ensure the directory exists
	var dir_path = "res://addons/flowkit/saved/event_sheet"
	DirAccess.make_dir_recursive_absolute(dir_path)
	
	# Save to a new resource file
	var file_path = "%s/%s.tres" % [dir_path, scene_name]
	print("Saving event sheet to: ", file_path)

	var error = ResourceSaver.save(new_sheet, file_path)
	if error == OK:
		print("New FlowKit event sheet created at: ", file_path)
	else:
		print("Failed to create new FlowKit event sheet. Error code: ", error)
	
	_display_sheet(new_sheet)

func set_scene_name(name: String):
	scene_name = name
	print("Scene name set: ", scene_name)

func update_scene_name():
	var current_scene = editor_interface.get_edited_scene_root()
	var new_name = ""
	
	if current_scene:
		new_name = current_scene.name
	
	if new_name != scene_name:
		scene_name = new_name

func set_editor_interface(interface: EditorInterface):
	editor_interface = interface
	update_scene_name()

func _on_add_event_button_pressed() -> void:
	if not editor_interface:
		print("Editor interface not available")
		return
	
	var current_scene = editor_interface.get_edited_scene_root()
	if not current_scene:
		print("No scene currently open")
		return
	
	# Pass the editor interface to the modal so it can access node icons
	select_modal.set_editor_interface(editor_interface)
	
	# Populate the modal with nodes from the current scene
	select_modal.populate_from_scene(current_scene)
	
	# Show the popup centered
	select_modal.popup_centered()

func _on_select_modal_node_selected(node_path: String) -> void:
	print("Node selected in editor UI:", node_path)

func _display_sheet(data: Variant) -> void:
	if not data == FKEventSheet:
		var file_path = "res://addons/flowkit/saved/event_sheet/%s.tres" % scene_name
		if FileAccess.file_exists(file_path):
			var loaded_sheet = ResourceLoader.load(file_path)
			if loaded_sheet is FKEventSheet:
				data = loaded_sheet
				print("Loaded existing event sheet: ", file_path)
			else:
				print("File exists but is not a valid FKEventSheet")
				return
		else:
			print("No existing event sheet found for scene: ", scene_name)
			return
	
	
