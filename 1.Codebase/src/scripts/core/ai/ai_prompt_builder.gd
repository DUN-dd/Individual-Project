extends RefCounted
class_name AIPromptBuilder
const MAX_PRAYER_LENGTH := 320
const MAX_CHOICE_TEXT_PREVIEW := 60
const MAX_JOURNAL_ENTRIES := 3
const REALITY_SCORE_MAX := 100
const POSITIVE_ENERGY_MAX := 100
const AIPromptsI18n = preload("res://1.Codebase/src/scripts/core/ai/ai_prompts_i18n.gd")
const AIContextDeltaScript = preload("res://1.Codebase/src/scripts/core/ai/ai_context_delta.gd")
var game_state: Node = null
var asset_registry: Node = null
var memory_store: RefCounted = null
var ai_manager: Node = null
var _system_persona: String = ""
var _delta: AIContextDelta = null
func setup(p_game_state: Node, p_asset_registry: Node, p_memory_store: RefCounted, p_ai_manager: Node) -> void:
	game_state = p_game_state
	asset_registry = p_asset_registry
	memory_store = p_memory_store
	ai_manager = p_ai_manager
	_delta = AIContextDeltaScript.new()
func get_delta() -> AIContextDelta:
	return _delta
func reset_delta() -> void:
	if _delta:
		_delta.reset()
func set_system_persona(persona: String) -> void:
	_system_persona = persona
func build_prompt(prompt: String, context: Dictionary) -> Array[Dictionary]:
	var messages: Array[Dictionary] = []
	var language := _get_language()
	if not _delta:
		_delta = AIContextDeltaScript.new()
	_delta.begin_build()
	_append_section_incremental(messages, "static_context",
		_get_static_context_messages(language))
	_append_single_incremental(messages, "system_persona",
		{ "role": "system", "content": _system_persona })
	messages.append({ "role": "assistant", "content": "Acknowledged. I will maintain ironic, pessimistic storytelling for GDA1 while enforcing the recorded facts." })
	_append_section_incremental(messages, "entropy_modifier",
		_get_entropy_modifier_message(language))
	_append_section_incremental(messages, "long_term_context",
		_get_long_term_context(language))
	_append_section_incremental(messages, "notes_context",
		_get_notes_context(language))
	for entry in _get_short_term_memory():
		var msg_copy = entry.duplicate(true)
		if msg_copy.get("role") == "model" or msg_copy.get("role") == "assistant":
			if msg_copy.has("thought_signature"):
				var sanitized_parts: Array = []
				sanitized_parts.append({ "text": str(msg_copy.get("content", "")) })
				if msg_copy.has("parts") and msg_copy["parts"] is Array:
					for part in msg_copy["parts"]:
						if not (part is Dictionary):
							continue
						if part.has("text") or part.has("inlineData") or part.has("fileData") or part.has("functionCall") or part.has("functionResponse"):
							sanitized_parts.append(part)
				sanitized_parts[0]["thoughtSignature"] = str(msg_copy["thought_signature"])
				msg_copy["parts"] = sanitized_parts
				msg_copy.erase("thought_signature")
		messages.append(msg_copy)
		_delta.add_tokens(_delta.estimate_tokens(str(msg_copy.get("content", ""))))
	var user_message_content := _build_user_message_incremental(prompt, context, language)
	var user_message := { "role": "user", "content": user_message_content }
	var parts_array: Array = [{ "text": user_message_content }]
	var voice_part := _build_voice_inline_part()
	if not voice_part.is_empty():
		parts_array.append(voice_part)
		user_message["voice_inline_attached"] = true
	user_message["parts"] = parts_array
	messages.append(user_message)
	_delta.add_tokens(_delta.estimate_tokens(user_message_content))
	_delta.finish_build()
	return messages
func _append_section_incremental(messages: Array[Dictionary], section_name: String, section_msgs: Array[Dictionary]) -> void:
	if section_msgs.is_empty():
		return
	var fingerprint := _delta.fingerprint_messages(section_msgs)
	if _delta.has_section_changed(section_name, fingerprint):
		if _delta.has_budget(fingerprint):
			for msg in section_msgs:
				messages.append(msg)
			_delta.record_section(section_name, fingerprint)
			_delta.add_tokens(_delta.estimate_tokens(fingerprint))
		else:
			var summary := _summarize_section(section_name, section_msgs)
			messages.append({ "role": "system", "content": summary })
			_delta.record_section(section_name, summary)
			_delta.add_tokens(_delta.estimate_tokens(summary))
	else:
		messages.append(_delta.build_unchanged_marker(section_name))
		_delta.add_tokens(10)  
func _append_single_incremental(messages: Array[Dictionary], section_name: String, msg: Dictionary) -> void:
	var content: String = str(msg.get("content", ""))
	if content.is_empty():
		return
	if _delta.has_section_changed(section_name, content):
		if _delta.has_budget(content):
			messages.append(msg)
			_delta.record_section(section_name, content)
			_delta.add_tokens(_delta.estimate_tokens(content))
	else:
		messages.append(_delta.build_unchanged_marker(section_name))
		_delta.add_tokens(10)
func _summarize_section(section_name: String, section_msgs: Array[Dictionary]) -> String:
	var total_chars := 0
	var msg_count := section_msgs.size()
	for msg in section_msgs:
		total_chars += str(msg.get("content", "")).length()
	return "[context:%s updated, %d messages, ~%d chars – truncated for budget]" % [
		section_name, msg_count, total_chars]
func _build_user_message_incremental(prompt: String, context: Dictionary, language: String) -> String:
	var content_parts: Array[String] = []
	content_parts.append(AIPromptsI18n.get_section_header("session_data", language))
	content_parts.append(AIPromptsI18n.get_language_instruction(language))
	var meta_lines := _build_metadata_lines(context)
	if meta_lines.size() > 0:
		content_parts.append("\n".join(meta_lines))
	var events_block := _collect_recent_events(language)
	if _delta.has_section_changed("recent_events", events_block):
		if not events_block.is_empty():
			content_parts.append("\n" + AIPromptsI18n.get_section_header("recent_events", language))
			content_parts.append(events_block)
		_delta.record_section("recent_events", events_block)
	elif not events_block.is_empty():
		content_parts.append("[recent_events unchanged]")
	var butterfly_block := _collect_butterfly_context(language)
	if _delta.has_section_changed("butterfly_effect", butterfly_block):
		if not butterfly_block.is_empty():
			content_parts.append("\n" + AIPromptsI18n.get_section_header("butterfly_effect", language))
			content_parts.append(butterfly_block)
		_delta.record_section("butterfly_effect", butterfly_block)
	elif not butterfly_block.is_empty():
		content_parts.append("[butterfly_effect unchanged]")
	var reflections_block := _collect_player_reflections(language)
	if _delta.has_section_changed("player_reflections", reflections_block):
		if not reflections_block.is_empty():
			content_parts.append("\n" + AIPromptsI18n.get_section_header("player_reflections", language))
			content_parts.append(reflections_block)
		_delta.record_section("player_reflections", reflections_block)
	elif not reflections_block.is_empty():
		content_parts.append("[player_reflections unchanged]")
	var assets_block := _collect_assets_context(context)
	if _delta.has_section_changed("available_assets", assets_block):
		if not assets_block.is_empty():
			content_parts.append("\n" + AIPromptsI18n.get_section_header("available_assets", _get_language()))
			content_parts.append(assets_block)
		_delta.record_section("available_assets", assets_block)
	elif not assets_block.is_empty():
		content_parts.append("[available_assets unchanged]")
	_append_stat_snapshot(content_parts, context)
	content_parts.append("\n" + AIPromptsI18n.get_section_header("prompt", language))
	content_parts.append(prompt.strip_edges())
	return "\n".join(content_parts)
func _collect_recent_events(language: String) -> String:
	if not game_state:
		return ""
	var recent_event_lines: Array = game_state.get_recent_event_notes(6, language)
	if recent_event_lines.size() == 0:
		return ""
	var lines: Array[String] = []
	for line in recent_event_lines:
		lines.append("- " + str(line))
	return "\n".join(lines)
func _collect_butterfly_context(language: String) -> String:
	if not game_state or not game_state.butterfly_tracker:
		return ""
	var butterfly_context: String = game_state.butterfly_tracker.get_context_for_ai(language)
	if butterfly_context.is_empty():
		return ""
	var parts: Array[String] = []
	parts.append(butterfly_context)
	parts.append(AIPromptsI18n.get_butterfly_effect_instruction("reference_past", language))
	parts.append(AIPromptsI18n.get_butterfly_effect_instruction("trigger_callback", language))
	var suggested_choice: Dictionary = game_state.butterfly_tracker.suggest_choice_for_callback()
	if not suggested_choice.is_empty():
		var choice_id: String = suggested_choice.get("id", "")
		var choice_text: String = suggested_choice.get("choice_text", "")
		var scenes_ago: int = game_state.butterfly_tracker.current_scene_number - suggested_choice.get("scene_number", 0)
		var callback_text := AIPromptsI18n.get_butterfly_effect_instruction("suggested_callback", language)
		parts.append(callback_text % [choice_text.left(MAX_CHOICE_TEXT_PREVIEW), scenes_ago, choice_id])
	return "\n".join(parts)
func _collect_player_reflections(language: String) -> String:
	if not game_state:
		return ""
	var reflections: Array = game_state.get_recent_journal_entries(MAX_JOURNAL_ENTRIES)
	if reflections.size() == 0:
		return ""
	var lines: Array[String] = []
	for entry in reflections:
		var timestamp := str(entry.get("timestamp", ""))
		var reflection_text := str(entry.get("text", "")).strip_edges()
		var summary_text := str(entry.get("ai_summary", "")).strip_edges()
		var reflection_line: String
		if language == "en":
			reflection_line = ""
			if not timestamp.is_empty():
				reflection_line += "[" + timestamp + "] "
			reflection_line += reflection_text
			if not summary_text.is_empty():
				reflection_line += " | Insight: " + summary_text
		else:
			reflection_line = ""
			if not timestamp.is_empty():
				reflection_line += "[" + timestamp + "] "
			reflection_line += reflection_text
			if not summary_text.is_empty():
				reflection_line += " | Reflection: " + summary_text
		lines.append("- " + reflection_line)
	return "\n".join(lines)
func _collect_assets_context(context: Dictionary) -> String:
	if not asset_registry:
		return ""
	var assets_for_prompt: Array = asset_registry.get_assets_for_context(context)
	if assets_for_prompt.size() == 0:
		return ""
	if game_state:
		var asset_ids: Array = []
		for asset in assets_for_prompt:
			asset_ids.append(asset.get("id", ""))
		game_state.set_metadata("recent_assets_data", assets_for_prompt)
		game_state.set_metadata("recent_asset_icons", asset_registry.get_asset_icons(assets_for_prompt))
		game_state.set_metadata("current_asset_ids", asset_ids)
	var parts: Array[String] = []
	parts.append(asset_registry.format_assets_for_prompt(assets_for_prompt))
	parts.append(AIPromptsI18n.get_text(AIPromptsI18n.ASSET_CONTEXT_INSTRUCTIONS, "freshest_context", _get_language()))
	return "\n".join(parts)
func _build_user_message(prompt: String, context: Dictionary, language: String) -> String:
	var content_parts: Array[String] = []
	content_parts.append(AIPromptsI18n.get_section_header("session_data", language))
	content_parts.append(AIPromptsI18n.get_language_instruction(language))
	var meta_lines := _build_metadata_lines(context)
	if meta_lines.size() > 0:
		content_parts.append("\n".join(meta_lines))
	_append_recent_events(content_parts, language)
	_append_butterfly_effect_context(content_parts, language)
	_append_player_reflections(content_parts, language)
	_append_assets_context(content_parts, context)
	_append_stat_snapshot(content_parts, context)
	content_parts.append("\n" + AIPromptsI18n.get_section_header("prompt", language))
	content_parts.append(prompt.strip_edges())
	return "\n".join(content_parts)
func _build_metadata_lines(context: Dictionary) -> Array[String]:
	var meta_lines: Array[String] = []
	if context.has("purpose"):
		var safe_purpose := _sanitize_user_text(str(context["purpose"]))
		if not safe_purpose.is_empty():
			meta_lines.append("Purpose: %s" % safe_purpose)
	if context.has("choice_text"):
		var safe_choice := _sanitize_user_text(str(context["choice_text"]))
		if not safe_choice.is_empty():
			meta_lines.append("Player choice: %s" % safe_choice)
	if context.has("success"):
		meta_lines.append("Success check: %s" % ("true" if bool(context["success"]) else "false"))
	if context.has("prayer_text"):
		var safe_prayer := _sanitize_user_text(str(context["prayer_text"]), MAX_PRAYER_LENGTH)
		if not safe_prayer.is_empty():
			meta_lines.append("Player prayer: %s" % safe_prayer)
	if context.has("player_action"):
		var safe_action := _sanitize_user_text(str(context["player_action"]))
		if not safe_action.is_empty():
			meta_lines.append("Player action: %s" % safe_action)
	if context.has("teammate"):
		var safe_teammate := _sanitize_user_text(str(context["teammate"]))
		if not safe_teammate.is_empty():
			meta_lines.append("Current teammate: %s" % safe_teammate)
	return meta_lines
func _append_recent_events(content_parts: Array[String], language: String) -> void:
	if not game_state:
		return
	var recent_event_lines: Array = game_state.get_recent_event_notes(6, language)
	if recent_event_lines.size() > 0:
		content_parts.append("\n" + AIPromptsI18n.get_section_header("recent_events", language))
		for line in recent_event_lines:
			content_parts.append("- " + line)
func _append_butterfly_effect_context(content_parts: Array[String], language: String) -> void:
	if not game_state or not game_state.butterfly_tracker:
		return
	var butterfly_context: String = game_state.butterfly_tracker.get_context_for_ai(language)
	if butterfly_context.is_empty():
		return
	content_parts.append("\n" + AIPromptsI18n.get_section_header("butterfly_effect", language))
	content_parts.append(butterfly_context)
	content_parts.append(AIPromptsI18n.get_butterfly_effect_instruction("reference_past", language))
	content_parts.append(AIPromptsI18n.get_butterfly_effect_instruction("trigger_callback", language))
	var suggested_choice: Dictionary = game_state.butterfly_tracker.suggest_choice_for_callback()
	if not suggested_choice.is_empty():
		var choice_id: String = suggested_choice.get("id", "")
		var choice_text: String = suggested_choice.get("choice_text", "")
		var scenes_ago: int = game_state.butterfly_tracker.current_scene_number - suggested_choice.get("scene_number", 0)
		var callback_text := AIPromptsI18n.get_butterfly_effect_instruction("suggested_callback", language)
		content_parts.append(callback_text % [choice_text.left(MAX_CHOICE_TEXT_PREVIEW), scenes_ago, choice_id])
func _append_player_reflections(content_parts: Array[String], language: String) -> void:
	if not game_state:
		return
	var reflections: Array = game_state.get_recent_journal_entries(MAX_JOURNAL_ENTRIES)
	if reflections.size() == 0:
		return
	content_parts.append("\n" + AIPromptsI18n.get_section_header("player_reflections", language))
	for entry in reflections:
		var timestamp := str(entry.get("timestamp", ""))
		var reflection_text := str(entry.get("text", "")).strip_edges()
		var summary_text := str(entry.get("ai_summary", "")).strip_edges()
		var reflection_line: String
		if language == "en":
			reflection_line = ""
			if not timestamp.is_empty():
				reflection_line += "[" + timestamp + "] "
			reflection_line += reflection_text
			if not summary_text.is_empty():
				reflection_line += " | Insight: " + summary_text
		else:
			reflection_line = ""
			if not timestamp.is_empty():
				reflection_line += "[" + timestamp + "] "
			reflection_line += reflection_text
			if not summary_text.is_empty():
				reflection_line += " | Reflection: " + summary_text
		content_parts.append("- " + reflection_line)
func _append_assets_context(content_parts: Array[String], context: Dictionary) -> void:
	if not asset_registry:
		return
	var assets_for_prompt: Array = asset_registry.get_assets_for_context(context)
	if assets_for_prompt.size() == 0:
		return
	if game_state:
		var asset_ids: Array = []
		for asset in assets_for_prompt:
			asset_ids.append(asset.get("id", ""))
		game_state.set_metadata("recent_assets_data", assets_for_prompt)
		game_state.set_metadata("recent_asset_icons", asset_registry.get_asset_icons(assets_for_prompt))
		game_state.set_metadata("current_asset_ids", asset_ids)
	content_parts.append("\n" + AIPromptsI18n.get_section_header("available_assets", _get_language()))
	content_parts.append(asset_registry.format_assets_for_prompt(assets_for_prompt))
	content_parts.append(AIPromptsI18n.get_text(AIPromptsI18n.ASSET_CONTEXT_INSTRUCTIONS, "freshest_context", _get_language()))
func _append_stat_snapshot(content_parts: Array[String], context: Dictionary) -> void:
	var stat_parts: Array[String] = []
	if context.has("reality_score"):
		stat_parts.append("Reality %d/%d" % [int(context["reality_score"]), REALITY_SCORE_MAX])
	if context.has("positive_energy"):
		stat_parts.append("Positive %d/%d" % [int(context["positive_energy"]), POSITIVE_ENERGY_MAX])
	if context.has("entropy_level"):
		stat_parts.append("Entropy %d" % int(context["entropy_level"]))
	elif context.has("entropy"):
		stat_parts.append("Entropy %d" % int(context["entropy"]))
	if stat_parts.size() > 0:
		content_parts.append("Stats: " + ", ".join(stat_parts))
func _get_language() -> String:
	return game_state.current_language if game_state else "en"
func _get_static_context_messages(language: String) -> Array[Dictionary]:
	if ai_manager and ai_manager.has_method("_get_static_context_messages"):
		return ai_manager._get_static_context_messages(language)
	return []
func _get_entropy_modifier_message(language: String) -> Array[Dictionary]:
	if ai_manager and ai_manager.has_method("_get_entropy_modifier_message"):
		return ai_manager._get_entropy_modifier_message(language)
	return []
func _get_long_term_context(language: String) -> Array[Dictionary]:
	if memory_store and memory_store.has_method("get_long_term_context"):
		return _coerce_message_array(memory_store.get_long_term_context(language))
	return []
func _get_notes_context(language: String) -> Array[Dictionary]:
	if memory_store and memory_store.has_method("get_notes_context"):
		return _coerce_message_array(memory_store.get_notes_context(language))
	return []
func _get_short_term_memory() -> Array[Dictionary]:
	if memory_store and memory_store.has_method("get_short_term_memory"):
		return _coerce_message_array(memory_store.get_short_term_memory())
	return []
func _build_voice_inline_part() -> Dictionary:
	if ai_manager and ai_manager.has_method("_build_voice_inline_part"):
		return ai_manager._build_voice_inline_part()
	return { }
func _sanitize_user_text(text: String, max_length: int = 256) -> String:
	if ai_manager and ai_manager.has_method("sanitize_user_text"):
		return ai_manager.sanitize_user_text(text, max_length)
	return text.strip_edges()
func _coerce_message_array(raw_messages) -> Array[Dictionary]:
	var safe_messages: Array[Dictionary] = []
	if raw_messages is Array:
		for entry in raw_messages:
			if entry is Dictionary:
				safe_messages.append((entry as Dictionary).duplicate(true))
			elif entry != null:
				safe_messages.append({ "role": "system", "content": str(entry) })
	return safe_messages
