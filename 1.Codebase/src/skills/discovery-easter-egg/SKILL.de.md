---
name: discovery-easter-egg
description: Schritt-für-Schritt-Anleitung zum Hinzufügen eines Discovery-Easter-Eggs (Klick-zum-Entsperren, Popup mit Songtexten und URL) zu einer beliebigen Spielszene – nach dem etablierten Muster der bestehenden Eier (kite, relic, hfgs, lyrics).
purpose_triggers:
  - add_easter_egg
  - easter_egg
  - hidden_egg
  - discovery_egg
---

# Discovery-Easter-Egg — Implementierungsleitfaden

## Was ist ein Discovery-Easter-Egg?

Ein **Discovery-Easter-Egg** ist ein dezentes, halb verstecktes UI-Element, das in eine bestehende Spielszene eingebettet ist.  
Es wird dem Spieler **nicht direkt gezeigt** — es fügt sich als leicht transparenter Text natürlich in die Szene ein.  
Wenn der Spieler innerhalb eines Zeitfensters **5 Mal darauf klickt**, erscheint ein Popup mit kontrastierenden Liedtexten, einer satirischen Reflexion und einem Link (Spotify / YouTube).

Alle bestehenden Eier folgen exakt demselben Mechanismus:

| Easter Egg | Lied | Platzierung | Sichtbarer Hinweis |
|---|---|---|---|
| Kite (讓風箏飛) | 陳僖儀 | Mechanism-Abschnitt | Verblasster Liedtextfragment |
| Relic (遺物) | 許廷鏗 | Philosophy-Abschnitt | Verblasster Liedtextfragment |
| HFGS (恍如隔世) | 鄧健泓 | Philosophy-Abschnitt | Verblasster Liedtextfragment |
| Lyrics (世事何曾是絕對) | Super Girls | Schlussfolgerungs-Karte | Sequenz-Entsperrung, dann Klick |

---

## Schritt 1 — Zielabschnitt analysieren

Bevor Code geschrieben wird: **Szene/Abschnitt sorgfältig lesen**, in dem das Ei platziert wird.

Folgende Fragen stellen:

1. **Welchen emotionalen Grundton hat dieser Abschnitt?** (z. B. unternehmerische Gehirnwäsche, erzwungene Positivität, ironischer Optimismus)
2. **Was lehrt das Spiel den Spieler in diesem Abschnitt zu glauben?** (z. B. „tägliches Einchecken führt zur Wiedergeburt", „positive Energie überwindet alles")
3. **Welcher Liedtext kontrastiert am stärksten mit dieser Botschaft?** Ziel ist Satire — das Lied soll das Gegenteil von dem sagen, was das Spiel predigt, oder dessen Absurdität entlarven.
4. **Wo passt ein verblasstes Label natürlich hin?** Einen VBoxContainer oder ähnlichen Layout-Knoten wählen, wo ein zusätzliches Label das Layout nicht zerstört, aber von neugierigen Spielern entdeckt werden kann.

---

## Schritt 2 — Popup-Inhalt auswählen und gestalten

### 2a. Kriterien für die Liedauswahl

Liedtexte wählen, die **maximalen Kontrast** erzeugen:

- Der Spielabschnitt lehrt Spieler, **die Realität zu ignorieren, Positivität aufzuführen, Zweifel zu unterdrücken**
- Das Lied soll über **das Akzeptieren von Schwierigkeiten, echtes Wachstum, Realität akzeptieren oder Loslassen** sprechen
- Die wirksamsten Eier verwenden einen Liedtext, den die Spielcharaktere als „negatives Denken" verurteilen würden — der aber tatsächlich gesund und wahr ist

### 2b. Popup-Inhaltsstruktur

Das Popup muss (in dieser Reihenfolge) enthalten:

1. **Titel** — der Liedname, formatiert als `~ ♪ Liedname ♪ ~`
2. **Trennlinie**
3. **Haupttext** — mit BBCode `[center]...[/center]`:
   - 1–3 Zeilen kontrastierende Liedtexte (in der Originalsprache, meist Chinesisch)
   - Eine englische oder deutsche Übersetzung dieser Zeilen
   - Ein satirischer oder reflexiver Satz, der den Liedtext mit der Absurdität des Spiels verbindet, zum Beispiel:
     - *„Vielleicht ist das, was wirkliches Erwachsenwerden bedeutet."*
     - *„Das Spiel nennt es ‚negatives Denken'. Das Lied nennt es Weisheit."*
     - *"也許，這才是真正的成長。"*
   - Quellenangabe: `— Künstlername「Liedtitel」`
4. **Schaltflächenreihe**:
   - **Anhören-Schaltfläche** (`♪ Spotify`) — öffnet die Track-URL via `OS.shell_open()`
   - **Schließen-Schaltfläche** — gibt das Overlay frei

### 2c. Gestaltung des entdeckbaren Hinweislabels

Das Label, auf das Spieler klicken, muss:
- **Niedrige Opazität** haben (Alpha `0.30` – `0.45`), subtil aber auffindbar
- **Kleine Schrift** verwenden (Größe 12–14)
- **Farbe passend zur Szenenstimmung** haben (z. B. Blaugrau für den Mechanism-Abschnitt, warmes Gold für Philosophy)
- **Text**: ein einzelner Liedtextfragment, der traumhaft oder leicht fehl am Platz wirkt — **keine** direkte Aufforderung zum Klicken
- `mouse_filter` des Labels muss `Control.MOUSE_FILTER_STOP` sein, um Eingaben zu empfangen

---

## Schritt 3 — Lokalisierungsschlüssel in CSV hinzufügen

Datei: `1.Codebase/localization/gda1_translations.csv`  
Format: `KEY,en,zh,de` (Spalten: Englisch, Traditionelles Chinesisch, Deutsch)

**7 Schlüssel** für das neue Ei hinzufügen (`XXX` durch den kurzen Einaggregat-Namen in UPPER_SNAKE_CASE ersetzen):

```
EASTER_EGG_XXX_TEXT,<en Hinweisfragment>,<zh Hinweisfragment>,<de Hinweisfragment>
EASTER_EGG_XXX_TITLE,~ ♪ <en Liedname> ♪ ~,~ ♪ <zh Liedname> ♪ ~,~ ♪ <de Liedname> ♪ ~
EASTER_EGG_XXX_BODY,"[center]<zh Liedtext>\n\n<en Liedtext>\n\n<satirische Reflexion>\n\n[i]— Künstler「Lied」[/i][/center]","[center]<zh Liedtext>\n\n<zh Reflexion>\n\n[i]— Künstler「Lied」[/i][/center]","[center]<zh Liedtext>\n\n<de Liedtext>\n\n<de Reflexion>\n\n[i]— Künstler「Lied」[/i][/center]"
EASTER_EGG_XXX_HINT,<en Tooltip-Beginn> ({remaining} clicks remaining),<zh Tooltip>（還有 {remaining} 下）,<de Tooltip> ({remaining} Klicks verbleibend)
EASTER_EGG_XXX_CLICK,Almost there... ({remaining} more),快了...（還差 {remaining} 下）,Fast da... (noch {remaining} mal)
EASTER_EGG_XXX_LISTEN,♪ Spotify,♪ Spotify 收聽,♪ Spotify
```

> `EASTER_EGG_CLOSE` ist bereits global definiert — **nicht** neu definieren.

**Sprachregeln:**
- Spalte `zh` muss **Traditionelles Chinesisch (繁體中文)** verwenden, nicht Vereinfachtes
- Spalte `de` soll natürliches Deutsch sein — den satirischen Satz sinngemäß übersetzen, nicht wörtlich
- BBCode-Tags (`[center]`, `[i]`, `\n`) funktionieren in der CSV-Körperspalte

---

## Schritt 4 — GDScript-Konstanten und Zustandsvariablen hinzufügen

Im Zielskript (z. B. `fsm_rebirth_explanation.gd`) oben in der Datei neben bestehenden Konstanten:

```gdscript
const XXX_EASTER_EGG_URL := "https://open.spotify.com/track/TRACK_ID"
const XXX_CLICK_TARGET := 5
const XXX_CLICK_TIMEOUT := 5.0
```

Neben bestehenden Zustandsvariablen:

```gdscript
var _xxx_click_count: int = 0
var _xxx_click_timer: float = 0.0
var _xxx_label: Label = null
```

---

## Schritt 5 — In `_ready()` und `_process()` einbinden

In `_ready()`, nach bestehenden Egg-Setup-Aufrufen:

```gdscript
_setup_xxx_easter_egg()
```

In `_process(delta)`, innerhalb des bestehenden Timer-Reset-Musters:

```gdscript
if _xxx_click_count > 0:
    _xxx_click_timer -= delta
    if _xxx_click_timer <= 0.0:
        _xxx_click_count = 0
```

---

## Schritt 6 — Die drei Kernfunktionen implementieren

### `_setup_xxx_easter_egg()`

Erstellt das verblasste Label und hängt es an den richtigen Elternknoten:

```gdscript
func _setup_xxx_easter_egg() -> void:
    if not <elternknoten>:
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
    <elternknoten>.add_child(_xxx_label)
```

### `_on_xxx_label_gui_input(event: InputEvent)`

Verarbeitet jeden Klick, aktualisiert den Tooltip und löst beim 5. Klick das Popup aus:

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

Baut das Overlay-Popup mit Titel, Haupttext und Schaltflächen:

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
    sb.bg_color = Color(BG_R, BG_G, BG_B, 0.97)
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

## Schritt 7 — Farbpaletten-Referenz

| Abschnitt | Hinweislabel-Farbe | Panel-Hintergrund | Rahmen | Titel |
|---|---|---|---|---|
| Mechanism (Blaugrau) | `Color(0.60, 0.72, 0.80, 0.35)` | `Color(0.04, 0.07, 0.12, 0.97)` | `Color(0.45, 0.70, 0.85, 0.6)` | `Color(0.55, 0.85, 1.0)` |
| Philosophy (Warmgold) | `Color(0.72, 0.65, 0.50, 0.42)` | `Color(0.08, 0.06, 0.12, 0.97)` | `Color(0.72, 0.60, 0.35, 0.6)` | `Color(0.92, 0.82, 0.50)` |
| Comparison (Lila-Grau) | `Color(0.65, 0.60, 0.75, 0.38)` | `Color(0.08, 0.06, 0.14, 0.97)` | `Color(0.65, 0.55, 0.80, 0.6)` | `Color(0.85, 0.75, 1.0)` |

---

## Schritt 8 — Checkliste für die Platzierungsentscheidung

Vor der Fertigstellung der Platzierung bestätigen:

- [ ] Der Elternknoten existiert bereits als `@onready` var im Skript
- [ ] Das Label steht **zwischen** anderen Elementen in der Kindknotenliste (nicht ganz oben oder unten, wo es zu offensichtlich wäre)
- [ ] Der Labeltext fühlt sich thematisch mit dem umgebenden Inhalt **verwandt** an — nicht völlig zusammenhangslos
- [ ] Der Alpha-Wert ist niedrig genug, dass ein oberflächlicher Spieler einfach vorbeiscrollt
- [ ] Der erste Klick-Tooltip ist **vage** (`{remaining} clicks remaining`); erst bei 1–2 verbleibenden Klicks erscheint ein Hinweis auf die Entdeckung

---

## Referenzbeispiel: Das „讓風箏飛"-Ei

Dieses Ei wurde in `mechanism_section` von `fsm_rebirth_explanation.gd` platziert.

**Warum diese Platzierung?** Der Mechanism-Abschnitt erklärt, wie das Wiedergeburtssystem des Spiels funktioniert — er sagt den Spielern, dass tägliches Einchecken positive Energie und Fortschritt bringt. Das Lied „讓風箏飛" sagt: *Der Himmel ist nicht immer klar und du musst lernen, Enttäuschungen zu begegnen und loszulassen* — das direkte Gegenteil der erzwungenen Positivität und Schmerzverleugnung des Spiels.

**Hinweistext (CSV-Schlüssel `EASTER_EGG_KITE_TEXT`):**
> EN: "The sky isn't always bright..."  
> ZH: 天色豈會每日也明亮如晴空……  
> DE: Der Himmel ist nicht immer hell...

**Popup-Haupttext (Schlüssel `EASTER_EGG_KITE_BODY`):** Zitiert den Refrain über den nicht immer klaren Himmel, enthält eine englische Übersetzung und schließt mit: *„Vielleicht ist das, was wirkliches Erwachsenwerden bedeutet."*

**URL:** `https://open.spotify.com/track/5iXbvvbd1JotBgyk1RvHQW`

---

## Häufige Fehler vermeiden

1. **`EASTER_EGG_CLOSE` NICHT neu definieren** — es ist ein bereits in der CSV vorhandener globaler Schlüssel
2. **`mouse_filter = Control.MOUSE_FILTER_PASS` NICHT** für das Hinweislabel setzen — es muss `MOUSE_FILTER_STOP` sein, um Klicks zu empfangen
3. **`push_warning()` NICHT verwenden** — stattdessen `ErrorReporter.report_warning("Context", "Message")` nutzen
4. **Keine `/root/`-Pfade hardcoden** — `ServiceLocator` für globale Dienste verwenden
5. **Immer `_tr(key)`** für Lokalisierungsstrings verwenden, niemals Display-Text hardcoden
6. **Egg-Setup-Aufruf immer in `_ready()`**, Timer-Reset immer in `_process(delta)`
7. **`z_index` des Popup-Overlays muss `210` sein** — stellt sicher, dass es über allen anderen UI-Ebenen in dieser Szene gerendert wird
8. **BBCode `\n` in CSV muss literales `\n` sein**, kein echter Zeilenumbruch — CSV-Zellen verwenden Strings mit Escape-Zeichen in Anführungszeichen
