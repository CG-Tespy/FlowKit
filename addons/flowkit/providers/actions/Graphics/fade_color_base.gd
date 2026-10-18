extends FKAction
class_name FKFadeColorBase

func is_abstract_provider() -> bool:
	return true

func may_need_multi_frames() -> bool:
	return true
	
func get_inputs() -> Array[FKActionInput]:
	return [_targ_color_input, _targ_alpha_input, _alpha_only_input, \
	_duration_input, _wait_for_finish_input]

func get_input_modal_scene() -> PackedScene:
	if not OS.has_feature("editor"):
		return null
	return load("res://addons/flowkit/editor/scenes/modals/FKActionCustom/fade_color_input_modal.tscn") as PackedScene
	
static var _targ_color_input: FKActionInput:
	get:
		return FKActionInput.new("Target Color", "Color",
		"The color to fade to. Its own alpha is ignored; see Target Alpha. Can also be a Color variable, or an expression that gives a Color. " + \
		"The older \"(255, 255, 255)\" string format still works. Default: white.",
		default_color)

static var _targ_alpha_input: FKFloatActionInput:
	get:
		return FKFloatActionInput.new("Target Alpha",
		"The opacity (percent) to fade to: 0 is fully transparent, 100 is fully opaque. Default: " + str(default_alpha) + ".",
		default_alpha)

static var _alpha_only_input: FKBoolActionInput:
	get:
		return FKBoolActionInput.new("Alpha Only",
		"If true, only the transparency (Target Alpha) will be changed, and the Target Color is ignored. Default: " + str(default_alpha_only),
		default_alpha_only)

static var _duration_input: FKFloatActionInput:
	get:
		return FKFloatActionInput.new("Duration",
		"How long (in seconds) the fade should take. Defaults to " + str(default_duration) + ".",
		default_duration)

static var _wait_for_finish_input: FKBoolActionInput:
	get:
		return FKBoolActionInput.new("Wait For Finish", 
		"Whether or not this pauses the Action list until the fade's done running. Default: " \
		+ str(default_wait_for_finish),
		default_wait_for_finish
)

static var default_color := Color.WHITE
static var default_alpha := 100.0
static var default_alpha_only := false
static var default_duration := 1.0
static var default_wait_for_finish := true

var tween: Tween = null

func execute(targetNode: Node, inputs: Dictionary, _int := -1) -> void:
	parse_inputs(targetNode, inputs)
	if tween:
		tween.cancel_free()

	var prop := decide_color_prop_name_for(targetNode)

	var apply_right_away = duration <= 0
	if apply_right_away:
		var log_message := "[FlowKit] Duration is 0. Setting " + targetNode.name + "'s " + prop
		log_message += " prop to " + to_rgb_coords(target_color) + " right away."
		#print(log_message)
		targetNode.set(prop, target_color)
	else:
		tween = targetNode.create_tween()
		tween.tween_property(targetNode, prop, target_color, duration)
		if wait_for_finish:
			await tween.finished
	
	exec_completed.emit()

func parse_inputs(target_node: Node, inputs: Dictionary) -> void:
	duration = _duration_input.get_val(inputs)
	target_alpha = clampf(_targ_alpha_input.get_val(inputs), 0.0, 100.0) / 100.0 # Stored as a percent; Color.a wants 0-1
	alpha_only = _alpha_only_input.get_val(inputs)
	wait_for_finish = _wait_for_finish_input.get_val(inputs)
	target_color = _parse_color_input(target_node, inputs)
	
var duration := 0.0
var target_alpha := 1.0
var alpha_only := false
var target_color := Color(1, 1, 1)
var wait_for_finish := true

# Subclasses override this
func decide_color_prop_name_for(_targetNode: Node) -> String:
	return "color"

func _parse_color_input(target_node: Node, inputs: Dictionary) -> Color:
	var prop: String = decide_color_prop_name_for(target_node)
	var raw = _targ_color_input.get_val(inputs)
	var target: Color
	if raw is Color:
		target = raw
	else:
		# Older sheets store the color as an "(r, g, b)" string
		target = Color.html(rgb_to_hex(str(raw)))

	target.a = target_alpha
	if not alpha_only:
		return target

	# Only the target color's opacity is used; the node keeps its current rgb.
	var result: Color = target_node.get(prop)
	result.a = target_alpha
	return result
	
func rgb_to_hex(rgb_string: String) -> String:
	var cleaned := rgb_string.replace("\"", "")
	cleaned = cleaned.replace("(", "")
	cleaned = cleaned.replace(")", "")

	var parts := cleaned.split(",")
	var r := int(parts[0])
	var g := int(parts[1])
	var b := int(parts[2])
	var result := hex_format % [r, g, b]
	return result

var hex_format := "#%02x%02x%02x"

func to_rgb_coords(color: Color) -> String:
	var r := int(color.r * 255)
	var g := int(color.g * 255)
	var b := int(color.b * 255)
	var a := int(color.a * 100)
	var result := rgb_format % [r, g, b, a]
	return result

var rgb_format := "(%d, %d, %d, %d)"
