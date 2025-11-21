@tool
extends VBoxContainer

func _can_drop_data(at_position: Vector2, data) -> bool:
	return data is Control and data.get_parent() == self

func _drop_data(at_position: Vector2, data):
	if not data is Control or data.get_parent() != self:
		return
	
	var old_index = data.get_index()
	var new_index: int = _get_drop_index(at_position)
	
	# Adjust index if moving down
	if new_index > old_index:
		new_index -= 1
	
	# Reorder the child
	if old_index != new_index:
		move_child(data, new_index)

func _get_drop_index(at_position: Vector2) -> int:
	var child_count = get_child_count()
	if child_count == 0:
		return 0
	
	for i in range(child_count):
		var child = get_child(i)
		if child is Control:
			var child_rect = child.get_rect()
			if at_position.y < child_rect.position.y + child_rect.size.y / 2:
				return i
	
	return child_count
