extends Node
class_name FKModalSignals

func _enter_tree() -> void:
	if s != self and s != null:
		var message := "[FKModalSignals]: Singleton already there. Deleting new instance."
		print(message)
		return
		
	s = self
		
static var s: FKModalSignals

signal node_selected(node_path: String, node_class: String)
signal event_selected(node_path: String, event_id: String, event_inputs: Array)
signal action_selected(node_path: String, action_id: String, action_inputs: Array)
signal condition_selected(node_path: String, condition_id: String, condition_inputs: Array)
signal expressions_confirmed(node_path: String, action_id: String, expressions: Dictionary)

func _exit_tree() -> void:
	if s == self:
		s = null
