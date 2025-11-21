@tool
extends MenuBar

signal new_sheet(data)

func _on_file_id_pressed(id: int) -> void:
	if id == 0:
		emit_signal("new_sheet")