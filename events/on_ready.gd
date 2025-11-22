extends FKEvent

func get_id() -> String:
	return "on_ready"

func get_name() -> String:
	return "On Ready"

func get_supported_types() -> Array[String]:
	return ["Node"]

func get_inputs() -> Array:
	return []

var _fired: Array = []


func poll(node: Node, inputs: Dictionary = {}) -> bool:
	if node == null:
		return false

	# Clean up freed nodes occasionally
	_cleanup_fired()

	# Check whether we've seen this node before
	if node not in _fired:
		_fired.append(node)
		return true

	return false


func _cleanup_fired() -> void:
	# Remove nodes that have been freed
	_fired = _fired.filter(func(n: Node) -> bool:
		return is_instance_valid(n)
	)
