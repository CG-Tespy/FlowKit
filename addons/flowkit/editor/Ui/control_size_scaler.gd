@tool
extends Node

class_name FKControlSizeScaler

@export var target: Control

## Invisible ones are ignored.
@export var contents: Array[Control] = []

@export_category("Scaling Config")
@export var scale_x := false

## If true, this goes by the combined widths of the content. Otherwise,
## just the widest among them. Does nothing is scale_x is false.
@export var cumulative_x := false

@export var scale_y := false

## If true, this goes by the combined heights of the content. Otherwise,
## just the tallest among them. Does nothing if scale_y is false.
@export var cumulative_y := false

@export_category("Debug Only")
@export var _last_chosen_size: Vector2

func _process(delta: float) -> void:
	if not able_to_scale():
		return

	_last_chosen_size = _calc_size_to_apply()
	_resize_target_to_chosen()

func able_to_scale() -> bool:
	return is_enabled() and has_valid_target() and has_contents_to_scale_off_of()

func is_enabled() -> bool:
	return process_mode != Node.ProcessMode.PROCESS_MODE_DISABLED and \
	(scale_x or scale_y)
	# ^Setting both scale_x and scale_y to false is one way we intend for this 
	# node to be disabled.

func has_valid_target() -> bool:
	return target != null

func has_contents_to_scale_off_of() -> bool:
	return contents.size() > 0

func _calc_size_to_apply() -> Vector2:
	var result: Vector2 = target.size

	if scale_x:
		result.x = 0
	if scale_y:
		result.y = 0

	for item in contents:
		if not item.visible:
			continue
		var contents_size := item.size
		
		if scale_x:
			if cumulative_x:
				result.x += contents_size.x
			else:
				result.x = max(result.x, contents_size.x)
		if scale_y:
			if cumulative_y:
				result.y += contents_size.y
			else:
				result.y = max(result.y, contents_size.y)
	return result

func _resize_target_to_chosen():
	target.custom_minimum_size = _last_chosen_size
	target.size = Vector2.ZERO 
	# ^Setting the current size below the min snaps it to the min
	# 0 is as low as it gets, so...