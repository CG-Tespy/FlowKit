extends Node

func _ready():
	var gut: GutMain = GutMain.new()
	gut.add_directory("res://tests/unit")
	gut.add_directory("res://tests/integration")
	add_child(gut)
	gut.run()
