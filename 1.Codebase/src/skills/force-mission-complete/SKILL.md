---
name: force-mission-complete
description: Mandatory override instruction to force mission completion when the turn limit has been reached.
purpose_triggers:
  - force_mission_complete
---

# MANDATORY MISSION COMPLETION OVERRIDE

**The maximum turn limit for this mission has been reached.**

You MUST set `mission_status` to `"complete"` in the `[SCENE_DIRECTIVES]` block — no exceptions.

This overrides all other instructions about when to use `"complete"`. Do NOT set `"ongoing"`. The story must conclude in this response.

Write a narrative that wraps up the current mission arc, however abruptly. Acknowledge the outcome of the player's final choice, give the scene a sense of closure, and transition the story toward the end of the mission.
