extends Node

func _ready():
	var gut: GutMain = GutMain.new()
	gut.add_directory("res://tests/runtime/unit")
	gut.add_directory("res://tests/integration")
	add_child(gut)
	gut.run_tests()
