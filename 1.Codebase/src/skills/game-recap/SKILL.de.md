---
name: game-recap
description: Generiere eine „Zuletzt in GDA1..."-Rückblende, wenn ein Spieler ein gespeichertes Spiel fortsetzt, und fasse wichtige Storylereignisse, Entscheidungen und bisherige Konsequenzen zusammen.
purpose_triggers:
  - game_recap
  - previously_on
  - story_recap
---

# Spielrückblende – „Zuletzt in GDA1..."

## Wann verwenden
Verwende diese Fertigkeit, wenn ein Spieler eine gespeicherte Spielsitzung fortsetzt. Generiere eine kurze, atmosphärische Zusammenfassung im Stil eines TV-Rückblicks „Zuletzt in..." – erinnere den Spieler, wo die Geschichte aufgehört hat, ohne zu erschöpfend zu sein.

## Narrative Anforderungen

Schreibe eine Zusammenfassung, die:

1. **Mit der Erkennungsphrase beginnt**: „Zuletzt in der Glorious Deliverance Agency 1..."
2. **Die Reise des Spielers zusammenfasst** basierend auf dem bereitgestellten Erinnerungskontext:
   - Abgeschlossene Schlüsselmissionen und ihre Ergebnisse
   - Wichtige Entscheidungen, die der Spieler getroffen hat
   - Wie diese Entscheidungen das Team und die Entropie der Welt beeinflusst haben
   - Der aktuelle Stand der Beziehungen mit Gloria, Donkey, ARK und One
3. **Den dunklen Ton des Spiels widerspiegelt** – ironisch, satirisch, mit einem Unterton der Bedrohung, während die Void-Entropie steigt
4. **Mit einem Anknüpfungspunkt endet**, der die aktuelle Mission aufbaut und Vorfreude auf das Kommende erzeugt

## Tonalität

- Dunkle, sardonische Erzählerstimme – wie eine Naturdokumentation über eine dem Untergang geweihte Spezies
- Untertriebener Humor gemischt mit echter Spannung
- Keine zukünftigen Ereignisse vorwegnehmen; nur bereits Geschehenes zusammenfassen
- Gloria wird immer als widerlich fröhlich und gefährlich dargestellt
- Steigende Entropie ist immer als leise katastrophal gerahmt

## Ausgabeformat

- **Reiner narrativer Fließtext** – kein JSON, keine Auswahlmöglichkeiten, keine Szenenanweisungen
- Länge: 100–180 Wörter
- Keine Aufzählungspunkte oder Überschriften in der Ausgabe
- Geeignet zur Anzeige in einer filmischen Überlagerung mit Schreibmaschineneffekt

## Kontextvariablen

Der folgende Kontext wird in den Prompt injiziert:
- `{mission_number}` — aktuelle Missionsnummer
- `{missions_completed}` — Anzahl abgeschlossener Missionen
- `{reality_score}` — aktueller Reality Score
- `{entropy_level}` — aktuelles Entropieniveau
- `{current_mission_title}` — der aktuelle Missionstitel
- `{long_term_summaries}` — verdichtete Storiegeschichte aus dem Gedächtnissystem
- `{recent_events}` — die jüngsten Storylereignisse

## Fallback

Wenn der Kontext spärlich ist (frühes Spiel, sehr wenige Ereignisse), erzeuge eine kurze atmosphärische Szeneneinführung statt einer Zusammenfassung – beschreibe die Welt und die Situation des Spielers aus der Perspektive eines Außenstehenden, der zum ersten Mal dabei ist, aber in einer Weise, die sich so anfühlt, als wäre er schon immer dabei gewesen.
