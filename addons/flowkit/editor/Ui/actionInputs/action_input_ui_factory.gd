extends RefCounted
class_name FKActionInputUiFactory

func _init(editor_globals: FKEditorGlobals) -> void:
	_globals = editor_globals

var _globals: FKEditorGlobals

func create_from(action_input: FKActionInput) -> FKActionInputUi:
	var scene: PackedScene = _get_scene_for(action_input)
	if scene == null:
		push_warning("[FlowKit] No action input UI is available for '%s' (%s)." % [action_input.name, action_input.type])
		return null

	var input_ui := scene.instantiate() as FKActionInputUi
	input_ui.legitimize(action_input, _globals)
	return input_ui

func _get_scene_for(action_input: FKActionInput) -> PackedScene:
	if action_input is FKBoolActionInput:
		return _globals.BOOL_ACTION_INPUT_SCENE
	if action_input is FKIntActionInput:
		return _globals.INTEGER_ACTION_INPUT_SCENE
	if action_input is FKFloatActionInput:
		return _globals.FLOAT_ACTION_INPUT_SCENE
	if action_input is FKStringActionInput:
		return _globals.STRING_ACTION_INPUT_SCENE
	if action_input.type == "Vector2":
		return _globals.VECTOR2_ACTION_INPUT_SCENE
	if action_input.type == "Vector3":
		return _globals.VECTOR3_ACTION_INPUT_SCENE
	if action_input.type == "Vector4":
		return _globals.VECTOR4_ACTION_INPUT_SCENE
	if action_input.type == "Color":
		return _globals.COLOR_ACTION_INPUT_SCENE
	return _globals.VARIANT_ACTION_INPUT_SCENE