@tool
extends FKActionInputModal
class_name FKGeneralActionInputModal

func _apply_input_state_to_ui():
	super._apply_input_state_to_ui()

	_clear_input_holder()

	for elem in _last_pop_args.action_inputs:
		var input_ui: FKActionInputUi = _ui_pool.acquire(elem)
		if input_ui == null:
			continue
		input_holder.add_child(input_ui)
		input_ui.try_set_value(_get_input_value(elem))

func _clear_input_holder():
	for child in input_holder.get_children():
		var input_ui: FKActionInputUi = child if child is FKActionInputUi else null
		if input_ui != null:
			input_ui.release()

var _ui_pool: FKActionInputUiPool:
	get:
		return editor_globals.action_input_ui_pool

func _apply_ui_state_to_inputs():
	for child in input_holder.get_children():
		var input_ui: FKActionInputUi = child if child is FKActionInputUi else null
		if input_ui == null or input_ui.action_input == null:
			continue
		_set_input_value(input_ui.action_input, input_ui.get_value())