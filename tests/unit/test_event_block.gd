extends GutTest

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
