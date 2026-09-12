extends FKCondition

func get_provider_id() -> String:
	return "test_dummy_condition"

func get_display_name() -> String:
	return "[Repo-Only Dummy Condition]"

func get_supported_types() -> Array[String]:
	return ["Node"]