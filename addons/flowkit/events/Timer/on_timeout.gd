extends FKEvent

func get_description() -> String:
    var result: String = "Executes when a Timer's done counting down."
    return result

func get_id() -> String:
    return "On Timer Timeout"

func get_name() -> String:
    return "On Timeout"

func get_supported_types() -> Array:
    return ["Timer"]

func poll(node: Node, _inputs: Dictionary = {}, _block_id: String = "") -> bool:
    if node is Timer:
        timer = node

    if !listening:
        timer.timeout.connect(on_timeout)
        listening = true

    return responded

var listening: bool = false
var timer: Timer = null

func on_timeout():
    responded = true
    pass

var responded: bool = false