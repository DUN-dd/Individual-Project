---
name: honeymoon-phase
description: Spezielle Regeln für die Honeymoon-Phase, in der Teamkollegen verdächtig kooperativ und hilfsbereit agieren.
purpose_triggers:
  - honeymoon
  - honeymoon_active
---

# Regeln für die Honeymoon-Phase

## Übersicht

Die Honeymoon-Phase ist ein vorübergehender Zeitraum, in dem Teamkollegen verdächtig nett sind. Es ist die „Ruhe vor dem Sturm" – ihre Hilfsbereitschaft ist unheimlich und beunruhigend, weil sie ihrem normalen toxischen Verhalten widerspricht.

## Wann aktiv

Diese Fertigkeit soll geladen werden, wenn `game_state.is_in_honeymoon() == true`.

---

## Deutsche Version

```
[WICHTIGER ZUSTAND: HONEYMOON-PHASE]

Wir befinden uns derzeit in der „Honeymoon-Phase". Alle Teamkollegen verhalten sich verdächtig kooperativ, hilfsbereit und freundlich.

NARRATIVE ANFORDERUNGEN:
• KEINE Sabotage oder Störungen generieren
• Teamkollegen führen Befehle „zu perfekt" aus – es fühlt sich falsch an
• Ein unheimliches Gefühl von „Ruhe vor dem Sturm" erzeugen
• Ihre Freundlichkeit soll beunruhigend wirken, nicht echt
• Erfolg kommt zu leicht, was den Spieler paranoid macht
• Subtile Hinweise, dass dieser Frieden nicht andauern kann

VERHALTENSÄNDERUNGEN DER TEAMKOLLEGEN:
• Gloria: Wirklich unterstützend statt passiv-aggressiv (unheimlich)
• Donkey: Tatsächlich kompetent und bescheiden (unmöglich)
• ARK: Klare Kommunikation und einfache Pläne (unerhört)
• One: Augenkontakt und zustimmendes Nicken (besorgniserregend)

Der Spieler soll sich während der Honeymoon-Phase UNWOHLER fühlen als während des normalen Chaos.
Dieser falsche Frieden ist eine narrative Falle – Spannung durch die Abwesenheit von Konflikt aufbauen.
```

---

## Honeymoon-Ladungen

- Anfangsladungen: typischerweise 3–5
- Jede „negative" Aktion des Spielers verbraucht eine Ladung
- Wenn die Ladungen 0 erreichen, endet die Honeymoon-Phase abrupt
- Der Übergang AUS der Honeymoon-Phase soll dramatisch und erschütternd sein
