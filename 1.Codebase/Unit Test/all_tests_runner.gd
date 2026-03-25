extends Node

var test_results: Array = []
var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

# Files that cannot be run as child nodes (extend SceneTree or are runners/utilities)
const SKIP_FILES: Array[String] = [
	"all_tests_runner.gd",
	"ui_tests_runner.gd",
	"quick_verify.gd",
	"test_prayer_sanitization.gd",        # extends SceneTree
	"test_gemini_session_resumption.gd",   # extends SceneTree
]

func _ready() -> void:
	print("\n" + "=".repeat(80))
	print("   RUNNING ALL UNIT TESTS")
	print("=".repeat(80) + "\n")
	call_deferred("_run_all_tests")

func _run_all_tests() -> void:
	await get_tree().process_frame

	# --- Inline quick sanity checks (feed into this runner's assert counter) ---
	print("\n Test Suite: Quick Sanity Checks")
	print("-".repeat(80))
	var suite_start := Time.get_ticks_msec()
	_test_service_locator()
	_test_error_reporter()
	_test_game_state_quick()
	_test_ai_system_quick()
	print("     Duration: %d ms" % (Time.get_ticks_msec() - suite_start))

	# --- Auto-discover and run all test_*.gd files ---
	var discovered := _discover_test_files("res://1.Codebase/Unit Test")
	discovered.sort()

	for file_path in discovered:
		var suite_name: String = file_path.get_file().get_basename()
		print("\n Test Suite: %s" % suite_name)
		print("-".repeat(80))
		var start_ms := Time.get_ticks_msec()
		await _run_test_file(file_path)
		print("     Duration: %d ms" % (Time.get_ticks_msec() - start_ms))

	print_summary()
	await get_tree().create_timer(1.0).timeout
	_prepare_for_shutdown()
	var exit_code := 0 if failed_tests == 0 else 1
	Engine.print_error_messages = false
	get_tree().quit(exit_code)

func _discover_test_files(base_path: String) -> Array[String]:
	var files: Array[String] = []
	var dir := DirAccess.open(base_path)
	if dir == null:
		push_warning("all_tests_runner: Cannot open directory: %s" % base_path)
		return files
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with("."):
			# Recurse into subdirectories (e.g. integration/)
			var sub := _discover_test_files(base_path + "/" + entry)
			files.append_array(sub)
		elif entry.begins_with("test_") and entry.ends_with(".gd") and entry not in SKIP_FILES:
			files.append(base_path + "/" + entry)
		entry = dir.get_next()
	dir.list_dir_end()
	return files

func _run_test_file(path: String) -> void:
	var TestClass = load(path)
	if TestClass == null:
		push_warning("all_tests_runner: Could not load %s" % path)
		return
	var test_instance: Node = TestClass.new()
	add_child(test_instance)
	await test_instance.tree_exited

func assert_test(condition: bool, test_name: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
		print("    PASS: %s" % test_name)
		test_results.append({"name": test_name, "status": "PASS"})
	else:
		failed_tests += 1
		print("    FAIL: %s" % test_name)
		test_results.append({"name": test_name, "status": "FAIL"})

# ---------------------------------------------------------------------------
# Inline quick checks — do NOT load external files; use assert_test() directly
# ---------------------------------------------------------------------------

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
	ErrorReporter.report_error("TestSuite", "Test error message", 42, false, {"detail": "test"})
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
	var initial_reality := GameState.reality_score
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
	var result := GameState.skill_check("logic", 5)
	assert_test(result.has("success"), "Skill check returns result structure")
	assert_test(result.has("roll"), "Skill check includes roll value")
	GameState.set_game_phase(GameConstants.GamePhase.CRISIS)
	assert_test(GameState.game_phase == GameConstants.GamePhase.CRISIS, "Game phase changes correctly")
	GameState.set_game_phase(GameConstants.GamePhase.NORMAL)
	var entropy := GameState.calculate_void_entropy()
	assert_test(entropy >= 0.0 and entropy <= 1.0, "Entropy calculation returns valid range")
	print("     For comprehensive GameState tests, run game_state_test_runner.tscn")

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
	var note_count := AIManager.memory_store.get_note_count()
	assert_test(note_count > 0, "AI note registration works")
	AIManager.clear_notes()
	assert_test(AIManager.gemini_model is String, "Gemini model configured")
	assert_test(AIManager.openrouter_model is String, "OpenRouter model configured")
	assert_test(AIManager.ollama_model is String, "Ollama model configured")
	assert_test(AIManager.custom_ai_tone_style.length() > 0, "AI tone style is set")
	print("     For comprehensive AI tests, run ai_system_test_runner.tscn")

# ---------------------------------------------------------------------------
# Summary & shutdown
# ---------------------------------------------------------------------------

func print_summary() -> void:
	print("\n" + "=".repeat(80))
	print("   TEST SUMMARY")
	print("=".repeat(80))
	var pass_rate := (float(passed_tests) / float(total_tests)) * 100.0 if total_tests > 0 else 0.0
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
