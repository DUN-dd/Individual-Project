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
		"de": "Erwäge, eine dieser vergangenen Entscheidungen in deiner Antwort zu referenzieren, wenn es narrativ passend ist.",
	},
	"trigger_callback": {
		"en": "Use butterfly_tracker.trigger_consequence_for_choice() when a past choice should echo forward.",
		"zh": "AI_I18N_BUTTERFLY_TRIGGER_CALLBACK",
		"de": "Verwende butterfly_tracker.trigger_consequence_for_choice(), wenn eine vergangene Entscheidung nachhallen soll.",
	},
	"suggested_callback": {
		"en": "\n SUGGESTED CALLBACK: Consider having \"%s\" (from %d scenes ago, ID: %s) affect the current situation.",
		"zh": "AI_I18N_BUTTERFLY_SUGGESTED_CALLBACK",
		"de": "\n VORGESCHLAGENER RÜCKRUF: Erwäge, \"%s\" (von vor %d Szenen, ID: %s) die aktuelle Situation beeinflussen zu lassen.",
	},
}
const ASSET_CONTEXT_INSTRUCTIONS := {
	"freshest_context": {
		"en": "Newest asset IDs appear last; treat them as the freshest context.",
		"zh": "AI_I18N_ASSET_FRESHEST_CONTEXT",
		"de": "Neueste Asset-IDs erscheinen zuletzt; behandle sie als den aktuellsten Kontext.",
	},
}
const METADATA_LABELS := {
	"purpose": {
		"en": "Purpose: %s",
		"zh": "AI_I18N_META_PURPOSE",
		"de": "Zweck: %s",
	},
	"player_choice": {
		"en": "Player choice: %s",
		"zh": "AI_I18N_META_PLAYER_CHOICE",
		"de": "Spielerwahl: %s",
	},
	"success_check": {
		"en": "Success check: %s",
		"zh": "AI_I18N_META_SUCCESS_CHECK",
		"de": "Erfolgsprüfung: %s",
	},
	"player_prayer": {
		"en": "Player prayer: %s",
		"zh": "AI_I18N_META_PLAYER_PRAYER",
		"de": "Spielergebet: %s",
	},
	"player_action": {
		"en": "Player action: %s",
		"zh": "AI_I18N_META_PLAYER_ACTION",
		"de": "Spieleraktion: %s",
	},
	"current_teammate": {
		"en": "Current teammate: %s",
		"zh": "AI_I18N_META_CURRENT_TEAMMATE",
		"de": "Aktueller Teamkollege: %s",
	},
}
const STATS_FORMAT := {
	"reality": {
		"en": "Reality %d/%d",
		"zh": "AI_I18N_STATS_REALITY",
		"de": "Realität %d/%d",
	},
	"positive": {
		"en": "Positive %d/%d",
		"zh": "AI_I18N_STATS_POSITIVE",
		"de": "Positiv %d/%d",
	},
	"entropy": {
		"en": "Entropy %d",
		"zh": "AI_I18N_STATS_ENTROPY",
		"de": "Entropie %d",
	},
	"stats_label": {
		"en": "Stats: %s",
		"zh": "AI_I18N_STATS_LABEL",
		"de": "Statistiken: %s",
	},
}
static func get_text(category: Dictionary, key: String, language: String = "en") -> String:
	if category.has(key) and category[key] is Dictionary:
		var text_dict: Dictionary = category[key]
		if language == "en" or language == "de":
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
	if language == "en" or language == "de":
		return LANGUAGE_INSTRUCTIONS.get(language, LANGUAGE_INSTRUCTIONS["en"])
	var tr_key: String = LANGUAGE_INSTRUCTIONS.get(language, "")
	if tr_key.is_empty():
		return LANGUAGE_INSTRUCTIONS["en"]
	return _tr(tr_key, language)
static func get_section_header(section: String, language: String = "en") -> String:
	return get_text(SECTION_HEADERS, section, language)
static func get_butterfly_effect_instruction(instruction: String, language: String = "en") -> String:
	return get_text(BUTTERFLY_EFFECT_INSTRUCTIONS, instruction, language)
