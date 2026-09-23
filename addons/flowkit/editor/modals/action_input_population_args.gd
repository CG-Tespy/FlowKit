extends RefCounted
class_name FKActionInputPopulationArgs

var action: FKAction
var node_path := ""
var action_id := ""
var action_inputs: Array[FKActionInput] = []
var inputs: Dictionary = {}

func set_to(other: FKActionInputPopulationArgs):
	self.action = other.action
	self.node_path = other.node_path
	self.action_id = other.action_id
	self.action_inputs.clear()
	self.action_inputs.assign(other.action_inputs)
	self.inputs.clear()
	self.inputs.assign(other.inputs)

func clear():
	action = null
	node_path = ""
	action_id = ""
	action_inputs.clear()
	inputs.clear()