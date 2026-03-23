extends Control
signal close_requested
var ai_manager: Node
var current_language: String = "en"
var _overlay_mode: bool = false
func _tr(key: String) -> String:
	if LocalizationManager:
		return LocalizationManager.get_translation(key)
	return key
func set_overlay_mode(enabled: bool) -> void:
	_overlay_mode = enabled
const VERBOSE_LOGS := GameConstants.Debug.ENABLE_VERBOSE_LOGS
const _ACTIVE_MODULATE := Color(1, 1, 1, 1)
const _INACTIVE_MODULATE := Color(0.6, 0.6, 0.6, 1)
const DEFAULT_OLLAMA_URL := "http://127.0.0.1:11434"
const GEMINI_MODEL_OPTIONS := [
	"★ gemini-3.1-flash-lite-preview",
	"gemini-3.1-pro-preview",
	"gemini-3-flash-preview",
	"gemini-2.5-flash-native-audio-preview-12-2025",
]
const OPENROUTER_MODEL_OPTIONS := [
	"openrouter/free",
	"openrouter/auto",
	"z-ai/glm-4.5-air:free",
	"stepfun/step-3.5-flash:free",
	"google/gemini-3-flash-preview",
	"deepseek/deepseek-r1-0528:free",
	"qwen/qwen3-coder:free",
	"moonshotai/kimi-k2:free",
	"openai/gpt-oss-120b:free",
	"openai/gpt-oss-20b:free",
	"mistralai/mistral-small-3.1-24b-instruct:free",
	"google/gemma-3-12b-it:free",
	"qwen/qwen3-4b:free",
	"nvidia/nemotron-nano-9b-v2:free",
]
@warning_ignore("shadowed_global_identifier")
const UIStyleManager = preload("res://1.Codebase/src/scripts/ui/ui_style_manager.gd")
@onready var main_vbox = $ScrollContainer/Panel/VBoxContainer
@onready var original_scroll = $ScrollContainer
@onready var panel = $ScrollContainer/Panel
@onready var buttons_container = $BottomControls
@onready var provider_option: OptionButton = $ScrollContainer/Panel/VBoxContainer/ProviderOption
@onready var provider_status_label: Label = $ScrollContainer/Panel/VBoxContainer/ProviderStatusLabel
@onready var test_button: Button = $ScrollContainer/Panel/VBoxContainer/TestButton
@onready var status_label: Label = $ScrollContainer/Panel/VBoxContainer/StatusLabel
@onready var provider_label: Label = $ScrollContainer/Panel/VBoxContainer/ProviderLabel
@onready var gemini_label: Label = $ScrollContainer/Panel/VBoxContainer/GeminiLabel
@onready var gemini_key_input: LineEdit = $ScrollContainer/Panel/VBoxContainer/GeminiKeyInput
@onready var gemini_hint_label: Label = $ScrollContainer/Panel/VBoxContainer/GeminiHintLabel
@onready var gemini_model_label: Label = $ScrollContainer/Panel/VBoxContainer/GeminiModelLabel
@onready var gemini_model_option: OptionButton = $ScrollContainer/Panel/VBoxContainer/GeminiModelOption
@onready var gemini_model_input: LineEdit = get_node_or_null("ScrollContainer/Panel/VBoxContainer/GeminiModelInput") as LineEdit
@onready var gemini_model_notice_label: Label = $ScrollContainer/Panel/VBoxContainer/GeminiModelNoticeLabel
@onready var gemini_disabled_label: Label = $ScrollContainer/Panel/VBoxContainer/GeminiDisabledLabel
@onready var openrouter_label: Label = $ScrollContainer/Panel/VBoxContainer/OpenRouterLabel
@onready var openrouter_key_input: LineEdit = $ScrollContainer/Panel/VBoxContainer/OpenRouterKeyInput
@onready var openrouter_hint_label: Label = $ScrollContainer/Panel/VBoxContainer/OpenRouterHintLabel
@onready var openrouter_model_label: Label = $ScrollContainer/Panel/VBoxContainer/ModelLabel
@onready var openrouter_model_option: OptionButton = $ScrollContainer/Panel/VBoxContainer/OpenRouterModelOption
@onready var openrouter_model_input: LineEdit = $ScrollContainer/Panel/VBoxContainer/ModelInput
@onready var openrouter_disabled_label: Label = $ScrollContainer/Panel/VBoxContainer/OpenRouterDisabledLabel
var openrouter_auto_router_check: CheckBox
var openrouter_auto_router_info_label: Label
var openrouter_auto_router_link_label: RichTextLabel
@onready var ollama_header_label: Label = $ScrollContainer/Panel/VBoxContainer/OllamaHeaderLabel
@onready var ollama_info_label: Label = $ScrollContainer/Panel/VBoxContainer/OllamaInfoLabel
@onready var ollama_host_label: Label = $ScrollContainer/Panel/VBoxContainer/OllamaHostLabel
@onready var ollama_host_input: LineEdit = $ScrollContainer/Panel/VBoxContainer/OllamaHostInput
@onready var ollama_port_label: Label = $ScrollContainer/Panel/VBoxContainer/OllamaPortLabel
@onready var ollama_port_spin: SpinBox = $ScrollContainer/Panel/VBoxContainer/OllamaPortSpin
@onready var ollama_model_label: Label = $ScrollContainer/Panel/VBoxContainer/OllamaModelLabel
@onready var ollama_model_input: LineEdit = $ScrollContainer/Panel/VBoxContainer/OllamaModelInput
@onready var ollama_use_chat_check: CheckBox = $ScrollContainer/Panel/VBoxContainer/OllamaUseChatCheck
@onready var ollama_options_label: Label = $ScrollContainer/Panel/VBoxContainer/OllamaOptionsLabel
@onready var ollama_options_input: TextEdit = $ScrollContainer/Panel/VBoxContainer/OllamaOptionsInput
@onready var ollama_hint_label: Label = $ScrollContainer/Panel/VBoxContainer/OllamaHintLabel
@onready var ollama_disabled_label: Label = $ScrollContainer/Panel/VBoxContainer/OllamaDisabledLabel
@onready var memory_settings_label: Label = $ScrollContainer/Panel/VBoxContainer/MemorySettingsLabel
@onready var memory_hint_label: Label = $ScrollContainer/Panel/VBoxContainer/MemoryHintLabel
@onready var memory_limit_container = $ScrollContainer/Panel/VBoxContainer/MemoryLimitContainer
@onready var memory_limit_label: Label = memory_limit_container.get_node("MemoryLimitLabel")
@onready var memory_limit_spin: SpinBox = memory_limit_container.get_node("MemoryLimitSpin")
@onready var memory_summary_container = $ScrollContainer/Panel/VBoxContainer/MemorySummaryContainer
@onready var memory_summary_label: Label = memory_summary_container.get_node("MemorySummaryLabel")
@onready var memory_summary_spin: SpinBox = memory_summary_container.get_node("MemorySummarySpin")
@onready var memory_full_container = $ScrollContainer/Panel/VBoxContainer/MemoryFullContainer
@onready var memory_full_label: Label = memory_full_container.get_node("MemoryFullLabel")
@onready var memory_full_spin: SpinBox = memory_full_container.get_node("MemoryFullSpin")
@onready var context_layers_label: Label = $ScrollContainer/Panel/VBoxContainer/ContextLayersLabel
@onready var context_panel = $ScrollContainer/Panel/VBoxContainer/ContextPanel
@onready var long_term_header: Label = context_panel.get_node("ContextVBox/LongTermHeader")
@onready var long_term_text: RichTextLabel = context_panel.get_node("ContextVBox/LongTermText")
@onready var notes_header: Label = context_panel.get_node("ContextVBox/NotesHeader")
@onready var notes_text: RichTextLabel = context_panel.get_node("ContextVBox/NotesText")
@onready var metrics_label: Label = $ScrollContainer/Panel/VBoxContainer/MetricsLabel
@onready var last_response_time_label: Label = $ScrollContainer/Panel/VBoxContainer/LastResponseTimeLabel
@onready var total_api_calls_label: Label = $ScrollContainer/Panel/VBoxContainer/TotalAPICallsLabel
@onready var total_tokens_used_label: Label = $ScrollContainer/Panel/VBoxContainer/TotalTokensUsedLabel
@onready var last_input_tokens_label: Label = $ScrollContainer/Panel/VBoxContainer/LastInputTokensLabel
@onready var last_output_tokens_label: Label = $ScrollContainer/Panel/VBoxContainer/LastOutputTokensLabel
@onready var metrics_chart_container: Panel = $ScrollContainer/Panel/VBoxContainer/MetricsChartContainer
var cumulative_header_label: Label = null
var cumulative_api_calls_label: Label = null
var cumulative_tokens_label: Label = null
var cumulative_avg_response_label: Label = null
var cumulative_first_request_label: Label = null
var max_tokens_container: HBoxContainer
var max_tokens_label: Label
var max_tokens_spin: SpinBox
var max_tokens_hint_label: Label
@onready var ai_tone_style_label: Label = $ScrollContainer/Panel/VBoxContainer/AIToneStyleLabel
@onready var ai_tone_style_input: LineEdit = $ScrollContainer/Panel/VBoxContainer/AIToneStyleInput
@onready var save_button = $BottomControls/SaveButton
@onready var back_button = $BottomControls/BackButton
@onready var home_button = $BottomControls/HomeButton
var tab_container: TabContainer
var tab_online_providers: VBoxContainer
var tab_gemini: VBoxContainer
var tab_openrouter: VBoxContainer
var tab_openai: VBoxContainer
var tab_claude: VBoxContainer
var tab_local_llm: VBoxContainer
var tab_ollama: VBoxContainer
var tab_lmstudio: VBoxContainer
var tab_ai_router: VBoxContainer
var tab_memory: VBoxContainer
var tab_metrics: VBoxContainer
var tab_behavior: VBoxContainer
var tab_safety: VBoxContainer
var tab_mock_mode: VBoxContainer
var safety_level_label: Label
var safety_level_option: OptionButton
var safety_hint_label: Label
var ai_metrics_chart: Control = preload("res://1.Codebase/src/scripts/ui/ai_metrics_chart.gd").new()
var _gemini_inputs: Array = []
var _gemini_visuals: Array = []
var _openrouter_inputs: Array = []
var _openrouter_visuals: Array = []
var _ollama_inputs: Array = []
var _ollama_visuals: Array = []
var openai_label: Label
var openai_key_input: LineEdit
var openai_hint_label: Label
var openai_model_label: Label
var openai_model_input: LineEdit
var openai_disabled_label: Label
var claude_label: Label
var claude_key_input: LineEdit
var claude_hint_label: Label
var claude_model_label: Label
var claude_model_input: LineEdit
var claude_disabled_label: Label
var lmstudio_header_label: Label
var lmstudio_info_label: Label
var lmstudio_host_label: Label
var lmstudio_host_input: LineEdit
var lmstudio_port_label: Label
var lmstudio_port_spin: SpinBox
var lmstudio_model_label: Label
var lmstudio_model_input: LineEdit
var lmstudio_disabled_label: Label
var ai_router_header_label: Label
var ai_router_info_label: Label
var ai_router_host_label: Label
var ai_router_host_input: LineEdit
var ai_router_port_label: Label
var ai_router_port_spin: SpinBox
var ai_router_api_key_label: Label
var ai_router_api_key_input: LineEdit
var ai_router_model_label: Label
var ai_router_model_input: LineEdit
var ai_router_format_label: Label
var ai_router_format_option: OptionButton
var ai_router_endpoint_label: Label
var ai_router_endpoint_input: LineEdit
var ai_router_disabled_label: Label
var _openai_inputs: Array = []
var _openai_visuals: Array = []
var _claude_inputs: Array = []
var _claude_visuals: Array = []
var _lmstudio_inputs: Array = []
var _lmstudio_visuals: Array = []
var _ai_router_inputs: Array = []
var _ai_router_visuals: Array = []
var _mock_mode_status_label: Label = null
func _clamp_port(value: int) -> int:
	return clampi(value, 1, 65535)
func _build_ollama_url(host: String, port: int, scheme: String = "http") -> String:
	var clean_host := host.strip_edges()
	if clean_host.is_empty():
		clean_host = "127.0.0.1"
	var clean_scheme := scheme.strip_edges()
	if clean_scheme.is_empty():
		clean_scheme = "http"
	var effective_port := _clamp_port(port)
	if clean_host.begins_with("[") and clean_host.ends_with("]"):
		return "%s://%s:%d" % [clean_scheme, clean_host, effective_port]
	if clean_host.contains(":") and not clean_host.contains(".") and not clean_host.begins_with("["):
		return "%s://[%s]:%d" % [clean_scheme, clean_host, effective_port]
	return "%s://%s:%d" % [clean_scheme, clean_host, effective_port]
func _parse_ollama_url(raw: String, fallback_port: int) -> Dictionary:
	var text := raw.strip_edges()
	var scheme := "http"
	var fallback := _clamp_port(fallback_port)
	if text.is_empty():
		return {
			"ok": true,
			"host": "127.0.0.1",
			"port": fallback,
			"scheme": scheme,
			"url": DEFAULT_OLLAMA_URL,
			"explicit_port": false,
		}
	var working := text
	var lower := working.to_lower()
	if lower.begins_with("http://"):
		scheme = "http"
		working = working.substr(7)
	elif lower.begins_with("https://"):
		scheme = "https"
		working = working.substr(8)
	var slash_idx := working.find("/")
	if slash_idx != -1:
		working = working.substr(0, slash_idx)
	working = working.strip_edges()
	if working.is_empty():
		return {
			"ok": false,
			"error": "Ollama URL missing host.",
		}
	var host_part := working
	var port_value := fallback
	var explicit_port := false
	if host_part.begins_with("["):
		var close_idx := host_part.find("]")
		if close_idx == -1:
			return {
				"ok": false,
				"error": "Ollama URL has malformed IPv6 host.",
			}
		var remainder := host_part.substr(close_idx + 1).strip_edges()
		if remainder.begins_with(":"):
			var port_str := remainder.substr(1).strip_edges()
			if port_str.is_empty():
				return {
					"ok": false,
					"error": "Ollama URL missing port number.",
				}
			if not port_str.is_valid_int():
				return {
					"ok": false,
					"error": "Ollama URL has invalid port.",
				}
			port_value = _clamp_port(int(port_str))
			explicit_port = true
		elif not remainder.is_empty():
			return {
				"ok": false,
				"error": "Ollama URL has invalid format.",
			}
		host_part = host_part.substr(1, close_idx - 1)
	else:
		var colon_idx := host_part.rfind(":")
		if colon_idx != -1:
			var port_str := host_part.substr(colon_idx + 1).strip_edges()
			if port_str.is_empty():
				return {
					"ok": false,
					"error": "Ollama URL missing port number.",
				}
			if not port_str.is_valid_int():
				return {
					"ok": false,
					"error": "Ollama URL has invalid port.",
				}
			port_value = _clamp_port(int(port_str))
			explicit_port = true
			host_part = host_part.substr(0, colon_idx)
	host_part = host_part.strip_edges()
	if host_part.is_empty():
		return {
			"ok": false,
			"error": "Ollama URL missing host.",
		}
	var display_host := host_part
	if display_host.contains(":") and not display_host.begins_with("["):
		display_host = "[%s]" % display_host
	return {
		"ok": true,
		"host": host_part,
		"port": port_value,
		"scheme": scheme,
		"explicit_port": explicit_port,
		"url": _build_ollama_url(host_part, port_value, scheme),
	}
func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	ai_manager = ServiceLocator.get_ai_manager() if ServiceLocator else AIManager
	current_language = GameState.current_language if GameState else "en"
	_rebuild_layout_into_tabs()
	_update_ui_labels()
	_configure_provider_widgets()
	if openrouter_model_option and not openrouter_model_option.item_selected.is_connected(_on_openrouter_model_option_changed):
		openrouter_model_option.item_selected.connect(_on_openrouter_model_option_changed)
	if gemini_model_option and not gemini_model_option.item_selected.is_connected(_on_gemini_model_option_changed):
		gemini_model_option.item_selected.connect(_on_gemini_model_option_changed)
	if metrics_chart_container:
		metrics_chart_container.add_child(ai_metrics_chart)
		ai_metrics_chart.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_update_metrics_display()
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_update_metrics_display)
	if ai_manager:
		ai_manager.ai_response_received.connect(_on_ai_test_success)
		ai_manager.ai_error.connect(_on_ai_test_error)
		if ai_manager.has_signal("ai_request_progress") and not ai_manager.ai_request_progress.is_connected(_on_ai_request_progress):
			ai_manager.ai_request_progress.connect(_on_ai_request_progress)
		load_current_settings()
	else:
		update_provider_ui()
	_apply_modern_styles()
	await get_tree().process_frame
	if save_button:
		save_button.grab_focus()
	if panel:
		UIStyleManager.fade_in(panel, 0.4)
func _input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match (event as InputEventKey).keycode:
		KEY_ESCAPE:
			_on_back_button_pressed()
			get_viewport().set_input_as_handled()
func _rebuild_layout_into_tabs():
	if panel and original_scroll and panel.get_parent() == original_scroll:
		panel.reparent(self)
		panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		panel.offset_left = 0
		panel.offset_top = 0
		panel.offset_right = 0
		panel.offset_bottom = 0
	if original_scroll:
		original_scroll.visible = false
	if buttons_container:
		buttons_container.visible = false
	if main_vbox:
		main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for child in main_vbox.get_children():
			main_vbox.remove_child(child)
		var global_settings = VBoxContainer.new()
		global_settings.name = "GlobalSettings"
		global_settings.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		global_settings.add_theme_constant_override("separation", 10)
		var global_margin = MarginContainer.new()
		global_margin.add_theme_constant_override("margin_top", 10)
		global_margin.add_theme_constant_override("margin_left", 10)
		global_margin.add_theme_constant_override("margin_right", 10)
		global_margin.add_theme_constant_override("margin_bottom", 5)
		global_margin.add_child(global_settings)
		main_vbox.add_child(global_margin)
		_move_control(provider_label, global_settings)
		_move_control(provider_option, global_settings)
		_move_control(provider_status_label, global_settings)
		_move_control(test_button, global_settings)
		_move_control(status_label, global_settings)
		_create_max_tokens_controls(global_settings)
		tab_container = TabContainer.new()
		tab_container.name = "AISettingsTabs"
		tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		tab_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		main_vbox.add_child(tab_container)
		if buttons_container:
			if buttons_container.get_parent():
				buttons_container.get_parent().remove_child(buttons_container)
			main_vbox.add_child(buttons_container)
			buttons_container.visible = true
	tab_online_providers = _create_tab_page("Online Providers")
	tab_local_llm = _create_tab_page("Local LLM")
	tab_safety = _create_tab_page("Safety")
	tab_memory = _create_tab_page("Memory")
	tab_behavior = _create_tab_page("Behavior")
	tab_metrics = _create_tab_page("Metrics")
	tab_mock_mode = _create_tab_page(_tr("AI_SETTINGS_TAB_MOCK_MODE"))
	_create_mock_mode_section(tab_mock_mode)
	_create_online_provider_sections()
	_create_local_llm_sections()
	safety_level_label = Label.new()
	safety_level_label.name = "SafetyLevelLabel"
	tab_safety.add_child(safety_level_label)
	safety_level_option = OptionButton.new()
	safety_level_option.name = "SafetyLevelOption"
	safety_level_option.add_item("Game Mode (Block None) Recommended")
	safety_level_option.add_item("Low Blocking (Block Few)")
	safety_level_option.add_item("Standard (Default)")
	safety_level_option.add_item("High Blocking (Strict)")
	tab_safety.add_child(safety_level_option)
	safety_hint_label = Label.new()
	safety_hint_label.name = "SafetyHintLabel"
	safety_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	safety_hint_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	tab_safety.add_child(safety_hint_label)
	_move_control(memory_settings_label, tab_memory)
	_move_control(memory_hint_label, tab_memory)
	_add_separator(tab_memory)
	_move_control(memory_limit_container, tab_memory)
	_move_control(memory_summary_container, tab_memory)
	_move_control(memory_full_container, tab_memory)
	_add_separator(tab_memory)
	_move_control(context_layers_label, tab_memory)
	_move_control(context_panel, tab_memory)
	if context_panel:
		context_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
		context_panel.custom_minimum_size.y = 200
	_move_control(ai_tone_style_label, tab_behavior)
	_move_control(ai_tone_style_input, tab_behavior)
	_move_control(metrics_label, tab_metrics)
	_move_control(metrics_chart_container, tab_metrics)
	if metrics_chart_container:
		metrics_chart_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		metrics_chart_container.custom_minimum_size.y = 200
	_move_control(last_response_time_label, tab_metrics)
	_move_control(total_api_calls_label, tab_metrics)
	_move_control(total_tokens_used_label, tab_metrics)
	_move_control(last_input_tokens_label, tab_metrics)
	_move_control(last_output_tokens_label, tab_metrics)
	_add_separator(tab_metrics)
	_create_cumulative_stats_labels(tab_metrics)
func _create_tab_page(tab_name: String) -> VBoxContainer:
	var scroll = ScrollContainer.new()
	scroll.name = tab_name + "Scroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var vbox = VBoxContainer.new()
	vbox.name = tab_name + "VBox"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 15)
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)
	margin.add_child(vbox)
	tab_container.add_child(scroll)
	return vbox
func _move_control(node: Control, new_parent: Control):
	if node:
		if node.get_parent():
			node.get_parent().remove_child(node)
		new_parent.add_child(node)
		node.visible = true
func _add_separator(parent: Control):
	var sep = HSeparator.new()
	sep.modulate = Color(1, 1, 1, 0.3)
	parent.add_child(sep)
func _create_cumulative_stats_labels(parent: Control) -> void:
	cumulative_header_label = Label.new()
	cumulative_header_label.name = "CumulativeHeaderLabel"
	cumulative_header_label.add_theme_font_size_override("font_size", 18)
	cumulative_header_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	parent.add_child(cumulative_header_label)
	cumulative_api_calls_label = Label.new()
	cumulative_api_calls_label.name = "CumulativeAPICallsLabel"
	parent.add_child(cumulative_api_calls_label)
	cumulative_tokens_label = Label.new()
	cumulative_tokens_label.name = "CumulativeTokensLabel"
	parent.add_child(cumulative_tokens_label)
	cumulative_avg_response_label = Label.new()
	cumulative_avg_response_label.name = "CumulativeAvgResponseLabel"
	parent.add_child(cumulative_avg_response_label)
	cumulative_first_request_label = Label.new()
	cumulative_first_request_label.name = "CumulativeFirstRequestLabel"
	cumulative_first_request_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	parent.add_child(cumulative_first_request_label)
func _create_max_tokens_controls(parent: VBoxContainer) -> void:
	max_tokens_container = HBoxContainer.new()
	max_tokens_container.name = "MaxTokensContainer"
	max_tokens_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	max_tokens_container.add_theme_constant_override("separation", 12)
	parent.add_child(max_tokens_container)
	max_tokens_label = Label.new()
	max_tokens_label.name = "MaxTokensLabel"
	max_tokens_label.text = "Max AI Reply Tokens (Per Request):"
	max_tokens_container.add_child(max_tokens_label)
	max_tokens_spin = SpinBox.new()
	max_tokens_spin.name = "MaxTokensSpin"
	max_tokens_spin.min_value = 1
	max_tokens_spin.max_value = 8192
	max_tokens_spin.step = 1
	max_tokens_spin.value = 4096
	max_tokens_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	max_tokens_container.add_child(max_tokens_spin)
	max_tokens_hint_label = Label.new()
	max_tokens_hint_label.name = "MaxTokensHintLabel"
	max_tokens_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	max_tokens_hint_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	max_tokens_hint_label.text = "Limits one AI response length (output only). Not full-playthrough total, and not input token limit."
	parent.add_child(max_tokens_hint_label)
func _create_online_provider_sections() -> void:
	var gemini_section = _create_provider_section("Google Gemini", tab_online_providers)
	tab_gemini = gemini_section
	_move_control(gemini_label, tab_gemini)
	_move_control(gemini_key_input, tab_gemini)
	_move_control(gemini_hint_label, tab_gemini)
	_move_control(gemini_model_label, tab_gemini)
	_move_control(gemini_model_option, tab_gemini)
	if gemini_model_input:
		_move_control(gemini_model_input, tab_gemini)
	else:
		_create_gemini_model_input(tab_gemini)
	_move_control(gemini_model_notice_label, tab_gemini)
	_move_control(gemini_disabled_label, tab_gemini)
	_add_separator(tab_online_providers)
	var openrouter_section = _create_provider_section("OpenRouter", tab_online_providers)
	tab_openrouter = openrouter_section
	_move_control(openrouter_label, tab_openrouter)
	_move_control(openrouter_key_input, tab_openrouter)
	_move_control(openrouter_hint_label, tab_openrouter)
	_move_control(openrouter_model_label, tab_openrouter)
	_move_control(openrouter_model_option, tab_openrouter)
	_move_control(openrouter_model_input, tab_openrouter)
	_create_openrouter_auto_router_controls(tab_openrouter)
	_move_control(openrouter_disabled_label, tab_openrouter)
	_add_separator(tab_online_providers)
	var openai_section = _create_provider_section("OpenAI", tab_online_providers)
	tab_openai = openai_section
	_create_openai_controls(tab_openai)
	_add_separator(tab_online_providers)
	var claude_section = _create_provider_section("Claude (Anthropic)", tab_online_providers)
	tab_claude = claude_section
	_create_claude_controls(tab_claude)
func _create_local_llm_sections() -> void:
	var ollama_section = _create_provider_section("Ollama", tab_local_llm)
	tab_ollama = ollama_section
	_move_control(ollama_header_label, tab_ollama)
	_move_control(ollama_info_label, tab_ollama)
	_move_control(ollama_host_label, tab_ollama)
	_move_control(ollama_host_input, tab_ollama)
	_move_control(ollama_port_label, tab_ollama)
	_move_control(ollama_port_spin, tab_ollama)
	_move_control(ollama_model_label, tab_ollama)
	_move_control(ollama_model_input, tab_ollama)
	_move_control(ollama_use_chat_check, tab_ollama)
	_move_control(ollama_options_label, tab_ollama)
	_move_control(ollama_options_input, tab_ollama)
	_move_control(ollama_hint_label, tab_ollama)
	_move_control(ollama_disabled_label, tab_ollama)
	_add_separator(tab_local_llm)
	var lmstudio_section = _create_provider_section("LMStudio", tab_local_llm)
	tab_lmstudio = lmstudio_section
	_create_lmstudio_controls(tab_lmstudio)
	_add_separator(tab_local_llm)
	var ai_router_section = _create_provider_section("AI Router (Local Proxy)", tab_local_llm)
	tab_ai_router = ai_router_section
	_create_ai_router_controls(tab_ai_router)
func _create_provider_section(title: String, parent: VBoxContainer) -> VBoxContainer:
	var header = Label.new()
	header.name = title.replace(" ", "") + "Header"
	header.text = title
	header.add_theme_font_size_override("font_size", 22)
	header.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	parent.add_child(header)
	var section = VBoxContainer.new()
	section.name = title.replace(" ", "") + "Section"
	section.add_theme_constant_override("separation", 10)
	parent.add_child(section)
	return section
func _create_gemini_model_input(parent: VBoxContainer) -> void:
	gemini_model_input = LineEdit.new()
	gemini_model_input.name = "GeminiModelInput"
	gemini_model_input.placeholder_text = "Enter custom Gemini model when 'Custom' is selected"
	gemini_model_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gemini_model_input.editable = false
	gemini_model_input.modulate = Color(0.7, 0.7, 0.7, 1)
	parent.add_child(gemini_model_input)
func _create_openai_controls(parent: VBoxContainer) -> void:
	openai_label = Label.new()
	openai_label.name = "OpenAILabel"
	openai_label.text = "OpenAI API Key:"
	parent.add_child(openai_label)
	openai_key_input = LineEdit.new()
	openai_key_input.name = "OpenAIKeyInput"
	openai_key_input.secret = true
	openai_key_input.placeholder_text = "sk-..."
	openai_key_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(openai_key_input)
	openai_hint_label = Label.new()
	openai_hint_label.name = "OpenAIHintLabel"
	openai_hint_label.text = "Get your key from: https://platform.openai.com/api-keys"
	openai_hint_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	openai_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(openai_hint_label)
	openai_model_label = Label.new()
	openai_model_label.name = "OpenAIModelLabel"
	openai_model_label.text = "OpenAI Model:"
	parent.add_child(openai_model_label)
	openai_model_input = LineEdit.new()
	openai_model_input.name = "OpenAIModelInput"
	openai_model_input.text = "gpt-5.2"
	openai_model_input.placeholder_text = "gpt-5.2, gpt-4o, gpt-4.1, o3, o1, etc."
	openai_model_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(openai_model_input)
	openai_disabled_label = Label.new()
	openai_disabled_label.name = "OpenAIDisabledLabel"
	openai_disabled_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.3))
	openai_disabled_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	openai_disabled_label.visible = false
	parent.add_child(openai_disabled_label)
func _create_claude_controls(parent: VBoxContainer) -> void:
	claude_label = Label.new()
	claude_label.name = "ClaudeLabel"
	claude_label.text = "Claude API Key:"
	parent.add_child(claude_label)
	claude_key_input = LineEdit.new()
	claude_key_input.name = "ClaudeKeyInput"
	claude_key_input.secret = true
	claude_key_input.placeholder_text = "sk-ant-..."
	claude_key_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(claude_key_input)
	claude_hint_label = Label.new()
	claude_hint_label.name = "ClaudeHintLabel"
	claude_hint_label.text = "Get your key from: https://console.anthropic.com/settings/keys"
	claude_hint_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	claude_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(claude_hint_label)
	claude_model_label = Label.new()
	claude_model_label.name = "ClaudeModelLabel"
	claude_model_label.text = "Claude Model:"
	parent.add_child(claude_model_label)
	claude_model_input = LineEdit.new()
	claude_model_input.name = "ClaudeModelInput"
	claude_model_input.text = "claude-sonnet-4-5-20250929"
	claude_model_input.placeholder_text = "claude-sonnet-4-5-20250929, claude-opus-4-5-20251101, claude-haiku-4-5-20251001, etc."
	claude_model_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(claude_model_input)
	claude_disabled_label = Label.new()
	claude_disabled_label.name = "ClaudeDisabledLabel"
	claude_disabled_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.3))
	claude_disabled_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	claude_disabled_label.visible = false
	parent.add_child(claude_disabled_label)
func _create_openrouter_auto_router_controls(parent: VBoxContainer) -> void:
	_add_separator(parent)
	openrouter_auto_router_check = CheckBox.new()
	openrouter_auto_router_check.name = "OpenRouterAutoRouterCheck"
	openrouter_auto_router_check.text = "Enable Auto Router for Cost Optimization"
	openrouter_auto_router_check.add_theme_font_size_override("font_size", 16)
	parent.add_child(openrouter_auto_router_check)
	openrouter_auto_router_info_label = Label.new()
	openrouter_auto_router_info_label.name = "OpenRouterAutoRouterInfoLabel"
	openrouter_auto_router_info_label.text = "When enabled, OpenRouter's Auto Router (openrouter/auto) automatically selects the most cost-effective model based on your prompt. Simple tasks like heartbeats and status checks are routed to cheaper (even free!) models, while complex interactions use more capable models. This can significantly reduce API costs."
	openrouter_auto_router_info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	openrouter_auto_router_info_label.add_theme_font_size_override("font_size", 14)
	openrouter_auto_router_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(openrouter_auto_router_info_label)
	openrouter_auto_router_link_label = RichTextLabel.new()
	openrouter_auto_router_link_label.name = "OpenRouterAutoRouterLinkLabel"
	openrouter_auto_router_link_label.bbcode_enabled = true
	openrouter_auto_router_link_label.fit_content = true
	openrouter_auto_router_link_label.scroll_active = false
	openrouter_auto_router_link_label.add_theme_font_size_override("normal_font_size", 14)
	openrouter_auto_router_link_label.text = "[color=#6699ff][url=https://openrouter.ai/docs/features/auto-router]Learn more about Auto Router at openrouter.ai/docs/features/auto-router[/url][/color]"
	openrouter_auto_router_link_label.meta_clicked.connect(_on_openrouter_auto_router_link_clicked)
	parent.add_child(openrouter_auto_router_link_label)
func _create_lmstudio_controls(parent: VBoxContainer) -> void:
	lmstudio_header_label = Label.new()
	lmstudio_header_label.name = "LMStudioHeaderLabel"
	lmstudio_header_label.text = "Configure LMStudio"
	lmstudio_header_label.add_theme_font_size_override("font_size", 18)
	parent.add_child(lmstudio_header_label)
	lmstudio_info_label = Label.new()
	lmstudio_info_label.name = "LMStudioInfoLabel"
	lmstudio_info_label.text = "LMStudio provides a local OpenAI-compatible API. Default: http://127.0.0.1:1234"
	lmstudio_info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	lmstudio_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(lmstudio_info_label)
	lmstudio_host_label = Label.new()
	lmstudio_host_label.name = "LMStudioHostLabel"
	lmstudio_host_label.text = "LMStudio Host:"
	parent.add_child(lmstudio_host_label)
	lmstudio_host_input = LineEdit.new()
	lmstudio_host_input.name = "LMStudioHostInput"
	lmstudio_host_input.text = "127.0.0.1"
	lmstudio_host_input.placeholder_text = "127.0.0.1"
	lmstudio_host_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(lmstudio_host_input)
	lmstudio_port_label = Label.new()
	lmstudio_port_label.name = "LMStudioPortLabel"
	lmstudio_port_label.text = "LMStudio Port:"
	parent.add_child(lmstudio_port_label)
	lmstudio_port_spin = SpinBox.new()
	lmstudio_port_spin.name = "LMStudioPortSpin"
	lmstudio_port_spin.min_value = 1
	lmstudio_port_spin.max_value = 65535
	lmstudio_port_spin.value = 1234
	lmstudio_port_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(lmstudio_port_spin)
	lmstudio_model_label = Label.new()
	lmstudio_model_label.name = "LMStudioModelLabel"
	lmstudio_model_label.text = "Model (optional):"
	parent.add_child(lmstudio_model_label)
	lmstudio_model_input = LineEdit.new()
	lmstudio_model_input.name = "LMStudioModelInput"
	lmstudio_model_input.placeholder_text = "Leave empty to use currently loaded model"
	lmstudio_model_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(lmstudio_model_input)
	lmstudio_disabled_label = Label.new()
	lmstudio_disabled_label.name = "LMStudioDisabledLabel"
	lmstudio_disabled_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.3))
	lmstudio_disabled_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lmstudio_disabled_label.visible = false
	parent.add_child(lmstudio_disabled_label)
func _create_ai_router_controls(parent: VBoxContainer) -> void:
	ai_router_header_label = Label.new()
	ai_router_header_label.name = "AIRouterHeaderLabel"
	ai_router_header_label.text = "Configure AI Router"
	ai_router_header_label.add_theme_font_size_override("font_size", 18)
	parent.add_child(ai_router_header_label)
	ai_router_info_label = Label.new()
	ai_router_info_label.name = "AIRouterInfoLabel"
	ai_router_info_label.text = "AI Router connects to cloud AI models through a local proxy service (e.g., Antigravity Manager, One API, New API). Supports OpenAI, Claude, and Gemini API formats."
	ai_router_info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	ai_router_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(ai_router_info_label)
	ai_router_host_label = Label.new()
	ai_router_host_label.name = "AIRouterHostLabel"
	ai_router_host_label.text = "Router Host:"
	parent.add_child(ai_router_host_label)
	ai_router_host_input = LineEdit.new()
	ai_router_host_input.name = "AIRouterHostInput"
	ai_router_host_input.text = "127.0.0.1"
	ai_router_host_input.placeholder_text = "127.0.0.1"
	ai_router_host_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(ai_router_host_input)
	ai_router_port_label = Label.new()
	ai_router_port_label.name = "AIRouterPortLabel"
	ai_router_port_label.text = "Router Port:"
	parent.add_child(ai_router_port_label)
	ai_router_port_spin = SpinBox.new()
	ai_router_port_spin.name = "AIRouterPortSpin"
	ai_router_port_spin.min_value = 1
	ai_router_port_spin.max_value = 65535
	ai_router_port_spin.value = 8046
	ai_router_port_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(ai_router_port_spin)
	ai_router_api_key_label = Label.new()
	ai_router_api_key_label.name = "AIRouterAPIKeyLabel"
	ai_router_api_key_label.text = "API Key (optional):"
	parent.add_child(ai_router_api_key_label)
	ai_router_api_key_input = LineEdit.new()
	ai_router_api_key_input.name = "AIRouterAPIKeyInput"
	ai_router_api_key_input.secret = true
	ai_router_api_key_input.placeholder_text = "e.g., sk-antigravity or your router's API key"
	ai_router_api_key_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(ai_router_api_key_input)
	ai_router_format_label = Label.new()
	ai_router_format_label.name = "AIRouterFormatLabel"
	ai_router_format_label.text = "API Format:"
	parent.add_child(ai_router_format_label)
	ai_router_format_option = OptionButton.new()
	ai_router_format_option.name = "AIRouterFormatOption"
	ai_router_format_option.add_item("OpenAI Format")
	ai_router_format_option.add_item("Claude Format")
	ai_router_format_option.add_item("Gemini Format")
	ai_router_format_option.selected = 0
	ai_router_format_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(ai_router_format_option)
	ai_router_model_label = Label.new()
	ai_router_model_label.name = "AIRouterModelLabel"
	ai_router_model_label.text = "Model:"
	parent.add_child(ai_router_model_label)
	ai_router_model_input = LineEdit.new()
	ai_router_model_input.name = "AIRouterModelInput"
	ai_router_model_input.placeholder_text = "e.g., gemini-3-flash, claude-sonnet-4-5, gemini-2.5-flash-thinking"
	ai_router_model_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(ai_router_model_input)
	ai_router_endpoint_label = Label.new()
	ai_router_endpoint_label.name = "AIRouterEndpointLabel"
	ai_router_endpoint_label.text = "Custom Endpoint (optional):"
	parent.add_child(ai_router_endpoint_label)
	ai_router_endpoint_input = LineEdit.new()
	ai_router_endpoint_input.name = "AIRouterEndpointInput"
	ai_router_endpoint_input.placeholder_text = "OpenAI: /v1/chat/completions, Claude: /v1/messages, Gemini: /v1beta/models/..."
	ai_router_endpoint_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(ai_router_endpoint_input)
	var ai_router_api_hint_label = Label.new()
	ai_router_api_hint_label.name = "AIRouterAPIHintLabel"
	ai_router_api_hint_label.text = "Note: API key requirement depends on your routing service. Some services (e.g., local-only routers) don't require a key, while others (e.g., cloud-based routers) do."
	ai_router_api_hint_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	ai_router_api_hint_label.add_theme_font_size_override("font_size", 13)
	ai_router_api_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(ai_router_api_hint_label)
	ai_router_disabled_label = Label.new()
	ai_router_disabled_label.name = "AIRouterDisabledLabel"
	ai_router_disabled_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.3))
	ai_router_disabled_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ai_router_disabled_label.visible = false
	parent.add_child(ai_router_disabled_label)
func _create_mock_mode_section(parent: VBoxContainer) -> void:
	var header = Label.new()
	header.name = "MockModeHeader"
	header.text = _tr("AI_SETTINGS_MOCK_SECTION_TITLE")
	header.add_theme_font_size_override("font_size", 24)
	header.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	parent.add_child(header)
	_add_separator(parent)
	var description = Label.new()
	description.name = "MockModeDescription"
	description.text = _tr("AI_SETTINGS_MOCK_SECTION_DESCRIPTION")
	description.add_theme_font_size_override("font_size", 16)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(description)
	_add_separator(parent)
	var enable_header = Label.new()
	enable_header.name = "MockModeEnableHeader"
	enable_header.text = _tr("AI_SETTINGS_MOCK_ENABLE_HEADER")
	enable_header.add_theme_font_size_override("font_size", 20)
	enable_header.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	parent.add_child(enable_header)
	var enable_instructions = Label.new()
	enable_instructions.name = "MockModeEnableInstructions"
	enable_instructions.text = _tr("AI_SETTINGS_MOCK_ENABLE_INSTRUCTIONS")
	enable_instructions.add_theme_font_size_override("font_size", 16)
	enable_instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(enable_instructions)
	_add_separator(parent)
	var status_header = Label.new()
	status_header.name = "MockModeStatusHeader"
	status_header.text = _tr("AI_SETTINGS_MOCK_STATUS_HEADER")
	status_header.add_theme_font_size_override("font_size", 20)
	status_header.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	parent.add_child(status_header)
	var mock_status_label = Label.new()
	mock_status_label.name = "MockModeStatusLabel"
	mock_status_label.add_theme_font_size_override("font_size", 16)
	parent.add_child(mock_status_label)
	_mock_mode_status_label = mock_status_label
	_update_mock_mode_status()
	_add_separator(parent)
	var fallback_note = Label.new()
	fallback_note.name = "MockModeFallbackNote"
	fallback_note.text = _tr("AI_SETTINGS_MOCK_FALLBACK_NOTE")
	fallback_note.add_theme_font_size_override("font_size", 14)
	fallback_note.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	fallback_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(fallback_note)
func _apply_modern_styles():
	if panel:
		var style = UIStyleManager.create_panel_style(0.98, 0)
		panel.add_theme_stylebox_override("panel", style)
	if save_button:
		UIStyleManager.apply_button_style(save_button, "primary", "large")
		UIStyleManager.add_hover_scale_effect(save_button)
	if back_button:
		UIStyleManager.apply_button_style(back_button, "secondary", "medium")
		UIStyleManager.add_hover_scale_effect(back_button)
	if home_button:
		UIStyleManager.apply_button_style(home_button, "secondary", "medium")
		UIStyleManager.add_hover_scale_effect(home_button)
	if test_button:
		UIStyleManager.apply_button_style(test_button, "accent", "medium")
		UIStyleManager.add_press_feedback(test_button)
func _exit_tree() -> void:
	if ai_manager:
		if ai_manager.ai_response_received.is_connected(_on_ai_test_success):
			ai_manager.ai_response_received.disconnect(_on_ai_test_success)
		if ai_manager.ai_error.is_connected(_on_ai_test_error):
			ai_manager.ai_error.disconnect(_on_ai_test_error)
		if ai_manager.has_signal("ai_request_progress") and ai_manager.ai_request_progress.is_connected(_on_ai_request_progress):
			ai_manager.ai_request_progress.disconnect(_on_ai_request_progress)
func _configure_provider_widgets() -> void:
	if not _gemini_inputs.is_empty():
		return
	_gemini_inputs = [gemini_key_input, gemini_model_option, gemini_model_input]
	_gemini_visuals = [
		gemini_label,
		gemini_key_input,
		gemini_hint_label,
		gemini_model_label,
		gemini_model_option,
		gemini_model_notice_label,
	]
	_openrouter_inputs = [openrouter_key_input, openrouter_model_option, openrouter_model_input]
	if openrouter_auto_router_check:
		_openrouter_inputs.append(openrouter_auto_router_check)
	_openrouter_visuals = [openrouter_label, openrouter_key_input, openrouter_hint_label, openrouter_model_label, openrouter_model_option, openrouter_model_input]
	if openrouter_auto_router_check:
		_openrouter_visuals.append(openrouter_auto_router_check)
	if openrouter_auto_router_info_label:
		_openrouter_visuals.append(openrouter_auto_router_info_label)
	if openrouter_auto_router_link_label:
		_openrouter_visuals.append(openrouter_auto_router_link_label)
	_ollama_inputs = [ollama_host_input, ollama_port_spin, ollama_model_input, ollama_use_chat_check, ollama_options_input]
	_ollama_visuals = [
		ollama_header_label,
		ollama_info_label,
		ollama_host_label,
		ollama_host_input,
		ollama_port_label,
		ollama_port_spin,
		ollama_model_label,
		ollama_model_input,
		ollama_use_chat_check,
		ollama_options_label,
		ollama_options_input,
		ollama_hint_label,
	]
	_openai_inputs = [openai_key_input, openai_model_input]
	_openai_visuals = [openai_label, openai_key_input, openai_hint_label, openai_model_label, openai_model_input]
	_claude_inputs = [claude_key_input, claude_model_input]
	_claude_visuals = [claude_label, claude_key_input, claude_hint_label, claude_model_label, claude_model_input]
	_lmstudio_inputs = [lmstudio_host_input, lmstudio_port_spin, lmstudio_model_input]
	_lmstudio_visuals = [
		lmstudio_header_label,
		lmstudio_info_label,
		lmstudio_host_label,
		lmstudio_host_input,
		lmstudio_port_label,
		lmstudio_port_spin,
		lmstudio_model_label,
		lmstudio_model_input,
	]
	_ai_router_inputs = [ai_router_host_input, ai_router_port_spin, ai_router_api_key_input, ai_router_model_input, ai_router_format_option, ai_router_endpoint_input]
	_ai_router_visuals = [
		ai_router_header_label,
		ai_router_info_label,
		ai_router_host_label,
		ai_router_host_input,
		ai_router_port_label,
		ai_router_port_spin,
		ai_router_api_key_label,
		ai_router_api_key_input,
		ai_router_format_label,
		ai_router_format_option,
		ai_router_model_label,
		ai_router_model_input,
		ai_router_endpoint_label,
		ai_router_endpoint_input,
	]
func _set_provider_section_state(inputs: Array, visuals: Array, disabled_label: Label, is_active: bool) -> void:
	for control in inputs:
		if control is LineEdit:
			(control as LineEdit).editable = is_active
		elif control is TextEdit:
			(control as TextEdit).editable = is_active
		elif control is SpinBox:
			(control as SpinBox).editable = is_active
		elif control is OptionButton:
			(control as OptionButton).disabled = not is_active
		elif control is CheckBox:
			(control as CheckBox).disabled = not is_active
		if control is Control:
			var ctrl := control as Control
			ctrl.mouse_filter = Control.MOUSE_FILTER_STOP if is_active else Control.MOUSE_FILTER_IGNORE
			if not is_active and ctrl.is_inside_tree():
				ctrl.release_focus()
	for item in visuals:
		if item is CanvasItem:
			(item as CanvasItem).modulate = _ACTIVE_MODULATE if is_active else _INACTIVE_MODULATE
	if is_active:
		disabled_label.text = ""
		disabled_label.visible = false
	else:
		disabled_label.text = _tr("AI_SETTINGS_PROVIDER_DISABLED_MESSAGE")
		disabled_label.visible = true
func _get_provider_display_name(provider: int) -> String:
	match provider:
		AIManager.AIProvider.GEMINI:
			return "Google Gemini"
		AIManager.AIProvider.OPENROUTER:
			return "OpenRouter"
		AIManager.AIProvider.OLLAMA:
			return "Ollama (Local)"
		AIManager.AIProvider.OPENAI:
			return "OpenAI"
		AIManager.AIProvider.CLAUDE:
			return "Claude (Anthropic)"
		AIManager.AIProvider.LMSTUDIO:
			return "LMStudio (Local)"
		AIManager.AIProvider.AI_ROUTER:
			return "AI Router (Local Proxy)"
		AIManager.AIProvider.MOCK_MODE:
			return _tr("AI_SETTINGS_PROVIDER_MOCK_MODE")
	return _tr("AI_SETTINGS_PROVIDER_UNKNOWN")
func update_provider_ui() -> void:
	_configure_provider_widgets()
	var selected := provider_option.selected
	_set_provider_section_state(_gemini_inputs, _gemini_visuals, gemini_disabled_label, true)
	_set_provider_section_state(_openrouter_inputs, _openrouter_visuals, openrouter_disabled_label, true)
	_set_provider_section_state(_ollama_inputs, _ollama_visuals, ollama_disabled_label, true)
	if openai_disabled_label:
		_set_provider_section_state(_openai_inputs, _openai_visuals, openai_disabled_label, true)
	if claude_disabled_label:
		_set_provider_section_state(_claude_inputs, _claude_visuals, claude_disabled_label, true)
	if lmstudio_disabled_label:
		_set_provider_section_state(_lmstudio_inputs, _lmstudio_visuals, lmstudio_disabled_label, true)
	if ai_router_disabled_label:
		_set_provider_section_state(_ai_router_inputs, _ai_router_visuals, ai_router_disabled_label, true)
	gemini_disabled_label.visible = false
	openrouter_disabled_label.visible = false
	ollama_disabled_label.visible = false
	if openai_disabled_label:
		openai_disabled_label.visible = false
	if claude_disabled_label:
		claude_disabled_label.visible = false
	if lmstudio_disabled_label:
		lmstudio_disabled_label.visible = false
	if ai_router_disabled_label:
		ai_router_disabled_label.visible = false
	var provider_name := _get_provider_display_name(selected)
	if selected == AIManager.AIProvider.OLLAMA:
		provider_name = _decorate_ollama_provider_label(provider_name)
	provider_status_label.text = _tr("AI_SETTINGS_STATUS_CURRENT_PROVIDER") % [provider_name]
	_update_mock_mode_status()
func _update_mock_mode_status() -> void:
	if not _mock_mode_status_label:
		return
	var selected := provider_option.selected if provider_option else -1
	if selected == AIManager.AIProvider.MOCK_MODE:
		_mock_mode_status_label.text = _tr("AI_SETTINGS_MOCK_STATUS_ACTIVE")
		_mock_mode_status_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	else:
		var provider_name := _get_provider_display_name(selected)
		_mock_mode_status_label.text = _tr("AI_SETTINGS_MOCK_STATUS_INACTIVE") % [provider_name]
		_mock_mode_status_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
func _decorate_ollama_provider_label(base_label: String) -> String:
	var model_text := ollama_model_input.text.strip_edges()
	var fallback_port := _clamp_port(int(ollama_port_spin.value))
	var parsed := _parse_ollama_url(ollama_host_input.text, fallback_port)
	if not parsed.get("ok", false):
		ollama_disabled_label.visible = true
		ollama_disabled_label.text = parsed.get(
			"error",
			_tr("AI_SETTINGS_OLLAMA_SETUP_REQUIRED"),
		)
		return base_label + _tr("AI_SETTINGS_OLLAMA_SETUP_SUFFIX")
	var host_text := String(parsed.get("host", ""))
	var port_value := int(parsed.get("port", fallback_port))
	if host_text.is_empty() or model_text.is_empty() or port_value <= 0:
		ollama_disabled_label.visible = true
		ollama_disabled_label.text = _tr("AI_SETTINGS_OLLAMA_SETUP_REQUIRED")
		return base_label + _tr("AI_SETTINGS_OLLAMA_SETUP_SUFFIX")
	if not ai_manager:
		ollama_disabled_label.visible = false
		ollama_disabled_label.text = ""
		return base_label
	var is_ready: bool = ai_manager.is_ollama_ready()
	if is_ready:
		ollama_disabled_label.visible = false
		ollama_disabled_label.text = ""
		return base_label + _tr("AI_SETTINGS_OLLAMA_READY_SUFFIX")
	var host_display: String = ai_manager.ollama_host.strip_edges()
	if host_display.is_empty():
		host_display = host_text
	var port_display: int = ai_manager.ollama_port
	if port_display <= 0:
		port_display = port_value
	ollama_disabled_label.visible = true
	ollama_disabled_label.text = _tr("AI_SETTINGS_OLLAMA_OFFLINE_TEMPLATE") % [host_display, port_display]
	return base_label + _tr("AI_SETTINGS_OLLAMA_OFFLINE_SUFFIX")
func _update_ui_labels():
	if tab_container:
		tab_container.set_tab_title(0, _tr("AI_SETTINGS_ONLINE_PROVIDERS"))
		tab_container.set_tab_title(1, _tr("AI_SETTINGS_LOCAL_LLM"))
		tab_container.set_tab_title(2, _tr("AI_SETTINGS_SAFETY"))
		tab_container.set_tab_title(3, _tr("AI_SETTINGS_MEMORY"))
		tab_container.set_tab_title(4, _tr("AI_SETTINGS_BEHAVIOR"))
		tab_container.set_tab_title(5, _tr("AI_SETTINGS_METRICS"))
		tab_container.set_tab_title(6, _tr("AI_SETTINGS_TAB_MOCK_MODE"))
	if safety_level_label: safety_level_label.text = _tr("AI_SETTINGS_SAFETY_FILTER_LABEL")
	if safety_hint_label: safety_hint_label.text = _tr("AI_SETTINGS_SAFETY_FILTER_HINT")
	if safety_level_option:
		safety_level_option.set_item_text(0, _tr("AI_SETTINGS_SAFETY_GAME_MODE"))
		safety_level_option.set_item_text(1, _tr("AI_SETTINGS_SAFETY_LOW_BLOCKING"))
		safety_level_option.set_item_text(2, _tr("AI_SETTINGS_SAFETY_STANDARD"))
		safety_level_option.set_item_text(3, _tr("AI_SETTINGS_SAFETY_STRICT"))
	ollama_header_label.text = "Configure Ollama"
	ollama_info_label.text = "Provide the local Ollama service URL and model tag. Default URL: http://127.0.0.1:11434"
	ollama_host_label.text = "Ollama URL:"
	ollama_port_label.text = "Ollama Port:"
	ollama_model_label.text = "Ollama Model Tag:"
	ollama_use_chat_check.text = "Use /api/chat streaming endpoint"
	if ollama_host_input:
		ollama_host_input.placeholder_text = DEFAULT_OLLAMA_URL
	ollama_hint_label.text = "Edit advanced sampling options in the JSON block below (temperature, top_p, num_predict, context, etc.)."
	ollama_options_label.text = "Ollama Options (JSON):"
	memory_settings_label.text = _tr("AI_SETTINGS_MEMORY_SETTINGS")
	memory_hint_label.text = _tr("AI_SETTINGS_MEMORY_HINT")
	memory_limit_label.text = _tr("AI_SETTINGS_MEMORY_LIMIT")
	memory_summary_label.text = _tr("AI_SETTINGS_MEMORY_SUMMARY_THRESHOLD")
	memory_full_label.text = _tr("AI_SETTINGS_MEMORY_FULL_RETENTION")
	context_layers_label.text = _tr("AI_SETTINGS_CONTEXT_LAYERS")
	long_term_header.text = _tr("AI_SETTINGS_LONG_TERM_SUMMARIES")
	notes_header.text = _tr("AI_SETTINGS_TRACKED_NOTES")
	if provider_label: provider_label.text = _tr("AI_SETTINGS_PROVIDER_LABEL")
	gemini_label.text = _tr("AI_SETTINGS_GEMINI_KEY_LABEL")
	gemini_hint_label.text = _tr("AI_SETTINGS_GEMINI_KEY_HINT")
	gemini_model_label.text = _tr("AI_SETTINGS_GEMINI_MODEL_LABEL")
	openrouter_label.text = _tr("AI_SETTINGS_OPENROUTER_KEY_LABEL")
	openrouter_hint_label.text = _tr("AI_SETTINGS_OPENROUTER_KEY_HINT")
	openrouter_model_label.text = _tr("AI_SETTINGS_OPENROUTER_MODEL_LABEL")
	test_button.text = _tr("AI_SETTINGS_BUTTON_TEST_CONNECTION")
	save_button.text = _tr("AI_SETTINGS_BUTTON_SAVE")
	back_button.text = _tr("AI_SETTINGS_BUTTON_BACK")
	home_button.text = _tr("AI_SETTINGS_BUTTON_HOME")
	memory_limit_spin.suffix = _tr("AI_SETTINGS_MEMORY_SUFFIX")
	memory_summary_spin.suffix = _tr("AI_SETTINGS_MEMORY_SUFFIX")
	memory_full_spin.suffix = _tr("AI_SETTINGS_MEMORY_SUFFIX")
	metrics_label.text = tr("METRICS_CURRENT_SESSION")
	last_response_time_label.text = _tr("AI_SETTINGS_LAST_RESPONSE_TIME")
	total_api_calls_label.text = tr("METRICS_SESSION_API_CALLS")
	total_tokens_used_label.text = tr("METRICS_SESSION_TOKENS")
	last_input_tokens_label.text = _tr("AI_SETTINGS_LAST_INPUT_TOKENS")
	last_output_tokens_label.text = _tr("AI_SETTINGS_LAST_OUTPUT_TOKENS")
	ai_tone_style_label.text = _tr("AI_SETTINGS_AI_TONE_STYLE")
	ai_tone_style_input.placeholder_text = _tr("AI_SETTINGS_AI_TONE_PLACEHOLDER")
	_refresh_context_layers()
func _update_metrics_display():
	if ai_manager:
		var metrics = ai_manager.get_ai_metrics()
		var last_metrics = ai_manager.get_prompt_metrics()
		last_response_time_label.text = ("%s %.2f s" % [tr("Last Response Time:"), metrics.get("last_response_time", 0.0)])
		total_api_calls_label.text = ("%s %d" % [tr("Total API Calls:"), metrics.get("total_requests", 0)])
		total_tokens_used_label.text = ("%s %d" % [tr("Total Tokens Used:"), metrics.get("total_tokens", 0)])
		var input_tokens = int(metrics.get("last_input_tokens", 0))
		var output_tokens = int(metrics.get("last_output_tokens", 0))
		var tps = float(last_metrics.get("tps", 0.0))
		last_input_tokens_label.text = ("%s %d" % [tr("Last Input Tokens:"), input_tokens])
		last_output_tokens_label.text = ("%s %d" % [tr("Last Output Tokens:"), output_tokens])
		if tps > 0:
			last_output_tokens_label.text += " (%.1f T/s)" % tps
		_update_cumulative_stats_display(metrics)
	if ai_metrics_chart:
		ai_metrics_chart.set_data(ai_manager.get_response_time_history(), ai_manager.get_token_usage_history())
	if max_tokens_label and max_tokens_spin:
		if current_language == "en":
			max_tokens_label.text = "Max AI Reply Tokens (Per Request):"
			max_tokens_spin.suffix = " tokens"
			if max_tokens_hint_label:
				max_tokens_hint_label.text = "Limits one AI response length (output only). Not full-playthrough total, and not input token limit."
		else:
			max_tokens_label.text = "Max Tokens:"
			max_tokens_spin.suffix = " token"
			if max_tokens_hint_label:
				max_tokens_hint_label.text = "Per-request AI output limit; not total game tokens and not input limit."
	if gemini_model_input and current_language == "en":
		gemini_model_input.placeholder_text = "Enter custom model name when Custom is selected"
	_refresh_context_layers()
func _update_cumulative_stats_display(metrics: Dictionary) -> void:
	if not cumulative_header_label:
		return
	var cumulative_calls := int(metrics.get("cumulative_api_calls", 0))
	var cumulative_tokens := int(metrics.get("cumulative_tokens", 0))
	var cumulative_input := int(metrics.get("cumulative_input_tokens", 0))
	var cumulative_output := int(metrics.get("cumulative_output_tokens", 0))
	var avg_response := float(metrics.get("average_response_time", 0.0))
	var first_request := str(metrics.get("first_request_timestamp", ""))
	cumulative_header_label.text = tr("METRICS_CUMULATIVE_HEADER")
	cumulative_api_calls_label.text = "%s %d" % [tr("METRICS_CUMULATIVE_API_CALLS"), cumulative_calls]
	cumulative_tokens_label.text = "%s %d (In: %d / Out: %d)" % [tr("METRICS_CUMULATIVE_TOKENS"), cumulative_tokens, cumulative_input, cumulative_output]
	cumulative_avg_response_label.text = "%s %.2f s" % [tr("METRICS_AVG_RESPONSE_TIME"), avg_response]
	if first_request.is_empty():
		cumulative_first_request_label.text = tr("METRICS_FIRST_REQUEST_NA")
	else:
		cumulative_first_request_label.text = "%s %s" % [tr("METRICS_FIRST_REQUEST"), first_request]
func _refresh_context_layers():
	var language = current_language
	var summary_count = 0
	var notes_count = 0
	var summary_lines: Array = []
	var note_lines: Array = []
	if ai_manager:
		summary_count = ai_manager.get_long_term_summary_count()
		notes_count = ai_manager.get_note_count()
		summary_lines = ai_manager.get_long_term_lines(language, 12)
		note_lines = ai_manager.get_notes_lines(language, 12)
	long_term_header.text = _tr("AI_SETTINGS_LONG_TERM_SUMMARIES_COUNT") % summary_count
	notes_header.text = _tr("AI_SETTINGS_TRACKED_NOTES_COUNT") % notes_count
	if summary_lines.is_empty():
		long_term_text.text = "[i]%s[/i]" % (_tr("AI_SETTINGS_NO_SUMMARIES_CAPTURED_YET"))
	else:
		var builder := ""
		for i in range(summary_lines.size()):
			builder += "%d. %s\n" % [i + 1, summary_lines[i]]
		long_term_text.text = builder.strip_edges()
	if note_lines.is_empty():
		notes_text.text = "[i]%s[/i]" % (_tr("AI_SETTINGS_NO_NOTES_RECORDED"))
	else:
		var note_builder := ""
		for line in note_lines:
			note_builder += "- %s\n" % line
		notes_text.text = note_builder.strip_edges()
	update_provider_ui()
func load_current_settings():
	if not ai_manager:
		return
	provider_option.selected = ai_manager.current_provider
	gemini_key_input.text = ai_manager.gemini_api_key
	openrouter_key_input.text = ai_manager.openrouter_api_key
	var gemini_display = [
		"★ gemini-3.1-flash-lite-preview",
		"gemini-3.1-pro-preview",
		"gemini-3-flash-preview",
		"gemini-2.5-flash-native-audio-preview-12-2025",
	]
	var gemini_values = [
		"gemini-3.1-flash-lite-preview",
		"gemini-3.1-pro-preview",
		"gemini-3-flash-preview",
		"gemini-2.5-flash-native-audio-preview-12-2025",
	]
	var option = gemini_model_option
	if option:
		option.clear()
		for model_name in GEMINI_MODEL_OPTIONS:
			option.add_item(model_name)
		option.add_item("Custom")
	_sync_gemini_model_selection(ai_manager.gemini_model)
	if max_tokens_spin:
		max_tokens_spin.value = ai_manager.max_tokens
	if safety_level_option:
		var current_safety = ai_manager.gemini_safety_settings
		match current_safety:
			"BLOCK_NONE": safety_level_option.selected = 0
			"BLOCK_ONLY_HIGH": safety_level_option.selected = 1
			"BLOCK_MEDIUM_AND_ABOVE": safety_level_option.selected = 2
			"BLOCK_LOW_AND_ABOVE": safety_level_option.selected = 3
			_: safety_level_option.selected = 0
	openrouter_model_input.text = ai_manager.openrouter_model
	_sync_openrouter_model_selection(ai_manager.openrouter_model)
	if openrouter_auto_router_check:
		openrouter_auto_router_check.button_pressed = ai_manager.openrouter_use_auto_router
	var parsed_url := _parse_ollama_url(ai_manager.ollama_host, ai_manager.ollama_port)
	if parsed_url.get("ok", false):
		ollama_host_input.text = String(parsed_url.get("url", DEFAULT_OLLAMA_URL))
		ollama_port_spin.value = int(parsed_url.get("port", ai_manager.ollama_port))
	else:
		ollama_host_input.text = _build_ollama_url(ai_manager.ollama_host, ai_manager.ollama_port)
		ollama_port_spin.value = ai_manager.ollama_port
	ollama_model_input.text = ai_manager.ollama_model
	ollama_use_chat_check.button_pressed = ai_manager.ollama_use_chat
	var options_json := JSON.stringify(ai_manager.ollama_options, "  ")
	ollama_options_input.text = options_json
	if openai_key_input:
		openai_key_input.text = ai_manager.openai_api_key
	if openai_model_input:
		openai_model_input.text = ai_manager.openai_model
	if claude_key_input:
		claude_key_input.text = ai_manager.claude_api_key
	if claude_model_input:
		claude_model_input.text = ai_manager.claude_model
	if lmstudio_host_input:
		lmstudio_host_input.text = ai_manager.lmstudio_host
	if lmstudio_port_spin:
		lmstudio_port_spin.value = ai_manager.lmstudio_port
	if lmstudio_model_input:
		lmstudio_model_input.text = ai_manager.lmstudio_model
	if ai_router_host_input:
		ai_router_host_input.text = ai_manager.ai_router_host
	if ai_router_port_spin:
		ai_router_port_spin.value = ai_manager.ai_router_port
	if ai_router_api_key_input:
		ai_router_api_key_input.text = ai_manager.ai_router_api_key
	if ai_router_model_input:
		ai_router_model_input.text = ai_manager.ai_router_model
	if ai_router_format_option:
		ai_router_format_option.selected = ai_manager.ai_router_api_format
	if ai_router_endpoint_input:
		ai_router_endpoint_input.text = ai_manager.ai_router_custom_endpoint
	ai_tone_style_input.text = ai_manager.custom_ai_tone_style
	if ai_manager.memory_store:
		memory_limit_spin.value = ai_manager.memory_store.max_memory_items
		memory_summary_spin.value = ai_manager.memory_store.memory_summary_threshold
		memory_full_spin.value = ai_manager.memory_store.memory_full_entries
	else:
		memory_limit_spin.value = memory_limit_spin.min_value
		memory_summary_spin.value = memory_summary_spin.min_value
		memory_full_spin.value = memory_full_spin.min_value
	_sync_memory_spinners()
	update_provider_ui()
func _on_provider_changed(index: int):
	update_provider_ui()
	_update_mock_mode_status()
	if ai_manager:
		ai_manager.current_provider = index
		update_status(_tr("AI_SETTINGS_STATUS_PROVIDER_CHANGED"))
func _on_test_button_pressed():
	if not ai_manager:
		update_status(_tr("AI_SETTINGS_ERROR_MANAGER_NOT_FOUND"), true)
		return
	if not save_ui_to_manager():
		return
	var use_mock := false
	var status_message := ""
	var provider_name := _get_provider_display_name(ai_manager.current_provider)
	var validation_error := ""
	match ai_manager.current_provider:
		AIManager.AIProvider.GEMINI:
			var api_key: String = str(ai_manager.gemini_api_key).strip_edges()
			var model: String = str(ai_manager.gemini_model).strip_edges()
			if api_key.is_empty():
				validation_error = _tr("AI_SETTINGS_VALIDATION_GEMINI_MISSING_KEY")
				use_mock = true
			elif api_key.begins_with("http"):
				validation_error = _tr("AI_SETTINGS_VALIDATION_GEMINI_INVALID_KEY")
				use_mock = true
			else:
				if model.is_empty():
					validation_error = _tr("AI_SETTINGS_VALIDATION_GEMINI_MISSING_MODEL")
					use_mock = true
				else:
					status_message = _tr("AI_SETTINGS_STATUS_TESTING_GEMINI") % [model]
		AIManager.AIProvider.OPENROUTER:
			var api_key: String = str(ai_manager.openrouter_api_key).strip_edges()
			var model: String = str(ai_manager.openrouter_model).strip_edges()
			if api_key.is_empty():
				validation_error = _tr("AI_SETTINGS_VALIDATION_OPENROUTER_MISSING_KEY")
				use_mock = true
			else:
				if model.is_empty():
					validation_error = _tr("AI_SETTINGS_VALIDATION_OPENROUTER_MISSING_MODEL")
					use_mock = true
				else:
					status_message = _tr("AI_SETTINGS_STATUS_TESTING_OPENROUTER") % [model]
		AIManager.AIProvider.OLLAMA:
			var host: String = str(ai_manager.ollama_host).strip_edges()
			var port: int = int(ai_manager.ollama_port)
			var model: String = str(ai_manager.ollama_model).strip_edges()
			if host.is_empty():
				validation_error = _tr("AI_SETTINGS_VALIDATION_OLLAMA_MISSING_HOST")
				use_mock = true
			elif model.is_empty():
				validation_error = _tr("AI_SETTINGS_VALIDATION_OLLAMA_MISSING_MODEL")
				use_mock = true
			else:
				status_message = _tr("AI_SETTINGS_STATUS_CHECKING_OLLAMA") % [host, port]
				update_status(status_message, false)
				if not OllamaClient.health_check(2.0, true):
					validation_error = _tr("AI_SETTINGS_VALIDATION_OLLAMA_UNREACHABLE") % [host, port]
					use_mock = true
				else:
					var tags_result: Dictionary = OllamaClient.fetch_tags(3.0, true)
					if not tags_result.get("ok", false):
						var tags_error: String = str(tags_result.get("error", "Unable to query models."))
						validation_error = _tr("AI_SETTINGS_VALIDATION_OLLAMA_LIST_MODELS_FAILED") % [tags_error]
						use_mock = true
					else:
						var models: Array = tags_result.get("models", [])
						var model_found := false
						var available_models: Array = []
						for entry in models:
							var model_name: String = ""
							if entry is Dictionary:
								model_name = str(entry.get("name", entry.get("model", ""))).strip_edges()
							else:
								model_name = str(entry).strip_edges()
							available_models.append(model_name)
							if model_name == model:
								model_found = true
						if not model_found:
							var models_list: String = ", ".join(available_models.slice(0, 5))
							if available_models.size() > 5:
								models_list += "..."
							validation_error = _tr("AI_SETTINGS_VALIDATION_OLLAMA_MODEL_NOT_FOUND") % [model, models_list, model]
							use_mock = true
						else:
							status_message = _tr("AI_SETTINGS_STATUS_TESTING_OLLAMA") % [host, port, model]
		AIManager.AIProvider.OPENAI:
			var api_key: String = str(ai_manager.openai_api_key).strip_edges()
			var model: String = str(ai_manager.openai_model).strip_edges()
			if api_key.is_empty():
				validation_error = _tr("AI_SETTINGS_VALIDATION_OPENAI_MISSING_KEY")
				use_mock = true
			elif not api_key.begins_with("sk-"):
				validation_error = _tr("AI_SETTINGS_VALIDATION_OPENAI_INVALID_KEY")
				use_mock = true
			else:
				if model.is_empty():
					model = "gpt-5.2"
				status_message = _tr("AI_SETTINGS_STATUS_TESTING_OPENAI") % [model]
		AIManager.AIProvider.CLAUDE:
			var api_key: String = str(ai_manager.claude_api_key).strip_edges()
			var model: String = str(ai_manager.claude_model).strip_edges()
			if api_key.is_empty():
				validation_error = _tr("AI_SETTINGS_VALIDATION_CLAUDE_MISSING_KEY")
				use_mock = true
			elif not api_key.begins_with("sk-ant-"):
				validation_error = _tr("AI_SETTINGS_VALIDATION_CLAUDE_INVALID_KEY")
				use_mock = true
			else:
				if model.is_empty():
					model = "claude-sonnet-4-5-20250929"
				status_message = _tr("AI_SETTINGS_STATUS_TESTING_CLAUDE") % [model]
		AIManager.AIProvider.LMSTUDIO:
			var host: String = str(ai_manager.lmstudio_host).strip_edges()
			var port: int = int(ai_manager.lmstudio_port)
			var model: String = str(ai_manager.lmstudio_model).strip_edges()
			var model_label: String = model
			if host.is_empty():
				host = "127.0.0.1"
			if model_label.is_empty():
				model_label = _tr("AI_SETTINGS_AUTO_DETECT")
			status_message = _tr("AI_SETTINGS_STATUS_TESTING_LMSTUDIO") % [host, port, model_label]
			var test_url: String = "http://%s:%d/v1/models" % [host, port]
			status_message += _tr("AI_SETTINGS_STATUS_CHECKING_URL") % [test_url]
		AIManager.AIProvider.AI_ROUTER:
			var host: String = str(ai_manager.ai_router_host).strip_edges()
			var port: int = int(ai_manager.ai_router_port)
			var model: String = str(ai_manager.ai_router_model).strip_edges()
			var api_format: int = int(ai_manager.ai_router_api_format)
			var format_name: String = "OpenAI"
			match api_format:
				1: format_name = "Claude"
				2: format_name = "Gemini"
			if host.is_empty():
				validation_error = _tr("AI_SETTINGS_VALIDATION_ROUTER_MISSING_HOST")
				use_mock = true
			elif model.is_empty():
				validation_error = _tr("AI_SETTINGS_VALIDATION_ROUTER_MISSING_MODEL")
				use_mock = true
			else:
				status_message = _tr("AI_SETTINGS_STATUS_TESTING_ROUTER") % [host, port, model, format_name]
		AIManager.AIProvider.MOCK_MODE:
			status_message = _tr("AI_SETTINGS_STATUS_TESTING_MOCK")
			use_mock = true
		_:
			validation_error = _tr("AI_SETTINGS_VALIDATION_UNKNOWN_PROVIDER")
			use_mock = true
	if not validation_error.is_empty():
		update_status(_tr("AI_SETTINGS_STATUS_CONFIG_ISSUE") + validation_error, true)
		if not use_mock:
			return
		status_message = _tr("AI_SETTINGS_STATUS_FALLBACK_TO_MOCK")
	update_status(status_message if not status_message.is_empty() else _tr("AI_SETTINGS_STATUS_TESTING_CONNECTION"), false)
	if test_button:
		test_button.disabled = true
		test_button.text = _tr("AI_SETTINGS_BUTTON_TESTING")
	var test_prompt = _tr("AI_SETTINGS_TEST_PROMPT")
	ai_manager.generate_story(test_prompt, { "purpose": "test", "force_mock": use_mock })
func _on_ai_test_success(response):
	if test_button:
		test_button.disabled = false
		test_button.text = _tr("AI_SETTINGS_BUTTON_TEST_CONNECTION")
	var display_text = ""
	var provider_name := _get_provider_display_name(ai_manager.current_provider) if ai_manager else _tr("AI_SETTINGS_PROVIDER_UNKNOWN")
	if typeof(response) == TYPE_DICTIONARY:
		if response.has("content"):
			display_text = str(response["content"])
		elif response.has("error"):
			var error_text: String = str(response.get("error", ""))
			update_status(_tr("AI_SETTINGS_STATUS_PROVIDER_ERROR") % [provider_name, error_text], true)
			return
	elif typeof(response) == TYPE_STRING:
		display_text = response
	if display_text.length() > 100:
		display_text = display_text.substr(0, 100) + "..."
	update_status(
		_tr("AI_SETTINGS_STATUS_TEST_SUCCESS") % [provider_name, display_text],
		false,
	)
	_debug_log("[AI Settings] Test Response from %s: %s" % [provider_name, display_text])
func _on_ai_test_error(error_message: String):
	if test_button:
		test_button.disabled = false
		test_button.text = _tr("AI_SETTINGS_BUTTON_TEST_CONNECTION")
	var provider_name := _get_provider_display_name(ai_manager.current_provider) if ai_manager else _tr("AI_SETTINGS_PROVIDER_UNKNOWN")
	var helpful_message := error_message
	var error_lower := error_message.to_lower()
	if "401" in error_message or "unauthorized" in error_lower or "invalid api key" in error_lower:
		helpful_message = _tr("AI_SETTINGS_ERROR_AUTH_FAILED")
	elif "403" in error_message or "forbidden" in error_lower:
		helpful_message = _tr("AI_SETTINGS_ERROR_FORBIDDEN")
	elif "404" in error_message or "not found" in error_lower:
		helpful_message = _tr("AI_SETTINGS_ERROR_NOT_FOUND")
	elif "429" in error_message or "rate limit" in error_lower or "too many" in error_lower:
		helpful_message = _tr("AI_SETTINGS_ERROR_RATE_LIMIT")
	elif "500" in error_message or "internal server" in error_lower:
		helpful_message = _tr("AI_SETTINGS_ERROR_SERVER")
	elif "502" in error_message or "bad gateway" in error_lower:
		helpful_message = _tr("AI_SETTINGS_ERROR_BAD_GATEWAY")
	elif "503" in error_message or "service unavailable" in error_lower:
		helpful_message = _tr("AI_SETTINGS_ERROR_SERVICE_UNAVAILABLE")
	elif "timeout" in error_lower or "timed out" in error_lower:
		helpful_message = _tr("AI_SETTINGS_ERROR_TIMEOUT")
	elif "connection refused" in error_lower or "econnrefused" in error_lower:
		helpful_message = _tr("AI_SETTINGS_ERROR_CONNECTION_REFUSED")
	elif "network" in error_lower or "dns" in error_lower or "resolve" in error_lower:
		helpful_message = _tr("AI_SETTINGS_ERROR_NETWORK")
	update_status(_tr("AI_SETTINGS_STATUS_PROVIDER_ERROR") % [provider_name, helpful_message], true)
func _on_ai_request_progress(update: Dictionary) -> void:
	if not ai_manager:
		return
	var provider: int = int(update.get("provider", ai_manager.current_provider))
	var provider_name := _get_provider_display_name(provider)
	var status: String = str(update.get("status", ""))
	var elapsed: float = float(update.get("elapsed_sec", 0.0))
	var tokens: int = 0
	if update.has("partial_tokens"):
		tokens = int(update["partial_tokens"])
	elif update.has("response_tokens"):
		tokens = int(update["response_tokens"])
	var is_error := false
	var message := ""
	if provider == AIManager.AIProvider.OLLAMA:
		var model: String = str(update.get("model", ai_manager.ollama_model))
		var host: String = str(update.get("host", ai_manager.ollama_host))
		var port: int = int(update.get("port", ai_manager.ollama_port))
		match status:
			"queued":
				message = _tr("AI_SETTINGS_PROGRESS_OLLAMA_QUEUED") % [model, host, port]
			"started":
				message = _tr("AI_SETTINGS_PROGRESS_OLLAMA_STARTED") % [host, port]
			"stream":
				message = _tr("AI_SETTINGS_PROGRESS_OLLAMA_STREAM") % [tokens, elapsed]
				var chunk_preview: String = str(update.get("last_chunk", "")).strip_edges()
				if chunk_preview.length() > 0:
					if chunk_preview.length() > 50:
						chunk_preview = chunk_preview.substr(0, 50) + "..."
					message += "\n\"%s\"" % chunk_preview
			"timeout":
				var attempt := int(update.get("attempt", 1))
				message = _tr("AI_SETTINGS_PROGRESS_OLLAMA_TIMEOUT") % [elapsed, attempt]
				is_error = true
			"error":
				var reason: String = str(update.get("reason", _tr("AI_SETTINGS_UNKNOWN_ERROR")))
				message = _tr("AI_SETTINGS_PROGRESS_OLLAMA_ERROR") % [reason]
				is_error = true
			"completed":
				message = _tr("AI_SETTINGS_PROGRESS_OLLAMA_COMPLETED") % [elapsed, tokens]
			_:
				return
	else:
		match status:
			"queued", "started":
				message = _tr("AI_SETTINGS_PROGRESS_GENERIC_SENDING") % [provider_name]
			"stream":
				message = _tr("AI_SETTINGS_PROGRESS_GENERIC_STREAM") % [provider_name, tokens, elapsed]
			"timeout":
				var attempt := int(update.get("attempt", 1))
				message = _tr("AI_SETTINGS_PROGRESS_GENERIC_TIMEOUT") % [provider_name, elapsed, attempt]
				is_error = true
			"error":
				var reason: String = str(update.get("reason", _tr("AI_SETTINGS_UNKNOWN_ERROR")))
				message = _tr("AI_SETTINGS_PROGRESS_GENERIC_ERROR") % [provider_name, reason]
				is_error = true
			"completed":
				message = _tr("AI_SETTINGS_PROGRESS_GENERIC_COMPLETED") % [provider_name, elapsed]
			_:
				return
	update_status(message, is_error)
func _on_save_button_pressed():
	if not ai_manager:
		update_status(_tr("AI_SETTINGS_ERROR_MANAGER_NOT_FOUND_SHORT"), true, true)
		return
	if not save_ui_to_manager():
		return
	if ai_manager.has_method("_sync_gemini_provider"):
		ai_manager._sync_gemini_provider()
	if ai_manager.has_method("_sync_openrouter_provider"):
		ai_manager._sync_openrouter_provider()
	if ai_manager.has_method("_sync_ollama_provider"):
		ai_manager._sync_ollama_provider()
	ai_manager.save_ai_settings()
	update_status(_tr("AI_SETTINGS_STATUS_SETTINGS_SAVED"), false, true)
	await get_tree().create_timer(1.0).timeout
	_on_back_button_pressed()
func save_ui_to_manager() -> bool:
	if not ai_manager:
		update_status(_tr("AI_SETTINGS_ERROR_MANAGER_NOT_FOUND_SHORT"), true, true)
		return false
	_sync_memory_spinners()
	ai_manager.current_provider = provider_option.selected
	if max_tokens_spin:
		if ai_manager.has_method("set_max_tokens"):
			ai_manager.set_max_tokens(int(max_tokens_spin.value))
		else:
			ai_manager.max_tokens = int(max_tokens_spin.value)
	var gemini_key_value := gemini_key_input.text.strip_edges()
	if not gemini_key_value.is_empty():
		if gemini_key_value.begins_with("http://") or gemini_key_value.begins_with("https://"):
			update_status(
				_tr("AI_SETTINGS_VALIDATION_GEMINI_URL"),
				true,
				true,
			)
			return false
	ai_manager.gemini_api_key = gemini_key_value
	var gemini_values = [
		"gemini-3.1-flash-lite-preview",
		"gemini-3.1-pro-preview",
		"gemini-3-flash-preview",
		"gemini-2.5-flash-native-audio-preview-12-2025",
	]
	var gemini_selected = gemini_model_option.selected
	if gemini_selected >= 0 and gemini_selected < gemini_values.size():
		ai_manager.gemini_model = gemini_values[gemini_selected]
	elif gemini_model_input:
		var custom_gemini_model := gemini_model_input.text.strip_edges()
		if not custom_gemini_model.is_empty():
			ai_manager.gemini_model = custom_gemini_model
	if safety_level_option:
		match safety_level_option.selected:
			0: ai_manager.gemini_safety_settings = "BLOCK_NONE"
			1: ai_manager.gemini_safety_settings = "BLOCK_ONLY_HIGH"
			2: ai_manager.gemini_safety_settings = "BLOCK_MEDIUM_AND_ABOVE"
			3: ai_manager.gemini_safety_settings = "BLOCK_LOW_AND_ABOVE"
			_: ai_manager.gemini_safety_settings = "BLOCK_NONE"
	ai_manager.openrouter_api_key = openrouter_key_input.text
	var openrouter_selected := openrouter_model_option.selected if openrouter_model_option else -1
	if openrouter_selected >= 0 and openrouter_selected < OPENROUTER_MODEL_OPTIONS.size():
		ai_manager.openrouter_model = OPENROUTER_MODEL_OPTIONS[openrouter_selected]
	else:
		ai_manager.openrouter_model = openrouter_model_input.text.strip_edges()
	if openrouter_auto_router_check:
		ai_manager.openrouter_use_auto_router = openrouter_auto_router_check.button_pressed
	var fallback_port := _clamp_port(int(ollama_port_spin.value))
	var parsed_url := _parse_ollama_url(ollama_host_input.text, fallback_port)
	if not parsed_url.get("ok", false):
		update_status(str(parsed_url.get("error", _tr("AI_SETTINGS_VALIDATION_OLLAMA_URL_INVALID"))), true, true)
		return false
	var host_text := String(parsed_url.get("host", "127.0.0.1"))
	var scheme := String(parsed_url.get("scheme", "http"))
	var use_port := fallback_port
	if parsed_url.get("explicit_port", false):
		use_port = int(parsed_url.get("port", fallback_port))
	var normalized_url := _build_ollama_url(host_text, use_port, scheme)
	ollama_host_input.text = normalized_url
	ollama_port_spin.value = use_port
	ai_manager.ollama_host = host_text
	ai_manager.ollama_port = use_port
	var model_text := ollama_model_input.text.strip_edges()
	if model_text.is_empty():
		model_text = ai_manager.ollama_model
		ollama_model_input.text = model_text
	ai_manager.ollama_model = model_text
	var options_text := ollama_options_input.text.strip_edges()
	if not options_text.is_empty():
		var json := JSON.new()
		var parse_err := json.parse(options_text)
		if parse_err != OK:
			update_status(
				_tr("AI_SETTINGS_VALIDATION_OLLAMA_JSON_INVALID") % [parse_err],
				true,
				true,
			)
			return false
		if not (json.data is Dictionary):
			update_status(_tr("AI_SETTINGS_VALIDATION_OLLAMA_JSON_OBJECT"), true, true)
			return false
		ai_manager.ollama_options = (json.data as Dictionary).duplicate(true)
	ai_manager.ollama_use_chat = ollama_use_chat_check.button_pressed
	if ai_manager.has_method("_apply_ollama_configuration"):
		ai_manager._apply_ollama_configuration()
	if openai_key_input:
		ai_manager.openai_api_key = openai_key_input.text.strip_edges()
	if openai_model_input:
		ai_manager.openai_model = openai_model_input.text.strip_edges()
	if claude_key_input:
		ai_manager.claude_api_key = claude_key_input.text.strip_edges()
	if claude_model_input:
		ai_manager.claude_model = claude_model_input.text.strip_edges()
	if lmstudio_host_input:
		ai_manager.lmstudio_host = lmstudio_host_input.text.strip_edges()
	if lmstudio_port_spin:
		ai_manager.lmstudio_port = int(lmstudio_port_spin.value)
	if lmstudio_model_input:
		ai_manager.lmstudio_model = lmstudio_model_input.text.strip_edges()
	if ai_router_host_input:
		ai_manager.ai_router_host = ai_router_host_input.text.strip_edges()
	if ai_router_port_spin:
		ai_manager.ai_router_port = int(ai_router_port_spin.value)
	if ai_router_api_key_input:
		ai_manager.ai_router_api_key = ai_router_api_key_input.text.strip_edges()
	if ai_router_model_input:
		ai_manager.ai_router_model = ai_router_model_input.text.strip_edges()
	if ai_router_format_option:
		ai_manager.ai_router_api_format = ai_router_format_option.selected
	if ai_router_endpoint_input:
		ai_manager.ai_router_custom_endpoint = ai_router_endpoint_input.text.strip_edges()
	ai_manager.custom_ai_tone_style = ai_tone_style_input.text
	if ai_manager.memory_store:
		ai_manager.memory_store.max_memory_items = int(memory_limit_spin.value)
		ai_manager.memory_store.memory_summary_threshold = int(memory_summary_spin.value)
		ai_manager.memory_store.memory_full_entries = int(memory_full_spin.value)
		ai_manager.apply_memory_settings()
	update_provider_ui()
	return true
func _on_back_button_pressed():
	var tree := get_tree()
	if not tree:
		return
	if _overlay_mode:
		close_requested.emit()
		queue_free()
		return
	tree.paused = false
	tree.change_scene_to_file("res://1.Codebase/src/scenes/ui/settings_menu.tscn")
func _on_home_button_pressed():
	var tree := get_tree()
	if not tree:
		return
	tree.paused = false
	tree.change_scene_to_file("res://1.Codebase/menu_main.tscn")
func _on_openrouter_auto_router_link_clicked(_meta: Variant) -> void:
	OS.shell_open("https://openrouter.ai/docs/features/auto-router")
func update_status(message: String, is_error: bool = false, emit_notification: bool = false):
	if not status_label:
		return
	if not status_label.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART:
		status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var line_count := message.count("\n") + 1
	if line_count > 1:
		status_label.custom_minimum_size.y = max(60, line_count * 20)
	else:
		status_label.custom_minimum_size.y = 0
	status_label.text = message
	if is_error:
		if message.begins_with(""):
			status_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
		else:
			status_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	else:
		if message.begins_with("✓"):
			status_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
		else:
			status_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	if emit_notification:
		_show_notification(message, is_error)
func _show_notification(message: String, is_error: bool) -> void:
	var notifier = ServiceLocator.get_notification_system() if ServiceLocator else null
	if notifier == null:
		return
	if is_error:
		notifier.show_error(message)
	else:
		notifier.show_success(message)
func _sync_memory_spinners() -> void:
	memory_limit_spin.step = 10
	memory_summary_spin.max_value = memory_limit_spin.value
	memory_full_spin.max_value = memory_limit_spin.value
	if memory_full_spin.value > memory_limit_spin.value:
		memory_full_spin.value = memory_limit_spin.value
	if memory_summary_spin.value > memory_limit_spin.value:
		memory_summary_spin.value = memory_limit_spin.value
	if memory_summary_spin.value < memory_full_spin.value:
		memory_summary_spin.value = memory_full_spin.value
	memory_summary_spin.min_value = memory_full_spin.value
func _on_memory_limit_value_changed(_value: float) -> void:
	_sync_memory_spinners()
func _on_memory_full_value_changed(value: float) -> void:
	if memory_summary_spin.value < value:
		memory_summary_spin.value = value
	_sync_memory_spinners()
func _sync_gemini_model_selection(model: String) -> void:
	if not gemini_model_option:
		return
	var model_lower := model.strip_edges().to_lower()
	var found_index := -1
	for i in range(GEMINI_MODEL_OPTIONS.size()):
		if GEMINI_MODEL_OPTIONS[i].to_lower() == model_lower:
			found_index = i
			break
	if found_index >= 0:
		gemini_model_option.selected = found_index
		if gemini_model_input:
			gemini_model_input.text = GEMINI_MODEL_OPTIONS[found_index]
			gemini_model_input.editable = false
			gemini_model_input.modulate = Color(0.7, 0.7, 0.7, 1)
	else:
		gemini_model_option.selected = GEMINI_MODEL_OPTIONS.size()
		if gemini_model_input:
			gemini_model_input.text = model
			gemini_model_input.editable = true
			gemini_model_input.modulate = Color(1, 1, 1, 1)
func _on_gemini_model_option_changed(index: int) -> void:
	if not gemini_model_input:
		return
	if index < GEMINI_MODEL_OPTIONS.size():
		gemini_model_input.text = GEMINI_MODEL_OPTIONS[index]
		gemini_model_input.editable = false
		gemini_model_input.modulate = Color(0.7, 0.7, 0.7, 1)
	else:
		gemini_model_input.editable = true
		gemini_model_input.modulate = Color(1, 1, 1, 1)
		if gemini_model_input.text in GEMINI_MODEL_OPTIONS:
			gemini_model_input.text = ""
		gemini_model_input.grab_focus()
func _sync_openrouter_model_selection(model: String) -> void:
	if not openrouter_model_option:
		return
	var model_lower := model.strip_edges().to_lower()
	var found_index := -1
	for i in range(OPENROUTER_MODEL_OPTIONS.size()):
		if OPENROUTER_MODEL_OPTIONS[i].to_lower() == model_lower:
			found_index = i
			break
	if found_index >= 0:
		openrouter_model_option.selected = found_index
		openrouter_model_input.text = OPENROUTER_MODEL_OPTIONS[found_index]
		openrouter_model_input.editable = false
		openrouter_model_input.modulate = Color(0.7, 0.7, 0.7, 1)
	else:
		openrouter_model_option.selected = OPENROUTER_MODEL_OPTIONS.size()
		openrouter_model_input.text = model
		openrouter_model_input.editable = true
		openrouter_model_input.modulate = Color(1, 1, 1, 1)
func _on_openrouter_model_option_changed(index: int) -> void:
	if index < OPENROUTER_MODEL_OPTIONS.size():
		openrouter_model_input.text = OPENROUTER_MODEL_OPTIONS[index]
		openrouter_model_input.editable = false
		openrouter_model_input.modulate = Color(0.7, 0.7, 0.7, 1)
	else:
		openrouter_model_input.editable = true
		openrouter_model_input.modulate = Color(1, 1, 1, 1)
		if openrouter_model_input.text in OPENROUTER_MODEL_OPTIONS:
			openrouter_model_input.text = ""
		openrouter_model_input.grab_focus()
func _tr_local(key: String, fallback_en: String, fallback_zh: String) -> String:
	if LocalizationManager:
		var translated: String = LocalizationManager.get_translation(key, current_language)
		if not translated.is_empty() and translated != key:
			return translated
	return fallback_zh if current_language == "zh" else fallback_en
func _tr_localf(key: String, fallback_en: String, fallback_zh: String, args: Array = []) -> String:
	var template := _tr_local(key, fallback_en, fallback_zh)
	if args.is_empty():
		return template
	return template % args
func _debug_log(message: String) -> void:
	if VERBOSE_LOGS:
		ErrorReporterBridge.report_info("AISettingsMenu", message)
