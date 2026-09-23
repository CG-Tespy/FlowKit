extends RefCounted
class_name FKEditorGlobals

const EVENT_ROW_SCENE_PATH := "res://addons/flowkit/editor/scenes/unitUis/event_row_ui.tscn"
const COMMENT_SCENE_PATH := "res://addons/flowkit/editor/scenes/unitUis/comment_ui.tscn"
const CONDITION_SCENE_PATH := "res://addons/flowkit/editor/scenes/unitUis/condition_unit_ui.tscn"
const ACTION_ITEM_SCENE_PATH := "res://addons/flowkit/editor/scenes/unitUis/action_unit_ui.tscn"
const BRANCH_ITEM_SCENE_PATH := "res://addons/flowkit/editor/scenes/unitUis/branch_unit_ui.tscn"
const GROUP_SCENE_PATH := "res://addons/flowkit/editor/scenes/unitUis/group_ui.tscn"
const SETTINGS_WINDOW_SCENE_PATH := "res://addons/flowkit/editor/scenes/fk_editor_settings.tscn"
const FLOAT_ACTION_INPUT_SCENE_PATH := "res://addons/flowkit/editor/scenes/actionInputs/float_input.tscn"
const INTEGER_ACTION_INPUT_SCENE_PATH := "res://addons/flowkit/editor/scenes/actionInputs/integer_input.tscn"
const BOOL_ACTION_INPUT_SCENE_PATH := "res://addons/flowkit/editor/scenes/actionInputs/bool_input.tscn"
const COLOR_ACTION_INPUT_SCENE_PATH := "res://addons/flowkit/editor/scenes/actionInputs/color_input.tscn"
const VECTOR2_ACTION_INPUT_SCENE_PATH := "res://addons/flowkit/editor/scenes/actionInputs/vector2_input.tscn"
const VECTOR3_ACTION_INPUT_SCENE_PATH := "res://addons/flowkit/editor/scenes/actionInputs/vector3_input.tscn"
const VECTOR4_ACTION_INPUT_SCENE_PATH := "res://addons/flowkit/editor/scenes/actionInputs/vector4_input.tscn"
const AUDIO_STREAM_ACTION_INPUT_SCENE_PATH := "res://addons/flowkit/editor/scenes/actionInputs/audio_stream_input.tscn"
const STRING_ACTION_INPUT_SCENE_PATH := "res://addons/flowkit/editor/scenes/actionInputs/string_input.tscn"
const VARIANT_ACTION_INPUT_SCENE_PATH := "res://addons/flowkit/editor/scenes/actionInputs/variant_input.tscn"
const PATH_TO_EVENTS_FOLDER := "res://addons/flowkit/events"

const MAIN_EDITOR_SCENE_PATH := "res://addons/flowkit/editor/scenes/main_editor.tscn"
const SETTINGS_WINDOW_TOOL_MENU_PATH = "FlowKit/Settings"

const EVENT_ROW_SCENE: PackedScene = preload(EVENT_ROW_SCENE_PATH)
const COMMENT_SCENE: PackedScene = preload(COMMENT_SCENE_PATH)
const CONDITION_ITEM_SCENE: PackedScene = preload(CONDITION_SCENE_PATH)
const ACTION_ITEM_SCENE: PackedScene = preload(ACTION_ITEM_SCENE_PATH)
const BRANCH_ITEM_SCENE: PackedScene = preload(BRANCH_ITEM_SCENE_PATH)
const FLOAT_ACTION_INPUT_SCENE: PackedScene = preload(FLOAT_ACTION_INPUT_SCENE_PATH)
const INTEGER_ACTION_INPUT_SCENE: PackedScene = preload(INTEGER_ACTION_INPUT_SCENE_PATH)
const BOOL_ACTION_INPUT_SCENE: PackedScene = preload(BOOL_ACTION_INPUT_SCENE_PATH)
const COLOR_ACTION_INPUT_SCENE: PackedScene = preload(COLOR_ACTION_INPUT_SCENE_PATH)
const VECTOR2_ACTION_INPUT_SCENE: PackedScene = preload(VECTOR2_ACTION_INPUT_SCENE_PATH)
const VECTOR3_ACTION_INPUT_SCENE: PackedScene = preload(VECTOR3_ACTION_INPUT_SCENE_PATH)
const VECTOR4_ACTION_INPUT_SCENE: PackedScene = preload(VECTOR4_ACTION_INPUT_SCENE_PATH)
const AUDIO_STREAM_ACTION_INPUT_SCENE: PackedScene = preload(AUDIO_STREAM_ACTION_INPUT_SCENE_PATH)
const STRING_ACTION_INPUT_SCENE: PackedScene = preload(STRING_ACTION_INPUT_SCENE_PATH)
const VARIANT_ACTION_INPUT_SCENE: PackedScene = preload(VARIANT_ACTION_INPUT_SCENE_PATH)

const AUTO_SAVE_TOGGLE_KEY = "flowkit/auto_save_enabled"
const EXPRESSION_TEXT_COLOR_KEY = "flowkit/expression_text_color"
const AUTO_ENCLOSE_STRING_INPUTS_KEY = "flowkit/auto_enclose_string_inputs"

static var is_action_input_modal_visible := false

var editor_interface: EditorInterface
var editor_settings: EditorSettings:
	get:
		if editor_interface == null:
			return null
		return editor_interface.get_editor_settings()

func should_auto_enclose_string_inputs() -> bool:
	var settings := editor_settings
	if settings == null:
		return true
	if not settings.has_setting(AUTO_ENCLOSE_STRING_INPUTS_KEY):
		return true
	return settings.get_setting(AUTO_ENCLOSE_STRING_INPUTS_KEY)
		
var generator: FKGenerator
var registry: FKRegistry 
var modal_signals: FKModalSignals = FKModalSignals.new()
var unit_ui_signals := FKUnitUiSignals.new()
var settings_window_signals := FKSettingsWindowSignals.new()
var action_input_ui_factory := FKActionInputUiFactory.new(self)
var action_input_ui_pool := FKActionInputUiPool.new(self, action_input_ui_factory)
var variable_editor_registry := FKVariableEditorRegistry.new()
var variable_editor_factory := FKVariableEditorFactory.new(variable_editor_registry)
var current_scene_uid: int = 0

## Should return a SceneTree object. No args.
var get_main_editor_tree: Callable

var is_in_undo_redo := false
var sheet_auto_saver: FKSheetAutoSaver
var sheet_io: FKSheetIO = FKSheetIO.new()
var block_container_ui: FKUnitContainerUi

var base_control: Control:
	get:
		return editor_interface.get_base_control()
		
var sheet_editor_visible: bool = false

## Ready to let the user do things like add and reorder Actions
var sheet_editor_ready := false
