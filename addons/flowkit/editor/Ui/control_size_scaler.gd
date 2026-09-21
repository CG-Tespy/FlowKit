@tool
extends Node

class_name FKControlSizeScaler

@export var target: Control

## Invisible ones are ignored.
@export var contents: Array[Control] = []

@export_category("Scaling Config")
@export var updates_per_second: int = 15

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

@export var _scale_timer: Timer

func _enter_tree() -> void:
	_report_invalid_contents()
	if updates_per_second < 15:
		updates_per_second = 15

	_scale_timer = Timer.new()
	add_child(_scale_timer)
	_toggle_subs(true)
	_scale_timer.start()

func _report_invalid_contents():
	for ind in range(contents.size()):
		var item := contents[ind]
		if not item:
			push_warning("[%s] Found invalid item at index %d registered under %s" % \
			[self.get_class(), ind, self.name])

func _toggle_subs(wants_subs_active: bool):
	if wants_subs_active and not _is_subbed:
		_scale_timer.timeout.connect(_scale_target)
	elif _is_subbed and not wants_subs_active:
		_scale_timer.timeout.disconnect(_scale_target)
	else:
		return

	_is_subbed = !_is_subbed

var _is_subbed := false

func _scale_target() -> void:
	if not able_to_scale():
		return

	_last_chosen_size = _calc_size_to_apply()
	_resize_target_to_chosen()

func able_to_scale() -> bool:
	return is_enabled() and has_valid_target() and has_valid_contents()

func is_enabled() -> bool:
	return process_mode != Node.ProcessMode.PROCESS_MODE_DISABLED and \
	(scale_x or scale_y)
	# ^Setting both scale_x and scale_y to false is one way we intend for this 
	# node to be disabled.

func has_valid_target() -> bool:
	return target != null

func has_valid_contents() -> bool:
	# Need to take nulls into account
	var found_valid := false

	for item in contents:
		if item:
			found_valid = true
			break

	return found_valid

func _calc_size_to_apply() -> Vector2:
	var result: Vector2 = target.size

	if scale_x:
		result.x = 0
	if scale_y:
		result.y = 0

	for item in contents:
		if not item or not item.visible:
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

func _exit_tree() -> void:
	_toggle_subs(false)
	_scale_timer.stop()

func get_class() -> String:
	return "FKControlSizeScaler"
