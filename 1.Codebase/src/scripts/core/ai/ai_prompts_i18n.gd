extends RefCounted
static func _tr(key: String, lang: String = "") -> String:
	if LocalizationManager:
		if lang.is_empty():
			return LocalizationManager.get_translation(key)
		return LocalizationManager.get_translation(key, lang)
	return key
const LANGUAGE_INSTRUCTIONS := {
	"en": "IMPORTANT: Respond in English. All narrative, dialogue, and descriptions must be in English.",
	"zh": "AI_I18N_LANG_INSTRUCTION",
}
const SECTION_HEADERS := {
	"session_data": {
		"en": "=== SESSION DATA ===",
		"zh": "AI_I18N_SECTION_SESSION_DATA",
	},
	"recent_events": {
		"en": "=== RECENT EVENTS ===",
		"zh": "AI_I18N_SECTION_RECENT_EVENTS",
	},
	"butterfly_effect": {
		"en": "=== BUTTERFLY EFFECT: PAST CHOICES ===",
		"zh": "AI_I18N_SECTION_BUTTERFLY_EFFECT",
	},
	"player_reflections": {
		"en": "=== PLAYER REFLECTIONS ===",
		"zh": "AI_I18N_SECTION_PLAYER_REFLECTIONS",
	},
	"available_assets": {
		"en": "=== AVAILABLE ASSETS ===",
		"zh": "AI_I18N_SECTION_AVAILABLE_ASSETS",
	},
	"prompt": {
		"en": "=== PROMPT ===",
		"zh": "AI_I18N_SECTION_PROMPT",
	},
	"mission_generation": {
		"en": "=== Mission Generation ===",
		"zh": "AI_I18N_SECTION_MISSION_GENERATION",
	},
	"consequence_generation": {
		"en": "=== Consequence Generation ===",
		"zh": "AI_I18N_SECTION_CONSEQUENCE_GENERATION",
	},
	"teammate_interference": {
		"en": "=== Teammate Interference ===",
		"zh": "AI_I18N_SECTION_TEAMMATE_INTERFERENCE",
	},
}
const BUTTERFLY_EFFECT_INSTRUCTIONS := {
	"reference_past": {
		"en": "Consider referencing one of these past choices in your response if narratively appropriate.",
		"zh": "AI_I18N_BUTTERFLY_REFERENCE_PAST",
	},
	"trigger_callback": {
		"en": "Use butterfly_tracker.trigger_consequence_for_choice() when a past choice should echo forward.",
		"zh": "AI_I18N_BUTTERFLY_TRIGGER_CALLBACK",
	},
	"suggested_callback": {
		"en": "\n SUGGESTED CALLBACK: Consider having \"%s\" (from %d scenes ago, ID: %s) affect the current situation.",
		"zh": "AI_I18N_BUTTERFLY_SUGGESTED_CALLBACK",
	},
}
const ASSET_CONTEXT_INSTRUCTIONS := {
	"freshest_context": {
		"en": "Newest asset IDs appear last; treat them as the freshest context.",
		"zh": "AI_I18N_ASSET_FRESHEST_CONTEXT",
	},
}
const MISSION_PROMPT_INSTRUCTIONS := {
	"create_scenario": {
		"en": "Create a new mission scenario for the player.",
		"zh": "AI_I18N_MISSION_CREATE_SCENARIO",
	},
	"generate_list": {
		"en": "Please generate:",
		"zh": "AI_I18N_MISSION_GENERATE_LIST",
	},
	"scene_description": {
		"en": "1. Scene description (200-300 words)",
		"zh": "AI_I18N_MISSION_SCENE_DESCRIPTION",
	},
	"mission_objective": {
		"en": "2. Mission objective",
		"zh": "AI_I18N_MISSION_MISSION_OBJECTIVE",
	},
	"challenges": {
		"en": "3. Potential dilemmas or challenges",
		"zh": "AI_I18N_MISSION_CHALLENGES",
	},
	"tone": {
		"en": "Maintain dark humor and satirical tone.",
		"zh": "AI_I18N_MISSION_TONE",
	},
}
const CONSEQUENCE_PROMPT_INSTRUCTIONS := {
	"player_chose": {
		"en": "Player chose: %s",
		"zh": "AI_I18N_CONSEQUENCE_PLAYER_CHOSE",
	},
	"outcome_success": {
		"en": "Outcome: Success",
		"zh": "AI_I18N_CONSEQUENCE_OUTCOME_SUCCESS",
	},
	"outcome_failure": {
		"en": "Outcome: Failure",
		"zh": "AI_I18N_CONSEQUENCE_OUTCOME_FAILURE",
	},
	"describe_consequences": {
		"en": "Describe the immediate consequences (%d-%d words).",
		"zh": "AI_I18N_CONSEQUENCE_DESCRIBE",
	},
	"include_header": {
		"en": "Include:",
		"zh": "AI_I18N_CONSEQUENCE_INCLUDE_HEADER",
	},
	"immediate_events": {
		"en": "1. What happens immediately",
		"zh": "AI_I18N_CONSEQUENCE_IMMEDIATE_EVENTS",
	},
	"npc_reactions": {
		"en": "2. NPC/environment reactions",
		"zh": "AI_I18N_CONSEQUENCE_NPC_REACTIONS",
	},
	"long_term_hints": {
		"en": "3. Hints of long-term effects",
		"zh": "AI_I18N_CONSEQUENCE_LONG_TERM_HINTS",
	},
}
const TEAMMATE_INTERFERENCE_INSTRUCTIONS := {
	"teammate_interferes": {
		"en": "Teammate %s decides to interfere with player's action.",
		"zh": "AI_I18N_TEAMMATE_INTERFERES",
	},
	"player_action": {
		"en": "Player is: %s",
		"zh": "AI_I18N_TEAMMATE_PLAYER_ACTION",
	},
	"describe_help": {
		"en": "Describe how the teammate 'helps' in their own dysfunctional way (%d words).",
		"zh": "AI_I18N_TEAMMATE_DESCRIBE_HELP",
	},
	"stay_true": {
		"en": "Stay true to their personality and create unexpected complications.",
		"zh": "AI_I18N_TEAMMATE_STAY_TRUE",
	},
}
const SCENE_DIRECTIVE_INSTRUCTIONS := {
	"important_json": {
		"en": "\n\n**IMPORTANT: Your response will use structured JSON format!**",
		"zh": "AI_I18N_SCENE_IMPORTANT_JSON",
	},
	"format_description": {
		"en": "Your response will be automatically formatted as JSON with:",
		"zh": "AI_I18N_SCENE_FORMAT_DESCRIPTION",
	},
	"scene_fields": {
		"en": "- scene: {background, atmosphere, lighting}",
		"zh": "AI_I18N_SCENE_SCENE_FIELDS",
	},
	"characters_required": {
		"en": "- characters: Expressions for all 5 main characters (ALL REQUIRED)",
		"zh": "AI_I18N_SCENE_CHARACTERS_REQUIRED",
	},
	"character_list": {
		"en": "  MUST include: protagonist (main character), gloria (Gloria), donkey (Donkey), ark (Ark), one (One)",
		"zh": "AI_I18N_SCENE_CHARACTER_LIST",
	},
	"character_format": {
		"en": "  Each character: {expression: emotion}",
		"zh": "AI_I18N_SCENE_CHARACTER_FORMAT",
	},
	"story_text": {
		"en": "- story_text: Your story content",
		"zh": "AI_I18N_SCENE_STORY_TEXT",
	},
	"all_visible": {
		"en": "\n**IMPORTANT: All 5 characters are always visible. You MUST set an expression for each one.**",
		"zh": "AI_I18N_SCENE_ALL_VISIBLE",
	},
	"choose_expressions": {
		"en": "Choose appropriate expressions for each character based on the scene and story. Even if a character doesn't speak, give them a contextually appropriate expression.",
		"zh": "AI_I18N_SCENE_CHOOSE_EXPRESSIONS",
	},
	"available_backgrounds": {
		"en": "\nAvailable backgrounds: ruins, cave, dungeon, forest, temple, laboratory, library, throne_room, battlefield, crystal_cavern, bridge, garden, portal_area, safe_zone, water, fire_area",
		"zh": "AI_I18N_SCENE_AVAILABLE_BACKGROUNDS",
	},
	"available_expressions": {
		"en": "Available expressions: neutral, happy, sad, angry, confused, shocked, thinking, embarrassed",
		"zh": "AI_I18N_SCENE_AVAILABLE_EXPRESSIONS",
	},
}
const METADATA_LABELS := {
	"purpose": {
		"en": "Purpose: %s",
		"zh": "AI_I18N_META_PURPOSE",
	},
	"player_choice": {
		"en": "Player choice: %s",
		"zh": "AI_I18N_META_PLAYER_CHOICE",
	},
	"success_check": {
		"en": "Success check: %s",
		"zh": "AI_I18N_META_SUCCESS_CHECK",
	},
	"player_prayer": {
		"en": "Player prayer: %s",
		"zh": "AI_I18N_META_PLAYER_PRAYER",
	},
	"player_action": {
		"en": "Player action: %s",
		"zh": "AI_I18N_META_PLAYER_ACTION",
	},
	"current_teammate": {
		"en": "Current teammate: %s",
		"zh": "AI_I18N_META_CURRENT_TEAMMATE",
	},
}
const STATS_FORMAT := {
	"reality": {
		"en": "Reality %d/%d",
		"zh": "AI_I18N_STATS_REALITY",
	},
	"positive": {
		"en": "Positive %d/%d",
		"zh": "AI_I18N_STATS_POSITIVE",
	},
	"entropy": {
		"en": "Entropy %d",
		"zh": "AI_I18N_STATS_ENTROPY",
	},
	"stats_label": {
		"en": "Stats: %s",
		"zh": "AI_I18N_STATS_LABEL",
	},
}
static func get_text(category: Dictionary, key: String, language: String = "en") -> String:
	if category.has(key) and category[key] is Dictionary:
		var text_dict: Dictionary = category[key]
		if language == "en":
			return text_dict.get("en", "")
		var tr_key: String = text_dict.get(language, "")
		if tr_key.is_empty():
			return text_dict.get("en", "")
		return _tr(tr_key, language)
	return ""
static func get_language_instruction(language: String = "en") -> String:
	if language == "en":
		return LANGUAGE_INSTRUCTIONS["en"]
	var tr_key: String = LANGUAGE_INSTRUCTIONS.get(language, "")
	if tr_key.is_empty():
		return LANGUAGE_INSTRUCTIONS["en"]
	return _tr(tr_key, language)
static func get_section_header(section: String, language: String = "en") -> String:
	return get_text(SECTION_HEADERS, section, language)
static func get_butterfly_effect_instruction(instruction: String, language: String = "en") -> String:
	return get_text(BUTTERFLY_EFFECT_INSTRUCTIONS, instruction, language)
