extends FKAction

## Should work with not just 2D, but 3D.
class_name FKSetVelocity

func get_description() -> String:
	return "Sets the character's velocity through a Vector3. Works with both 2D and 3D."

func get_provider_id() -> String:
	return "set_velocity_general"

func get_display_name() -> String:
	return "Set Velocity (General)"

func get_inputs() -> Array[FKActionInput]:
	return [_vec_input, _apply_x, _apply_y, _apply_z]

var _vec_input: FKVector3ActionInput = FKVector3ActionInput.new("New Velocity", 
		"Contains the X, Y, and Z values of the velocity to apply.")
var _apply_x := FKBoolActionInput.new("Apply X", "Whether or not to apply the x value of the above vec.", true)
var _apply_y := FKBoolActionInput.new("Apply Y", "Whether or not to apply the y value of the above vec.", true)
var _apply_z := FKBoolActionInput.new("Apply Z", "Whether or not to apply the z value of the above vec. " + \
"Ignored for 2D-only Nodes.", true)

func get_supported_types() -> Array[String]:
	return ["CharacterBody2D", "CharacterBody3D"]

func execute(body: Node, inputs: Dictionary, block_id: int = -1) -> void:
	if not body is CharacterBody2D and not body is CharacterBody3D:
		return
	
	var apply_x: bool = _apply_x.get_val(inputs) 
	var apply_y: bool = _apply_y.get_val(inputs)
	var apply_z: bool = body is CharacterBody3D and _apply_z.get_val(inputs)

	var vel_input: Vector3 = _vec_input.get_val(inputs)
	var targ_vel = body.velocity
	
	if apply_x:
		targ_vel.x = vel_input.x
	if apply_y:
		targ_vel.y = vel_input.y
	if apply_z:
		targ_vel.z = vel_input.z

	body.velocity = targ_vel
