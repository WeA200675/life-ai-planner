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

## Fortsetzung 2026-11-20 (Abendlauf)
- Ausgangs-HEAD vor diesem Lauf: `2aad3874e87952edc03684bf46c7a203f7286d76`.
- Neu: `packages/scheduler/calibration.py` mit deterministischer, begrenzter 14-Tage-Pufferkalibrierung; fehlende/ungültige Tage werden nicht als Null-Unterbrechungen gewertet.
- Neu: `tests/test_calibration.py` mit neun Regressionstests (Schrittgrenzen, Mindeststichprobe, Duplikate, Zeitfenster, ungültige Daten).
- Letzter Code-Commit dieses Laufs: `9d46f664631d08f35409f195e63d79dc8292eb43`.
- **Verifikation:** Dateien auf GitHub erstellt; lokale Ausführung und CI-Ergebnis für diese Änderungen noch nicht nachgewiesen.
- Nächste Schritte: CI-Status prüfen; Scheduler-Grenzfälle korrigieren; API und SQLite-Persistenz aufbauen; später Flutter und Android-Geräteabnahme.
- **Abnahme:** M1–M4 weiterhin offen. Keine vollständige Implementierung behauptet.

## Weitere Implementierung – 2026-11-20
- SQLite-basierte, lokale Task-Persistenz unter `packages/storage/sqlite_store.py` ergänzt (atomare Upserts, Wiederöffnung, Statusänderung, Filter, Zeitzonenprüfung).
- Sieben neue Unit-Tests unter `tests/test_sqlite_store.py`.
- Code-Commit: `983073f4ab22d7f942c4fe3aad7a01c764ba6276`.
- Testausführung/CI für diese Änderungen noch nicht verifiziert; daher kein grüner Status behauptet.
- Nächster Schritt: Scheduler-Integration mit Persistenz und HTTP-API, Migrationskonzept und Android-MVP.
- Gesamtprojekt weiterhin unvollständig; Geräteabnahme ausstehend.

## API-Implementierung – 2026-11-20
- Loopback-only HTTP-API für Health, Task-Upsert, Task-Liste und Tagesplanung in `services/api/server.py`.
- Vier HTTP-Integrationstests ergänzt; API-Beschreibung in `docs/LOCAL_API.md`.
- Sicherheitsgrenze: absichtlich keine externe Netzbindung ohne Authentifizierung/TLS.
- Code und Tests committed; Ausführung/CI noch nicht verifiziert.
- Nächste Schritte: CI kontrollieren, API-Eingaben härten, Datenmigrationen und feste Kalenderblöcke ergänzen, Android-MVP erstellen.
- M1–M4 nicht vollständig; kein Release oder Geräteabnahme.
