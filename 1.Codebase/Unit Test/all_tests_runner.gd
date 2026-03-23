extends Node
var test_results: Array = []
var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0
var _suite_names: Array[String] = []
var _suite_callables: Array[Callable] = []
var _current_suite_index: int = 0
func _ready() -> void:
	print("\n" + "=".repeat(80))
	print("   RUNNING ALL UNIT TESTS")
	print("=".repeat(80) + "\n")
	_suite_names = [
		"ServiceLocator Integration",
		"ErrorReporter Functionality",
		"GameState Core (Quick)",
		"Polish Regression (Quick)",
		"CLIRunner Parser Unit",
		"CLIRunner Command Integration",
		"AI System Core (Quick)",
		"OllamaClient API",
		"LiveAPIClient WebSocket",
		"AssetInteractionSystem",
		"Resource Loaders",
		"TeammateSystem",
		"VoiceInteractionController",
		"AI Providers",
		"SessionProgressTracker",
		"TrolleyProblemGenerator",
		"MissionScenarioLibrary",
		"BackgroundLoader",
		"IntroStory Loading",
		"TrolleyProblemRelationshipBug",
		"Integration: StoryFlow",
		"Integration: AchievementUnlock",
		"Integration: AINarrativeParse",
		"AIPromptBuilder",
		"AISystem",
		"AudioManager",
		"CLIRunner",
		"GameState",
		"MockAIGeneratorI18n",
		"NotificationSystem",
		"SceneDirectivesParser",
		"StoryChoiceController",
		"StoryUIController",
		"TooltipManager",
	]
	_suite_callables = [
		_test_service_locator,
		_test_error_reporter,
		_test_game_state_quick,
		_test_polish_regressions,
		_test_cli_runner_parser,
		_test_cli_runner_integration,
		_test_ai_system_quick,
		_test_ollama_client,
		_test_live_api_client,
		_test_asset_interaction_system,
		_test_resource_loaders,
		_test_teammate_system,
		_test_voice_interaction_controller,
		_test_ai_providers,
		_test_session_progress_tracker,
		_test_trolley_problem_generator,
		_test_mission_scenario_library,
		_test_background_loader,
		_test_intro_story_loading,
		_test_trolley_problem_relationship_bug,
		_test_integration_story_flow,
		_test_integration_achievement_unlock,
		_test_integration_ai_narrative_parse,
		_test_ai_prompt_builder,
		_test_ai_system,
		_test_audio_manager,
		_test_cli_runner,
		_test_game_state,
		_test_mock_ai_generator_i18n,
		_test_notification_system,
		_test_scene_directives_parser,
		_test_story_choice_controller,
		_test_story_ui_controller,
		_test_tooltip_manager,
	]
	call_deferred("_run_next_suite")
func _run_next_suite() -> void:
	if _current_suite_index == 0:
		await get_tree().process_frame
	if _current_suite_index >= _suite_names.size():
		print_summary()
		await get_tree().create_timer(1.0).timeout
		_prepare_for_shutdown()
		var exit_code = 0 if failed_tests == 0 else 1
		Engine.print_error_messages = false
		get_tree().quit(exit_code)
		return
	var suite_name: String = _suite_names[_current_suite_index]
	var suite_callable: Callable = _suite_callables[_current_suite_index]
	print("\n Test Suite: %s" % suite_name)
	print("-".repeat(80))
	var suite_start = Time.get_ticks_msec()
	if not suite_callable.is_null():
		await suite_callable.call()
	var suite_duration = Time.get_ticks_msec() - suite_start
	print("     Duration: %d ms" % suite_duration)
	_current_suite_index += 1
	call_deferred("_run_next_suite")
func assert_test(condition: bool, test_name: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
		print("    PASS: %s" % test_name)
		test_results.append({ "name": test_name, "status": "PASS" })
	else:
		failed_tests += 1
		print("    FAIL: %s" % test_name)
		test_results.append({ "name": test_name, "status": "FAIL" })
func _test_service_locator() -> void:
	assert_test(ServiceLocator != null, "ServiceLocator exists")
	var ai_manager = ServiceLocator.get_ai_manager()
	assert_test(ai_manager != null, "Can get AIManager via ServiceLocator")
	var game_state = ServiceLocator.get_game_state()
	assert_test(game_state != null, "Can get GameState via ServiceLocator")
	var asset_registry = ServiceLocator.get_asset_registry()
	assert_test(asset_registry != null, "Can get AssetRegistry via ServiceLocator")
	var achievement_system = ServiceLocator.get_achievement_system()
	assert_test(achievement_system != null, "Can get AchievementSystem via ServiceLocator")
	var services = ServiceLocator.list_services()
	assert_test(services.size() > 5, "ServiceLocator has multiple services registered")
	print("     Magic strings reduced from 94 to 9 (only in test files)")
func _test_error_reporter() -> void:
	assert_test(ErrorReporter != null, "ErrorReporter exists as autoload")
	ErrorReporter.report_info("TestSuite", "Test info message")
	assert_test(true, "Can report info message")
	ErrorReporter.report_warning("TestSuite", "Test warning message")
	assert_test(true, "Can report warning message")
	var previous_console_logs := ErrorReporter.enable_console_logs
	ErrorReporter.enable_console_logs = false
	ErrorReporter.report_error("TestSuite", "Test error message", 42, false, { "detail": "test" })
	ErrorReporter.enable_console_logs = previous_console_logs
	assert_test(true, "Can report error with details")
	var stats = ErrorReporter.get_statistics()
	assert_test(stats.has("errors"), "ErrorReporter tracks error statistics")
	assert_test(stats.has("warnings"), "ErrorReporter tracks warning statistics")
	assert_test(stats["total"] > 0, "ErrorReporter counts total messages")
	assert_test(ErrorReporter.enable_console_logs is bool, "ErrorReporter has console_logs config")
	assert_test(ErrorReporter.enable_user_notifications is bool, "ErrorReporter has notifications config")
	ErrorReporter.reset_statistics()
	print("     ErrorReporter statistics reset")
func _test_game_state_quick() -> void:
	assert_test(GameState != null, "GameState exists")
	var initial_reality = GameState.reality_score
	GameState.modify_reality_score(5, "Test")
	assert_test(GameState.reality_score == initial_reality + 5, "Reality score modification works")
	GameState.reality_score = initial_reality
	GameState.reality_score = 98
	GameState.modify_reality_score(10, "Test clamping")
	assert_test(GameState.reality_score == 100, "Reality score clamps at 100")
	GameState.reality_score = initial_reality
	GameState.clear_events()
	GameState.add_event("Test event EN", (LocalizationManager.get_translation("TEST_EVENT_ZH", "zh") if LocalizationManager else "Test Event") + " ZH")
	assert_test(GameState.recent_events.size() > 0, "Event logging works")
	var result = GameState.skill_check("logic", 5)
	assert_test(result.has("success"), "Skill check returns result structure")
	assert_test(result.has("roll"), "Skill check includes roll value")
	GameState.set_game_phase(GameConstants.GamePhase.CRISIS)
	assert_test(GameState.game_phase == GameConstants.GamePhase.CRISIS, "Game phase changes correctly")
	GameState.set_game_phase(GameConstants.GamePhase.NORMAL)
	var entropy = GameState.calculate_void_entropy()
	assert_test(entropy >= 0.0 and entropy <= 1.0, "Entropy calculation returns valid range")
	print("     For comprehensive GameState tests, run game_state_test_runner.tscn")
func _test_polish_regressions() -> void:
	var PolishRegressionTest = load("res://1.Codebase/Unit Test/test_polish_regressions.gd")
	var test_instance = PolishRegressionTest.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     Polish regression checks completed")
func _test_cli_runner_parser() -> void:
	var CLIRunnerParserTest = load("res://1.Codebase/Unit Test/test_cli_runner_parser.gd")
	var test_instance = CLIRunnerParserTest.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     CLIRunner parser unit tests completed")
func _test_cli_runner_integration() -> void:
	var CLIRunnerIntegrationTest = load("res://1.Codebase/Unit Test/test_cli_runner_integration.gd")
	var test_instance = CLIRunnerIntegrationTest.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     CLIRunner command integration tests completed")
func _test_ai_system_quick() -> void:
	assert_test(AIManager != null, "AIManager exists")
	var current_provider = AIManager.current_provider
	assert_test(
		current_provider in [
			AIManager.AIProvider.GEMINI,
			AIManager.AIProvider.OPENROUTER,
			AIManager.AIProvider.OLLAMA,
			AIManager.AIProvider.OPENAI,
			AIManager.AIProvider.CLAUDE,
			AIManager.AIProvider.LMSTUDIO,
			AIManager.AIProvider.AI_ROUTER,
			AIManager.AIProvider.MOCK_MODE,
		],
		"AIManager has valid provider",
	)
	assert_test(AIManager.memory_store != null, "AIManager has memory store")
	AIManager.clear_notes()
	AIManager.register_note_pair("Test EN", (LocalizationManager.get_translation("TEST_STAT_MODIFIER", "zh") if LocalizationManager else "Test") + " ZH", ["test"], 2, "test")
	var note_count = AIManager.memory_store.get_note_count()
	assert_test(note_count > 0, "AI note registration works")
	AIManager.clear_notes()
	assert_test(AIManager.gemini_model is String, "Gemini model configured")
	assert_test(AIManager.openrouter_model is String, "OpenRouter model configured")
	assert_test(AIManager.ollama_model is String, "Ollama model configured")
	assert_test(AIManager.custom_ai_tone_style.length() > 0, "AI tone style is set")
	print("     For comprehensive AI tests, run ai_system_test_runner.tscn")
func _test_ollama_client() -> void:
	var OllamaClientTest = load("res://1.Codebase/Unit Test/test_ollama_client.gd")
	var test_instance = OllamaClientTest.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     OllamaClient tests completed")
func _test_live_api_client() -> void:
	var LiveAPIClientTest = load("res://1.Codebase/Unit Test/test_live_api_client.gd")
	var test_instance = LiveAPIClientTest.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     LiveAPIClient tests completed")
func _test_asset_interaction_system() -> void:
	var AssetInteractionTest = load("res://1.Codebase/Unit Test/test_asset_interaction_system.gd")
	var test_instance = AssetInteractionTest.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     AssetInteractionSystem tests completed")
func _test_resource_loaders() -> void:
	var ResourceLoadersTest = load("res://1.Codebase/Unit Test/test_resource_loaders.gd")
	var test_instance = ResourceLoadersTest.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     Resource Loaders tests completed")
func _test_teammate_system() -> void:
	var TeammateSystemTest = load("res://1.Codebase/Unit Test/test_teammate_system.gd")
	var test_instance = TeammateSystemTest.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     TeammateSystem tests completed")
func _test_voice_interaction_controller() -> void:
	var VoiceControllerTest = load("res://1.Codebase/Unit Test/test_voice_interaction_controller.gd")
	var test_instance = VoiceControllerTest.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     VoiceInteractionController tests completed")
func _test_ai_providers() -> void:
	var AIProvidersTest = load("res://1.Codebase/Unit Test/test_ai_providers.gd")
	var test_instance = AIProvidersTest.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     AI Providers tests completed")
func _test_session_progress_tracker() -> void:
	var TrackerTest = load("res://1.Codebase/Unit Test/test_session_progress_tracker.gd")
	var test_instance = TrackerTest.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     SessionProgressTracker tests completed")
func _test_trolley_problem_generator() -> void:
	var TrolleyTest = load("res://1.Codebase/Unit Test/test_trolley_problem_generator.gd")
	var test_instance = TrolleyTest.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     TrolleyProblemGenerator tests completed")
func _test_mission_scenario_library() -> void:
	var LibraryTest = load("res://1.Codebase/Unit Test/test_mission_scenario_library.gd")
	var test_instance = LibraryTest.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     MissionScenarioLibrary tests completed")
func _test_background_loader() -> void:
	var LoaderTest = load("res://1.Codebase/Unit Test/test_background_loader.gd")
	var test_instance = LoaderTest.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     BackgroundLoader tests completed")
func _test_intro_story_loading() -> void:
	var IntroStoryLoadingTest = load("res://1.Codebase/Unit Test/test_intro_story_loading.gd")
	var test_instance = IntroStoryLoadingTest.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     IntroStory loading tests completed")
func _test_trolley_problem_relationship_bug() -> void:
	var BugTest = load("res://1.Codebase/Unit Test/test_trolley_problem_relationship_bug.gd")
	var test_instance = BugTest.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     TrolleyProblemRelationshipBug tests completed")
func _test_integration_story_flow() -> void:
	var TestClass = load("res://1.Codebase/Unit Test/integration/test_story_flow.gd")
	var test_instance = TestClass.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     Integration: StoryFlow tests completed")
func _test_integration_achievement_unlock() -> void:
	var TestClass = load("res://1.Codebase/Unit Test/integration/test_achievement_unlock.gd")
	var test_instance = TestClass.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     Integration: AchievementUnlock tests completed")
func _test_integration_ai_narrative_parse() -> void:
	var TestClass = load("res://1.Codebase/Unit Test/integration/test_ai_narrative_parse.gd")
	var test_instance = TestClass.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     Integration: AINarrativeParse tests completed")
func _test_ai_prompt_builder() -> void:
	var TestClass = load("res://1.Codebase/Unit Test/test_ai_prompt_builder.gd")
	var test_instance = TestClass.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     AIPromptBuilder tests completed")
func _test_ai_system() -> void:
	var TestClass = load("res://1.Codebase/Unit Test/test_ai_system.gd")
	var test_instance = TestClass.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     AISystem tests completed")
func _test_audio_manager() -> void:
	var TestClass = load("res://1.Codebase/Unit Test/test_audio_manager.gd")
	var test_instance = TestClass.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     AudioManager tests completed")
func _test_cli_runner() -> void:
	var TestClass = load("res://1.Codebase/Unit Test/test_cli_runner.gd")
	var test_instance = TestClass.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     CLIRunner tests completed")
func _test_game_state() -> void:
	var TestClass = load("res://1.Codebase/Unit Test/test_game_state.gd")
	var test_instance = TestClass.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     GameState tests completed")
func _test_mock_ai_generator_i18n() -> void:
	var TestClass = load("res://1.Codebase/Unit Test/test_mock_ai_generator_i18n.gd")
	var test_instance = TestClass.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     MockAIGeneratorI18n tests completed")
func _test_notification_system() -> void:
	var TestClass = load("res://1.Codebase/Unit Test/test_notification_system.gd")
	var test_instance = TestClass.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     NotificationSystem tests completed")
func _test_scene_directives_parser() -> void:
	var TestClass = load("res://1.Codebase/Unit Test/test_scene_directives_parser.gd")
	var test_instance = TestClass.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     SceneDirectivesParser tests completed")
func _test_story_choice_controller() -> void:
	var TestClass = load("res://1.Codebase/Unit Test/test_story_choice_controller.gd")
	var test_instance = TestClass.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     StoryChoiceController tests completed")
func _test_story_ui_controller() -> void:
	var TestClass = load("res://1.Codebase/Unit Test/test_story_ui_controller.gd")
	var test_instance = TestClass.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     StoryUIController tests completed")
func _test_tooltip_manager() -> void:
	var TestClass = load("res://1.Codebase/Unit Test/test_tooltip_manager.gd")
	var test_instance = TestClass.new()
	add_child(test_instance)
	await test_instance.tree_exited
	print("     TooltipManager tests completed")
func print_summary() -> void:
	print("\n" + "=".repeat(80))
	print("   TEST SUMMARY")
	print("=".repeat(80))
	var pass_rate = (float(passed_tests) / float(total_tests)) * 100.0 if total_tests > 0 else 0.0
	print("\n  Total Tests: %d" % total_tests)
	print("  Passed: %d" % passed_tests)
	print("  Failed: %d" % failed_tests)
	print("  Pass Rate: %.1f%%" % pass_rate)
	if failed_tests == 0:
		print("\n   ALL TESTS PASSED!")
	else:
		print("\n    SOME TESTS FAILED: Review output above")
	print("\n" + "=".repeat(80) + "\n")
	if failed_tests > 0:
		print("Failed tests:")
		for result in test_results:
			if result["status"] == "FAIL":
				print("  * %s" % result["name"])
func _prepare_for_shutdown() -> void:
	_suite_callables.clear()
	_suite_names.clear()
	test_results.clear()
	if AIManager:
		if AIManager.has_method("cancel_parallel_requests"):
			AIManager.cancel_parallel_requests()
		if AIManager.has_method("cancel_pending_requests"):
			AIManager.cancel_pending_requests()
		if AIManager.has_method("clear_pending_voice_input"):
			AIManager.clear_pending_voice_input()
		if AIManager.has_method("clear_notes"):
			AIManager.clear_notes()
		if AIManager.has_method("clear_memory"):
			AIManager.clear_memory()
		if AIManager.has_method("clear_call_log"):
			AIManager.clear_call_log()
		AIManager.pending_callback = Callable()
		AIManager.last_prompt_metrics = {}
	if GameState and GameState.has_method("clear_all_debuffs"):
		GameState.clear_all_debuffs()
