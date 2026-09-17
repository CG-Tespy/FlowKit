extends FKActionInputModal
class_name FKGeneralActionInputModal

func _apply_input_state_to_ui():
	super._apply_input_state_to_ui()
	_clear_input_holder()
	for action_input in _last_pop_args.action_inputs:
		var input_ui: FKActionInputUi = _ui_factory.create_from(action_input)
		if input_ui == null:
			continue
		input_holder.add_child(input_ui)
		input_ui.set_value(_get_input_value(action_input))

var _ui_factory: FKActionInputUiFactory:
	get:
		return editor_globals.action_input_ui_factory

func _clear_input_holder():
	for child in input_holder.get_children():
		child.queue_free()

func _apply_ui_state_to_inputs():
	for child in input_holder.get_children():
		var input_ui := child as FKActionInputUi
		if input_ui == null or input_ui.action_input == null:
			continue
		_set_input_value(input_ui.action_input, input_ui.get_value())