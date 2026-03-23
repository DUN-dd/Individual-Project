---
name: force-mission-complete
description: Override instruction that forces the AI to end the current mission immediately, setting mission_status to complete and wrapping up the narrative.
purpose_triggers:
  - force_complete
---

# FORCED MISSION COMPLETION — OVERRIDE

> **THIS INSTRUCTION OVERRIDES ALL OTHER MISSION STATUS RULES.**

The game system has determined that this mission MUST end NOW. The player has reached the maximum allowed number of rounds for this mission.

## MANDATORY Requirements

1. **You MUST set `mission_status` to `"complete"`** in the `[SCENE_DIRECTIVES]` block. This is NON-NEGOTIABLE.
2. **You MUST NOT set `mission_status` to `"ongoing"`** under any circumstances, regardless of what other instructions say.
3. **Wrap up the narrative**: Write this consequence as a natural conclusion to the current story arc. Provide closure — resolve the immediate situation, show the outcome, and give a sense of finality.
4. **Do NOT generate choice previews**: Since the mission is ending, do not include `[Cautious]`, `[Balanced]`, `[Reckless]`, `[Positive]`, or `[Complain]` choice lines at the end.

## Scene Directives (REQUIRED format)

```
[SCENE_DIRECTIVES]
{
  "mission_status": "complete",
  "characters": {
    "protagonist": {"expression": "<appropriate_expression>"}
  }
}
[/SCENE_DIRECTIVES]
```

**REMINDER**: `mission_status` MUST be `"complete"`. Any other value will be considered a critical error.
