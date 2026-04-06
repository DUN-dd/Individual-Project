extends Control
const UIConstants = preload("res://1.Codebase/src/scripts/ui/ui_constants.gd")
const UIStyleManager = preload("res://1.Codebase/src/scripts/ui/ui_style_manager.gd")
const TS2B_EASTER_EGG_URL := "https://music.apple.com/gb/album/%E5%A4%A9%E7%94%9F%E4%BA%8C%E5%93%81-live/1616116741?i=1616117256"
const TS2B_CLICK_TARGET := 5
const TS2B_CLICK_TIMEOUT := 5.0
var _ts2b_click_count: int = 0
var _ts2b_click_timer: float = 0.0
var _ts2b_label: Label = null
@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var stats_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/StatsContainer
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/ButtonContainer/CloseButton
@onready var refresh_button: Button = $Panel/MarginContainer/VBoxContainer/ButtonContainer/RefreshButton
var stat_categories := [
	{
		"id": "missions",
		"title_en": "Mission Statistics",
		"title_key": "GAME_STATS_CAT_MISSIONS",
		"stats": [
			{ "key": "missions_completed", "label_en": "Total Missions", "label_key": "GAME_STATS_TOTAL_MISSIONS", "format": "number" },
			{ "key": "current_mission", "label_en": "Current Mission", "label_key": "GAME_STATS_CURRENT_MISSION", "format": "number" },
		],
	},
	{
		"id": "time",
		"title_en": "Time Statistics",
		"title_key": "GAME_STATS_CAT_TIME",
		"stats": [
			{ "key": "total_playtime", "label_en": "Total Playtime", "label_key": "GAME_STATS_TOTAL_PLAYTIME", "format": "time" },
			{ "key": "session_start", "label_en": "Session Started", "label_key": "GAME_STATS_SESSION_STARTED", "format": "datetime" },
		],
	},
	{
		"id": "core_stats",
		"title_en": "Core Stats",
		"title_key": "GAME_STATS_CAT_CORE_STATS",
		"stats": [
			{ "key": "reality_score", "label_en": "Reality Score", "label_key": "GAME_STATS_REALITY_SCORE", "format": "stat" },
			{ "key": "positive_energy", "label_en": "Positive Energy", "label_key": "GAME_STATS_POSITIVE_ENERGY", "format": "stat" },
			{ "key": "entropy_level", "label_en": "Entropy Level", "label_key": "GAME_STATS_ENTROPY_LEVEL", "format": "stat" },
		],
	},
	{
		"id": "stat_changes",
		"title_en": "Stat Changes",
		"title_key": "GAME_STATS_CAT_STAT_CHANGES",
		"stats": [
			{ "key": "reality_changes", "label_en": "Reality Changes", "label_key": "GAME_STATS_REALITY_CHANGES", "format": "number" },
			{ "key": "entropy_peak", "label_en": "Peak Entropy", "label_key": "GAME_STATS_PEAK_ENTROPY", "format": "number" },
			{ "key": "lowest_reality", "label_en": "Lowest Reality", "label_key": "GAME_STATS_LOWEST_REALITY", "format": "number" },
		],
	},
	{
		"id": "skills",
		"title_en": "Skills",
		"title_key": "GAME_STATS_CAT_SKILLS",
		"stats": [
			{ "key": "logic", "label_en": "Logic", "label_key": "GAME_STATS_LOGIC", "format": "skill" },
			{ "key": "perception", "label_en": "Perception", "label_key": "GAME_STATS_PERCEPTION", "format": "skill" },
			{ "key": "composure", "label_en": "Composure", "label_key": "GAME_STATS_COMPOSURE", "format": "skill" },
			{ "key": "empathy", "label_en": "Empathy", "label_key": "GAME_STATS_EMPATHY", "format": "skill" },
		],
	},
	{
		"id": "skill_checks",
		"title_en": "Skill Checks",
		"title_key": "GAME_STATS_CAT_SKILL_CHECKS",
		"stats": [
			{ "key": "logic_checks", "label_en": "Logic Checks Passed", "label_key": "GAME_STATS_LOGIC_CHECKS", "format": "number" },
			{ "key": "perception_checks", "label_en": "Perception Checks Passed", "label_key": "GAME_STATS_PERCEPTION_CHECKS", "format": "number" },
			{ "key": "composure_checks", "label_en": "Composure Checks Passed", "label_key": "GAME_STATS_COMPOSURE_CHECKS", "format": "number" },
			{ "key": "empathy_checks", "label_en": "Empathy Checks Passed", "label_key": "GAME_STATS_EMPATHY_CHECKS", "format": "number" },
		],
	},
	{
		"id": "choices",
		"title_en": "Choice Patterns",
		"title_key": "GAME_STATS_CAT_CHOICES",
		"stats": [
			{ "key": "most_chosen_type", "label_en": "Most Chosen Option Type", "label_key": "GAME_STATS_MOST_CHOSEN", "format": "text" },
			{ "key": "total_choices", "label_en": "Total Choices Made", "label_key": "GAME_STATS_TOTAL_CHOICES", "format": "number" },
		],
	},
	{
		"id": "social",
		"title_en": "Social",
		"title_key": "GAME_STATS_CAT_SOCIAL",
		"stats": [
			{ "key": "teammates_met", "label_en": "Teammates Met", "label_key": "GAME_STATS_TEAMMATES_MET", "format": "number" },
			{ "key": "gloria_interventions", "label_en": "Gloria Interventions", "label_key": "GAME_STATS_GLORIA_INTERVENTIONS", "format": "number" },
			{ "key": "complaint_counter", "label_en": "Current Complaints", "label_key": "GAME_STATS_CURRENT_COMPLAINTS", "format": "number" },
		],
	},
	{
		"id": "activities",
		"title_en": "Activities",
		"title_key": "GAME_STATS_CAT_ACTIVITIES",
		"stats": [
			{ "key": "prayers_made", "label_en": "Prayers Made", "label_key": "GAME_STATS_PRAYERS_MADE", "format": "number" },
			{ "key": "journal_entries", "label_en": "Journal Entries", "label_key": "GAME_STATS_JOURNAL_ENTRIES", "format": "number" },
			{ "key": "moral_dilemmas", "label_en": "Moral Dilemmas Faced", "label_key": "GAME_STATS_MORAL_DILEMMAS", "format": "number" },
		],
	},
	{
		"id": "achievements",
		"title_en": "Achievements",
		"title_key": "GAME_STATS_CAT_ACHIEVEMENTS",
		"stats": [
			{ "key": "achievements_unlocked", "label_en": "Achievements Unlocked", "label_key": "GAME_STATS_ACHIEVEMENTS_UNLOCKED", "format": "achievement_ratio" },
			{ "key": "achievement_progress", "label_en": "Achievement Progress", "label_key": "GAME_STATS_ACHIEVEMENT_PROGRESS", "format": "percentage" },
		],
	},
]
var playtime_start: int = 0
func _ready() -> void:
	playtime_start = Time.get_ticks_msec()
	_apply_panel_styling()
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
		UIStyleManager.apply_button_style(close_button, "primary", "medium")
		UIStyleManager.add_hover_scale_effect(close_button, 1.05)
		UIStyleManager.add_press_feedback(close_button)
	if refresh_button:
		refresh_button.pressed.connect(_on_refresh_pressed)
		UIStyleManager.apply_button_style(refresh_button, "secondary", "medium")
		UIStyleManager.add_hover_scale_effect(refresh_button, 1.05)
		UIStyleManager.add_press_feedback(refresh_button)
	_localize_ui()
	_render_stats()
	_setup_ts2b_easter_egg()
func _apply_panel_styling() -> void:
	var backdrop = ColorRect.new()
	backdrop.color = Color(0.0, 0.0, 0.0, 0.55)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	move_child(backdrop, 0)
	var panel = $Panel
	if panel:
		UIStyleManager.apply_panel_style(panel, 0.96, UIStyleManager.CORNER_RADIUS_LARGE)
		UIStyleManager.fade_in(panel, 0.3)
		UIStyleManager.slide_in_from_bottom(panel, 0.4, 24.0)
	if title_label:
		title_label.add_theme_font_size_override("font_size", 22)
		title_label.add_theme_color_override("font_color", Color(0.92, 0.95, 1.0))
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
func _tr(key: String) -> String:
	if LocalizationManager:
		return LocalizationManager.get_translation(key)
	return key
func _localize_ui() -> void:
	var lang = GameState.current_language if GameState else "en"
	if lang == "zh":
		if title_label:
			title_label.text = _tr("GAME_STATS_TITLE")
		if close_button:
			close_button.text = _tr("GAME_STATS_CLOSE")
		if refresh_button:
			refresh_button.text = _tr("GAME_STATS_REFRESH")
	else:
		if title_label:
			title_label.text = "Gameplay Statistics"
		if close_button:
			close_button.text = "Close"
		if refresh_button:
			refresh_button.text = "Refresh"
func _input(event: InputEvent) -> void:
	if not visible or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match (event as InputEventKey).keycode:
		KEY_ESCAPE:
			_on_close_pressed()
			get_viewport().set_input_as_handled()
		KEY_R:
			_on_refresh_pressed()
			get_viewport().set_input_as_handled()
func _render_stats() -> void:
	if not stats_container:
		return
	for child in stats_container.get_children():
		child.queue_free()
	var gameplay_stats = _get_gameplay_stats()
	var lang = GameState.current_language if GameState else "en"
	for category in stat_categories:
		_render_category(category, gameplay_stats, lang)
func _get_gameplay_stats() -> Dictionary:
	var stats := { }
	if not GameState:
		return stats
	stats["missions_completed"] = GameState.missions_completed
	stats["current_mission"] = GameState.current_mission
	stats["total_playtime"] = _get_playtime_formatted()
	stats["session_start"] = Time.get_datetime_string_from_system()
	stats["reality_score"] = GameState.reality_score
	stats["positive_energy"] = GameState.positive_energy
	stats["entropy_level"] = GameState.entropy_level
	stats["reality_changes"] = _count_stat_changes("reality")
	stats["entropy_peak"] = _get_max_entropy_reached()
	stats["lowest_reality"] = _get_min_reality_reached()
	var player_skills: Dictionary = GameState.player_stats if GameState.get("player_stats") is Dictionary else {}
	stats["logic"] = player_skills.get("logic", 0)
	stats["perception"] = player_skills.get("perception", 0)
	stats["composure"] = player_skills.get("composure", 0)
	stats["empathy"] = player_skills.get("empathy", 0)
	if AchievementSystem:
		stats["logic_checks"] = AchievementSystem.skill_check_counters.get("logic", 0)
		stats["perception_checks"] = AchievementSystem.skill_check_counters.get("perception", 0)
		stats["composure_checks"] = AchievementSystem.skill_check_counters.get("composure", 0)
		stats["empathy_checks"] = AchievementSystem.skill_check_counters.get("empathy", 0)
	stats["most_chosen_type"] = _analyze_choice_patterns()
	stats["total_choices"] = _count_total_choices()
	stats["teammates_met"] = _get_unlocked_teammates()
	stats["gloria_interventions"] = _count_gloria_interventions()
	stats["complaint_counter"] = GameState.complaint_counter
	stats["prayers_made"] = _count_prayers()
	stats["journal_entries"] = _count_journal_entries()
	stats["moral_dilemmas"] = _count_moral_dilemmas()
	if AchievementSystem:
		var unlocked = AchievementSystem.get_unlocked_achievements().size()
		var total = AchievementSystem.get_all_achievements().size()
		stats["achievements_unlocked"] = "%d / %d" % [unlocked, total]
		stats["achievement_progress"] = (float(unlocked) / float(total) * 100.0) if total > 0 else 0.0
	return stats
func _render_category(category: Dictionary, gameplay_stats: Dictionary, lang: String) -> void:
	var title_text = _tr(category["title_key"]) if lang == "zh" else category["title_en"]
	var card = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.10, 0.12, 0.20, 0.88)
	card_style.border_color = Color(0.35, 0.55, 0.88, 0.45)
	card_style.border_width_left = 3
	card_style.set_corner_radius_all(8)
	card.add_theme_stylebox_override("panel", card_style)
	var inner_margin = MarginContainer.new()
	inner_margin.add_theme_constant_override("margin_left", 14)
	inner_margin.add_theme_constant_override("margin_top", 10)
	inner_margin.add_theme_constant_override("margin_right", 14)
	inner_margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(inner_margin)
	var card_vbox = VBoxContainer.new()
	card_vbox.add_theme_constant_override("separation", 4)
	inner_margin.add_child(card_vbox)
	var hdr = Label.new()
	hdr.text = title_text
	hdr.add_theme_font_size_override("font_size", UIConstants.FONT_SIZE_SUBTITLE)
	hdr.add_theme_color_override("font_color", Color(0.55, 0.82, 1.00))
	card_vbox.add_child(hdr)
	var sep = HSeparator.new()
	sep.add_theme_color_override("color", Color(0.35, 0.55, 0.88, 0.28))
	card_vbox.add_child(sep)
	for i in range(category["stats"].size()):
		_render_stat_row(category["stats"][i], gameplay_stats, lang, card_vbox, i % 2 == 1)
	stats_container.add_child(card)
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 6)
	stats_container.add_child(spacer)
func _render_stat_row(stat: Dictionary, gameplay_stats: Dictionary, lang: String, target: VBoxContainer, alt_bg: bool = false) -> void:
	var row = PanelContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if alt_bg:
		var row_style = StyleBoxFlat.new()
		row_style.bg_color = Color(0.14, 0.16, 0.26, 0.55)
		row_style.set_corner_radius_all(4)
		row.add_theme_stylebox_override("panel", row_style)
	var hbox = HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(0, 28)
	hbox.add_theme_constant_override("separation", 8)
	row.add_child(hbox)
	var label_text = _tr(stat["label_key"]) if lang == "zh" else stat["label_en"]
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(200, 0)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.78, 0.82, 0.92))
	hbox.add_child(label)
	var value = gameplay_stats.get(stat["key"], 0)
	var format = stat["format"]
	if format in ["stat", "skill"]:
		var progress_bar = ProgressBar.new()
		progress_bar.custom_minimum_size = Vector2(120, 18)
		progress_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		if format == "stat":
			progress_bar.max_value = 100.0
			progress_bar.value = float(value)
		else:
			progress_bar.max_value = 10.0
			progress_bar.value = float(value)
		progress_bar.show_percentage = false
		hbox.add_child(progress_bar)
	var value_label = Label.new()
	value_label.text = _format_stat_value(value, format)
	value_label.custom_minimum_size = Vector2(90, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_font_size_override("font_size", 13)
	value_label.add_theme_color_override("font_color", Color(0.92, 0.96, 1.00))
	hbox.add_child(value_label)
	target.add_child(row)
func _format_stat_value(value: Variant, format: String) -> String:
	match format:
		"number":
			return str(value)
		"stat":
			return "%.1f / 100" % float(value)
		"skill":
			return "%d / 10" % int(value)
		"time":
			return str(value)
		"datetime":
			return str(value)
		"text":
			return str(value)
		"percentage":
			return "%.1f%%" % float(value)
		"achievement_ratio":
			return str(value)
		_:
			return str(value)
func _get_playtime_formatted() -> String:
	var elapsed_ms = Time.get_ticks_msec() - playtime_start
	var elapsed_sec = elapsed_ms / 1000
	var hours = elapsed_sec / 3600
	var minutes = (elapsed_sec % 3600) / 60
	var seconds = elapsed_sec % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]
func _count_stat_changes(stat_name: String) -> int:
	if not GameState:
		return 0
	var count = 0
	for event in GameState.event_log:
		if event.get("type", "") == "stat_changed" and event.get("details", { }).get("stat", "") == stat_name:
			count += 1
	return count
func _get_max_entropy_reached() -> float:
	if not GameState:
		return 0.0
	var max_entropy = GameState.entropy_level
	for event in GameState.event_log:
		if event.get("type", "") == "stat_changed" and event.get("details", { }).get("stat", "") == "entropy":
			var value = event.get("details", { }).get("new_value", 0.0)
			if value > max_entropy:
				max_entropy = value
	return max_entropy
func _get_min_reality_reached() -> float:
	if not GameState:
		return 100.0
	var min_reality = GameState.reality_score
	for event in GameState.event_log:
		if event.get("type", "") == "stat_changed" and event.get("details", { }).get("stat", "") == "reality":
			var value = event.get("details", { }).get("new_value", 100.0)
			if value < min_reality:
				min_reality = value
	return min_reality
func _analyze_choice_patterns() -> String:
	if not GameState or not GameState.butterfly_tracker:
		return "N/A"
	var choice_types := { }
	var tracker_choices: Variant = GameState.butterfly_tracker.get("recorded_choices")
	var choices: Array = tracker_choices if tracker_choices is Array else []
	for choice in choices:
		var choice_type = choice.get("type", "unknown")
		choice_types[choice_type] = choice_types.get(choice_type, 0) + 1
	var most_common = ""
	var max_count = 0
	for type in choice_types:
		if choice_types[type] > max_count:
			max_count = choice_types[type]
			most_common = type
	return most_common if most_common else "N/A"
func _count_total_choices() -> int:
	if not GameState or not GameState.butterfly_tracker:
		return 0
	var tracker_choices: Variant = GameState.butterfly_tracker.get("recorded_choices")
	var choices: Array = tracker_choices if tracker_choices is Array else []
	return choices.size()
func _get_unlocked_teammates() -> int:
	if not GameState:
		return 0
	var encountered_teammates := {}
	for event in GameState.event_log:
		if event.get("type", "") == "teammate_interference":
			var teammate_id = event.get("details", {}).get("teammate", "")
			if not teammate_id.is_empty():
				encountered_teammates[teammate_id] = true
	return encountered_teammates.size()
func _count_gloria_interventions() -> int:
	if not GameState:
		return 0
	var count = 0
	for event in GameState.event_log:
		if event.get("type", "") == "gloria_intervention":
			count += 1
	return count
func _count_prayers() -> int:
	if not GameState:
		return 0
	var count = 0
	for event in GameState.event_log:
		if event.get("type", "") == "prayer_made":
			count += 1
	return count
func _count_journal_entries() -> int:
	if not AchievementSystem:
		return 0
	return AchievementSystem.journal_entry_count
func _count_moral_dilemmas() -> int:
	if not AchievementSystem:
		return 0
	return AchievementSystem.moral_dilemma_count
func _on_close_pressed() -> void:
	queue_free()
func _on_refresh_pressed() -> void:
	_render_stats()
func show_stats() -> void:
	show()
	_render_stats()
func _process(delta: float) -> void:
	if _ts2b_click_count > 0:
		_ts2b_click_timer += delta
		if _ts2b_click_timer >= TS2B_CLICK_TIMEOUT:
			_ts2b_click_count = 0
			_ts2b_click_timer = 0.0
func _setup_ts2b_easter_egg() -> void:
	if not title_label:
		return
	var parent_container = title_label.get_parent()
	if not parent_container:
		return
	_ts2b_label = Label.new()
	_ts2b_label.text = _tr("EASTER_EGG_TS2B_TEXT")
	_ts2b_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ts2b_label.add_theme_font_size_override("font_size", 11)
	_ts2b_label.add_theme_color_override("font_color", Color(0.60, 0.80, 0.40, 0.28))
	_ts2b_label.mouse_filter = Control.MOUSE_FILTER_STOP
	_ts2b_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_ts2b_label.tooltip_text = _tr("EASTER_EGG_TS2B_HINT").replace("{remaining}", str(TS2B_CLICK_TARGET))
	_ts2b_label.gui_input.connect(_on_ts2b_label_gui_input)
	parent_container.add_child(_ts2b_label)
func _on_ts2b_label_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	var mb := event as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_LEFT or not mb.pressed:
		return
	_ts2b_click_count += 1
	_ts2b_click_timer = 0.0
	var remaining := TS2B_CLICK_TARGET - _ts2b_click_count
	if _ts2b_label and remaining > 0:
		_ts2b_label.tooltip_text = _tr("EASTER_EGG_TS2B_CLICK").replace("{remaining}", str(remaining))
	if _ts2b_click_count >= TS2B_CLICK_TARGET:
		_ts2b_click_count = 0
		_ts2b_click_timer = 0.0
		_show_ts2b_popup()
func _show_ts2b_popup() -> void:
	var overlay = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.60)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 210
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var popup_panel = PanelContainer.new()
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.09, 0.06, 0.97)
	panel_style.border_color = Color(0.55, 0.78, 0.35, 0.60)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	popup_panel.add_theme_stylebox_override("panel", panel_style)
	popup_panel.set_anchors_preset(Control.PRESET_CENTER)
	popup_panel.custom_minimum_size = Vector2(420, 0)
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	popup_panel.add_child(margin)
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)
	var title_lbl = Label.new()
	title_lbl.text = _tr("EASTER_EGG_TS2B_TITLE")
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 17)
	title_lbl.add_theme_color_override("font_color", Color(0.82, 0.95, 0.55))
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(title_lbl)
	var body_lbl = RichTextLabel.new()
	body_lbl.bbcode_enabled = true
	body_lbl.fit_content = true
	body_lbl.custom_minimum_size = Vector2(364, 0)
	body_lbl.text = _tr("EASTER_EGG_TS2B_BODY")
	body_lbl.add_theme_font_size_override("normal_font_size", 14)
	body_lbl.add_theme_color_override("default_color", Color(0.90, 0.94, 0.84))
	vbox.add_child(body_lbl)
	var listen_btn = Button.new()
	listen_btn.text = _tr("EASTER_EGG_TS2B_LISTEN")
	UIStyleManager.apply_button_style(listen_btn, "primary", "medium")
	listen_btn.pressed.connect(func(): OS.shell_open(TS2B_EASTER_EGG_URL))
	vbox.add_child(listen_btn)
	var close_btn = Button.new()
	close_btn.text = _tr("EASTER_EGG_TS2B_CLICK").replace("{remaining}", "0")
	UIStyleManager.apply_button_style(close_btn, "secondary", "medium")
	close_btn.pressed.connect(func(): overlay.queue_free())
	vbox.add_child(close_btn)
	overlay.add_child(popup_panel)
	add_child(overlay)
	UIStyleManager.fade_in(overlay, 0.3)
