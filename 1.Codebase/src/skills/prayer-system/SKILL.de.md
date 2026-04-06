---
name: prayer-system
description: Regeln zum Generieren verdrehter Gebetskonsequenzen – Gebete werden oberflächlich erhört, verursachen aber größere Katastrophen.
purpose_triggers:
  - prayer
---

# Gebetssystem – Katastrophengenerierung

## Übersicht

Der Spieler betet zum „Fliegenden Spaghettimonster". Gebete werden oberflächlich „erhört", verursachen aber tatsächlich größere Katastrophen. Dies ist die zentrale Ironie der toxischen Positivitätssatire des Spiels.

## Eingabevariablen

- `{prayer_text}`: Der Gebetsinhalt des Spielers
- `{reality_score}`: 0–100 (niedriger = anfälliger für Verzerrung)
- `{positive_energy}`: 0–100 (höher = blinderer Optimismus)
- `{distortion_level}`: Basiert auf dem Reality Score

### Verzerrungsstufen

| Reality Score | Deutsch |
|--------------|---------|
| < 30 | äußerst verzerrt und katastrophal |
| 30–49 | stark verzerrt |
| 50–69 | verzerrt |
| ≥ 70 | subtil verzerrt |

---

## Deutsche Prompt-Vorlage

```
Spieler betet zum „Fliegenden Spaghettimonster": „{prayer_text}"

Reality Score des Spielers: {reality_score}/100 (niedriger = anfälliger für Verzerrung)
Positive Energie des Spielers: {positive_energy}/100 (höher = blinderer Optimismus)

Generiere eine {distortion_level}e Konsequenz (150–200 Wörter):

1. Erhört das Gebet des Spielers oberflächlich
2. Verursacht aber tatsächlich eine größere Katastrophe
3. Nutzt Ironie, um die Absurdität des „positiven Denkens" aufzuzeigen
4. Der Schweregrad der Katastrophe ist umgekehrt proportional zum Reality Score

Beispiellogik:
- Gebet für „Weltfrieden" → Alle werden gehirngewaschen und verlieren ihr Selbstbewusstsein
- Gebet zur „Beseitigung von Negativität" → Alle Menschen, die die Realität wahrnehmen können, werden eliminiert
- Gebet, „alle glücklich zu machen" → Zwangsweise verabreichte „Glückshormone" führen zum gesellschaftlichen Zusammenbruch

Generiere das verzerrte Ergebnis dieses Gebets und behalte dabei den schwarzen Humor bei.
```

---

## Ausgabeanforderungen

- 150–200 Wörter, die die verdrehte Konsequenz beschreiben
- Schwarzen Humor und Ironie beibehalten
- Die Katastrophe soll sich wie eine „Affenpfoten"-Wunscherfüllung anfühlen
- Subtile Hinweise einbeziehen, dass das Gebet des Spielers dies verursacht hat
