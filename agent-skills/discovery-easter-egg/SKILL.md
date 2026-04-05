---
name: discovery-easter-egg
description: Step-by-step guide for adding a discovery-style easter egg (click-to-unlock, popup with song lyrics and URL) to any section of the game — following the established pattern used by the kite, relic, hfgs, and lyrics eggs.
purpose_triggers:
  - add_easter_egg
  - easter_egg
  - hidden_egg
  - discovery_egg
---

# Discovery Easter Egg — Implementation Guide

## What Is a Discovery Easter Egg?

A **discovery easter egg** is a subtle, semi-hidden UI element placed inside an existing game scene.
It is **not** directly shown to the player — it blends into the scene as a faint piece of text or imagery.
When the player clicks it **5 times** within a timeout window, a popup appears with a song lyric, a satirical reflection, and a link (Spotify / YouTube).

All existing eggs follow this identical mechanic:

| Easter Egg | Song | Placement | Visible hint |
|---|---|---|---|
| Kite (讓風箏飛) | 陳僖儀 | Mechanism section | Faded lyric fragment |
| Relic (遺物) | 許廷鏗 | Philosophy section | Faded lyric fragment |
| HFGS (恍如隔世) | 鄧健泓 | Philosophy section | Faded lyric fragment |
| Lyrics (世事何曾是絕對) | Super Girls | Conclusion card | Sequence-unlock then click |

---

## Step 1 — Analyse the Target Section

Before writing any code, **read the scene/section** the egg will live in.

Ask yourself:

1. **What is the emotional tone?** (e.g. corporate brainwashing, forced positivity, ironic optimism)
2. **What does the game tell the player to believe in this section?** (e.g. "rebirth through check-ins", "positive energy conquers all")
3. **What lyric or song contrasts most sharply with this message?** The goal is irony and satire — the song should say the opposite of what the game preaches, or expose its absurdity.
4. **Where can a faint label fit naturally?** Choose a parent VBoxContainer or similar layout node where an extra label won't break the layout but can be discovered by curious players.

---

## Step 2 — Choose and Design the Popup Content

### 2a. Song Selection Criteria

Choose lyrics that create **maximum contrast** with the section:

- The game section teaches players to **ignore reality, perform positivity, suppress doubt**
- The song should speak about **accepting hardship, genuine growth, facing reality, or letting go**
- The most effective eggs use a lyric that the game's characters would condemn as "negative thinking" — but is actually healthy and true

### 2b. Popup Content Structure

The popup must contain (in order):

1. **Title** — the song name, formatted as `~ ♪ Song Name ♪ ~`
2. **Separator line**
3. **Body** — using BBCode `[center]...[/center]`:
   - 1–3 lines of contrasting lyrics (in the original language, usually Chinese)
   - An English or German translation of those lyrics (for multilingual support)
   - A satirical or reflective line that connects the lyric to the game's absurdity, for example:
     - *"Perhaps this is what growing up actually looks like."*
     - *"The game calls this 'negative thinking'. The song calls it wisdom."*
     - *"也許，這才是真正的成長。"*
   - Attribution: `— Artist Name「Song Title」`
4. **Button row**:
   - **Listen button** (`♪ Spotify` or `♪ Listen`) — opens the track URL via `OS.shell_open()`
   - **Close button** — frees the overlay

### 2c. Hint Label Design (the discoverable element)

The label that players click must be:
- **Low opacity** (`0.30` – `0.45` alpha) so it's subtle but findable
- **Small font** (size 12–14)
- **Colour matching the scene's mood** (e.g. blue-grey for the mechanism section, warm gold for philosophy)
- **Text**: a single lyric fragment that feels dreamlike or slightly out of place — NOT a clear invitation to click
- The label's `mouse_filter` must be `Control.MOUSE_FILTER_STOP` so it receives input

---

## Step 3 — Add Localization Keys to CSV

File: `1.Codebase/localization/gda1_translations.csv`
Format: `KEY,en,zh,de` (columns: English, Traditional Chinese, German)

Add **7 keys** for the new egg (replace `XXX` with your egg's short name in UPPER_SNAKE_CASE):

```
EASTER_EGG_XXX_TEXT,<en hint fragment>,<zh hint fragment>,<de hint fragment>
EASTER_EGG_XXX_TITLE,~ ♪ <en song name> ♪ ~,~ ♪ <zh song name> ♪ ~,~ ♪ <de song name> ♪ ~
EASTER_EGG_XXX_BODY,"[center]<zh lyrics>\n\n<en lyrics>\n\n<satirical line>\n\n[i]— Artist「Song」[/i][/center]","[center]<zh lyrics>\n\n<satirical line zh>\n\n[i]— Artist「Song」[/i][/center]","[center]<zh lyrics>\n\n<de lyrics>\n\n<satirical line de>\n\n[i]— Artist「Song」[/i][/center]"
EASTER_EGG_XXX_HINT,<en tooltip start> ({remaining} clicks remaining),<zh tooltip start>（還有 {remaining} 下）,<de tooltip start> ({remaining} Klicks verbleibend)
EASTER_EGG_XXX_CLICK,Almost there... ({remaining} more),快了...（還差 {remaining} 下）,Fast da... (noch {remaining} mal)
EASTER_EGG_XXX_LISTEN,♪ Spotify,♪ Spotify 收聽,♪ Spotify
```

> `EASTER_EGG_CLOSE` is already defined globally — do NOT redefine it.

**Language rules:**
- `zh` column must use **Traditional Chinese (繁體中文)**, not Simplified
- `de` column should be natural German — translate the satirical line meaningfully, not literally
- BBCode tags (`[center]`, `[i]`, `\n`) work in the CSV body column

---

## Step 4 — Add GDScript Constants and State Variables

In the target `.gd` script (e.g. `fsm_rebirth_explanation.gd`), add at the top of the file alongside existing constants:

```gdscript
const XXX_EASTER_EGG_URL := "https://open.spotify.com/track/TRACK_ID"
const XXX_CLICK_TARGET := 5
const XXX_CLICK_TIMEOUT := 5.0
```

And alongside existing state variables:

```gdscript
var _xxx_click_count: int = 0
var _xxx_click_timer: float = 0.0
var _xxx_label: Label = null
```

---

## Step 5 — Wire Up in `_ready()` and `_process()`

In `_ready()`, after existing egg setup calls:

```gdscript
_setup_xxx_easter_egg()
```

In `_process(delta)`, inside the existing timer-reset block pattern:

```gdscript
if _xxx_click_count > 0:
    _xxx_click_timer -= delta
    if _xxx_click_timer <= 0.0:
        _xxx_click_count = 0
```

---

## Step 6 — Implement the Three Functions

### `_setup_xxx_easter_egg()`

Creates the faint label and attaches it to the correct parent node:

```gdscript
func _setup_xxx_easter_egg() -> void:
    if not <parent_node>:
        return
    _xxx_label = Label.new()
    _xxx_label.text = _tr("EASTER_EGG_XXX_TEXT")
    _xxx_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _xxx_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _xxx_label.add_theme_font_size_override("font_size", 13)
    _xxx_label.add_theme_color_override("font_color", Color(R, G, B, 0.35))
    _xxx_label.mouse_filter = Control.MOUSE_FILTER_STOP
    _xxx_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    _xxx_label.gui_input.connect(_on_xxx_label_gui_input)
    _xxx_label.tooltip_text = _tr("EASTER_EGG_XXX_HINT").format({"remaining": XXX_CLICK_TARGET})
    <parent_node>.add_child(_xxx_label)
```

### `_on_xxx_label_gui_input(event: InputEvent)`

Handles each click, updates the tooltip, and triggers the popup at count 5:

```gdscript
func _on_xxx_label_gui_input(event: InputEvent) -> void:
    if not (event is InputEventMouseButton):
        return
    var mb := event as InputEventMouseButton
    if mb.button_index != MOUSE_BUTTON_LEFT or not mb.pressed:
        return
    _xxx_click_count += 1
    _xxx_click_timer = XXX_CLICK_TIMEOUT
    if _xxx_label and is_instance_valid(_xxx_label):
        _xxx_label.pivot_offset = _xxx_label.size * 0.5
        var tween := create_tween()
        tween.tween_property(_xxx_label, "scale", Vector2(1.03, 1.03), 0.10)
        tween.tween_property(_xxx_label, "scale", Vector2.ONE, 0.10)
    var remaining := XXX_CLICK_TARGET - _xxx_click_count
    if remaining > 0:
        if remaining <= 2:
            _xxx_label.tooltip_text = _tr("EASTER_EGG_XXX_CLICK").format({"remaining": remaining})
        else:
            _xxx_label.tooltip_text = _tr("EASTER_EGG_XXX_HINT").format({"remaining": remaining})
        return
    _xxx_click_count = 0
    _xxx_click_timer = 0.0
    _show_xxx_popup()
```

### `_show_xxx_popup()`

Builds the overlay popup with title, body, and buttons:

```gdscript
func _show_xxx_popup() -> void:
    if audio_manager:
        audio_manager.play_sfx("ui_click", 0.8)
    var overlay := Control.new()
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.z_index = 210
    var bg := ColorRect.new()
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    bg.color = Color(0.0, 0.0, 0.05, 0.92)
    overlay.add_child(bg)
    var center := CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.add_child(center)
    var panel := Panel.new()
    panel.custom_minimum_size = Vector2(560, 400)
    var sb := StyleBoxFlat.new()
    sb.bg_color = Color(BG_R, BG_G, BG_B, 0.97)   # choose a colour that matches the scene
    sb.corner_radius_top_left = 18
    sb.corner_radius_top_right = 18
    sb.corner_radius_bottom_left = 18
    sb.corner_radius_bottom_right = 18
    sb.border_width_left = 1
    sb.border_width_right = 1
    sb.border_width_top = 1
    sb.border_width_bottom = 1
    sb.border_color = Color(BORDER_R, BORDER_G, BORDER_B, 0.6)
    sb.shadow_size = 16
    sb.shadow_color = Color(0, 0, 0, 0.6)
    panel.add_theme_stylebox_override("panel", sb)
    center.add_child(panel)
    var margin := MarginContainer.new()
    margin.set_anchors_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 40)
    margin.add_theme_constant_override("margin_right", 40)
    margin.add_theme_constant_override("margin_top", 32)
    margin.add_theme_constant_override("margin_bottom", 28)
    panel.add_child(margin)
    var vbox := VBoxContainer.new()
    vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
    vbox.add_theme_constant_override("separation", 16)
    margin.add_child(vbox)
    var title_lbl := Label.new()
    title_lbl.text = _tr("EASTER_EGG_XXX_TITLE")
    title_lbl.add_theme_font_size_override("font_size", 24)
    title_lbl.add_theme_color_override("font_color", Color(TITLE_R, TITLE_G, TITLE_B))
    title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title_lbl)
    var sep := HSeparator.new()
    sep.modulate = Color(SEP_R, SEP_G, SEP_B, 0.5)
    vbox.add_child(sep)
    var body_lbl := RichTextLabel.new()
    body_lbl.bbcode_enabled = true
    body_lbl.text = _tr("EASTER_EGG_XXX_BODY")
    body_lbl.fit_content = true
    body_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body_lbl.add_theme_font_size_override("normal_font_size", 17)
    body_lbl.add_theme_color_override("default_color", Color(0.92, 0.92, 0.96))
    vbox.add_child(body_lbl)
    var spacer := Control.new()
    spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    vbox.add_child(spacer)
    var btn_row := HBoxContainer.new()
    btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
    btn_row.add_theme_constant_override("separation", 16)
    vbox.add_child(btn_row)
    var listen_btn := Button.new()
    listen_btn.text = _tr("EASTER_EGG_XXX_LISTEN")
    listen_btn.custom_minimum_size = Vector2(140, 44)
    listen_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    UIStyleManager.apply_button_style(listen_btn, "primary", "medium")
    UIStyleManager.add_hover_scale_effect(listen_btn, 1.06)
    listen_btn.pressed.connect(func(): OS.shell_open(XXX_EASTER_EGG_URL))
    btn_row.add_child(listen_btn)
    var close_btn := Button.new()
    close_btn.text = _tr("EASTER_EGG_CLOSE")
    close_btn.custom_minimum_size = Vector2(140, 44)
    close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    UIStyleManager.apply_button_style(close_btn, "danger", "medium")
    UIStyleManager.add_hover_scale_effect(close_btn, 1.06)
    close_btn.pressed.connect(overlay.queue_free)
    btn_row.add_child(close_btn)
    overlay.modulate.a = 0.0
    get_tree().root.add_child(overlay)
    var fade_tw := create_tween()
    fade_tw.tween_property(overlay, "modulate:a", 1.0, 0.35)
```

---

## Step 7 — Colour Palette Guidelines

| Section | Hint label colour | Panel bg | Border | Title |
|---|---|---|---|---|
| Mechanism (blue-grey) | `Color(0.60, 0.72, 0.80, 0.35)` | `Color(0.04, 0.07, 0.12, 0.97)` | `Color(0.45, 0.70, 0.85, 0.6)` | `Color(0.55, 0.85, 1.0)` |
| Philosophy (warm gold) | `Color(0.72, 0.65, 0.50, 0.42)` | `Color(0.08, 0.06, 0.12, 0.97)` | `Color(0.72, 0.60, 0.35, 0.6)` | `Color(0.92, 0.82, 0.50)` |
| Comparison (purple-grey) | `Color(0.65, 0.60, 0.75, 0.38)` | `Color(0.08, 0.06, 0.14, 0.97)` | `Color(0.65, 0.55, 0.80, 0.6)` | `Color(0.85, 0.75, 1.0)` |

---

## Step 8 — Placement Decision Checklist

Before finalising placement, confirm:

- [ ] The parent node exists as an `@onready` var in the script
- [ ] The label's position in the parent node list is **between** other elements (not at the very top or bottom where it's immediately obvious)
- [ ] The label's text fragment feels **thematically related** to the surrounding content — not completely random
- [ ] The alpha is low enough that a casual player would scroll past it
- [ ] The hint tooltip is **vague on first click** (`{remaining} clicks remaining`) and only hints at discovery when 1–2 clicks remain

---

## Example: "讓風箏飛" Egg (Reference Implementation)

This egg was placed in `mechanism_section` of `fsm_rebirth_explanation.gd`.

**Why this placement?** The Mechanism section explains how the game's rebirth system works — it tells players that checking in daily earns them positive energy and progress. The kite song says *the sky isn't always clear and you must learn to face disappointment and let go* — the direct opposite of the game's message of forced positivity and denial of pain.

**Hint text (CSV key `EASTER_EGG_KITE_TEXT`):**
> EN: "The sky isn't always bright..."  
> ZH: 天色豈會每日也明亮如晴空……  
> DE: Der Himmel ist nicht immer hell...

**Popup body (key `EASTER_EGG_KITE_BODY`):** Quotes the chorus about the sky not always being clear, includes an English translation, and closes with: *"也許，這才是真正的成長。 / Perhaps this is what growing up actually looks like."*

**URL:** `https://open.spotify.com/track/5iXbvvbd1JotBgyk1RvHQW`

---

## Common Mistakes to Avoid

1. **Do NOT redefine `EASTER_EGG_CLOSE`** — it is a shared key already in the CSV
2. **Do NOT set `mouse_filter = Control.MOUSE_FILTER_PASS`** on the hint label — it must be `MOUSE_FILTER_STOP` to receive clicks
3. **Do NOT use `push_warning()`** — use `ErrorReporter.report_warning("Context", "Message")` instead
4. **Do NOT hardcode `/root/` paths** — use `ServiceLocator` for global services
5. **Always use `_tr(key)`** to fetch localization strings, never hardcode display text
6. **Always place the egg setup call in `_ready()`** and the timer reset in `_process(delta)`
7. **The `z_index` of the popup overlay must be `210`** — this ensures it renders above all other UI layers in this scene
8. **BBCode `\n` in CSV must be a literal `\n`**, not a real newline character — CSV cells use quoted strings with escaped newlines
