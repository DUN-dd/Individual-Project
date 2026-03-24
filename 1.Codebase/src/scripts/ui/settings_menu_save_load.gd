extends RefCounted
class_name SettingsMenuSaveLoad

## Handles serialisation and deserialisation of all settings-menu state.
## All methods are static; call them directly without instantiation.

## Saves every settings value to GameSave and propagates the relevant subset
## to GameState.settings so the rest of the game sees the changes immediately.
##
## Parameters:
##   data       – flat Dictionary containing every settings key/value to persist
##   game_state – GameState node (may be null)
static func save(data: Dictionary, game_state: Node) -> void:
	GameSave.save_settings(data)
	if game_state:
		game_state.settings.text_speed = float(data.get("text_speed", 1.0))
		game_state.settings.screen_shake_enabled = bool(data.get("screen_shake", true))
		game_state.settings.high_contrast_mode = bool(data.get("high_contrast", false))
		game_state.settings["max_rounds_per_mission"] = int(data.get("max_rounds_per_mission", 0))

## Loads settings from GameSave, merging with `defaults` for any missing key.
## Returns the raw data Dictionary (may be empty if no save file exists).
## When data is found, applies audio immediately via `apply_audio_fn` and
## propagates text/shake/contrast/rounds to game_state.settings.
##
## IMPORTANT: the caller must assign data["resolution"] to selected_resolution
## and then call _normalize_selected_resolution AFTER this returns, because
## normalisation reads the just-assigned value.
##
## Parameters:
##   defaults       – Dictionary of fallback values (pre-populated by caller)
##   game_state     – GameState node (may be null)
##   apply_audio_fn – Callable() that re-applies audio settings after loading
static func load(
	defaults: Dictionary,
	game_state: Node,
	apply_audio_fn: Callable,
) -> Dictionary:
	var data := GameSave.load_settings(defaults)
	if not data.is_empty():
		apply_audio_fn.call()
		if game_state:
			game_state.settings.text_speed = float(data.get("text_speed", 1.0))
			game_state.settings.screen_shake_enabled = bool(data.get("screen_shake", true))
			game_state.settings.high_contrast_mode = bool(data.get("high_contrast", false))
			game_state.settings["max_rounds_per_mission"] = int(data.get("max_rounds_per_mission", 0))
	return data

## Returns the default font name for the given language code.
static func get_default_font(language: String) -> String:
	if language == "zh":
		return FontManager.DEFAULT_ZH_FONT if FontManager else "Noto Sans SC"
	return FontManager.DEFAULT_EN_FONT if FontManager else "Trajan Pro"
