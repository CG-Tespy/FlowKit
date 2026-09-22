extends FKAction

## Should work with not just 2D, but 3D.
class_name FKSetPosition

func get_description() -> String:
	return "Sets the node's position through a Vector3. Works with both 2D and 3D."

func get_provider_id() -> String:
	return "set_position_general"

func get_display_name() -> String:
	return "Set Position (General)"

func get_inputs() -> Array[FKActionInput]:
	return [_vec_input, _apply_x, _apply_y, _apply_z]

var _vec_input: FKVector3ActionInput = FKVector3ActionInput.new("New Position", 
		"Contains the X, Y, and Z values of the position to apply.")
var _apply_x := FKBoolActionInput.new("Apply X", "Whether or not to apply the x value of the above vec.", true)
var _apply_y := FKBoolActionInput.new("Apply Y", "Whether or not to apply the y value of the above vec.", true)
var _apply_z := FKBoolActionInput.new("Apply Z", "Whether or not to apply the z value of the above vec. " + \
"Ignored for 2D-only Nodes.", true)

func get_supported_types() -> Array[String]:
	return ["Node2D", "Node3D"]

func execute(node: Node, inputs: Dictionary, block_id: int = -1) -> void:
	if not node is Node2D and not node is Node3D:
		return
	
	var apply_x: bool = _apply_x.get_val(inputs) 
	var apply_y: bool = _apply_y.get_val(inputs)
	var apply_z: bool = node is Node3D and _apply_z.get_val(inputs)

	var position_input: Vector3 = _vec_input.get_val(inputs)
	var target_position = node.position
	
	if apply_x:
		target_position.x = position_input.x
	if apply_y:
		target_position.y = position_input.y
	if apply_z:
		target_position.z = position_input.z

	node.position = target_position