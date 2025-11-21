extends FKAction

func get_id() -> String: return "move_toward"
func get_name() -> String: return "Move Toward"

func get_inputs():
    return [
        {"name": "Speed", "type": "float"},
        {"name": "DirX", "type": "float"},
        {"name": "DirY", "type": "float"},
    ]

func get_supported_types():
    return ["CharacterBody2D"]

func execute(node: CharacterBody2D, inputs: Dictionary):
    var dir := Vector2(inputs["DirX"], inputs["DirY"]).normalized()
    var speed: float = inputs["Speed"]
    node.velocity = dir * speed
    node.move_and_slide()
