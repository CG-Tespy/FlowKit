@tool
extends PopupPanel

signal node_selected(node_path: String)

var editor_interface: EditorInterface

@onready var item_list := $ItemList

func _ready() -> void:
	if item_list:
		item_list.item_activated.connect(_on_item_activated)
		item_list.item_selected.connect(_on_item_selected)

func set_editor_interface(interface: EditorInterface):
	editor_interface = interface

func populate_from_scene(scene_root: Node) -> void:
	if not item_list:
		return
	
	item_list.clear()
	
	if not scene_root:
		return
	
	_add_node_recursive(scene_root, "")

func _add_node_recursive(node: Node, prefix: String) -> void:
	var node_name = node.name
	var display_name = prefix + node_name
	
	# Add the node to the list
	item_list.add_item(display_name)
	var index = item_list.item_count - 1
	item_list.set_item_metadata(index, node.get_path())
	
	# Get and set the node's icon from the editor
	if editor_interface:
		var icon = editor_interface.get_base_control().get_theme_icon(node.get_class(), "EditorIcons")
		if icon:
			item_list.set_item_icon(index, icon)
	
	# Add children recursively with indentation
	for child in node.get_children():
		_add_node_recursive(child, prefix + "  ")

func _on_item_activated(index: int) -> void:
	var node_path = item_list.get_item_metadata(index)
	print("Node selected: ", node_path)
	node_selected.emit(node_path)
	hide()

func _on_item_selected(index: int) -> void:
	# Optional: handle single click if needed
	pass
