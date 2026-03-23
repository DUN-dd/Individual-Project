extends Node
func _ready() -> void:
	print("\n[CLIRunnerTest] Starting compatibility runner...")
	await get_tree().process_frame
	await _run_suite("CLIRunnerParserTest", "res://1.Codebase/Unit Test/test_cli_runner_parser.gd")
	await _run_suite("CLIRunnerIntegrationTest", "res://1.Codebase/Unit Test/test_cli_runner_integration.gd")
	print("[CLIRunnerTest] Compatibility runner completed")
	queue_free()
func _run_suite(label: String, script_path: String) -> void:
	var suite_script: Script = load(script_path)
	if suite_script == null:
		print("   FAIL: %s script not found at %s" % [label, script_path])
		return
	var suite_instance: Node = suite_script.new()
	if suite_instance == null:
		print("   FAIL: %s could not be instantiated" % label)
		return
	add_child(suite_instance)
	await suite_instance.tree_exited
