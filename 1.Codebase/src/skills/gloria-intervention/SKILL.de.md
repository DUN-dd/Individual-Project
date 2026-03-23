---
name: gloria-intervention
description: Regeln zum Generieren von Glorias Positivenergie-Bombardierung, wenn die Positive Energie des Spielers zu niedrig ist.
purpose_triggers:
  - gloria_intervention
  - gloria
---

# Glorias Positivenergie-Bombardierung

## Übersicht

Wenn die Positive Energie des Spielers zu niedrig sinkt, greift Gloria mit einer Rede ein, die vor toxischer Positivität trieft. Dies ist eine eigenständige Intervention – KEIN Teil des Haupthandlungsflusses.

## Auslösebedingungen

- Positive Energie des Spielers ≤ 30
- Ausreichend Runden seit der letzten Intervention (Abklingzeit)
- Nicht während des Nachtzyklus

---

## Redeanforderungen

### Länge
- 80–120 Wörter (kurz und wirkungsvoll)
- Dies ist eine schnelle Intervention, kein Monolog

### Tonalität
- Toxische Positivität als Fürsorge getarnt
- Passiv-aggressive Süße
- Gaslighting als Besorgnis präsentiert
- Emotionale Manipulation (PUA-Taktiken)

---

## Inhaltsstruktur

### Deutsche Version
```
=== Glorias Positivenergie-Bombardierung ===

Die Positive Energie des Spielers ist zu niedrig, also greift Gloria ein.
Spieler hat gerade gewählt: {choice_text}

Schreibe eine KURZE Rede von 80–120 Wörtern, triefend vor toxischer Positivität:
1. Vorgeben zu helfen, während gaslighting betrieben wird
2. Den Spieler für seine „Negativität" verantwortlich machen
3. Absurden Optimismus und Gehorsam einfordern

WICHTIGE EINSCHRÄNKUNGEN:
- Dies ist eine eigenständige Intervention, NICHT die Hauptgeschichte
- KEINE Entscheidungen oder Auswahlvorschauen generieren
- KEIN [Choice Preview] oder irgendwelche Auswahllisten einbeziehen
- NUR Glorias Rede ausgeben, KURZ halten (max. 80–120 Wörter)
```

---

## Glorias Redemuster

### Häufige Phrasen
- „Ich bin nicht wütend, nur enttäuscht von deinen Entscheidungen."
- „Wir sind eine Familie hier. Familien unterstützen sich bedingungslos."
- „Deine Negativität schadet dem Team. Ist das, was du willst?"
- „Ich will nur das Beste für dich. Warum kannst du das nicht sehen?"
- „Das Universum gibt zurück, was wir hineinstecken. Wähle Positivität!"

### Taktiken
1. **Falsche Empathie**: „Ich verstehe, dass du kämpfst, ABER..."
2. **Schuldgefühle**: „Nach allem, was wir für dich getan haben..."
3. **Gaslighting**: „Du bist gar nicht wirklich verärgert, du bist nur müde."
4. **Ziele verschieben**: „Das ist gut, aber du könntest noch mehr lächeln."
5. **Opferumkehr**: „DEINE Negativität verletzt MICH."

---

## Szenenanweisungen

```
[SCENE_DIRECTIVES]
{
  "characters": {
    "gloria": {"expression": "happy"}
  }
}
[/SCENE_DIRECTIVES]
```

Gloria sollte typischerweise „happy" oder „sad" (enttäuscht) zeigen.
Der Redeinhalt soll NACH dem Szenenanweisungsblock erscheinen.

---

## Wichtige Hinweise

- Diese Intervention generiert KEINE Entscheidungen
- Nach der Intervention kehrt das Spiel zum normalen Ablauf zurück
- Die Intervention soll unangenehm und peinlich wirken
- Spieler sollen sich unter Druck gesetzt, aber auch die Manipulation durchschauen
