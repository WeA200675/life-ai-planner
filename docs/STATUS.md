# Entwicklungsstatus – 2026-11-20

## Verifizierter Ausgangszustand
- Initialer HEAD: `e70b32f9b33dc143c091818006f01b09dbff46fd`.
- Vor diesem Lauf: keine offenen Issues, PRs oder GitHub Actions Runs; nur README und Implementierungsplan.
- Repository ist **öffentlich** (GitHub API: `private=false`), entgegen der früheren Empfehlung für ein privates Repository. Keine persönlichen Daten committen.

## Dieser Entwicklungsschritt
- Erster unabhängiger, deterministischer Python-Scheduler mit unveränderlichen Fixterminen, 70/30-Zeitbudget, Prioritäten, Deadlines, explizit verschobenen Aufgaben, Konflikten und Eingabevalidierung.
- Fünf unittest-Testfälle und GitHub-Actions-CI ergänzt.
- Keine Laufzeit- oder CI-Ergebnisse behauptet: GitHub Actions muss nach Commit erst laufen. Lokale Toolchain-/Gerätetests ausstehend.

## Nächste Schritte
1. CI-Ausführung prüfen und alle Fehler korrigieren.
2. Zeitgrenzen, Sommerzeit, Abhängigkeiten, Pausen und inkrementelle Umplanung testen.
3. Persistente Aufgabenmodelle und API mit SQLite-Fallback und PostgreSQL-Migrationen aufbauen.
4. Flutter-MVP und Sprach-Textfallback implementieren.

## Abnahme
M1–M4 nicht abgeschlossen; kein APK-Build oder Android-Gerätetest nachgewiesen.
