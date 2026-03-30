extends RefCounted
class_name AIContextManager
const ErrorReporterBridge = preload("res://1.Codebase/src/scripts/core/error_reporter_bridge.gd")
const ERROR_CONTEXT := "AIContextManager"
const AISafetyFilter = preload("res://1.Codebase/src/scripts/core/ai_safety_filter.gd")
func _report_info(message: String, details: Dictionary = {}) -> void:
	ErrorReporterBridge.report_info(ERROR_CONTEXT, message, details)
func _report_warning(message: String, details: Dictionary = {}) -> void:
	ErrorReporterBridge.report_warning(ERROR_CONTEXT, message, details)
func _report_error(message: String, details: Dictionary = {}) -> void:
	ErrorReporterBridge.report_error(ERROR_CONTEXT, message, -1, false, details)
var _prompt_builder: AIPromptBuilder = null
var memory_store: AIMemoryStore = null
var _config_manager: AIConfigManager = null
var _voice_manager: AIVoiceManager = null
const _BLOCKED_SEQUENCE_REPLACEMENTS := {
	"<|im_end|>": "",
	"<|im_start|>": "",
	"<|endoftext|>": "",
	"### Instruction": "",
	"### Response": "",
}
const _BLOCKED_REGEX_PATTERNS := [
	"(?i)<\\|?(system|assistant|user)\\|?>",
	"(?i)###\\s*(instruction|response)",
]
func _get_skill_manager() -> Node:
	if ServiceLocator and ServiceLocator.has_method("get_skill_manager"):
		var sl_skill_manager = ServiceLocator.get_skill_manager()
		if sl_skill_manager != null:
			return sl_skill_manager
	var tree := Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		var service_locator = tree.root.get_node_or_null("ServiceLocator")
		if service_locator and service_locator.has_method("get_skill_manager"):
			var locator_skill_manager = service_locator.call("get_skill_manager")
			if locator_skill_manager != null:
				return locator_skill_manager
		return tree.root.get_node_or_null("SkillManager")
	return null
func _tr(key: String) -> String:
	if LocalizationManager:
		return LocalizationManager.get_translation(key)
	return key
func set_config_manager(config_mgr: AIConfigManager) -> void:
	_config_manager = config_mgr
func set_voice_manager(voice_mgr) -> void:
	_voice_manager = voice_mgr
func initialize_context_system(service_locator) -> void:
	var AIPromptBuilderScript = preload("res://1.Codebase/src/scripts/core/ai/ai_prompt_builder.gd")
	var AIMemoryStoreScript = preload("res://1.Codebase/src/scripts/core/ai_memory_store.gd")
	var gs = service_locator.get_game_state() if service_locator else GameState
	var ar = service_locator.get_asset_registry() if service_locator else AssetRegistry
	memory_store = AIMemoryStoreScript.new()
	_prompt_builder = AIPromptBuilderScript.new()
	_prompt_builder.setup(gs, ar, memory_store, null)
	_report_info("Context system initialized (incremental delta enabled)")
func set_system_persona(persona: String) -> void:
	if _prompt_builder:
		_prompt_builder.set_system_persona(persona)
func build_request_messages(prompt: String, context: Dictionary) -> Array[Dictionary]:
	var messages: Array[Dictionary] = []
	if _prompt_builder:
		messages = _prompt_builder.build_prompt(prompt, context)
	else:
		push_error("[AIContextManager] CRITICAL: _prompt_builder is null — no prompt can be built. Check initialize_context_system() was called.")
		_report_error("CRITICAL: _prompt_builder is null, cannot build prompt", {"prompt_preview": prompt.left(100), "context_keys": str(context.keys())})
		return messages
	_inject_skill_context(messages, context)
	_attach_pending_voice_input(messages)
	_append_formatting_reminder(messages)
	_log_delta_stats(messages)
	return messages
func _log_delta_stats(messages: Array[Dictionary]) -> void:
	var delta := _get_active_delta()
	if not delta:
		return
	var total_chars := 0
	for msg in messages:
		total_chars += str(msg.get("content", "")).length()
	var est_tokens := delta.get_current_tokens()
	_report_info("Request: %d messages, ~%d chars, ~%d est tokens (budget: %d)" % [
		messages.size(), total_chars, est_tokens, delta.token_budget])
func _get_active_delta() -> AIContextDelta:
	if _prompt_builder and _prompt_builder._delta:
		return _prompt_builder._delta
	return null
func _inject_skill_context(messages: Array[Dictionary], context: Dictionary) -> void:
	var skill_mgr := _get_skill_manager()
	if not skill_mgr:
		push_error("[AIContextManager] SKILL INJECTION FAILED: SkillManager not found. Skills will NOT be injected into prompt.")
		_report_error("SkillManager not found during skill injection", {"context_purpose": str(context.get("purpose", ""))})
		return
	if not skill_mgr.is_initialized():
		push_error("[AIContextManager] SKILL INJECTION FAILED: SkillManager exists but is not initialized. Skills will NOT be injected.")
		_report_error("SkillManager not initialized during skill injection", {"context_purpose": str(context.get("purpose", ""))})
		return
	var injected_skills: Array[String] = []
	var purpose: String = str(context.get("purpose", ""))
	var is_choice_followup := purpose == "choice_followup"
	if not purpose.is_empty():
		var skill_name: String = skill_mgr.get_skill_for_purpose(purpose)
		if not skill_name.is_empty() and skill_name not in injected_skills:
			_inject_single_skill(messages, skill_name, injected_skills)
	if GameState and GameState.is_in_honeymoon():
		var honeymoon_skill: String = skill_mgr.get_skill_for_purpose("honeymoon")
		if honeymoon_skill.is_empty():
			honeymoon_skill = "honeymoon-phase"
		if honeymoon_skill not in injected_skills:
			_inject_single_skill(messages, honeymoon_skill, injected_skills)
	if GameState and not is_choice_followup:
		var entropy_threshold: String = GameState.get_entropy_threshold()
		if entropy_threshold == "high" or entropy_threshold == "medium":
			var entropy_skill: String = skill_mgr.get_skill_for_purpose("entropy_" + entropy_threshold)
			if entropy_skill.is_empty():
				entropy_skill = "entropy-effects"
			if entropy_skill not in injected_skills:
				_inject_single_skill(messages, entropy_skill, injected_skills)
	if purpose in ["interference", "gloria_intervention", "teammate_interference"]:
		if "character-profiles" not in injected_skills:
			_inject_single_skill(messages, "character-profiles", injected_skills)
	if is_choice_followup and "character-profiles" not in injected_skills:
		_inject_single_skill(messages, "character-profiles", injected_skills)
	var story_purposes := ["new_mission", "mission_generation", "consequence",
						   "intro_story", "night_cycle", "teammate_interference", "gloria_intervention", "prayer"]
	if purpose in story_purposes:
		if "scene-directives" not in injected_skills:
			_inject_single_skill(messages, "scene-directives", injected_skills)
		if "character-profiles" not in injected_skills:
			_inject_single_skill(messages, "character-profiles", injected_skills)
	if not injected_skills.is_empty():
		_report_info("Injected skills: %s for purpose: %s" % [injected_skills, purpose])
func _inject_single_skill(messages: Array[Dictionary], skill_name: String, injected_list: Array[String]) -> void:
	var skill_mgr := _get_skill_manager()
	if not skill_mgr:
		push_error("[AIContextManager] Cannot inject skill '%s': SkillManager is null" % skill_name)
		_report_error("SkillManager null when injecting skill", {"skill_name": skill_name})
		return
	var language := GameState.current_language if GameState else "en"
	var skill_content: String = skill_mgr.load_skill(skill_name, language)
	if skill_content.is_empty():
		push_error("[AIContextManager] SKILL LOAD FAILED: skill='%s', language='%s' — content is empty. The AI will NOT receive this skill." % [skill_name, language])
		_report_error("Skill content empty", {"skill_name": skill_name, "language": language})
		return
	var skill_message := {
		"role": "system",
		"content": "[SKILL: %s]\n%s" % [skill_name, skill_content]
	}
	var insert_index := 0
	for i in range(min(5, messages.size())):
		if messages[i].get("role", "") == "system":
			insert_index = i + 1
		else:
			break
	messages.insert(insert_index, skill_message)
	injected_list.append(skill_name)
func _get_available_skills_for_prompt() -> String:
	var skill_mgr := _get_skill_manager()
	if not skill_mgr or not skill_mgr.is_initialized():
		return ""
	return skill_mgr.get_available_skills_xml()
func _append_formatting_reminder(messages: Array[Dictionary]) -> void:
	if messages.is_empty():
		return
	var reminder_text := _tr("AI_CTX_MGR_SYSTEM_REMINDER")
	var last_msg = messages.back()
	if last_msg["role"] == "user":
		last_msg["content"] += reminder_text
		if last_msg.has("parts") and last_msg["parts"] is Array and not last_msg["parts"].is_empty():
			var first_part: Variant = last_msg["parts"][0]
			if first_part is Dictionary and first_part.has("text"):
				var updated_part: Dictionary = (first_part as Dictionary).duplicate(true)
				updated_part["text"] = str(updated_part.get("text", "")) + reminder_text
				last_msg["parts"][0] = updated_part
	else:
		messages.append({"role": "system", "content": reminder_text})
func _attach_pending_voice_input(messages: Array[Dictionary]) -> void:
	if messages.is_empty() or _voice_manager == null or _config_manager == null:
		return
	if _config_manager.current_provider != AIConfigManager.AIProvider.GEMINI:
		return
	var voice_session: Variant = _voice_manager.voice_session if _voice_manager else null
	if voice_session != null and voice_session.has_method("wants_voice_input"):
		if not bool(voice_session.wants_voice_input()):
			return
	if not _voice_manager.has_pending_voice_input():
		return
	var voice_part := _voice_manager.build_voice_inline_part()
	if voice_part.is_empty():
		return
	for index in range(messages.size() - 1, -1, -1):
		var msg: Variant = messages[index]
		if not (msg is Dictionary):
			continue
		var msg_dict := msg as Dictionary
		if str(msg_dict.get("role", "")) != "user":
			continue
		if msg_dict.has("parts") and msg_dict["parts"] is Array:
			var parts: Array = msg_dict["parts"]
			parts.append(voice_part)
			msg_dict["parts"] = parts
		else:
			msg_dict["parts"] = [{ "text": str(msg_dict.get("content", "")) }, voice_part]
		msg_dict["voice_inline_attached"] = true
		messages[index] = msg_dict
		break
func build_voice_inline_part() -> Dictionary:
	if _voice_manager:
		return _voice_manager.build_voice_inline_part()
	return { }
static func sanitize_user_text(raw_text: String, max_length: int = 256) -> String:
	if typeof(raw_text) == TYPE_NIL:
		return ""
	var sanitized := String(raw_text).strip_edges()
	if sanitized.is_empty():
		return ""
	sanitized = sanitized.replace("\r", " ")
	sanitized = sanitized.replace("\n", " ")
	sanitized = sanitized.replace("\t", " ")
	for sequence in _BLOCKED_SEQUENCE_REPLACEMENTS.keys():
		sanitized = sanitized.replace(sequence, _BLOCKED_SEQUENCE_REPLACEMENTS[sequence])
	for pattern in _BLOCKED_REGEX_PATTERNS:
		var regex := RegEx.new()
		if regex.compile(pattern) == OK:
			sanitized = regex.sub(sanitized, "", true)
	sanitized = sanitized.replace("\t", " ").replace("\n", " ").replace("\r", " ")
	while sanitized.find("  ") != -1:
		sanitized = sanitized.replace("  ", " ")
	sanitized = sanitized.strip_edges()
	if max_length > 0 and sanitized.length() > max_length:
		sanitized = sanitized.substr(0, max_length)
	var scrub_report: Dictionary = AISafetyFilter.scrub_user_text(sanitized)
	sanitized = scrub_report.get("text", sanitized)
	return sanitized
func add_to_memory(role: String, content: String, extra_data: Dictionary = {}) -> void:
	if memory_store:
		memory_store.add_entry(role, content, extra_data)
func register_note_pair(text_en: String, text_zh: String = "", tags: Array = [], importance: int = 1, source: String = "") -> void:
	if memory_store:
		memory_store.register_note_pair(text_en, text_zh, tags, importance, source)
func clear_notes() -> void:
	if memory_store:
		memory_store.clear_notes()
func summarize_memory() -> String:
	if memory_store:
		return memory_store.summarize_memory()
	return ""
func clear_memory() -> void:
	if memory_store:
		memory_store.clear_all()
	reset_delta()
func reset_delta() -> void:
	if _prompt_builder and _prompt_builder._delta:
		_prompt_builder._delta.reset()
func set_context_token_budget(budget: int) -> void:
	if _prompt_builder and _prompt_builder._delta:
		_prompt_builder._delta.token_budget = budget
func get_context_token_estimate() -> int:
	var delta := _get_active_delta()
	if delta:
		return delta.get_current_tokens()
	return 0
func apply_memory_settings() -> void:
	if memory_store:
		memory_store.apply_settings()
func get_long_term_summary_count() -> int:
	if memory_store:
		return memory_store.long_term_summaries.size()
	return 0
func get_note_count() -> int:
	if memory_store:
		return memory_store.get_note_count()
	return 0
func get_memory_state() -> Dictionary:
	if memory_store:
		return memory_store.get_state()
	return { }
func load_memory_state(state: Dictionary) -> void:
	if memory_store:
		memory_store.set_state(state)
func is_initialized() -> bool:
	return _prompt_builder != null and memory_store != null
