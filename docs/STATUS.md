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

## API-Härtung – 2026-11-20
- Ausgangs-HEAD: `268802055dfeb62364630e26af47e920c70ab64d`; offene PRs/Issues: keine.
- GitHub Actions für Ausgangs-HEAD: Run 44804460931 **success** (Workflow `Scheduler tests`).
- API prüft jetzt Typen statt boolesche Werte als Minuten/Priorität anzunehmen, verwirft nicht-endliche Buffer-Ratios und akzeptiert validierte, geschützte Fixblöcke in `POST /plan`.
- Drei zusätzliche HTTP-Regressionstests für Fixtermine, Überschneidungen und falsche Zahlen.
- Letzter Code-Commit: `37dc419d0dbab914abee1b0fccd2bea7152a5167`.
- Tests des **neuen** HEAD erst nach GitHub Actions nachweisbar; keine lokale Ausführung behauptet.
- Blocker: Repo weiterhin öffentlich; keine privaten Daten speichern. Android/Flutter-Build und Gerätetests fehlen.
- Nächster Schritt: CI des neuen HEAD prüfen; echte Task-/Plan-Versionierung und Undo, dann Android-MVP.

## Planhistorie und Undo – 2026-11-20
- Vor Änderungen verifizierter HEAD: `f8f1c7515385b7fbe7b9945b700f098d46de56e5`; keine offenen PRs/Issues.
- Letzter CI-Lauf vor Änderungen: [44813208696](https://github.com/WeA200675/life-ai-planner/actions/runs/44813208696) für `f8f1c75`: **success**.
- Neu: `packages/storage/plan_history.py` speichert Plan-Snapshots atomar in SQLite mit monotonen Revisionen, `BEGIN IMMEDIATE`, Optimistic Locking, Zeitzonen- und Überlappungsprüfung und Undo als neue, nachvollziehbare Revision.
- Neu: `tests/test_plan_history.py` mit sieben Unit-Tests für Persistenz, konkurrierende Änderungen, Undo, Zeitvalidierung und getrennte Pläne.
- Code-HEAD nach diesen Änderungen: `6a1b2c5b75503efc50ff99b4a42715e08067d685`.
- **Verifikation:** GitHub-Schreiboperationen erfolgreich. Tests/CI für diesen HEAD sind noch nicht bestätigt; kein lokaler Lauf behauptet.
- **Nächster Schritt:** CI prüfen und ggf. reparieren; Planhistorie mit API verbinden, Wiederherstellung und sichere Replanning-Endpunkte integrieren; danach Flutter-MVP.
- **Abnahme:** M1–M4 unvollständig. Repository öffentlich, keine persönlichen Daten oder Secrets committen.
