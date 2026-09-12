extends FKAction

func get_provider_id() -> String:
	return "test_dummy_action"

func get_display_name() -> String:
	return "[Repo-Only Dummy Action]"

func get_supported_types() -> Array[String]:
	return ["Node"]