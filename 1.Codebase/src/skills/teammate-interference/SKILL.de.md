---
name: teammate-interference
description: Regeln zum Generieren von Teamkollegen-Interferenzszenen, in denen Teamkollegen auf dysfunktionale Weise „helfen".
purpose_triggers:
  - teammate_interference
  - interference
---

# Regeln zur Teamkollegen-Interferenz

## Übersicht

Teamkollegen-Interferenz tritt auf, wenn ein Teamkollege versucht, dem Spieler zu „helfen", dies aber auf eine Weise tut, die seine dysfunktionale Persönlichkeit widerspiegelt. Das Ergebnis ist meist Chaos, Komplikationen oder dass die Dinge schlimmer werden.

## Normalmodus (Keine Honeymoon-Phase)

### Deutsche Version
```
=== Teamkollegen-Interferenz ===

Teamkollege {name} greift auf die denkbar schlechteste Weise ein.
Spieleraktion: {action}

Beschreibe ihren dysfunktionalen Versuch zu „helfen" (~150 Wörter).
- Treu zur Persönlichkeit des Archetyps bleiben
- Sie glauben, wirklich zu helfen
- Die „Hilfe" macht die Dinge schlimmer oder schafft neue Probleme
- Unerwartete Komplikationen erzeugen
- Anknüpfungspunkte für zukünftige narrative Folgen hinterlassen
```

---

## Honeymoon-Modus

### Deutsche Version
```
[HONEYMOON-PHASE AKTIV]

Teamkollege {name} versucht ausnahmsweise wirklich hilfsbereit und freundlich zu sein.
Spieleraktion: {action}

Beschreibe ihre „perfekte" Unterstützung (~150 Wörter).
- Sie sind verdächtig freundlich und kompetent
- Die Aktion gelingt, aber es wirkt unheimlich/beunruhigend
- Gefühl von „Ruhe vor dem Sturm" erzeugen
- Ihre Hilfsbereitschaft ist ZU perfekt, was den Spieler paranoid macht
- Hinweise, dass dieser Frieden nicht andauern kann
```

---

## Charakterspezifisches Verhalten

### Gloria (bei Interferenz)
- Nutzt die Interferenz als Lehrmoment
- Weist passiv-aggressiv darauf hin, dass der Spieler Hilfe braucht
- Lässt den Spieler schuldig fühlen, Hilfe zu benötigen
- „Ich wusste, dass du mich brauchen würdest. Das ist das, wofür Familie da ist!"

### Donkey (bei Interferenz)
- Verwandelt eine einfache Aufgabe in eine epische Quest
- Hält eine dramatische Rede, bevor er etwas tut
- Nimmt Verdienst für jeden Erfolg in Anspruch, gibt anderen die Schuld für Misserfolge
- Wechselt mitten im Satz zu gebrochenem Deutsch, um autoritär zu klingen, obwohl er die Wörter eindeutig nicht kennt – stolpert, missausspricht, füllt Lücken mit „...ja, ja" oder Gesten
- „Fürchtet euch nicht! Ein Ritter verlässt niemals seinen... warte, was haben wir gemacht?"

### ARK (bei Interferenz)
- Erstellt einen übermäßig komplexen Plan für ein einfaches Problem
- Weigert sich, den Plan klar zu erklären
- Fühlt sich beleidigt, wenn nach dem Plan gefragt wird
- Fragt scheinheilig nach dem Beitrag aller, macht dann aber genau das, was er immer geplant hatte
- Gibt so vage Anweisungen, dass Teamkollegen raten müssen – weist das Ergebnis dann ab und verlangt einen völligen Neustart
- „Du würdest die Eleganz meines Ansatzes nicht verstehen."
- „Das... ist nicht ganz richtig. Von vorne anfangen." (keine weitere Erklärung)

### One (bei Interferenz)
- Bietet minimale, kryptische Hilfe an
- Weiß offensichtlich einen besseren Weg, sagt es aber nicht
- Seufzt schwer und tut das absolute Minimum
- „...Gut. Ich erledige diesen Teil. Nur... sei vorsichtig."

---

## Szenenanweisungen

Charakterausdrucksaktualisierungen einbeziehen:

```
[SCENE_DIRECTIVES]
{
  "characters": {
    "{teammate_id}": {"expression": "expression_type"}
  }
}
[/SCENE_DIRECTIVES]
```

Verfügbare Ausdrücke: neutral, happy, sad, angry, confused, shocked, thinking, embarrassed
