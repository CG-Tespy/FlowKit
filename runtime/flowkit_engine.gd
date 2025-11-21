extends Node
class_name FlowKitEngine

var registry: FKRegistry
var active_sheets: Array = []
var last_scene: Node = null

func _ready():
	# Load registry
	registry = FKRegistry.new()
	registry.load_all()

	print("[FlowKit] Engine initialized.")

	# Do a deferred check in case the scene is already present at startup.
	call_deferred("_check_current_scene")

func _process(delta):
	# Regularly check if the current_scene changed (robust against timing issues).
	_check_for_scene_change()
	for sheet in active_sheets:
		_run_sheet(sheet)


# --- Scene detection helpers -----------------------------------------------
func _check_current_scene():
	var cs = get_tree().current_scene
	if cs:
		_on_scene_changed(cs)

func _check_for_scene_change():
	var cs = get_tree().current_scene
	if cs != last_scene:
		# Scene changed (including from null -> scene)
		_on_scene_changed(cs)


func _on_scene_changed(scene_root: Node) -> void:
	last_scene = scene_root
	if scene_root == null:
		# Scene unloaded: clear active sheets (optional)
		active_sheets.clear()
		print("[FlowKit] Scene cleared.")
		return

	print("[FlowKit] Scene detected:", scene_root.name)
	_load_sheet_for_scene(scene_root)


func _load_sheet_for_scene(scene_root: Node) -> void:
	# Clear previous sheet(s)
	active_sheets.clear()

	var scene_name: String = scene_root.name
	var sheet_path := "res://events/%s.tres" % scene_name

	# Debug: show whether the file exists
	if ResourceLoader.exists(sheet_path):
		var sheet = load(sheet_path)
		if sheet:
			active_sheets.append(sheet)
			print("[FlowKit] Loaded event sheet for scene:", scene_name, "->", sheet_path)
		else:
			print("[FlowKit] Failed to load sheet resource at:", sheet_path)
	else:
		print("[FlowKit] No sheet found for scene:", scene_name, "(expected at %s)" % sheet_path)


# --- Event loop ------------------------------------------------------------
func _run_sheet(sheet):
	# Defensive: ensure we have a current scene
	var current_scene = get_tree().current_scene
	if not current_scene:
		return

	for block in sheet.events:
		# Resolve target node (relative to the current scene)
		var node = current_scene.get_node_or_null(block.target_node)
		if not node:
			# Optionally debug: print missing node paths if you want
			# print("[FlowKit] Missing target node for block:", block.target_node)
			continue

		# Event trigger
		if not registry.poll_event(block.event_id, node):
			continue

		# Conditions
		var passed := true
		for cond in block.conditions:
			var cnode = current_scene.get_node_or_null(cond.target_node)
			if not cnode:
				passed = false
				break

			if not registry.check_condition(cond.condition_id, cnode, cond.inputs):
				passed = false
				break

		if not passed:
			continue

		# Actions
		for act in block.actions:
			var anode = current_scene.get_node_or_null(act.target_node)
			if anode:
				registry.execute_action(act.action_id, anode, act.inputs)
