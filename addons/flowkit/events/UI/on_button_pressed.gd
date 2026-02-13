extends FKEvent

func get_description() -> String:
	return "Executes a block of Actions in response to a button-press."

func get_id() -> String:
	return "On Button Pressed"

func get_name() -> String:
	return "On Button Pressed"
	
func get_supported_types() -> Array:
	return ["Button"]

func is_signal_event() -> bool:
	return true

# Store per-instance connection data: instance_id -> { "node": Button, "callback": Callable }
var _connections: Dictionary = {}

func setup(target_node: Node, trigger_callback: Callable, instance_id: String = "") -> void:
	# Create a unique callback for this instance so multiple buttons don't share state
	var callback: Callable = func(): trigger_callback.call()
	target_node.pressed.connect(callback)
	_connections[instance_id] = { "node": target_node, "callback": callback }

func teardown(target_node: Node, instance_id: String = "") -> void:
	if _connections.has(instance_id):
		var data: Dictionary = _connections[instance_id]
		var node: Node = data["node"]
		var callback: Callable = data["callback"]
		if is_instance_valid(node) and node.pressed.is_connected(callback):
			node.pressed.disconnect(callback)
		_connections.erase(instance_id)
