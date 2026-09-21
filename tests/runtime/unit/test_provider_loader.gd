extends GutTest

const ACTION_FIXTURE_PATH := "res://tests/fixtures/providers/action"
const PROJECT_SETTINGS_PATH := "res://addons/flowkit/editor/_fk_project_settings.tres"

func test_loader_returns_fresh_non_accumulating_results() -> void:
	var loader := FKProviderLoader.new()
	var first_result := loader.load_all()
	var second_result := loader.load_all()

	assert_ne(first_result, second_result)
	assert_eq(first_result.source, second_result.source)
	assert_eq(first_result.get_total_provider_count(), second_result.get_total_provider_count())

func test_registry_reload_replaces_provider_catalog() -> void:
	var registry := FKRegistry.new()
	registry.load_all()
	var first_count := registry.action_providers.size() + registry.condition_providers.size() + \
	registry.event_providers.size() + registry.behavior_providers.size() + registry.branch_providers.size()

	registry.load_all()
	var second_count := registry.action_providers.size() + registry.condition_providers.size() + \
	registry.event_providers.size() + registry.behavior_providers.size() + registry.branch_providers.size()

	assert_eq(first_count, second_count)

func test_new_registry_can_dispatch_an_unknown_action() -> void:
	var registry := FKRegistry.new()
	var target_node := Node.new()

	var result = await registry.execute_action("missing_action", target_node, {})

	assert_null(result)

func test_loader_filters_invalid_providers_and_reports_duplicates() -> void:
	var loader := FKProviderLoader.new()
	loader.default_provider_path = ACTION_FIXTURE_PATH

	var result := loader.load_all()
	var diagnostics := "\n".join(result.diagnostics)

	assert_eq(result.source, "directory")
	assert_eq(result.action_providers.size(), 4)
	assert_eq(result.condition_providers.size(), 2)
	assert_true(diagnostics.contains("does not extend FKProvider"))
	assert_true(diagnostics.contains("empty id"))
	assert_true(diagnostics.contains("Duplicate action provider id 'duplicate_action'"))

func test_loader_registers_default_test_provider_path() -> void:
	var settings := load(PROJECT_SETTINGS_PATH) as FKProjectSettings
	var loader := FKProviderLoader.new()
	loader.project_settings = settings

	var paths := loader._get_provider_paths()

	assert_eq(paths, [
		FKProviderLoader.DEFAULT_PROVIDER_PATH,
		FKProviderLoader.DEFAULT_TEST_PROVIDER_PATH,
	])
	assert_eq(paths.count(FKProviderLoader.DEFAULT_TEST_PROVIDER_PATH), 1)

func test_loader_loads_default_test_providers() -> void:
	var loader := FKProviderLoader.new()
	loader.default_provider_path = ""

	var result := loader.load_all()

	assert_eq(result.source, "directory")
	assert_true(_has_provider_id(result.action_providers, "test_dummy_action"))
	assert_true(_has_provider_id(result.condition_providers, "test_dummy_condition"))

func test_loader_uses_project_settings_provider_paths() -> void:
	var settings := load(PROJECT_SETTINGS_PATH) as FKProjectSettings
	var loader := FKProviderLoader.new()
	loader.project_settings = settings

	var result := loader.load_all()

	assert_true(_has_provider_id(result.action_providers, "test_dummy_action"))
	assert_true(_has_provider_id(result.condition_providers, "test_dummy_condition"))

func _has_provider_id(providers: Array, provider_id: String) -> bool:
	for provider in providers:
		if provider.get_provider_id() == provider_id:
			return true
	return false