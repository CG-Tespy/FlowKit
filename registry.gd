extends Node
class_name FKRegistry

var action_providers = []
var condition_providers = []
var event_providers = []

func load_all():
    _load_folder("actions", action_providers)
    _load_folder("conditions", condition_providers)
    _load_folder("events", event_providers)

func load_providers():
    # Alias for load_all() for backward compatibility
    load_all()

func _load_folder(subpath: String, array: Array):
    var path = "res://addons/flowkit/" + subpath
    var dir = DirAccess.open(path)
    if dir:
        for file in dir.get_files():
            if file.ends_with(".gd"):
                array.append(load(path + "/" + file).new())

func poll_event(event_id: String, node: Node) -> bool:
    for provider in event_providers:
        if provider.poll(event_id, node):
            return true
    return false

func check_condition(condition_id: String, node: Node, inputs: Dictionary) -> bool:
    for provider in condition_providers:
        if provider.check(condition_id, node, inputs):
            return true
    return false

func execute_action(action_id: String, node: Node, inputs: Dictionary) -> void:
    for provider in action_providers:
        provider.execute(action_id, node, inputs)
