extends RefCounted
class_name AIContextBuilder
const SHORT_TERM_WINDOW := 6
var memory_store
var game_state
var asset_registry
var background_loader
var ai_system_persona: String = "You are the story director for Glorious Deliverance Agency 1 (GDA1)."
var voice_bridge
func _init(mem_store, gs = null, ar = null, bl = null):
	memory_store = mem_store
	game_state = gs
	asset_registry = ar
	background_loader = bl
func set_voice_bridge(vb) -> void:
	voice_bridge = vb
func set_system_persona(persona: String) -> void:
	ai_system_persona = persona
func build_context_prompt(prompt: String, context: Dictionary) -> Array:
	var messages: Array = []
	var language = game_state.current_language if game_state else "en"
	messages.append_array(_get_static_context_messages(language))
	messages.append({ "role": "system", "content": ai_system_persona })
	messages.append({ "role": "assistant", "content": "Acknowledged. I will maintain ironic, pessimistic storytelling for GDA1 while enforcing the recorded facts." })
	messages.append_array(_get_entropy_modifier_message(language))
	if memory_store:
		messages.append_array(memory_store.get_long_term_context(language))
		messages.append_array(memory_store.get_notes_context(language))
		for entry in memory_store.get_short_term_memory():
			messages.append(entry.duplicate(true))
	var user_message_content = _build_user_message(prompt, context, language)
	var user_message := { "role": "user", "content": user_message_content }
	var parts_array: Array = [{ "text": user_message_content }]
	var voice_part := _build_voice_inline_part()
	if not voice_part.is_empty():
		parts_array.append(voice_part)
		user_message["voice_inline_attached"] = true
	user_message["parts"] = parts_array
	messages.append(user_message)
	return messages
func _build_user_message(prompt: String, context: Dictionary, language: String) -> String:
	var content := ""
	var language_instruction := ""
	language_instruction = _tr("AI_CTX_LANGUAGE_INSTRUCTION") + "\n"
	content += "=== SESSION DATA ===\n"
	content += language_instruction
	content += _build_meta_context(context)
	content += _build_recent_events(language)
	content += _build_butterfly_context(language)
	content += _build_player_reflections(language)
	content += _build_asset_context(context)
	content += _build_stats_context(context)
	content += "\n=== PROMPT ===\n"
	content += prompt.strip_edges()
	return content
func _get_static_context_messages(_language: String) -> Array:
	var static_text = _tr("AI_CTX_STATIC_CONTEXT")
	var rules_text = _tr("AI_CTX_NON_NEGOTIABLE_RULES")
	var directives_text = _tr("AI_CTX_SCENE_DIRECTIVES")
	var messages := [
		{ "role": "system", "content": static_text },
		{ "role": "system", "content": rules_text },
		{ "role": "system", "content": directives_text },
	]
	if background_loader and background_loader.has_method("get_backgrounds_for_ai_prompt"):
		var backgrounds_text = background_loader.get_backgrounds_for_ai_prompt()
		messages.append({ "role": "system", "content": backgrounds_text })
	return messages
func _get_entropy_modifier_message(_language: String) -> Array:
	if not game_state or not game_state.has_method("calculate_void_entropy"):
		return []
	var entropy: float = game_state.calculate_void_entropy()
	var threshold: String = game_state.get_entropy_threshold() if game_state.has_method("get_entropy_threshold") else "low"
	if threshold == "low":
		return []
	var modifier_text: String = ""
	if threshold == "high":
		modifier_text = _tr("AI_CTX_ENTROPY_HIGH") % entropy
	elif threshold == "medium":
		modifier_text = _tr("AI_CTX_ENTROPY_MEDIUM") % entropy
	if modifier_text.is_empty():
		return []
	return [{ "role": "system", "content": modifier_text }]
func _build_meta_context(context: Dictionary) -> String:
	var meta_lines: Array = []
	if context.has("purpose"):
		var safe_purpose := _sanitize_text(str(context["purpose"]))
		if not safe_purpose.is_empty():
			meta_lines.append("Purpose: %s" % safe_purpose)
	if context.has("choice_text"):
		var safe_choice := _sanitize_text(str(context["choice_text"]))
		if not safe_choice.is_empty():
			meta_lines.append("Player choice: %s" % safe_choice)
	if context.has("success"):
		meta_lines.append("Success check: %s" % ("true" if bool(context["success"]) else "false"))
	if context.has("prayer_text"):
		var safe_prayer := _sanitize_text(str(context["prayer_text"]), 320)
		if not safe_prayer.is_empty():
			meta_lines.append("Player prayer: %s" % safe_prayer)
	if context.has("player_action"):
		var safe_action := _sanitize_text(str(context["player_action"]))
		if not safe_action.is_empty():
			meta_lines.append("Player action: %s" % safe_action)
	if context.has("teammate"):
		var safe_teammate := _sanitize_text(str(context["teammate"]))
		if not safe_teammate.is_empty():
			meta_lines.append("Current teammate: %s" % safe_teammate)
	if meta_lines.size() > 0:
		return "\n".join(meta_lines) + "\n"
	return ""
func _build_recent_events(_language: String) -> String:
	if not game_state or not game_state.has_method("get_recent_event_notes"):
		return ""
	var recent_event_lines = game_state.get_recent_event_notes(SHORT_TERM_WINDOW, _language)
	if recent_event_lines.size() == 0:
		return ""
	var content := "\n=== RECENT EVENTS ===\n"
	for line in recent_event_lines:
		content += "- " + line + "\n"
	return content
func _build_butterfly_context(_language: String) -> String:
	if not game_state or not game_state.has_method("get") or game_state.get("butterfly_tracker") == null:
		return ""
	var butterfly_tracker = game_state.get("butterfly_tracker")
	if not butterfly_tracker or not butterfly_tracker.has_method("get_context_for_ai"):
		return ""
	var butterfly_context = butterfly_tracker.get_context_for_ai(_language)
	if butterfly_context.is_empty():
		return ""
	var content := "\n=== BUTTERFLY EFFECT: PAST CHOICES ===\n"
	content += butterfly_context
	content += _tr("AI_CTX_BUTTERFLY_CONSIDER") + "\n"
	if butterfly_tracker.has_method("suggest_choice_for_callback"):
		var suggested_choice = butterfly_tracker.suggest_choice_for_callback()
		if not suggested_choice.is_empty():
			var choice_id = suggested_choice.get("id", "")
			var choice_text = suggested_choice.get("choice_text", "")
			var scenes_ago = butterfly_tracker.current_scene_number - suggested_choice.get("scene_number", 0) if butterfly_tracker.has("current_scene_number") else 0
			content += "\n" + (_tr("AI_CTX_BUTTERFLY_CALLBACK") % [choice_text.left(60), scenes_ago, choice_id]) + "\n"
	return content
func _build_player_reflections(_language: String) -> String:
	if not game_state or not game_state.has_method("get_recent_journal_entries"):
		return ""
	var reflections: Array = game_state.get_recent_journal_entries(3)
	if reflections.size() == 0:
		return ""
	var content := "\n=== PLAYER REFLECTIONS ===\n"
	for entry in reflections:
		var timestamp = str(entry.get("timestamp", ""))
		var reflection_text = str(entry.get("text", "")).strip_edges()
		var summary_text = str(entry.get("ai_summary", "")).strip_edges()
		var line = ""
		if not timestamp.is_empty():
			line += "[" + timestamp + "] "
		line += reflection_text
		if not summary_text.is_empty():
			line += _tr("AI_CTX_INSIGHT_LABEL") + summary_text
		content += "- " + line + "\n"
	return content
func _build_asset_context(context: Dictionary) -> String:
	if not asset_registry or not asset_registry.has_method("get_assets_for_context"):
		return ""
	var assets_for_prompt: Array = asset_registry.get_assets_for_context(context)
	if assets_for_prompt.size() == 0:
		return ""
	if game_state and game_state.has_method("set_metadata"):
		var asset_ids: Array = []
		for asset in assets_for_prompt:
			asset_ids.append(asset.get("id", ""))
		game_state.set_metadata("recent_assets_data", assets_for_prompt)
		if asset_registry.has_method("get_asset_icons"):
			game_state.set_metadata("recent_asset_icons", asset_registry.get_asset_icons(assets_for_prompt))
		game_state.set_metadata("current_asset_ids", asset_ids)
	var content := "\n=== AVAILABLE ASSETS ===\n"
	if asset_registry.has_method("format_assets_for_prompt"):
		content += asset_registry.format_assets_for_prompt(assets_for_prompt) + "\n"
	content += _tr("AI_I18N_ASSET_FRESHEST_CONTEXT") + "\n"
	return content
func _build_stats_context(context: Dictionary) -> String:
	var stat_parts: Array = []
	if context.has("reality_score"):
		stat_parts.append("Reality %d / 100" % int(context["reality_score"]))
	if context.has("positive_energy"):
		stat_parts.append("Positive %d / 100" % int(context["positive_energy"]))
	if context.has("entropy_level"):
		stat_parts.append("Entropy %d" % int(context["entropy_level"]))
	elif context.has("entropy"):
		stat_parts.append("Entropy %d" % int(context["entropy"]))
	if stat_parts.size() > 0:
		return "Stats: " + ", ".join(stat_parts) + "\n"
	return ""
func _build_voice_inline_part() -> Dictionary:
	if not voice_bridge:
		return { }
	if voice_bridge.has_method("build_inline_part"):
		return voice_bridge.build_inline_part(GameConstants.AI.DEFAULT_INPUT_SAMPLE_RATE)
	if voice_bridge.has_method("build_inline_audio_part"):
		return voice_bridge.build_inline_audio_part()
	return { }
func _tr(key: String) -> String:
	if LocalizationManager:
		return LocalizationManager.get_translation(key)
	return key
func _sanitize_text(text: String, max_length: int = 256) -> String:
	var sanitized := text.strip_edges()
	if sanitized.length() > max_length and max_length > 0:
		sanitized = sanitized.substr(0, max_length)
	return sanitized
