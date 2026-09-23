extends GutTest

func test_int_variable_converts_numeric_values() -> void:
	var variable := FKIntVariable.new()

	assert_true(variable.set_value(3.8))
	assert_eq(variable.get_value(), 3)
	assert_eq(variable.get_value_as("integer"), 3)
	assert_eq(variable.get_value_as("float"), 3.0)

func test_string_variable_rejects_incompatible_values() -> void:
	var variable := FKStringVariable.new()
	variable.set_value("ready")

	assert_false(variable.set_value(42))
	assert_eq(variable.get_value(), "ready")

func test_successful_assignment_emits_changed() -> void:
	var variable := FKBoolVariable.new()
	watch_signals(variable)

	assert_true(variable.set_value(true))
	assert_signal_emitted(variable, "changed")

func test_audio_stream_variable_keeps_resource_reference() -> void:
	var variable := FKAudioStreamVariable.new()
	var stream := AudioStreamWAV.new()

	assert_true(variable.set_value(stream))
	assert_eq(variable.get_value(), stream)
	assert_eq(variable.get_value_as("AudioStream"), stream)

func test_node_variable_persists_relative_path_and_resolves_value() -> void:
	var owner := Node.new()
	owner.name = "Owner"
	var target := Node.new()
	target.name = "Target"
	owner.add_child(target)
	add_child_autofree(owner)

	var variable := FKNodeVariable.new()
	variable.set_owner(owner)

	assert_true(variable.set_value(target))
	assert_eq(variable.get_node_path(), NodePath("Target"))
	assert_eq(variable.get_value(), target)
	assert_eq(variable.get_value_as("node"), target)

func test_node_variable_requires_owner_context() -> void:
	var variable := FKNodeVariable.new()
	var target := Node.new()
	add_child_autofree(target)

	assert_false(variable.set_value(target))
	assert_null(variable.get_value())