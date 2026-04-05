---
name: mission-generation
description: Vollständige Regeln und JSON-Schema zum Generieren neuer Missionsszenen mit korrekter Struktur.
purpose_triggers:
  - new_mission
  - mission_generation
---

# Regeln zur Missionsgenerierung

## Übersicht

Generiere eine neue Missionsszene, die den narrativen Bogen aufbaut. Jede Mission soll eine dunkel-humorvolle Situation darstellen, in der „Erfolg" paradoxerweise die Apokalypse beschleunigt.

## Generierungsanforderungen

### Inhaltsstruktur
1. **Szenenbeschreibung** (350–500 Wörter)
   - Lebhafte Umgebungsdetails
   - Charakterinteraktionen und -dialoge
   - Atmosphäre mit dunkel-humorvollen Untertönen

2. **Missionsziel**
   - Scheinbar „positives" Ziel, an das die Agentur glaubt
   - Verborgene Ironie: Das Erreichen dieses Ziels erhöht die Void-Entropie

3. **Potenzielle Dilemmata**
   - Moralisch graue Bereiche
   - Entscheidungen ohne gute Ergebnisse
   - Satirischer Kommentar zur toxischen Positivität

### Tonrichtlinien
- Schwarzer Humor und ruhige Ironie durchgehend
- Blinden Optimismus niemals belohnen
- Scheinbare Siege müssen greifbaren Schaden verbergen
- Satirische Schärfe beibehalten und gleichzeitig unterhaltsam sein

---

## JSON-Ausgabeschema

```json
{
  "mission_title": "<Kreativer Kapiteltitel mit schwarzem Humor>",
  "scene": {
    "background": "<background_id>",
    "atmosphere": "<Tonbeschreibung>",
    "lighting": "<Beleuchtungshinweis>"
  },
  "characters": {
    "protagonist": {"expression": "<Ausdruck>", "visible": true},
    "gloria": {"expression": "<Ausdruck>", "visible": true},
    "donkey": {"expression": "<Ausdruck>", "visible": true},
    "ark": {"expression": "<Ausdruck>", "visible": true},
    "one": {"expression": "<Ausdruck>", "visible": true}
  },
  "relationships": [
    {"source": "character_id", "target": "character_id", "status": "Statustext", "value_change": 0}
  ],
  "story_text": "<350–500 Wörter Narrativ>",
  "choices": [
    {"archetype": "cautious", "summary": "<10–20 Wörter Vorschau>"},
    {"archetype": "balanced", "summary": "<10–20 Wörter Vorschau>"},
    {"archetype": "reckless", "summary": "<10–20 Wörter Vorschau>"},
    {"archetype": "positive", "summary": "<10–20 Wörter Vorschau>"},
    {"archetype": "complain", "summary": "<10–20 Wörter Vorschau>"}
  ]
}
```

---

## Verfügbare Werte

### Hintergründe
ruins, cave, dungeon, forest, temple, laboratory, library, throne_room, battlefield, crystal_cavern, bridge, garden, portal_area, safe_zone, water, fire_area, prayer, default

### Ausdrücke
neutral, happy, sad, angry, confused, shocked, thinking, embarrassed

### Auswahlarchetypen
- **cautious**: Sicherer, risikoaverser Ansatz
- **balanced**: Moderater, diplomatischer Ansatz
- **reckless**: Hochrisiko-, Hochgewinn-Ansatz
- **positive**: Konformer, optimistischer Ansatz (erhöht Entropie)
- **complain**: Widerständiger, hinterfragender Ansatz (ärgert Gloria)

---

## Auswahlvorschau-Anforderungen

Der `story_text` muss mit einem „Choice Preview"-Block ENDEN:

```
[Vorsichtig] Vorschautext für die vorsichtige Wahl...
[Ausgewogen] Vorschautext für die ausgewogene Wahl...
[Rücksichtslos] Vorschautext für die rücksichtslose Wahl...
[Positiv] Vorschautext für die positive Wahl...
[Beschweren] Vorschautext für die beschwerende Wahl...
```

Diese müssen exakt mit den Zusammenfassungen im `choices`-Array übereinstimmen.
