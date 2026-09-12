@tool
## Not to be confused with the editor settings. This holds the FlowKit-specific
## settings for a particular project.
extends Resource
class_name FKProjectSettings

## Best mutate this through funcs like set_provider_paths
## rather than doing so directly.
@export var provider_paths: Array[String] = []

func set_provider_paths(new_paths: Array[String]):
	provider_paths.clear()
	provider_paths.append_array(new_paths)

func add_provider_path(to_add: String):
	provider_paths.append(to_add)

func add_multi_provider_paths(to_add: Array[String]):
	provider_paths.append_array(to_add)

func serialized() -> Dictionary:
	var result: Dictionary = \
	{
		"provider_paths": provider_paths
	}
	return result