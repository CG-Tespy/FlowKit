extends GutTest
class_name FKEventBlockTests

func test_event_block_defaults():
	var ev := FKEventBlock.new()
	assert_eq(ev.conditions.size(), 0)
	assert_eq(ev.actions.size(), 0)
	assert_eq(ev.event_id, "")

func test_event_block_serialization_roundtrip():
	var ev := FKEventBlock.new()
	ev.event_id = "TestEvent"
	ev.conditions.append(FKConditionUnit.new())
	ev.actions.append(FKActionUnit.new())

	var json: Dictionary = ev.serialize()
	var restored: FKEventBlock = FKEventBlock.new()
	restored.deserialize(json)

	assert_eq(restored.event_id, "TestEvent")
	assert_eq(restored.conditions.size(), 1)
	assert_eq(restored.actions.size(), 1)
	
func test_deep_duplication():
	var ev := FKEventBlock.new()
	ev.event_id = "TestEvent"
	ev.inputs = {"x": 1, "y": 2}
	ev.conditions.append(FKConditionUnit.new())
	ev.actions.append(FKActionUnit.new())

	var dup := ev.duplicate_block() as FKEventBlock

	# Basic sanity: not the same instance
	assert_ne(dup, ev, "Duplicate should be a different instance")

	# Inputs dictionary must be deep-copied
	var deep_copy_success: bool = not is_same(dup.inputs, ev.inputs)
	assert_true(deep_copy_success, "Both inputs, despite having the same contents, should be different instances")
	assert_eq(dup.inputs, ev.inputs, "Inputs dictionary should contain same values")

	# Conditions must be deep-copied
	assert_eq(dup.conditions.size(), 1)
	
	deep_copy_success = not is_same(dup.conditions[0], ev.conditions[0])
	assert_true(deep_copy_success, "Condition should be a deep copy")

	# Actions must be deep-copied
	assert_eq(dup.actions.size(), 1)
	
	deep_copy_success = not is_same(dup.actions[0], ev.actions[0])
	assert_true(deep_copy_success, "Action should be a deep copy")

	# Mutating duplicate should not mutate original
	dup.inputs["x"] = 999
	assert_ne(ev.inputs["x"], dup.inputs["x"], "Mutating duplicate should not affect original")

func test_ensure_block_id():
	# Case 1: Empty block_id should generate a new one
	var ev1 := FKEventBlock.new()
	ev1.block_id = ""
	ev1.ensure_block_id()
	assert_false(ev1.block_id.is_empty(), "ensure_block_id should generate a new ID when empty")

	# Case 2: Existing block_id should be preserved
	var ev2 := FKEventBlock.new()
	ev2.block_id = "my_custom_id"
	ev2.ensure_block_id()
	assert_eq(ev2.block_id, "my_custom_id", "ensure_block_id should not overwrite existing ID")

	# Case 3: Generated IDs should be unique
	var ev3 := FKEventBlock.new()
	ev3.block_id = ""
	ev3.ensure_block_id()

	var ev4 := FKEventBlock.new()
	ev4.block_id = ""
	ev4.ensure_block_id()

	assert_ne(ev3.block_id, ev4.block_id, "Generated block IDs should be unique")

func test_serialization_structure():
	var ev := FKEventBlock.new()
	ev.event_id = "TestEvent"
	ev.inputs = {"foo": "bar"}

	# --- Condition setup ---
	var cond := FKConditionUnit.new()
	cond.condition_id = "IsReady"
	cond.target_node = NodePath("Player")
	cond.inputs = {"threshold": 5}
	cond.negated = true
	ev.conditions.append(cond)

	# --- Action setup ---
	var act := FKActionUnit.new()
	act.action_id = "Move"
	act.target_node = NodePath("Enemy")
	act.inputs = {"speed": 10}
	ev.actions.append(act)

	var json: Dictionary = ev.serialize()

	# --- Top-level keys ---
	assert_true(json.has("type"))
	assert_true(json.has("block_id"))
	assert_true(json.has("event_id"))
	assert_true(json.has("inputs"))
	assert_true(json.has("conditions"))
	assert_true(json.has("actions"))

	# --- Inputs preserved ---
	assert_eq(json["inputs"], {"foo": "bar"})

	# --- Condition structure ---
	assert_eq(json["conditions"].size(), 1)
	var cond_json = json["conditions"][0]

	assert_eq(cond_json["type"], "condition")
	assert_eq(cond_json["condition_id"], "IsReady")
	assert_eq(cond_json["target_node"], "Player")
	assert_eq(cond_json["inputs"], {"threshold": 5})
	assert_eq(cond_json["negated"], true)

	# --- Action structure ---
	assert_eq(json["actions"].size(), 1)
	var act_json = json["actions"][0]

	assert_eq(act_json["type"], "action")
	assert_eq(act_json["action_id"], "Move")
	assert_eq(act_json["target_node"], "Enemy")
	assert_eq(act_json["inputs"], {"speed": 10})

	# Branch fields should exist but be default values
	assert_eq(act_json["is_branch"], false)
	assert_eq(act_json["branch_type"], "")
	assert_eq(act_json["branch_id"], "")
	assert_eq(act_json["branch_inputs"], {})

	# No branch_condition or branch_actions when is_branch == false
	assert_false(act_json.has("branch_condition"))
	assert_false(act_json.has("branch_actions"))

	# --- Round-trip check ---
	var restored := FKEventBlock.new()
	restored.deserialize(json)

	assert_eq(restored.inputs, ev.inputs)
	assert_eq(restored.conditions.size(), 1)
	assert_eq(restored.actions.size(), 1)

	# Condition round-trip
	var restored_cond := restored.conditions[0]
	assert_eq(restored_cond.condition_id, "IsReady")
	assert_eq(restored_cond.target_node, NodePath("Player"))
	assert_eq(restored_cond.inputs, {"threshold": 5})
	assert_eq(restored_cond.negated, true)

	# Action round-trip
	var restored_act := restored.actions[0]
	assert_eq(restored_act.action_id, "Move")
	assert_eq(restored_act.target_node, NodePath("Enemy"))
	assert_eq(restored_act.inputs, {"speed": 10})
	assert_false(restored_act.is_branch)

func test_event_block_target_node_roundtrip():
	var ev := FKEventBlock.new()
	ev.event_id = "OnReady"
	ev.target_node = NodePath("Player/Camera")

	var json := ev.serialize()

	assert_eq(json["target_node"], "Player/Camera")

	var restored := FKEventBlock.new()
	restored.deserialize(json)

	assert_eq(restored.target_node, NodePath("Player/Camera"))

func test_event_block_inputs_nested_roundtrip():
	var ev := FKEventBlock.new()
	ev.inputs = {
		"simple": 1,
		"nested": {"a": 10, "b": 20}
	}

	var json := ev.serialize()
	assert_eq(json["inputs"], {
		"simple": 1,
		"nested": {"a": 10, "b": 20}
	})

	var restored := FKEventBlock.new()
	restored.deserialize(json)

	assert_eq(restored.inputs, ev.inputs)


func test_event_block_duplicate_multiple_items():
	var ev := FKEventBlock.new()
	ev.event_id = "Multi"
	ev.inputs = {"x": 1}

	# Add multiple conditions
	var c1 := FKConditionUnit.new()
	c1.condition_id = "C1"
	var c2 := FKConditionUnit.new()
	c2.condition_id = "C2"
	ev.conditions.append_array([c1, c2])

	# Add multiple actions
	var a1 := FKActionUnit.new()
	a1.action_id = "A1"
	var a2 := FKActionUnit.new()
	a2.action_id = "A2"
	ev.actions.append_array([a1, a2])

	var dup := ev.duplicate_block() as FKEventBlock

	# Conditions deep-copied
	assert_eq(dup.conditions.size(), 2)
	assert_true(not is_same(dup.conditions[0], ev.conditions[0]))
	assert_true(not is_same(dup.conditions[1], ev.conditions[1]))

	# Actions deep-copied
	assert_eq(dup.actions.size(), 2)
	assert_true(not is_same(dup.actions[0], ev.actions[0]))
	assert_true(not is_same(dup.actions[1], ev.actions[1]))

	# Mutating duplicate should not affect original
	dup.conditions[0].condition_id = "Changed"
	assert_ne(ev.conditions[0].condition_id, dup.conditions[0].condition_id)
