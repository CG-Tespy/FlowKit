extends FKEvent 

func get_description() -> String:
	return "Runs the actions when the designated Timer is done counting down."

func get_id() -> String:
	return "Timer on Timeout"

func get_name() -> String:
	return "On Timeout"

func get_supported_types() -> Array[String]:
	return ["Timer"]

func is_signal_event() -> bool:
	return true

# Store per-instance connection data: block_id -> { "node": Timer, "callback": Callable }
var _connections: Dictionary = {}

func setup(node: Node, trigger_callback: Callable, _block_id: String = "") -> void:
	# Create a unique callback for this instance so multiple timers don't share state
	var callback: Callable = func(): trigger_callback.call()
	node.timeout.connect(callback)
	_connections[_block_id] = { "node": node, "callback": callback }

func teardown(_node: Node, _block_id: String = "") -> void:
	if _connections.has(_block_id):
		var data: Dictionary = _connections[_block_id]
		var stored_node: Node = data["node"]
		var callback: Callable = data["callback"]
		if is_instance_valid(stored_node) and stored_node.timeout.is_connected(callback):
			stored_node.timeout.disconnect(callback)
		_connections.erase(_block_id)
