extends Node
func _ready():
	print("\n" + "=".repeat(80))
	print(" MENU TRANSLATION KEYS TEST")
	print("=".repeat(80) + "\n")
	await get_tree().process_frame
	if not LocalizationManager:
		print("ERROR: LocalizationManager not available!")
		queue_free()
		return
	var test_keys = [
		"MENU_TIMESTAMP_FMT",
		"MENU_SLOT_FMT",
		"MENU_LAST_SAVE_FMT"
	]
	var all_passed = true
	for key in test_keys:
		print("Testing key: %s" % key)
		var en_value = LocalizationManager.get_translation(key, "en")
		var zh_value = LocalizationManager.get_translation(key, "zh")
		print("  EN: %s" % en_value)
		print("  ZH: %s" % zh_value)
		if en_value == key:
			print("  ❌ FAILED: English translation not found!")
			all_passed = false
		else:
			print("  ✓ English translation found")
		if zh_value == key:
			print("  ❌ FAILED: Chinese translation not found!")
			all_passed = false
		else:
			print("  ✓ Chinese translation found")
		print("")
	print("Testing string formatting:")
	print("")
	var slot_fmt = LocalizationManager.get_translation("MENU_SLOT_FMT", "en")
	if slot_fmt != "MENU_SLOT_FMT":
		if "%" in slot_fmt:
			var formatted = slot_fmt % 3
			print("  MENU_SLOT_FMT %% 3 = '%s'" % formatted)
		else:
			print("  MENU_SLOT_FMT missing format string")
		print("  ✓ Slot formatting works")
	else:
		print("  ❌ Cannot test MENU_SLOT_FMT formatting: key not found")
		all_passed = false
	print("")
	var timestamp_fmt = LocalizationManager.get_translation("MENU_TIMESTAMP_FMT", "en")
	if timestamp_fmt != "MENU_TIMESTAMP_FMT":
		if "%" in timestamp_fmt:
			var formatted = timestamp_fmt % [2026, 2, 25, 14, 30]
			print("  MENU_TIMESTAMP_FMT %% [2026, 2, 25, 14, 30] = '%s'" % formatted)
		else:
			print("  MENU_TIMESTAMP_FMT missing format string")
		print("  ✓ Timestamp formatting works")
	else:
		print("  ❌ Cannot test MENU_TIMESTAMP_FMT formatting: key not found")
		all_passed = false
	print("")
	var last_save_fmt = LocalizationManager.get_translation("MENU_LAST_SAVE_FMT", "en")
	if last_save_fmt != "MENU_LAST_SAVE_FMT":
		if "%" in last_save_fmt:
			var formatted = last_save_fmt % [85, 12, "Slot 3", "2026-02-25 14:30"]
			print("  MENU_LAST_SAVE_FMT %% [85, 12, 'Slot 3', '2026-02-25 14:30'] = '%s'" % formatted)
		else:
			print("  MENU_LAST_SAVE_FMT missing format string")
		print("  ✓ Last save formatting works")
	else:
		print("  ❌ Cannot test MENU_LAST_SAVE_FMT formatting: key not found")
		all_passed = false
	print("")
	print("=".repeat(80))
	if all_passed:
		print("✓ ALL TESTS PASSED")
	else:
		print("❌ SOME TESTS FAILED")
	print("=".repeat(80) + "\n")
	queue_free()
