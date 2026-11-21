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

## API-Planhistorie – 2026-11-20 (später Lauf)
- Vor Beginn: HEAD `05bf6ea32d327b8a4d5f40ae59ac355867ebb9ca`; keine offenen Issues oder PRs.
- GitHub Actions für Ausgangs-HEAD: Run [44819750555](https://github.com/WeA200675/life-ai-planner/actions/runs/44819750555) erfolgreich abgeschlossen.
- `services/api/server.py`: neue lokale Endpunkte `GET /plans/{id}/latest`, `POST /plans/{id}/commit`, `POST /plans/{id}/undo`. Revisionen werden atomar in derselben SQLite-Datei wie Tasks gespeichert. Stale Revision liefert HTTP 409; unzulässige Eingaben HTTP 400.
- `tests/test_plan_revision_api.py`: vier neue HTTP-Testfälle (Commit/Undo, 409-Konflikt, ungültige Payloads, fehlender Plan); `tests/__init__.py` für stabile Testimporte.
- Letzter Code-Commit: `15c62ba6e1aa36eb78341fc14c20d057a03ee990`.
- **Verifikation:** GitHub Actions für diesen Code-HEAD [44822342644](https://github.com/WeA200675/life-ai-planner/actions/runs/44822342644) zum Prüfzeitpunkt **queued**, Ergebnis offen. Kein lokaler Testlauf behauptet.
- **Offen:** API-Authentifizierung vor Netzwerkfreigabe, SQLite-Migrationsstrategie, Abhängigkeiten/Pausen/Zeitzonen-Härtung, Flutter-Android-MVP, STT/Textfallback, optionale Biometrie und Reflexion, vollständige M1–M4-Abnahme. Repo ist öffentlich: keine persönlichen Daten committen.
- **Nächster Schritt:** CI für neuen HEAD kontrollieren und ggf. reparieren; sichere API-Versionierung weiter härten, danach Flutter-MVP aufbauen.

## Zeitzonen-/DST-Härtung – 2026-11-20 (23:20 Europe/Berlin)
- Vor diesem Lauf HEAD `e073ec59e41503a77a4052e9378de5ac77b1c51c`; offene Issues/PRs: jeweils 0.
- Vorheriger CI-Lauf [44822367253](https://github.com/WeA200675/life-ai-planner/actions/runs/44822367253): **success**.
- Scheduler rechnet jetzt auf UTC-Instanten, sodass die tatsächliche verstrichene Zeit beim Sommerzeitwechsel für Kapazität, Puffer und Slotbelegung maßgeblich ist. Naive Deadlines und Fixtermine werden ausdrücklich abgewiesen.
- Vier zusätzliche Regressionstests: Sommerzeitbeginn, Sommerzeitende, naive Deadline und gemischte Zeitzonen.
- Code-Commits: `26a68b6fdafb7a93f9036d7804458c913a63cff2`, `c8eb0b2f5ca468169ee72935d390c32e1b3e648a`, Testkorrektur `1d5257adbad0211677ce48e0d8c16e6002399b4e`.
- **Verifikation:** GitHub-Commits bestätigt; CI für diesen letzten Stand beim Schreiben noch nicht abgeschlossen. Kein lokaler Testlauf behauptet.
- **Nächste Schritte:** CI-Ergebnis des letzten Commits prüfen und ggf. reparieren; anschließend sichere SQLite-Migrationen, API-Validierung und Flutter-Android-MVP.
- **Blocker:** keine Geräteabnahme, kein Android-Release-Build; Repository öffentlich, keine privaten Daten committen. M1–M4 noch offen.

## CI-Reparatur – 2026-11-20 (Folgelauf)
- Vor Änderung HEAD `f22f8d710c9c7b045826091973aa94ef922449a7`; offene Issues 0, offene PRs 0.
- GitHub Actions [44828198466](https://github.com/WeA200675/life-ai-planner/actions/runs/44828198466): **failure**, 57 ausgeführte Tests, drei Fehlschläge durch dieselbe veraltete Assertion in `tests/test_local_api.py` (auch über importierende Testklassen ausgeführt).
- Ursache: Nach DST-Härtung serialisiert der Scheduler UTC-Zeitpunkte. Der Test verglich die Offset-Darstellung `09:00+00:00` mit `10:00+01:00` als Zeichenkette, obwohl beide denselben Zeitpunkt beschreiben.
- Korrektur: Der Test vergleicht jetzt `datetime.fromisoformat`-Zeitpunkte, sodass gleichwertige Offsets akzeptiert werden; die Fixtermin-Schutzprüfung bleibt bestehen.
- Korrektur-Commit: `9f4c7002c1a4a147726070eb7b8658aa770399bb`.
- **Verifikation:** Ursache anhand echter CI-Logs belegt und Änderung auf GitHub committed. CI für den Korrektur-Commit noch nicht bestätigt; kein lokaler Testlauf behauptet.
- **Nächster Schritt:** CI für `9f4c700` prüfen; falls grün, SQLite-Migrationsstrategie und Flutter-Android-MVP priorisieren. M1–M4 weiterhin unvollständig.

## Transaktionale SQLite-Migrationen – 2026-11-21 (00:22 Europe/Berlin)
- Vor dem Lauf zuletzt dokumentierter HEAD: `857f671e1f032697db6b9dfc737f9683ec5c5283`; GitHub-Commitliste und offene Issues geprüft (0 offene Issues einschließlich PRs laut GitHub-Issue-Suche).
- Neu: `packages/storage/migrations.py` führt Schema-Version 0 → 1 transaktional mit `BEGIN IMMEDIATE` aus; bestehende Aufgaben bleiben erhalten, inkompatible Legacy-Schemas und unbekannte höhere Datenbankversionen werden sicher zurückgewiesen.
- `TaskStore` startet jetzt über die zentrale Migration statt die Versionsnummer ungeprüft zu überschreiben.
- `tests/test_migrations.py`: sechs neue Regressionstests (Neuanlage, Idempotenz, Datenübernahme, Future-Version, inkompatibles Schema, aktive Transaktion).
- Commits: `018c2bffde7af793363d6e883bc07f84c14bcac6`, `703dcf454fe0c863c5ef546e43305b15b0594f9f`, `4a234002b4187d1d29fb25905f19230989cefeb6`.
- **Testnachweis:** GitHub-Änderungen bestätigt. Lokaler Klon/Testlauf blockiert durch DNS-/Netzwerkfehler (`Could not resolve host: github.com`); keine lokale Testausführung und kein grüner CI-Lauf für diese Änderungen behauptet. GitHub Combined Status für vorherigen HEAD lieferte keine klassischen Statuschecks; das belegt keinen CI-Erfolg.
- **Blocker:** Laufzeitverifikation und Flutter-/Android-Geräteabnahme ausstehend. Öffentliches Repository: keine personenbezogenen Daten oder Geheimnisse committen.
- **Nächster Schritt:** GitHub-Actions-Workflow-Ergebnis des neuen HEAD prüfen und gegebenenfalls Fehler korrigieren; anschließend SQLite-Backup/Restore und Flutter-MVP implementieren.
- **Abnahme:** M1–M4 nicht vollständig.


## Offline SQLite Backup/Restore – 2026-11-21 (00:42 Europe/Berlin)
- Ausgangs-HEAD: `90da0eb5e50dfab7391d25300c206016ef93f7eb`; offene Issues 0, offene PRs 0. GitHub Actions [44836361432](https://github.com/WeA200675/life-ai-planner/actions/runs/44836361432) für diesen Ausgangs-HEAD: **success**.
- `packages/storage/backup.py`: konsistentes SQLite-Online-Backup statt unsicherer Dateikopie (WAL-kompatibel), Integritäts-/Schemaversionprüfung, exklusive Veröffentlichung ohne Überschreiben, Wiederherstellung ausschließlich in neuen Zielpfad. Bestehende Datenbanken werden niemals automatisch ersetzt.
- `tests/test_backup.py`: sieben neue Regressionstests für Snapshot/Restore, Snapshot-Isolation, Überschreibschutz, beschädigte Backups, zukünftige Schemas und fehlende Quelle.
- Commits: `28de7141dd8cf6ecd67bb2878fb2564f1263e390` (Code), `fb63f8e85cf143cbfed779e70f1cd0324d6d6d7b` (Tests).
- **Testnachweis:** Letzter vor Änderungen abgeschlossener CI-Lauf war grün. Neuer Workflow [44838816178](https://github.com/WeA200675/life-ai-planner/actions/runs/44838816178) beim Prüfen **queued**; keine erfolgreiche Ausführung für den neuen Code behauptet. Lokaler Klon wegen DNS `Could not resolve host: github.com` blockiert.
- **Einschränkungen:** Restore absichtlich nur in neue Datei; eine produktive Umschaltung muss bei geschlossenen Verbindungen separat, abgesichert und mit Rollback erfolgen. Backups sind unverschlüsselt und müssen lokal geschützt werden. Keine Cloud-Exposition.
- **Nächster Schritt:** CI des neuen HEAD prüfen, Fehler beheben, Backup/Restore bei WAL-Parallelzugriff zusätzlich testen und Flutter-Android-MVP priorisieren.
- **Abnahme:** M1–M4 weiterhin offen; Android-Build und Geräteabnahme fehlen.


## WAL-Snapshot-Regression – 2026-11-21 (01:20 Europe/Berlin)
- Ausgangs-HEAD vor Änderung: `422d13436ee2b928b6598b12210bc5601ad0861f`. Offene Issues: 0, offene PRs: 0 (GitHub-Suchen).
- Zusätzliche Regressionstests in `tests/test_backup.py`: (1) committed WAL-Eintrag wird im Snapshot erhalten, obwohl noch kein Checkpoint erzwungen wurde; (2) uncommitted WAL-Eintrag wird nicht in den Snapshot übernommen. Beide Tests verwenden ausschließlich synthetische Daten.
- Test-Code-Commit: `6ec1469026cf31cfc35502016512531f710c85d6`.
- **Testnachweis:** Commit auf GitHub bestätigt. Keine lokale Ausführung und kein CI-Ergebnis für diesen Commit verifiziert; grüne Tests werden nicht behauptet.
- **Blocker:** GitHub Actions für den neuen HEAD prüfen, Flutter-Toolchain/Android-Gerät für Build und Abnahme fehlen; Backup-Verschlüsselung und sichere Restore-Umschaltung noch offen.
- **Nächster Schritt:** GitHub Actions für `6ec1469` prüfen und gegebenenfalls korrigieren; danach Android-Flutter-MVP (lokale Taskliste, Textinput, Tagesansicht) priorisieren.
- **Abnahme:** M1–M4 weiterhin offen.

## Flutter Offline-Text-MVP – 2026-11-21 (Folgelauf)
- Ausgangs-HEAD vor Änderungen: `667ce62b459ea0b7ed1825eb69185618139256ac`. Offene GitHub-Issues/PRs: 0 (Issue-Suche). Combined Status des Ausgangs-HEAD enthielt keine klassischen Statuschecks; dies ist **kein** CI-Erfolgsnachweis.
- Neuer Flutter-Quellcode unter `apps/mobile/lib/main.dart` mit lokalem SQLite-Taskstore, Texteingabe (Offline-Fallback), Taskliste, Abschlussmarkierung, Fehleranzeige und Eingabevalidierung. `apps/mobile/pubspec.yaml` enthält Flutter-, sqflite- und path-Abhängigkeiten. `apps/mobile/README.md` dokumentiert Buildschritte und Grenzen.
- Code-Commits: `012b79d9a200bd4a2260754acbf11506d2129c41`, `6489d0820f685e8933b221cf0bf79dcbf71ea78f`, `39343c3505c1af37aa898450fa872e75d351d4c3`.
- **Testnachweis:** GitHub-Dateien erfolgreich angelegt. Weder Flutter SDK/Android Toolchain noch Flutter-Testausführung oder APK-Build in diesem Lauf nachgewiesen. Mobile-Code daher ausdrücklich **unverifiziert**. Android-Plattformverzeichnis fehlt und muss generiert und eingecheckt werden.
- **Blocker:** fehlende Android-Plattformdateien, Flutter-/Android-Build- und Gerätetests; keine gemeinsame Datenbankschema-/Sync-Integration mit Python. Repo öffentlich; keine Secrets oder personenbezogenen Testdaten.
- **Nächster Schritt:** Android-Plattformgerüst erzeugen; Flutter Analyze/Tests/Debug-APK in CI ausführen; Fehler korrigieren und anschließend lokale Tagesplanung mit Scheduler-Anbindung und Sprach-Textfallback erweitern.
- **Abnahme:** M1–M4 weiterhin nicht vollständig.


## Flutter-Testautomatisierung – 2026-11-21 (02:20 Europe/Berlin)
- Ausgangs-HEAD `1b07d0fe22bfc3af839cf984e84d6b575bcbb55c`; offene Issues/PRs 0 laut GitHub-Suche.
- `apps/mobile/test/offline_task_test.dart`: zwei Flutter-Testfälle für lokale Titelvalidierung ohne SQLite-Initialisierung und Sichtbarkeit der Offline-Texteingabe.
- `.github/workflows/flutter.yml`: separater GitHub-Actions-Job für `flutter pub get`, `flutter analyze`, `flutter test` bei Mobile-Änderungen und manuellem Dispatch; kein Android-APK-Build vorgetäuscht.
- Commits `b1eba6143f84fc7246e62503795e8bc2447af07a` (Tests), `a62e0bb93d56d04519edb02f33e63322c62e2556` (Workflow).
- **Testnachweis:** Dateien erfolgreich über GitHub API committed. Flutter-Tests/Analyse und neuer CI-Lauf noch nicht als erfolgreich nachgewiesen; CI-Ergebnis nach Start abwarten und Fehler beheben.
- **Blocker:** Android-Plattformgerüst und reproduzierbarer APK-Build fehlen; kein Gerätetest, keine Scheduler-Integration in Flutter. Repository öffentlich: keine Secrets oder personenbezogenen Daten.
- **Nächster Schritt:** Flutter-Workflow-Ergebnis prüfen, Lint-/Testfehler beheben, Android-Plattformdateien mit passender Toolchain generieren und Debug-APK bauen; danach lokale Tagesansicht und Scheduler-Anbindung.
- **Abnahme:** M1–M4 weiterhin offen.

## Android-APK-CI-Fallback – 2026-11-21 (02:38 Europe/Berlin)
- Vor Änderung HEAD `c110972e6559dc64b25fd67a4e030aa66b01eb6e`; GitHub-Suche ergab keine offenen Issues/PRs. Combined Status des Ausgangs-HEAD lieferte keine klassischen Statuschecks; dies ist kein Nachweis eines erfolgreichen Actions-Laufs.
- `.github/workflows/flutter.yml` erweitert: Flutter- und Java-Versionen werden protokolliert; nach `flutter pub get`, `flutter analyze` und `flutter test` wird das fehlende Android-Plattformgerüst mit `flutter create --platforms=android --project-name life_ai_planner .` im CI-Workspace generiert und ein Debug-APK gebaut. Das Artefakt wird nur bei erfolgreichem Build für sieben Tage hochgeladen; fehlendes APK lässt den Job scheitern.
- Code-/Workflow-Commit: `3960f6aab7b5f3ad61470941a64489f376b8214e`. Der generierte Android-Code ist **noch nicht** ins Repository eingecheckt; dies ist ein CI-Fallback, kein bestätigter reproduzierbarer Release-Build.
- **Verifikation:** GitHub-Commit bestätigt. Kein lokaler Flutter-/Android-Lauf; der neue CI-Job und APK-Build sind zum Dokumentationszeitpunkt nicht als erfolgreich nachgewiesen. Workflow verwendet den beweglichen Flutter-Stable-Kanal; für langfristige Reproduzierbarkeit ist eine konkrete SDK-Version samt Lockfile nötig.
- **Blocker:** Android-Geräteabnahme, Release-Signierung, lokale Scheduler-Integration und M1–M4-Gesamtabnahme stehen aus. Repo öffentlich; keine Secrets oder privaten Daten eingecheckt.
- **Nächster Schritt:** Actions-Lauf für `3960f6a` prüfen, konkrete Fehlermeldungen korrigieren, Flutter-Version pinnen, Android-Plattformdateien kontrolliert einchecken und danach Offline-Tagesplanung implementieren.
