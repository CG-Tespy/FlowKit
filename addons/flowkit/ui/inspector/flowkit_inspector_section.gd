@tool
extends VBoxContainer

## FlowKit Inspector Section
## Displays node variables and behavior options in the inspector

var node: Node = null
var registry: FKRegistry = null
var editor_interface: EditorInterface = null

# UI Components
var category_button: Button = null
var content_container: VBoxContainer = null
var variables_container: VBoxContainer = null
var behavior_container: VBoxContainer = null

# Variable editing
var add_variable_button: Button = null
var variable_list: VBoxContainer = null

# Behavior selection
var behavior_label: Label = null
var behavior_dropdown: OptionButton = null

# Collapsed state
var is_collapsed: bool = true

func _ready() -> void:
	_build_ui()
	_load_node_data()

func set_node(p_node: Node) -> void:
	node = p_node

func set_registry(p_registry: FKRegistry) -> void:
	registry = p_registry

func _build_ui() -> void:
	# Category header button
	category_button = Button.new()
	category_button.text = "▶ FlowKit"
	category_button.flat = true
	category_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	category_button.pressed.connect(_on_category_toggled)
	add_child(category_button)
	
	# Content container (collapsible)
	content_container = VBoxContainer.new()
	content_container.visible = false
	add_child(content_container)
	
	# Add margin
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	content_container.add_child(margin)
	
	var inner_vbox: VBoxContainer = VBoxContainer.new()
	inner_vbox.add_theme_constant_override("separation", 12)
	margin.add_child(inner_vbox)
	
	# Variables section
	_build_variables_section(inner_vbox)
	
	# Separator
	var separator: HSeparator = HSeparator.new()
	inner_vbox.add_child(separator)
	
	# Behavior section
	_build_behavior_section(inner_vbox)

func _build_variables_section(parent: Control) -> void:
	var label: Label = Label.new()
	label.text = "Node Variables"
	label.add_theme_font_size_override("font_size", 12)
	parent.add_child(label)
	
	variable_list = VBoxContainer.new()
	variable_list.add_theme_constant_override("separation", 4)
	parent.add_child(variable_list)
	
	add_variable_button = Button.new()
	add_variable_button.text = "+ Add Variable"
	add_variable_button.pressed.connect(_on_add_variable)
	parent.add_child(add_variable_button)

func _build_behavior_section(parent: Control) -> void:
	behavior_label = Label.new()
	behavior_label.text = "Default Behavior"
	behavior_label.add_theme_font_size_override("font_size", 12)
	parent.add_child(behavior_label)
	
	behavior_dropdown = OptionButton.new()
	behavior_dropdown.add_item("None", 0)
	behavior_dropdown.item_selected.connect(_on_behavior_selected)
	parent.add_child(behavior_dropdown)

func _load_node_data() -> void:
	if not node:
		return
	
	_refresh_variables()
	_refresh_behaviors()

func _refresh_variables() -> void:
	if not node or not variable_list:
		return
	
	# Clear existing variable widgets
	for child in variable_list.get_children():
		child.queue_free()
	
	# Get node variables from FlowKitSystem
	if not Engine.is_editor_hint():
		return
	
	# In editor, we need to store variables in node metadata
	var vars: Dictionary = {}
	if node.has_meta("flowkit_variables"):
		vars = node.get_meta("flowkit_variables", {})
	
	# Display existing variables
	for var_name in vars.keys():
		_add_variable_widget(var_name, vars[var_name])

func _add_variable_widget(var_name: String, value: Variant) -> void:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	variable_list.add_child(hbox)
	
	# Name field
	var name_edit: LineEdit = LineEdit.new()
	name_edit.text = var_name
	name_edit.custom_minimum_size = Vector2(120, 0)
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_edit.placeholder_text = "Variable Name"
	name_edit.text_changed.connect(func(new_name: String): _on_variable_name_changed(var_name, new_name))
	hbox.add_child(name_edit)
	
	# Value field
	var value_edit: LineEdit = LineEdit.new()
	value_edit.text = str(value)
	value_edit.custom_minimum_size = Vector2(120, 0)
	value_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_edit.placeholder_text = "Value"
	value_edit.text_changed.connect(func(new_value: String): _on_variable_value_changed(var_name, new_value))
	hbox.add_child(value_edit)
	
	# Delete button
	var delete_btn: Button = Button.new()
	delete_btn.text = "✕"
	delete_btn.custom_minimum_size = Vector2(32, 0)
	delete_btn.pressed.connect(func(): _on_delete_variable(var_name))
	hbox.add_child(delete_btn)

func _refresh_behaviors() -> void:
	if not node or not registry or not behavior_dropdown:
		return
	
	# Clear existing items (keep "None")
	while behavior_dropdown.item_count > 1:
		behavior_dropdown.remove_item(1)
	
	# Get behaviors compatible with this node type
	var node_type: String = node.get_class()
	var compatible_behaviors: Array = []
	
	if registry.behavior_providers:
		for behavior in registry.behavior_providers:
			if behavior.has_method("get_supported_types"):
				var supported_types: Array = behavior.get_supported_types()
				if _is_compatible_type(node_type, supported_types):
					compatible_behaviors.append(behavior)
	
	# Add compatible behaviors to dropdown
	var index: int = 1
	for behavior in compatible_behaviors:
		var behavior_name: String = behavior.get_name() if behavior.has_method("get_name") else "Unknown"
		behavior_dropdown.add_item(behavior_name, index)
		behavior_dropdown.set_item_metadata(index, behavior.get_id())
		index += 1
	
	# Select current behavior
	if node.has_meta("flowkit_behavior"):
		var current_behavior_id: String = node.get_meta("flowkit_behavior", "")
		for i in range(behavior_dropdown.item_count):
			if behavior_dropdown.get_item_metadata(i) == current_behavior_id:
				behavior_dropdown.select(i)
				break

func _is_compatible_type(node_type: String, supported_types: Array) -> bool:
	if supported_types.is_empty():
		return true
	
	for type in supported_types:
		if node_type == type or ClassDB.is_parent_class(node_type, type):
			return true
	
	return false

func _on_category_toggled() -> void:
	is_collapsed = not is_collapsed
	content_container.visible = not is_collapsed
	category_button.text = "▼ FlowKit" if not is_collapsed else "▶ FlowKit"

func _on_add_variable() -> void:
	if not node:
		return
	
	# Create new variable with default name
	var vars: Dictionary = {}
	if node.has_meta("flowkit_variables"):
		vars = node.get_meta("flowkit_variables", {})
	
	# Find unique name
	var var_name: String = "variable"
	var counter: int = 1
	while vars.has(var_name):
		var_name = "variable" + str(counter)
		counter += 1
	
	vars[var_name] = ""
	node.set_meta("flowkit_variables", vars)
	
	_refresh_variables()

func _on_variable_name_changed(old_name: String, new_name: String) -> void:
	if not node or old_name == new_name:
		return
	
	new_name = new_name.strip_edges()
	if new_name.is_empty():
		return
	
	var vars: Dictionary = {}
	if node.has_meta("flowkit_variables"):
		vars = node.get_meta("flowkit_variables", {})
	
	# Check if new name already exists
	if vars.has(new_name) and new_name != old_name:
		_refresh_variables()  # Revert to old name
		return
	
	# Rename variable
	if vars.has(old_name):
		var value: Variant = vars[old_name]
		vars.erase(old_name)
		vars[new_name] = value
		node.set_meta("flowkit_variables", vars)

func _on_variable_value_changed(var_name: String, new_value: String) -> void:
	if not node:
		return
	
	var vars: Dictionary = {}
	if node.has_meta("flowkit_variables"):
		vars = node.get_meta("flowkit_variables", {})
	
	vars[var_name] = new_value
	node.set_meta("flowkit_variables", vars)

func _on_delete_variable(var_name: String) -> void:
	if not node:
		return
	
	var vars: Dictionary = {}
	if node.has_meta("flowkit_variables"):
		vars = node.get_meta("flowkit_variables", {})
	
	vars.erase(var_name)
	node.set_meta("flowkit_variables", vars)
	
	_refresh_variables()

func _on_behavior_selected(index: int) -> void:
	if not node:
		return
	
	if index == 0:
		# None selected
		node.remove_meta("flowkit_behavior")
	else:
		var behavior_id: Variant = behavior_dropdown.get_item_metadata(index)
		if behavior_id:
			node.set_meta("flowkit_behavior", behavior_id)
