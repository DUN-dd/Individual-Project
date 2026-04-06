---
name: force-mission-complete
description: 強制 AI 立即結束當前任務的覆蓋指令，將 mission_status 設定為 complete 並收束敘事。
purpose_triggers:
  - force_complete
---

# 強制任務完成 — 覆蓋指令

> **此指令覆蓋所有其他任務狀態規則。**

遊戲系統判定本次任務必須在此刻結束。玩家已達到此任務允許的最大回合數上限。

## 強制要求

1. **你必須將 `mission_status` 設定為 `"complete"`**，寫在 `[SCENE_DIRECTIVES]` 區塊中。此為不可違反之指令。
2. **你絕對不可以將 `mission_status` 設定為 `"ongoing"`**，無論其他指令如何說明。
3. **收束敘事**：將此結果寫成當前故事線的自然結局。提供收尾——解決當前情境、展示結果、並給予完結感。
4. **不要生成選項預覽**：由於任務即將結束，不要在末尾加入 `[謹慎]`、`[平衡]`、`[魯莽]`、`[正能量]`、`[抱怨]` 等選項行。

## 場景指令（必須格式）

```
[SCENE_DIRECTIVES]
{
  "mission_status": "complete",
  "characters": {
    "protagonist": {"expression": "<合適的表情>"}
  }
}
[/SCENE_DIRECTIVES]
```

**提醒**：`mission_status` 必須為 `"complete"`。任何其他值都將被視為嚴重錯誤。
