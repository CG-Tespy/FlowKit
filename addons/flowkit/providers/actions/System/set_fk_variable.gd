extends FKAction
class_name FKSetVariable
## Sets the value of one of the current Event Sheet's FKVariables (the ones made in the
## sheet's variable editor), by way of one of the SetOperators the variable supports.

const ENGINE_PATH := "/root/FlowKit"
const VARIABLE_INPUT_NAME := "Variable"
const OPERATOR_INPUT_NAME := "Operator"
const VALUE_INPUT_NAME := "Value"

func get_description() -> String:
	return "Sets the value of one of this sheet's variables. What the value can be, and " + \
	"which operators work with it, depends on the type of the variable."

func get_id() -> String:
	return "set_fk_variable"

func get_display_name() -> String:
	return "Set Variable"

func get_supported_types() -> Array[String]:
	return ["System"]

## The Value input here is only a stand-in: the real one depends on the type of the chosen
## variable (see FKVariable.create_value_action_input).
func get_inputs() -> Array[FKActionInput]:
	return [_variable_input, _operator_input, _value_input]

static var _variable_input: FKActionInput:
	get:
		return FKActionInput.new(VARIABLE_INPUT_NAME, "Variable",
		"The sheet variable to set.", null)

static var _operator_input: FKStringActionInput:
	get:
		return FKStringActionInput.new(OPERATOR_INPUT_NAME,
		"How the value gets applied to the variable.",
		"\"%s\"" % FKVariable.operator_symbol(FKVariable.SetOperator.ASSIGN))

static var _value_input: FKActionInput:
	get:
		return FKActionInput.new(VALUE_INPUT_NAME, "Variant",
		"The value to apply to the variable.", null)

func get_input_modal_scene() -> PackedScene:
	if not OS.has_feature("editor"):
		return null
	return load(VAR_INPUT_MODAL_SCENE_PATH) as PackedScene

const VAR_INPUT_MODAL_SCENE_PATH := "res://addons/flowkit/editor/scenes/modals/FKActionCustom/set_variable_input_modal.tscn"

func execute(node: Node, inputs: Dictionary, _unit_id: int = -1) -> void:
	var target := _variable_input.get_val(inputs) as FKVariableRef
	if target == null or not target.is_valid():
		push_error("[FlowKit] Set Variable: No variable was chosen.")
		return

	var scene_root := _find_scene_root(node)
	var manager := _get_variable_manager(node, scene_root)
	var variable := manager.get_var_by_id(target.variable_id) if manager != null else null
	if variable == null:
		push_error("[FlowKit] Set Variable: No variable with id %d in this sheet." % target.variable_id)
		return

	var symbol := str(_operator_input.get_val(inputs))
	var op := FKVariable.operator_from_symbol(symbol)
	if op == FKVariable.SetOperator.NULL:
		push_error("[FlowKit] Set Variable: '%s' isn't a valid operator." % symbol)
		return

	if not inputs.has(VALUE_INPUT_NAME) and not inputs.has(VALUE_INPUT_NAME.to_lower()):
		push_error("[FlowKit] Set Variable: No value was given for '%s'." % variable.key)
		return

	var value_input := variable.create_value_action_input(VALUE_INPUT_NAME)
	var value: Variant = value_input.get_val(inputs)

	if variable is FKNodeVariable:
		_set_node_variable(variable as FKNodeVariable, scene_root, value)
		return
	variable.apply_operator(op, value)

## Node variables hold paths relative to the root of the scene their sheet is for, and the
## sheet can't be their owner at runtime, so they get the path set directly.
func _set_node_variable(variable: FKNodeVariable, scene_root: Node, value: Variant) -> void:
	if scene_root == null or not (value is Node):
		push_error("[FlowKit] Set Variable: '%s' needs a Node as its value." % variable.key)
		return
	variable.set_node_path(scene_root.get_path_to(value))
	variable.value_changed.emit(variable)

func _get_engine(node: Node) -> FlowKitEngine:
	return node.get_node_or_null(ENGINE_PATH) as FlowKitEngine

## The root of the scene that a running sheet belongs to, looked for from the node up.
func _find_scene_root(node: Node) -> Node:
	var engine := _get_engine(node)
	if engine == null:
		return null

	var candidate := node
	while candidate != null:
		if engine.get_variable_manager_for(candidate) != null:
			return candidate
		candidate = candidate.get_parent()
	# The target might not be in the scene at all (like the System node)
	return node.get_tree().current_scene

func _get_variable_manager(node: Node, scene_root: Node) -> FKVariableManager:
	var engine := _get_engine(node)
	if engine == null or scene_root == null:
		return null
	return engine.get_variable_manager_for(scene_root)

func get_class() -> String:
	return "FKSetVariable"
