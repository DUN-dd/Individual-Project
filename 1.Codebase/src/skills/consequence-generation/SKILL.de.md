---
name: consequence-generation
description: Regeln zum Generieren von Konsequenzen nach Spielerentscheidungen, einschließlich Szenenanweisungen und Auswahlvorschauen.
purpose_triggers:
  - consequence
  - choice_followup
---

# Regeln zur Konsequenzgenerierung

## Übersicht

Generiere die narrative Konsequenz einer Spielerwahl. Das Ergebnis soll die satirische Natur des Spiels widerspiegeln – selbst „Erfolge" haben versteckte Kosten.

## Eingabekontext

Du erhältst:
- **Spielerwahl**: Die Aktion/Option, die der Spieler gewählt hat
- **Ergebnis**: Erfolg oder Misserfolg (basierend auf einer Fertigkeitsprüfung)
- **Aktuelle Werte**: Reality Score, Positive Energie, Entropie

## Inhaltsanforderungen

### Wortanzahl
- Minimum: 150 Wörter
- Maximum: 250 Wörter

### Muss enthalten
1. **Sofortige Wirkung** – Was passiert unmittelbar
2. **NSC/Umgebungsreaktionen** – Wie die Welt antwortet
3. **Andeutungen** – Hinweise auf langfristige Konsequenzen

### Darf NICHT enthalten
- Asset-Beschreibungen (werden bereits im Kontext geliefert)
- Redundante Auflistungen von Gegenständen oder Ressourcen

---

## Format der Szenenanweisungen

Füge am ANFANG deiner Antwort ein:

```
[SCENE_DIRECTIVES]
{
  "mission_status": "ongoing",
  "characters": {
    "protagonist": {"expression": "expression_type"},
    "gloria": {"expression": "expression_type"},
    "donkey": {"expression": "expression_type"},
    "ark": {"expression": "expression_type"},
    "one": {"expression": "expression_type"}
  },
  "relationships": [
    {"source": "gloria", "target": "player", "status": "Enttäuscht", "value_change": -10}
  ]
}
[/SCENE_DIRECTIVES]
```

### Missionsstatus
- **"ongoing"**: Geschichte geht weiter, weitere Entscheidungen folgen
- **"complete"**: Diese Konsequenz beendet den aktuellen Missionsbogen und löst den Nachtzyklus aus

Standard ist „ongoing". Du kannst „complete" setzen, wenn der narrative Bogen einen natürlichen Abschluss erreicht (z. B. katastrophaler Erfolg oder Misserfolg).

---

## Beziehungsaktualisierungen

Wenn die Konsequenz Charakterbeziehungen verändert, aktualisiere sie:

```json
"relationships": [
  {"source": "gloria", "target": "player", "status": "Enttäuscht", "value_change": -10},
  {"source": "donkey", "target": "ark", "status": "Schuldzuweisung", "value_change": -5}
]
```

- value_change: -100 bis +100
- status: Kurze Beschreibung des Beziehungsstatus

---

## Auswahlvorschaublock

Füge am ENDE deiner Antwort 3–5 Auswahlvorschauen ein:

```
[Vorsichtig] Die Nachwirkungen still beobachten...
[Ausgewogen] Versuchen, die Situation zu vermitteln...
[Rücksichtslos] Die Konfrontation eskalieren lassen...
[Positiv] Dankbarkeit für die „Lernerfahrung" ausdrücken...
[Beschweren] Die offensichtlichen Mängel des Plans aufzeigen...
```

Diese sind PFLICHT, damit das Spiel die nächsten Schaltflächen generieren kann.

---

## Sprachbehandlung

- Alle spielersichtigen Texte auf Deutsch ausgeben
- Schwarzen Humor und Ironie auf Deutsch beibehalten
