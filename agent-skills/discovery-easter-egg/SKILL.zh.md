---
name: discovery-easter-egg
description: 為遊戲任意場景新增「發現式彩蛋」（點擊解鎖、歌詞彈窗、URL 連結）的完整逐步指引，遵循 kite、relic、hfgs、lyrics 等現有彩蛋的既定模式。
purpose_triggers:
  - add_easter_egg
  - easter_egg
  - hidden_egg
  - discovery_egg
---

# 發現式彩蛋 — 實作指引

## 什麼是「發現式彩蛋」？

**發現式彩蛋**是一個放置在現有遊戲場景內的細微 UI 元素。  
它**不會直接展示給玩家**——它以一段半透明的文字自然融入場景。  
當玩家在限時內**點擊 5 次**，便會彈出一個視窗，內含諷刺性的歌詞對比、反思，以及一個 Spotify / YouTube 連結。

所有現有彩蛋均遵循完全相同的機制：

| 彩蛋 | 歌曲 | 放置位置 | 可見提示 |
|---|---|---|---|
| Kite（讓風箏飛） | 陳僖儀 | 機制（Mechanism）區塊 | 淡化歌詞片段 |
| Relic（遺物） | 許廷鏗 | 哲理（Philosophy）區塊 | 淡化歌詞片段 |
| HFGS（恍如隔世） | 鄧健泓 | 哲理（Philosophy）區塊 | 淡化歌詞片段 |
| Lyrics（世事何曾是絕對） | Super Girls | 結論卡片 | 序列解鎖後再點擊 |

---

## 第一步 — 分析目標場景區塊

在寫任何程式碼之前，**先仔細閱讀彩蛋所在的場景/區塊**。

思考以下問題：

1. **這個區塊的情緒基調是什麼？**（例如：企業式洗腦、強制正能量、諷刺的樂觀）
2. **遊戲在這個區塊告訴玩家要相信什麼？**（例如：「每日打卡就能重生」、「正能量可以戰勝一切」）
3. **哪首歌的歌詞與遊戲訊息形成最大反差？** 目標是諷刺——歌曲應該說出與遊戲說教相反的話，或揭露其荒謬性。
4. **淡化的標籤可以自然嵌入哪個位置？** 選擇一個 VBoxContainer 或類似佈局節點，讓多一個 Label 不會破壞版面，但好奇的玩家可以發現它。

---

## 第二步 — 選擇並設計彈窗內容

### 2a. 歌曲選擇標準

選擇能製造**最大反差**的歌詞：

- 遊戲區塊教玩家**忽略現實、表演正能量、壓抑懷疑**
- 歌曲應該訴說**接受困難、真正成長、面對現實、學會放手**
- 最有效的彩蛋使用一句遊戲角色會斥為「負面思維」的歌詞——但這句話實際上是健康而真實的

### 2b. 彈窗內容結構

彈窗必須依序包含：

1. **標題** — 歌名，格式為 `~ ♪ 歌名 ♪ ~`
2. **分隔線**
3. **主體** — 使用 BBCode `[center]...[/center]`：
   - 1–3 行對比歌詞（以原文語言，通常是中文）
   - 英文或德文翻譯（多語言支援）
   - 一句**含蓄的**反思語句 — 參見下方**語氣原則**
   - 出處：`— 藝人名「歌名」`

> **⚠️ 語氣原則 — 留白，不要解釋**
>
> 反思語句**絕對不要**直接點明在諷刺什麼。
> 不要寫類似「遊戲稱之為『負面思維』，歌詞卻稱之為智慧。」或「這與遊戲強制正能量形成對比。」這樣的句子。
> 這太過直白——會破壞玩家的發現感，也等於在假設玩家無法自己思考。
>
> 應該讓**反差自己說話**。歌詞本身已經說出了與遊戲相反的話——好的反思語句只需讓玩家停留在那種張力中，而不是把答案塞給他們。
>
> ✅ **好的範例（含蓄、讓玩家自己感受諷刺）：**
> - *「也許，這才是真正的成長。」*
> - *「風箏斷了線，卻飛得更高。」*
> - *「有些事，放下了才看得見。」*
>
> ❌ **不好的範例（太直白，等於解釋笑話）：**
> - *「遊戲叫你保持正面，這首歌卻持相反態度。」*
> - *「與遊戲的洗腦不同，這句歌詞才是真正的道理。」*
> - *「這是對重生系統有毒正能量的諷刺。」*
>
> 玩家費心找到了一個隱藏彩蛋——用詩意回報他們的好奇心，而不是一篇說教。
4. **按鈕列**：
   - **收聽按鈕**（`♪ Spotify` 或 `♪ 聆聽`）— 以 `OS.shell_open()` 開啟曲目 URL
   - **關閉按鈕** — 釋放 overlay 節點

### 2c. 可發現的提示標籤設計

玩家點擊的標籤必須：
- **低透明度**（alpha 值 `0.30` – `0.45`），夠細微但可被找到
- **小字體**（大小 12–14）
- **顏色配合場景情緒**（例如：機制區用藍灰色，哲理區用暖金色）
- **文字**：一小段歌詞片段，讀起來像夢幻或稍微格格不入——**不要**直接邀請玩家點擊
- 標籤的 `mouse_filter` 必須設為 `Control.MOUSE_FILTER_STOP` 才能接收輸入事件

---

## 第三步 — 在 CSV 新增本地化鍵

檔案：`1.Codebase/localization/gda1_translations.csv`  
格式：`KEY,en,zh,de`（欄位：英文、繁體中文、德文）

為新彩蛋新增 **7 個鍵**（用彩蛋短名稱的大寫蛇形命名取代 `XXX`）：

```
EASTER_EGG_XXX_TEXT,<英文提示片段>,<中文提示片段>,<德文提示片段>
EASTER_EGG_XXX_TITLE,~ ♪ <英文歌名> ♪ ~,~ ♪ <中文歌名> ♪ ~,~ ♪ <德文歌名> ♪ ~
EASTER_EGG_XXX_BODY,"[center]<中文歌詞>\n\n<英文歌詞>\n\n<諷刺反思>\n\n[i]— 藝人「歌名」[/i][/center]","[center]<中文歌詞>\n\n<中文反思>\n\n[i]— 藝人「歌名」[/i][/center]","[center]<中文歌詞>\n\n<德文歌詞>\n\n<德文反思>\n\n[i]— 藝人「歌名」[/i][/center]"
EASTER_EGG_XXX_HINT,<英文tooltip開始> ({remaining} clicks remaining),<中文tooltip>（還有 {remaining} 下）,<德文tooltip> ({remaining} Klicks verbleibend)
EASTER_EGG_XXX_CLICK,Almost there... ({remaining} more),快了...（還差 {remaining} 下）,Fast da... (noch {remaining} mal)
EASTER_EGG_XXX_LISTEN,♪ Spotify,♪ Spotify 收聽,♪ Spotify
```

> `EASTER_EGG_CLOSE` 已全局定義——**不要**重複定義。

**語言規則：**
- `zh` 欄必須使用**繁體中文**，不用簡體
- `de` 欄應使用自然德文——有意義地翻譯諷刺語句，不要逐字直譯
- BBCode 標籤（`[center]`、`[i]`、`\n`）可在 CSV 主體欄中使用

---

## 第四步 — 在 GDScript 新增常數和狀態變數

在目標 `.gd` 腳本（如 `fsm_rebirth_explanation.gd`）的頂部，與現有常數並排添加：

```gdscript
const XXX_EASTER_EGG_URL := "https://open.spotify.com/track/TRACK_ID"
const XXX_CLICK_TARGET := 5
const XXX_CLICK_TIMEOUT := 5.0
```

與現有狀態變數並排添加：

```gdscript
var _xxx_click_count: int = 0
var _xxx_click_timer: float = 0.0
var _xxx_label: Label = null
```

---

## 第五步 — 在 `_ready()` 和 `_process()` 串接

在 `_ready()` 中，現有彩蛋設置調用之後添加：

```gdscript
_setup_xxx_easter_egg()
```

在 `_process(delta)` 中，現有計時器重置模式內添加：

```gdscript
if _xxx_click_count > 0:
    _xxx_click_timer -= delta
    if _xxx_click_timer <= 0.0:
        _xxx_click_count = 0
```

---

## 第六步 — 實作三個核心函數

### `_setup_xxx_easter_egg()`

創建淡化標籤並附加到正確的父節點：

```gdscript
func _setup_xxx_easter_egg() -> void:
    if not <父節點>:
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
    <父節點>.add_child(_xxx_label)
```

### `_on_xxx_label_gui_input(event: InputEvent)`

處理每次點擊、更新 tooltip、達到 5 次時觸發彈窗：

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

建構彈窗 overlay，包含標題、主體和按鈕：

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

## 第七步 — 色調參考

| 區塊 | 提示標籤顏色 | 面板背景 | 邊框 | 標題 |
|---|---|---|---|---|
| 機制（藍灰） | `Color(0.60, 0.72, 0.80, 0.35)` | `Color(0.04, 0.07, 0.12, 0.97)` | `Color(0.45, 0.70, 0.85, 0.6)` | `Color(0.55, 0.85, 1.0)` |
| 哲理（暖金） | `Color(0.72, 0.65, 0.50, 0.42)` | `Color(0.08, 0.06, 0.12, 0.97)` | `Color(0.72, 0.60, 0.35, 0.6)` | `Color(0.92, 0.82, 0.50)` |
| 對比（紫灰） | `Color(0.65, 0.60, 0.75, 0.38)` | `Color(0.08, 0.06, 0.14, 0.97)` | `Color(0.65, 0.55, 0.80, 0.6)` | `Color(0.85, 0.75, 1.0)` |

---

## 第八步 — 放置位置決策清單

確認放置前，核對以下事項：

- [ ] 父節點已在腳本中作為 `@onready` var 存在
- [ ] 標籤在父節點子節點列表中的位置處於**其他元素之間**（不在最頂或最底，以免過於明顯）
- [ ] 標籤文字片段在主題上與周圍內容**有所關聯**——不要完全無關
- [ ] Alpha 值低到普通玩家會直接滾動跳過
- [ ] 第一次點擊時 tooltip 語氣**模糊**（`{remaining} clicks remaining`），只在剩餘 1–2 次時才暗示「快了」

---

## 參考範例：「讓風箏飛」彩蛋

此彩蛋放置在 `fsm_rebirth_explanation.gd` 的 `mechanism_section` 中。

**為何選擇此位置？** 機制區塊解釋了遊戲重生系統的運作方式——告訴玩家每日打卡可以獲得正能量和進步。《讓風箏飛》則說「天色豈會每日也明亮，你必須學會面對失望與放手」——與遊戲強制正能量、否認痛苦的訊息恰恰相反。

**提示文字（CSV 鍵 `EASTER_EGG_KITE_TEXT`）：**
> EN: "The sky isn't always bright..."  
> ZH: 天色豈會每日也明亮如晴空……  
> DE: Der Himmel ist nicht immer hell...

**彈窗主體（鍵 `EASTER_EGG_KITE_BODY`）：** 引用了關於天色的副歌、英文翻譯，以及結語：*「也許，這才是真正的成長。/ Perhaps this is what growing up actually looks like.」*

**URL：** `https://open.spotify.com/track/5iXbvvbd1JotBgyk1RvHQW`

---

## 常見錯誤提示

1. **不要重複定義 `EASTER_EGG_CLOSE`** — 它是 CSV 中已有的全局鍵
2. **不要將提示標籤設為 `mouse_filter = Control.MOUSE_FILTER_PASS`** — 必須設為 `MOUSE_FILTER_STOP` 才能接收點擊
3. **不要使用 `push_warning()`** — 改用 `ErrorReporter.report_warning("Context", "Message")`
4. **不要硬編碼 `/root/` 路徑** — 使用 `ServiceLocator` 存取全局服務
5. **始終使用 `_tr(key)`** 獲取本地化字串，絕不硬編碼顯示文字
6. **始終在 `_ready()` 中調用彩蛋設置函數**，在 `_process(delta)` 中重置計時器
7. **彈窗 overlay 的 `z_index` 必須為 `210`** — 確保它渲染在此場景所有其他 UI 層之上
8. **CSV 中 BBCode 的 `\n` 必須是字面的 `\n`**，不是真實換行符——CSV 儲存格使用帶跳脫字符的引號字串
