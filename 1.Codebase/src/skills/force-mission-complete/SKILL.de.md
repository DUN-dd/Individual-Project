---
name: force-mission-complete
description: Override-Anweisung, die die KI zwingt, die aktuelle Mission sofort zu beenden und mission_status auf complete zu setzen.
purpose_triggers:
  - force_complete
---

# ERZWUNGENER MISSIONSABSCHLUSS — OVERRIDE

> **DIESE ANWEISUNG UEBERSCHREIBT ALLE ANDEREN MISSION-STATUS-REGELN.**

Das Spielsystem hat festgelegt, dass diese Mission JETZT enden MUSS. Der Spieler hat die maximal erlaubte Rundenzahl fuer diese Mission erreicht.

## ZWINGENDE Anforderungen

1. **Sie MUESSEN `mission_status` auf `"complete"` setzen** im `[SCENE_DIRECTIVES]`-Block. Dies ist NICHT VERHANDELBAR.
2. **Sie duerfen `mission_status` unter KEINEN Umstaenden auf `"ongoing"` setzen**, unabhaengig davon, was andere Anweisungen besagen.
3. **Schliessen Sie die Erzaehlung ab**: Schreiben Sie diese Konsequenz als natuerlichen Abschluss des aktuellen Handlungsstrangs. Bieten Sie einen Abschluss — loesen Sie die unmittelbare Situation, zeigen Sie das Ergebnis und vermitteln Sie ein Gefuehl der Endgueltigkeit.
4. **Generieren Sie KEINE Vorschau-Optionen**: Da die Mission endet, fuegen Sie am Ende KEINE `[Cautious]`, `[Balanced]`, `[Reckless]`, `[Positive]` oder `[Complain]` Zeilen hinzu.

## Szenenanweisungen (ERFORDERLICHES Format)

```
[SCENE_DIRECTIVES]
{
  "mission_status": "complete",
  "characters": {
    "protagonist": {"expression": "<passender_ausdruck>"}
  }
}
[/SCENE_DIRECTIVES]
```

**ERINNERUNG**: `mission_status` MUSS `"complete"` sein. Jeder andere Wert wird als kritischer Fehler betrachtet.
