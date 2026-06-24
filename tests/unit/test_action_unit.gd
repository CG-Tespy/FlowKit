extends GutTest

func test_basic_serialization():
	var act := FKActionUnit.new()
	act.action_id = "Move"
	act.target_node = NodePath("Enemy")
	act.inputs = {"speed": 10}

	var json := act.serialize()

	assert_eq(json["type"], "action")
	assert_eq(json["action_id"], "Move")
	assert_eq(json["target_node"], "Enemy")
	assert_eq(json["inputs"], {"speed": 10})

	# Branch fields should exist but be default values
	assert_false(json["is_branch"])
	assert_eq(json["branch_type"], "")
	assert_eq(json["branch_id"], "")
	assert_eq(json["branch_inputs"], {})

	# No branch_condition or branch_actions when not a branch
	assert_false(json.has("branch_condition"))
	assert_false(json.has("branch_actions"))

func test_branch_serialization_roundtrip():
	var act := FKActionUnit.new()
	act.action_id = "IfCheck"
	act.is_branch = true
	act.branch_type = "if"
	act.branch_id = "branch_provider"
	act.branch_inputs = {"foo": "bar"}

	# Add branch condition
	var cond := FKConditionUnit.new()
	cond.condition_id = "IsReady"
	cond.negated = true
	act.branch_condition = cond

	# Add branch actions
	var sub := FKActionUnit.new()
	sub.action_id = "SubAction"
	sub.inputs = {"x": 1}
	act.branch_actions.append(sub)

	var json := act.serialize()

	# Validate structure
	assert_true(json.has("branch_condition"))
	assert_true(json.has("branch_actions"))
	assert_eq(json["branch_actions"].size(), 1)

	# Round-trip
	var restored := FKActionUnit.new()
	restored.deserialize(json)

	assert_true(restored.is_branch)
	assert_eq(restored.branch_type, "if")
	assert_eq(restored.branch_id, "branch_provider")
	assert_eq(restored.branch_inputs, {"foo": "bar"})

	# Condition restored
	assert_true(restored.branch_condition is FKConditionUnit)
	assert_eq(restored.branch_condition.condition_id, "IsReady")
	assert_true(restored.branch_condition.negated)

	# Branch actions restored
	assert_eq(restored.branch_actions.size(), 1)
	assert_eq(restored.branch_actions[0].action_id, "SubAction")
	assert_eq(restored.branch_actions[0].inputs, {"x": 1})

func test_deep_duplication():
	var act := FKActionUnit.new()
	act.action_id = "Root"
	act.inputs = {"speed": 5}
	act.is_branch = true
	act.branch_type = "if"
	act.branch_inputs = {"foo": "bar"}

	# Condition
	var cond := FKConditionUnit.new()
	cond.condition_id = "Check"
	act.branch_condition = cond

	# Nested action
	var sub := FKActionUnit.new()
	sub.action_id = "Nested"
	sub.inputs = {"x": 1}
	act.branch_actions.append(sub)

	var dup := act.duplicate_block() as FKActionUnit

	# Not the same instance
	var deep_copy_success: bool = not is_same(dup, act)
	assert_ne(dup, act, "Failed FKAction deep duplication at top instance level")

	# Inputs deep-copied
	deep_copy_success = not is_same(dup.inputs, act.inputs)
	assert_true(deep_copy_success, "Input collection deep copy failed.")
	
	var same_contents: bool = dup.inputs == act.inputs
	assert_true(same_contents)

	deep_copy_success = not is_same(dup.branch_inputs, act.branch_inputs)
	assert_true(deep_copy_success, "Branch input collection deep copy failed.")
	
	same_contents = dup.branch_inputs == act.branch_inputs
	assert_true(same_contents)

	deep_copy_success = not is_same(dup.branch_condition, act.branch_condition)
	assert_true(deep_copy_success, "Branch condition deep copy failed.")
	
	assert_eq(dup.branch_condition.condition_id, "Check")
	assert_eq(dup.branch_actions.size(), 1, "Wrong amount of branch actions")
	
	deep_copy_success = not is_same(dup.branch_actions[0], act.branch_actions[0])
	assert_true(deep_copy_success, "Branch Action deep copy failed.")
	assert_eq(dup.branch_actions[0].action_id, "Nested")

	dup.inputs["speed"] = 999
	assert_ne(act.inputs["speed"], dup.inputs["speed"], "Mutating the duplicate affected the orig.")
