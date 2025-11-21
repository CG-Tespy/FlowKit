extends FKEventProvider

func get_supported_types():
    return ["Node"]

func get_events_for(node):
    return [
        {
            "id": "scene_start",
            "name": "On Scene Start",
            "inputs": []
        },
        {
            "id": "always",
            "name": "On Always",
            "inputs": []
        }
    ]

var fired_once = false

func poll(event_id, node):
    if event_id == "scene_start" and not fired_once:
        fired_once = true
        return true
    if event_id == "always":
        return true
    return false
