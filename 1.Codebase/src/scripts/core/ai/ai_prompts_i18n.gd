extends RefCounted
static func _tr(key: String, lang: String = "") -> String:
	var tree := Engine.get_main_loop() as SceneTree
	var localization_manager: Node = null
	if tree and tree.root:
		localization_manager = tree.root.get_node_or_null("LocalizationManager")
	if localization_manager and localization_manager.has_method("get_translation"):
		if lang.is_empty():
			return localization_manager.call("get_translation", key)
		return localization_manager.call("get_translation", key, lang)
	return key
const LANGUAGE_INSTRUCTIONS := {
	"en": "IMPORTANT: Respond in English. All narrative, dialogue, and descriptions must be in English.",
	"zh": "AI_I18N_LANG_INSTRUCTION",
	"de": "AI_I18N_LANG_INSTRUCTION_DE",
}
const SECTION_HEADERS := {
	"session_data": {
		"en": "=== SESSION DATA ===",
		"zh": "AI_I18N_SECTION_SESSION_DATA",
		"de": "AI_I18N_SECTION_SESSION_DATA_DE",
	},
	"recent_events": {
		"en": "=== RECENT EVENTS ===",
		"zh": "AI_I18N_SECTION_RECENT_EVENTS",
		"de": "AI_I18N_SECTION_RECENT_EVENTS_DE",
	},
	"butterfly_effect": {
		"en": "=== BUTTERFLY EFFECT: PAST CHOICES ===",
		"zh": "AI_I18N_SECTION_BUTTERFLY_EFFECT",
		"de": "AI_I18N_SECTION_BUTTERFLY_EFFECT_DE",
	},
	"player_reflections": {
		"en": "=== PLAYER REFLECTIONS ===",
		"zh": "AI_I18N_SECTION_PLAYER_REFLECTIONS",
		"de": "AI_I18N_SECTION_PLAYER_REFLECTIONS_DE",
	},
	"available_assets": {
		"en": "=== AVAILABLE ASSETS ===",
		"zh": "AI_I18N_SECTION_AVAILABLE_ASSETS",
		"de": "AI_I18N_SECTION_AVAILABLE_ASSETS_DE",
	},
	"prompt": {
		"en": "=== PROMPT ===",
		"zh": "AI_I18N_SECTION_PROMPT",
		"de": "AI_I18N_SECTION_PROMPT_DE",
	},
	"mission_generation": {
		"en": "=== Mission Generation ===",
		"zh": "AI_I18N_SECTION_MISSION_GENERATION",
		"de": "AI_I18N_SECTION_MISSION_GENERATION_DE",
	},
	"consequence_generation": {
		"en": "=== Consequence Generation ===",
		"zh": "AI_I18N_SECTION_CONSEQUENCE_GENERATION",
		"de": "AI_I18N_SECTION_CONSEQUENCE_GENERATION_DE",
	},
	"teammate_interference": {
		"en": "=== Teammate Interference ===",
		"zh": "AI_I18N_SECTION_TEAMMATE_INTERFERENCE",
		"de": "AI_I18N_SECTION_TEAMMATE_INTERFERENCE_DE",
	},
}
const BUTTERFLY_EFFECT_INSTRUCTIONS := {
	"reference_past": {
		"en": "Consider referencing one of these past choices in your response if narratively appropriate.",
		"zh": "AI_I18N_BUTTERFLY_REFERENCE_PAST",
		"de": "AI_I18N_BUTTERFLY_REFERENCE_PAST_DE",
	},
	"trigger_callback": {
		"en": "Use butterfly_tracker.trigger_consequence_for_choice() when a past choice should echo forward.",
		"zh": "AI_I18N_BUTTERFLY_TRIGGER_CALLBACK",
		"de": "AI_I18N_BUTTERFLY_TRIGGER_CALLBACK_DE",
	},
	"suggested_callback": {
		"en": "\n SUGGESTED CALLBACK: Consider having \"%s\" (from %d scenes ago, ID: %s) affect the current situation.",
		"zh": "AI_I18N_BUTTERFLY_SUGGESTED_CALLBACK",
		"de": "AI_I18N_BUTTERFLY_SUGGESTED_CALLBACK_DE",
	},
}
const ASSET_CONTEXT_INSTRUCTIONS := {
	"freshest_context": {
		"en": "Newest asset IDs appear last; treat them as the freshest context.",
		"zh": "AI_I18N_ASSET_FRESHEST_CONTEXT",
		"de": "AI_I18N_ASSET_FRESHEST_CONTEXT_DE",
	},
}
const METADATA_LABELS := {
	"purpose": {
		"en": "Purpose: %s",
		"zh": "AI_I18N_META_PURPOSE",
		"de": "AI_I18N_META_PURPOSE_DE",
	},
	"player_choice": {
		"en": "Player choice: %s",
		"zh": "AI_I18N_META_PLAYER_CHOICE",
		"de": "AI_I18N_META_PLAYER_CHOICE_DE",
	},
	"success_check": {
		"en": "Success check: %s",
		"zh": "AI_I18N_META_SUCCESS_CHECK",
		"de": "AI_I18N_META_SUCCESS_CHECK_DE",
	},
	"player_prayer": {
		"en": "Player prayer: %s",
		"zh": "AI_I18N_META_PLAYER_PRAYER",
		"de": "AI_I18N_META_PLAYER_PRAYER_DE",
	},
	"player_action": {
		"en": "Player action: %s",
		"zh": "AI_I18N_META_PLAYER_ACTION",
		"de": "AI_I18N_META_PLAYER_ACTION_DE",
	},
	"current_teammate": {
		"en": "Current teammate: %s",
		"zh": "AI_I18N_META_CURRENT_TEAMMATE",
		"de": "AI_I18N_META_CURRENT_TEAMMATE_DE",
	},
}
const STATS_FORMAT := {
	"reality": {
		"en": "Reality %d/%d",
		"zh": "AI_I18N_STATS_REALITY",
		"de": "AI_I18N_STATS_REALITY_DE",
	},
	"positive": {
		"en": "Positive %d/%d",
		"zh": "AI_I18N_STATS_POSITIVE",
		"de": "AI_I18N_STATS_POSITIVE_DE",
	},
	"entropy": {
		"en": "Entropy %d",
		"zh": "AI_I18N_STATS_ENTROPY",
		"de": "AI_I18N_STATS_ENTROPY_DE",
	},
	"stats_label": {
		"en": "Stats: %s",
		"zh": "AI_I18N_STATS_LABEL",
		"de": "AI_I18N_STATS_LABEL_DE",
	},
}
static func get_text(category: Dictionary, key: String, language: String = "en") -> String:
	if category.has(key) and category[key] is Dictionary:
		var text_dict: Dictionary = category[key]
		if language == "en":
			var direct: String = text_dict.get(language, "")
			if direct.is_empty():
				return text_dict.get("en", "")
			return direct
		var tr_key: String = text_dict.get(language, "")
		if tr_key.is_empty():
			return text_dict.get("en", "")
		return _tr(tr_key, language)
	return ""
static func get_language_instruction(language: String = "en") -> String:
	if language == "en":
		return LANGUAGE_INSTRUCTIONS.get(language, LANGUAGE_INSTRUCTIONS["en"])
	var tr_key: String = LANGUAGE_INSTRUCTIONS.get(language, "")
	if tr_key.is_empty():
		return LANGUAGE_INSTRUCTIONS["en"]
	return _tr(tr_key, language)
static func get_section_header(section: String, language: String = "en") -> String:
	return get_text(SECTION_HEADERS, section, language)
static func get_butterfly_effect_instruction(instruction: String, language: String = "en") -> String:
	return get_text(BUTTERFLY_EFFECT_INSTRUCTIONS, instruction, language)
