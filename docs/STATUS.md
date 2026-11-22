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

## Flutter-CI-Reihenfolge – 2026-11-21 (03:16 Europe/Berlin)
- Vor Änderung verifizierter HEAD: `ca827641cc2f53a1f862b05002c83c5afe089981`; offene Issues 0, PRs 0 (GitHub-Suche).
- `.github/workflows/flutter.yml`: fehlendes Android-Gerüst wird nun **vor** `flutter pub get`, `flutter analyze` und `flutter test` erzeugt; bereits eingechecktes Gerüst wird nicht überschrieben. `--no-pub` verhindert einen unnötigen doppelten Dependency-Resolve. AndroidManifest wird explizit geprüft, bevor Tests/Build starten.
- Code-Commit: `1898c83143a054857626d48fb685edc57040ec45`.
- **Testnachweis:** GitHub-Commit bestätigt; Combined Commit Status des Ausgangs-HEAD enthielt keine klassischen Checks (kein CI-Erfolgsbeleg). Für den neuen Commit wurde weder ein grüner Flutter-Workflow noch ein APK-Build oder Gerätetest nachgewiesen. Kein lokaler Flutter-SDK-Lauf verfügbar.
- **Blocker:** Generiertes Android-Gerüst noch nicht versioniert, Toolchain-Version nicht gepinnt, Release-/Geräteabnahme fehlt; M1–M4 offen. Repository öffentlich: keine personenbezogenen Daten oder Secrets.
- **Nächster Schritt:** Flutter-Actions-Logs für den neuen HEAD prüfen und Fehler beheben; Android-Gerüst/Lockfile reproduzierbar einchecken; danach Offline-Tagesplanung und Scheduler-Anbindung.

## Offline-Aufgabenfilter – 2026-11-21 (03:36 Europe/Berlin)
- Vor Änderungen verifizierter HEAD: `c35b5c2d50f5e7873f2e8935942c4e4416523978`; offene Issues 0, offene PRs 0.
- `apps/mobile/lib/main.dart`: offline nutzbare Ansichten **Offen**, **Erledigt**, **Alle** für bereits lokal gespeicherte SQLite-Aufgaben. Die Filterfunktion erhält die Reihenfolge und verändert keine gespeicherten Daten; eigene Leerzustandsmeldung bei leerem Filter.
- `apps/mobile/test/offline_task_test.dart`: zwei neue Tests für Filtersemantik, Eingabereihenfolge und sichtbare Umschaltoptionen.
- Code-Commits: `3b5956f3d22cf45a03ce48cfb9940ea495fac377`, Syntaxkorrektur `96e2500897795f0bef1b863856663968d5471ecc`, Tests `a152f19b558bdaff1a1bd7ef829d73c376b97735`.
- **Testnachweis:** GitHub-Commits und Dateiinhalte überprüft; lokale Flutter-/Dart-Toolchain nicht verfügbar. GitHub Combined Status für `a152f19` lieferte keine klassischen Statuschecks; dies bestätigt **keinen** erfolgreichen Flutter-Actions-Lauf. Die neuen Tests wurden nicht nachweislich ausgeführt, APK und Gerätetest fehlen.
- **Infrastrukturblocker:** Lokaler Git-Klon scheitert an DNS-Auflösung von github.com; Änderungen daher ausschließlich über GitHub-Connector mit Blob-SHA-Konfliktschutz vorgenommen. Android-Gerüst wird bisher nur im CI-Workspace erzeugt und ist nicht versioniert.
- **Nächster Schritt:** Flutter-Actions-Job und Logs überprüfen, ggf. Analyse-/Buildfehler beheben; danach Android-Gerüst und SDK/Lockfile reproduzierbar versionieren, Tagesplanung mit lokalem Scheduler integrieren.
- **Abnahme:** M1–M4 weiterhin offen; keine Gesamt-Abnahme behauptet.


## Flutter-CI-Fehlerbehebung – 2026-11-21 (04:24 Europe/Berlin)
- Ausgangs-HEAD vor Änderungen: `2bee66e94789649f5b368f137bd9954127b98e5b`; offene Issues 0, PRs 0.
- Tatsächlicher GitHub-Actions-Nachweis: Scheduler [44856857463](https://github.com/WeA200675/life-ai-planner/actions/runs/44856857463) **success**; Flutter [44856844796](https://github.com/WeA200675/life-ai-planner/actions/runs/44856844796) **failure**, Job 136700926264, Schritt `flutter analyze`.
- Log-Ursachen: überzählige schließende Klammer in `lib/main.dart:79`; automatisch erzeugter `test/widget_test.dart` referenziert nicht vorhandene `MyApp` und `material_ui`; Flutter 3.50.1 meldet zusätzliche `material.dart`-Deprecation-Infos.
- Code-Fix `7f2d1780eeb7917f3cf600aa42514671532915db`: überzählige Klammer entfernt. Workflow-Fix `8ea8002bd7f41e28d928ae2e2e4a3aaede6b5701`: ausschließlich beim Generieren des Android-Gerüsts den unpassenden Template-Test entfernen; Analyse mit `--no-fatal-infos`, damit Hinweise weiterhin sichtbar bleiben, aber nicht als Fehler gelten. Echte Analyzer-Fehler bleiben fatal.
- **Testnachweis:** Ursachen aus echten CI-Logs; Änderungen per GitHub-API committed. Für die Fixes liegt noch **kein** bestätigter erfolgreicher Flutter-Test oder APK-Build vor. Kein lokaler Flutter-Lauf behauptet.
- **Blocker:** CI-Ergebnis der Fixes abwarten; Android-Gerüst und Lockfile noch nicht versioniert, Geräte-/Release-Abnahme fehlt. Repo öffentlich, keine privaten Daten oder Secrets committen.
- **Nächster Schritt:** neuen Flutter-Actions-Lauf prüfen und verbliebene Analyzer-/Test-/Gradle-Fehler korrigieren; danach Android-Gerüst/SDK-Version pinnen und Offline-Tagesplanung integrieren.
- **Gesamtabnahme:** M1–M4 offen.


## Offline-Löschung mit Bestätigung – 2026-11-21 (04:40 Europe/Berlin)
- Vor Änderungen verifizierter HEAD: `5e58d089e87d95dbdade874cdd9e02aa9897dd82`; offene Issues und PRs: jeweils 0.
- Vorherige Flutter-CI [44860966659](https://github.com/WeA200675/life-ai-planner/actions/runs/44860966659) für `8ea8002`: **success**. Scheduler-CI [44860979021](https://github.com/WeA200675/life-ai-planner/actions/runs/44860979021) für `5e58d08`: **success**. Das belegt keine Tests für die neuen Änderungen.
- Neu in `apps/mobile/lib/main.dart`: lokale SQLite-Aufgabenlöschung über parametrisierte ID; expliziter Bestätigungsdialog mit Abbrechen-Option, Fehleranzeige und Sperre gegen parallele Löschaktionen. Kein Cloud-Zugriff erforderlich.
- Regressionstest in `apps/mobile/test/offline_task_test.dart`: ungültige Lösch-IDs werden vor Datenbankzugriff abgewiesen.
- Code-Commits: `15d16287b12f2c357800af8466e5627c69af8e1d` (Implementierung), `a5a66a56bd85677e99aeb061e313c0ce8e2c7fa5` (Test).
- **Verifikation:** GitHub-Commits bestätigt; neue Flutter-/Scheduler-CI nach Implementierungs-Commit beim Abruf **queued** ([Flutter 44862228129](https://github.com/WeA200675/life-ai-planner/actions/runs/44862228129)). Für Test-Commit noch kein abgeschlossenes Ergebnis verifiziert; kein lokaler Flutter-Testlauf und kein Gerätetest behauptet.
- **Blocker:** Flutter/Android lokal nicht verifiziert, APK und manuelle Geräteabnahme ausstehend; Repository öffentlich, daher keine Secrets oder personenbezogenen Testdaten.
- **Nächster Schritt:** CI für neuesten HEAD auswerten, bei Fehlern reparieren; anschließend Android-Plattformgerüst dauerhaft versionieren und lokale Tagesplanung/Scheduler-Anbindung ergänzen.
- **Gesamtabnahme:** M1–M4 weiterhin offen.


## Offline-Statusänderungen abgesichert – 2026-11-21 (05:17 Europe/Berlin)
- Vor Änderung HEAD `a47ec1e60e94d0efdf6d1696a6ab30e7b71a737c`; GitHub-Suche: 0 offene Issues, 0 offene PRs.
- `apps/mobile/lib/main.dart`: `setDone` lehnt nichtpositive IDs vor dem Datenbankzugriff ab und meldet fehlende/mehrdeutige Datensätze statt einen stillen Erfolg vorzutäuschen. Der UI-Toggle nutzt dieselbe Busy-Sperre wie Hinzufügen und Löschen; `finally` gibt sie auch bei Fehlern frei.
- `apps/mobile/test/offline_task_test.dart`: Regressionstest für ungültige Statusänderungs-IDs ohne SQLite-Zugriff.
- Code-Commit `b28f21ad3a7bf747a6b9d715e739937e225c7e00`; Test-Commit `daef336bfb6eca88390dd175e09635bc432b61b6`.
- **Verifikation:** GitHub-API bestätigte beide Commits. Für den Ausgangs-HEAD lieferte der klassische Combined-Status keine Checks; das ist kein Actions-Testnachweis. Flutter-/Android-Tests für diese Änderungen wurden in diesem Lauf nicht ausgeführt oder als grün bestätigt.
- **Blocker:** Flutter-/Android-Laufzeitverifikation, reproduzierbarer Android-Release-Build und Geräteabnahme ausstehend. Repository öffentlich: keine privaten Daten oder Secrets.
- **Nächster Schritt:** Flutter-Actions-Ergebnisse für den neuesten HEAD prüfen, bei Fehlschlag reparieren; danach Android-Plattformgerüst und lokale Tagesplanung/Scheduler-Anbindung priorisieren.
- **Gesamtabnahme:** M1–M4 weiterhin offen.


## Offline-Aufgabenbearbeitung – 2026-11-21 (05:42 Europe/Berlin)
- Vor Änderungen verifizierter HEAD: `9ce20d924f9af0d792da1449bd42f0d866600351`; GitHub-Suchen: 0 offene Issues, 0 offene PRs.
- Flutter-Actions-Lauf [44865415150](https://github.com/WeA200675/life-ai-planner/actions/runs/44865415150) für vorherigen Code-Commit `daef336`: **success**; Scheduler-Lauf [44865424597](https://github.com/WeA200675/life-ai-planner/actions/runs/44865424597) für Ausgangs-HEAD: **success**.
- Neu: Offline-Aufgaben können per Dialog bearbeitet oder ohne Änderungen abgebrochen werden. `LocalTasks.rename` prüft positive ID, nichtleeren Titel und maximal 500 Zeichen vor SQLite-Zugriff, aktualisiert parametrisiert und meldet fehlende Datensätze. UI nutzt Busy-Sperre und Fehleranzeige.
- Regressionstest für ungültige IDs/Titel vor SQLite-Zugriff ergänzt; ausschließlich synthetische Testwerte.
- Code-Commit `003e6c50b836427fae613d59390f7891e9e1db54`; Test-Commit `819ff95cfd2531cb457187fc24faf5df83908be1`.
- **Testnachweis:** GitHub bestätigte Commits. Neue Flutter-Actions-Ausführung [44867428272](https://github.com/WeA200675/life-ai-planner/actions/runs/44867428272) beim Abruf **queued**; kein erfolgreicher Testlauf für die neuen Änderungen nachgewiesen. Keine lokale Flutter- oder Android-Geräteausführung behauptet.
- **Blocker:** Android-Plattformgerüst/Lockfile noch nicht fest versioniert, Release-APK und Geräteabnahme fehlen; öffentliches Repository, keine privaten Daten oder Secrets.
- **Nächster Schritt:** neue Flutter-CI auswerten und Fehler korrigieren, anschließend Android-Gerüst reproduzierbar versionieren und Tagesplanung/Scheduler-Anbindung implementieren.
- **Gesamtabnahme:** M1–M4 offen.


## Offline-Suche – 2026-11-21 (06:18 Europe/Berlin)
- Ausgangs-HEAD vor Änderungen: `4edce45a6c3b1b8e01cdd2b44a2c9cf18296f56c`; 0 offene Issues, 0 offene PRs (GitHub-Suche).
- Vorherige Flutter-CI [44867428272](https://github.com/WeA200675/life-ai-planner/actions/runs/44867428272) für `819ff95`: **success**; Scheduler-CI [44867439207](https://github.com/WeA200675/life-ai-planner/actions/runs/44867439207) für `4edce45`: **success**.
- Neu: Offline-Aufgabensuche ohne Netzwerk, trim-/case-insensitiv, kombinierbar mit Offen/Erledigt/Alle; Suchfeld und Zurücksetzen; kein Ändern der SQLite-Daten. Regressionstest für Suchkombination, Leerabfrage und Quellreihenfolge sowie Widget-Testanpassung.
- Code-Commit: `df5126133528188c0f5d0355babdcb26c3b47087`; Test-Commit: `de3a300960581c8b930c0a7a902642179e74a225`.
- **Verifikation:** GitHub-API bestätigte beide Commits. Die vorherige CI ist grün, aber kein Testnachweis für neue Suche. Neuer Flutter-Test/Android-Build beim Dokumentieren nicht als erfolgreich verifiziert; kein lokaler Flutter-Lauf behauptet.
- **Blocker:** Android-Gerüst und Lockfile noch nicht versioniert; Release-APK und Geräteabnahme fehlen. Öffentliches Repository: keine personenbezogenen Daten/Secrets committen.
- **Nächster Schritt:** Flutter-CI für `de3a300` prüfen und Fehler beheben; danach Android-Gerüst/Lockfile reproduzierbar versionieren und lokale Tagesplanung mit Scheduler-Anbindung implementieren.
- **Gesamtabnahme:** M1–M4 weiterhin offen.

## Offline-Aufgabenstatistik – 2026-11-21 (06:40 Europe/Berlin)
- Ausgangs-HEAD vor Änderungen: `35438dd013381b562086c23c0f01c54d1f528ca7`; GitHub-Suchen: 0 offene Issues und 0 offene PRs.
- Flutter-MVP: offline berechnete Zähler für offene, erledigte und alle Aufgaben in der Oberfläche ergänzt; unabhängig von Suchbegriff/Filter, ohne neue SQLite-Tabelle, Netzwerk oder personenbezogene Testdaten.
- Regressionstests für gemischte und leere Aufgabenlisten sowie sichtbaren Zähler ergänzt.
- Code-Commit `12441c52a73d1d036b0f4e685ebc9054712a7597`; Test-Commit `9726094c040b7101a73775057b232f488ff55e91`.
- **Testnachweis:** GitHub-Schreiboperationen bestätigt; Flutter-Tests, Analyzer, Android-Build und neuer CI-Lauf für diese Commits in diesem Lauf **nicht** erfolgreich verifiziert. Der klassische Combined-Status des Ausgangs-HEAD enthielt keine Checks und belegt keinen Actions-Erfolg.
- **Blocker:** Android-Plattformgerüst/Lockfile nicht dauerhaft versioniert, Release-APK und Geräteabnahme fehlen; öffentliches Repository, keine Secrets oder persönlichen Testdaten.
- **Nächster Schritt:** Flutter-CI für `9726094` auswerten und gegebenenfalls reparieren; Android-Gerüst reproduzierbar einchecken und Offline-Tagesplanung mit Scheduler-Anbindung priorisieren.
- **Abnahme:** M1–M4 weiterhin offen.


## APK-Verifikation – 2026-11-21 (Priorität Android-Testbarkeit)
- Ausgangs-HEAD: `dc5166c86912370f38c6426c7a1569dd686379d0`; offene PRs/Issues: 0/0.
- Verifizierte vorherige CI: Flutter-Lauf [44872007704](https://github.com/WeA200675/life-ai-planner/actions/runs/44872007704) für `9726094` **success**; Scheduler-Lauf [44872017776](https://github.com/WeA200675/life-ai-planner/actions/runs/44872017776) für `dc5166c` **success**. Dies belegt nicht den neuen Workflow.
- Änderung: `.github/workflows/flutter.yml` prüft vor Artefakt-Upload jetzt APK-Datei auf Existenz und nichtleere Größe, ZIP-Archivintegrität via `unzip -t`, erstellt `app-debug.apk.sha256` und lädt APK und Prüfsumme gemeinsam hoch. Aufbewahrung 14 Tage. Code-Commit: `086f846398a8c7aeb7acf75221cb67753b02d922`.
- **Testnachweis/Blocker:** Die YAML-Änderung ist committed, aber ein neuer CI-Lauf für diesen Commit war beim Abruf noch nicht sichtbar; daher sind APK-Integritätsprüfung und SHA-256-Artefakt noch nicht als erfolgreich bestätigt. Kein Android-Gerätetest. Android-Plattformgerüst wird derzeit im CI generiert und ist noch nicht versioniert.
- **Nächster Schritt:** Flutter-Workflow für `086f846` abwarten bzw. auslösen, ZIP-/Checksum-Prüfung und Artefakt prüfen; anschließend Android-Gerüst dauerhaft versionieren und Offline-Tagesplanung mit Scheduler verknüpfen. M1–M4-Abnahme weiterhin offen.


## Lokale Tagesplanungs-Engine – 2026-11-21 (07:16 Europe/Berlin)
- Ausgangs-HEAD: `8dbd622d58f3893afa9e77cf296a1cdfa851fff8`; 0 offene PRs, 0 offene Issues.
- Neuer Flutter/Dart-Kern `apps/mobile/lib/offline_day_planner.dart`: rein lokale deterministische Zeitplanung mit Priorität, Deadline, geschützten unveränderlichen Fixblöcken, 70/30-Reserve, expliziten verschobenen Aufgaben/Konflikten und Eingabevalidierung. Zeitdifferenzen basieren auf tatsächlicher Dauer und vermeiden einfache DST-Wanduhrsubtraktion. Keine Netzwerk- oder Backend-Abhängigkeit.
- Neue Tests `apps/mobile/test/offline_day_planner_test.dart`: 70/30-Budget und Reihenfolge, Fixblock und freie Lücke, Deadline-Konflikt, ungültige Zeitfenster/Überlappung/Duplikate. Synthetische Testdaten.
- Code-Commit `0a20183c02096dd174fec7aac7a845f1ec8c11d1`; Test-Commit `049f2a6d8f77a373068792534c503de06b4c4415`.
- **Nachweis:** GitHub-Commits bestätigt. Flutter-Run [44874803474](https://github.com/WeA200675/life-ai-planner/actions/runs/44874803474) und Scheduler-Run [44874803429](https://github.com/WeA200675/life-ai-planner/actions/runs/44874803429) beim Abruf **queued**, kein neuer Test-Erfolg behauptet. Vorheriger Scheduler-Run [44874579428](https://github.com/WeA200675/life-ai-planner/actions/runs/44874579428) für `8dbd622` **success**; APK-Verifikations-Run [44874566880](https://github.com/WeA200675/life-ai-planner/actions/runs/44874566880) für `086f846` noch **in_progress**.
- **Grenzen/Blocker:** Dart-Engine ist noch nicht mit der SQLite-Taskliste oder einer Tagesansicht verbunden; Aufgaben besitzen bisher keine Dauerschätzung. Keine Flutter-/Android-Geräteabnahme, kein Release-APK-Nachweis. Python-/Dart-Scheduler-Parität nicht durch gemeinsame Testvektoren nachgewiesen. Repository öffentlich; keine privaten Daten/Secrets.
- **Nächster Schritt:** CI-Ergebnis und APK-Artefakt prüfen, eventuelle Fehler beheben; anschließend Dauer/Deadline lokal in SQLite migrieren, Tagesansicht mit Dart-Scheduler anbinden und Python/Dart-Konformitätstests ergänzen. M1–M4 weiterhin offen.


## Offline-Tagesvorschau aus SQLite – 2026-11-21 (07:42 Europe/Berlin)
- Vor Beginn HEAD `8c9969064d3488eab33d8ad28193c2f8d444d3d1`, offene PRs/Issues 0/0.
- Vorherige Flutter-CI [44874803474](https://github.com/WeA200675/life-ai-planner/actions/runs/44874803474) für `049f2a6` **success**, Scheduler-CI [44874817494](https://github.com/WeA200675/life-ai-planner/actions/runs/44874817494) für `8c99690` **success**.
- Neuer Adapter `apps/mobile/lib/offline_task_plan_adapter.dart`: offene SQLite-Aufgaben werden ohne Mutation und ohne Netzwerk in `DayTask` umgewandelt; erledigte Aufgaben bleiben aus der Planung; defekte IDs/Statuswerte lösen explizite Fehler aus. Solange die DB keine Dauer enthält, wird **transparent nur eine vorläufige 30-Minuten-Schätzung** verwendet.
- Flutter-UI: Button **Tagesvorschau** zeigt lokal geplante Blöcke, verbleibende Reserve und nicht einplanbare Aufgaben für 08:00–18:00. Es werden weder Termine geändert noch Planstände gespeichert. Fixtermine und echte Dauern sind noch nicht an die SQLite-Oberfläche angebunden.
- Commits: Adapter `ba223a5b18edd7e5d025b38a59c66b39d38f7207`, drei Regressionstests `924bfac90c47fd38a1b4ea758e5bd3e7ce328777`, UI `a68ec635e6459bae5e76f4f3dfafb82e2e39fe39`.
- **Verifikation:** GitHub bestätigte die Commits. Neue Flutter-CI [44876872213](https://github.com/WeA200675/life-ai-planner/actions/runs/44876872213) für `a68ec63` beim Abruf **queued**; vorheriger Flutter-Lauf [44876834672](https://github.com/WeA200675/life-ai-planner/actions/runs/44876834672) noch **in_progress**. Keine erfolgreiche neue Flutter-Testausführung oder Geräteabnahme behauptet.
- **Blocker/Nächster Schritt:** Flutter-CI prüfen, Fehler beheben; anschließend SQLite-Migration für individuelle Dauer/Deadline und geschützte Fixtermine, UI-Tests für Vorschau, echte Planpersistenz/Undo sowie Android-Geräteabnahme. M1–M4 offen. Keine personenbezogenen Testdaten oder Secrets committed.


## Offline-Planungsmetadaten – 2026-11-21 (08:20 Europe/Berlin)
- Ausgangs-HEAD `42da03f31960ada9972a952efdf288af64c83a07`; offene PRs/Issues 0/0.
- Vorheriger Flutter-CI-Lauf [44876872213](https://github.com/WeA200675/life-ai-planner/actions/runs/44876872213) für `a68ec63` **success**; Scheduler-CI [44876895408](https://github.com/WeA200675/life-ai-planner/actions/runs/44876895408) für `42da03f` **success**.
- Code-Commit `2a5310ac3f7688a1fed4933b90932f0ac107c96f`: `offline_task_plan_adapter.dart` verarbeitet pro offener Aufgabe optionale, validierte `minutes` (1–1440) und `priority` (0–10). Alte SQLite-Zeilen ohne Metadaten verwenden weiterhin 30 Minuten und Priorität 0; ungültige Werte erzeugen einen expliziten Formatfehler, statt unbemerkt in den Plan einzufließen.
- Test-Commit `7419177128768975cc5c3747a20763d76f60f25a`: drei Regressionstests für Prioritäts-/Dauerreihenfolge, Altbestand-Fallback und ungültige Metadaten ergänzt.
- **Testnachweis:** Flutter- und Scheduler-CI für den ersten Code-Commit beim Abruf noch `in_progress` ([Flutter 44879834214](https://github.com/WeA200675/life-ai-planner/actions/runs/44879834214)); der Test-Commit ist noch nicht durch erfolgreich abgeschlossene CI bestätigt. Keine lokale Flutter-Toolchain oder Geräteabnahme nachgewiesen.
- **Blocker:** Die SQLite-Tabelle speichert `minutes` und `priority` noch nicht; die Adapter-Erweiterung ist vorbereitet, aber in der UI noch nicht editierbar. Android-Gerätetest und M1–M4-Gesamtabnahme fehlen.
- **Nächster Schritt:** Neue CI-Läufe prüfen und Fehler beheben; anschließend SQLite-Migration (Version 2) für `minutes`/`priority`, sichere Eingabeoberfläche und Persistenztests ergänzen. Keine persönlichen Daten oder Secrets im öffentlichen Repository.


## Flutter SQLite-Migration v2 – 2026-11-21 (08:40 Europe/Berlin)
- Ausgangs-HEAD: `fafa1f1a49a594b177c8ff2160fcf0ce2567a790`; offene PRs/Issues 0/0. Vorherige Flutter-CI [44879843679](https://github.com/WeA200675/life-ai-planner/actions/runs/44879843679) für `7419177` und Scheduler-CI [44879855972](https://github.com/WeA200675/life-ai-planner/actions/runs/44879855972) für `fafa1f1` erfolgreich.
- `apps/mobile/lib/local_task_schema.dart`: neue SQLite-Schema-Version 2 mit optionalen Dauerminuten (1–1440) und Priorität (0–10), Datenbank-CHECK-Constraints; Migration aus v1 per ALTER TABLE ohne Löschen alter Aufgaben. Null-Dauer nutzt weiterhin den dokumentierten 30-Minuten-Fallback.
- `apps/mobile/lib/main.dart`: Datenbank öffnet mit Version 2, führt Upgrade aus und stellt validierte `setPlanningMetadata`-Speicherung bereit. UI-Bearbeitung der Werte ist **noch nicht** implementiert.
- Regressionstests mit `sqflite_common_ffi` prüfen Schema-Grenzen, nichtdestruktives Upgrade von v1 mit unveränderter ID/Titel/Status und Default-Werten.
- Commits: Schema `d15e7f9f519ee35e21ce286ea8f1e12631bf6431`, Integration `3d0f536aaeef35ccb8f0db574c05da5f528a12eb`, Testabhängigkeit `fa1ff2d07be4c6321379bdb990d45fa2a66e7907`, Tests `c33e4adfac4efbbc4870b94c36f9d3b864b4d30e`.
- **Verifikation:** GitHub-Commits bestätigt; Flutter-CI für `fa1ff2d` [44881299243](https://github.com/WeA200675/life-ai-planner/actions/runs/44881299243) beim Abruf `in_progress`. Für den Test-Commit noch kein erfolgreich abgeschlossener Lauf bestätigt. Lokale Dart/Flutter- und Android-Gerätetests nicht ausgeführt; kein grüner neuer Teststatus behauptet.
- **Blocker/Nächster Schritt:** CI für den neuesten HEAD prüfen und Fehler reparieren; UI zum Editieren von Dauer/Priorität hinzufügen, Migration auf echter Android-Installation testen, Fixtermine und Deadlines später persistieren. M1–M4 weiterhin offen; keine Secrets oder personenbezogenen Testdaten.


## Flutter-UI für Dauer/Priorität – 2026-11-21 (09:22 Europe/Berlin)
- Ausgangs-HEAD `4f189ba3a1955756fd5f6f849e06cd56383ff06f`; offene PRs/Issues: 0/0. Vorherige Flutter-CI [44881310273](https://github.com/WeA200675/life-ai-planner/actions/runs/44881310273) für `c33e4ad` **success**; Scheduler-CI [44881323987](https://github.com/WeA200675/life-ai-planner/actions/runs/44881323987) für `4f189ba` **success**.
- `apps/mobile/lib/main.dart`: Dialog „Planungswerte bearbeiten“ für individuelle Minuten (leer = bisheriger 30-Minuten-Fallback) und Priorität 0–10; Eingaben werden vor dem SQLite-Update geprüft, Abbrechen verändert nichts; vorhandene `setPlanningMetadata`-Persistenz und anschließendes Refresh werden verwendet. Tagesvorschau-Text korrigiert, damit nicht mehr pauschal 30 Minuten behauptet werden.
- Code-Commit `0829e79aec2900ff7daeec43bb0d6c06e3d68cf8`; Regressionstest-Commit `136d5bc24009f7b0fc1adfec0c8129bf3f548e19` (ungültige IDs/Dauern/Prioritäten vor DB-Zugriff).
- **Nachweis:** GitHub-Commits bestätigt. Flutter-CI [44884603037](https://github.com/WeA200675/life-ai-planner/actions/runs/44884603037) für Code-Commit beim Abruf **in_progress**; für Regressionstest-Commit noch kein erfolgreicher Lauf nachgewiesen. Keine lokale Flutter-Toolchain oder Android-Geräteabnahme behauptet.
- **Blocker:** Noch keine End-to-End-Widgetprüfung für erfolgreiche Dialogspeicherung auf Android; Deadlines und Fixtermine nicht in lokaler DB erfasst. Android-Gerüst/Lockfile und Release-Build weiterhin offen; Repository öffentlich, keine Secrets oder persönlichen Daten.
- **Nächster Schritt:** Flutter-CI für `136d5bc` prüfen, Fehler beheben; dann Dialog-/Persistenz-Widgettests und Deadline-/Fixtermin-Schema samt Migration, danach Android-Gerätetest. M1–M4 nicht abgenommen.


## Offline-Deadline-Grundlage – 2026-11-21 (09:36 Europe/Berlin)
- Vor Änderungen verifizierter HEAD: `69e7df7285c56295ee12c2b343f25f99ac0ee29b`; offene Issues/PRs 0/0. Vorherige Flutter-CI [44884616189](https://github.com/WeA200675/life-ai-planner/actions/runs/44884616189) für `136d5bc` **success**; Scheduler-CI [44884629660](https://github.com/WeA200675/life-ai-planner/actions/runs/44884629660) für `69e7df7` **success**.
- Neue SQLite-Schema-Version 3 mit nullable `deadline_utc_ms` und CHECK für positive UTC-Epoch-Millisekunden; v2→v3 via nichtdestruktivem ALTER TABLE. Bei Upgrade von v1 werden v2 und v3 nacheinander migriert. Bestehende IDs/Titel/Status/Dauer/Priorität bleiben erhalten.
- Flutter-Planungsadapter berücksichtigt vorhandene UTC-Deadlines und verschiebt Aufgaben mit unerfüllbarer Deadline statt sie zu ignorieren. Ungültige Deadline-Typen und Werte erzeugen explizite FormatException. Ohne Deadline bleibt bisheriges Verhalten erhalten. **Noch keine Deadline-Eingabeoberfläche oder Store-Setter**; Migration/Adapter sind vorbereitende, offline-fähige Funktionalität.
- Commits: Schema `28a8be6`, DB-Upgrade `e84a9c6`, Adapter `d786f9b`, Migrationstests `94d8299`, Adaptertests `49ab301`, Fehlerbehandlung `f74329a`.
- **Testnachweis:** GitHub-Commits bestätigt; Flutter-CI [44885759116](https://github.com/WeA200675/life-ai-planner/actions/runs/44885759116) für `49ab301` beim Abruf **queued**, frühere Flutter-Läufe für diese Änderung noch `in_progress`. Neuer CI-Erfolg, lokale Flutter-Ausführung, Android-Gerätetest und v1→v3-Echtmigration **nicht** bestätigt. Nachfolgender Commit `f74329a` benötigt eigene CI-Bestätigung.
- **Nächster Schritt:** Flutter-CI auf neuestem HEAD kontrollieren und Fehler beheben; dann validierte Deadline-Bearbeitung mit SQLite-Setter und Flutter-Dialog, Widget-/Persistenztests und geschützte Fixtermine ergänzen. Android-Release und M1–M4-Abnahme weiterhin offen. Öffentliches Repo: keine persönlichen Daten oder Secrets.


## Android-Praxistest: rote Flutter-Assertion – 2026-11-21
- Nutzer meldete beim Start der Debug-APK den roten Flutter-Fehler `framework.dart:6286 _dependents.isEmpty is not true`. Dies ist ein **reproduktionsbedürftiger Gerätefehler**, kein nachgewiesener SQLite-Fehler. Debug-APK war zuvor in [Flutter CI 44885766287](https://github.com/WeA200675/life-ai-planner/actions/runs/44885766287) erfolgreich gebaut worden; CI erkennt den Gerätefehler nicht.
- Codeprüfung ergab: Editierdialoge in `apps/mobile/lib/main.dart` erzeugten `TextEditingController` außerhalb der Dialogroute und entsorgten sie unmittelbar nach `showDialog`-Rückkehr, obwohl die Route noch animiert ausblenden kann. **Mögliche** Lifecycle-Ursache, nicht als eindeutige Root Cause bestätigt.
- Sicherer Fix im Commit `022e5ef1de7d5c69dea7c1775a4570b806a48230`: Dialoge verwenden `TextFormField(initialValue, onChanged)` statt frühzeitig entsorgter externer Controller; Controller-Lifecycle liegt bei der Flutter-Dialogroute. Bestehende Validierung und Abbruch-Fallback bleiben erhalten.
- **Verifikation:** Commit auf GitHub bestätigt. Flutter-CI und Geräte-Neutest für diesen Fix noch ausstehend; daher keine Behauptung, dass die Assertion beseitigt ist.
- **Nächster Schritt:** Flutter-CI für `022e5ef` prüfen, neue Debug-APK installieren und App-Start sowie beide Bearbeitungsdialoge testen. Falls Assertion fortbesteht, vollständigen Stacktrace via `adb logcat` sammeln und Widget-Lifecycle gezielt untersuchen. M1–M4 weiterhin offen.


## Offline-Deadline-Setter und Android-Fix-CI – 2026-11-21 10:20 Europe/Berlin
- Ausgangs-HEAD `a0483cf050437b8816c1b46c8c5bc3e675cc08bb`; offene PRs/Issues: 0/0. README, Implementierungsplan und Status gelesen.
- **Verifiziert:** Flutter-CI [44887089927](https://github.com/WeA200675/life-ai-planner/actions/runs/44887089927) für vorherigen Dialog-Lifecycle-Fix `022e5ef` **success**; Scheduler-CI [44887101485](https://github.com/WeA200675/life-ai-planner/actions/runs/44887101485) für Ausgangs-HEAD **success**. Android-Praxistest nach Fix noch ausstehend, rote Assertion damit **nicht** als beseitigt bestätigt.
- Code-Commit `7b54a955832363b3c8f5fb3bfd2a62d32487ad74`: `LocalTasks.setDeadline(id, DateTime?)` mit UTC-Normalisierung, positiver Epoch-Millisekundenprüfung, atomarem SQLite-Update, explizitem `null` zum Entfernen einer Frist und Fehler bei fehlender Aufgabe. Vorhandenes v3-Schema wird genutzt, keine Migration oder Netzwerkabhängigkeit.
- Test-Commit `bbb544c0f3ade9d3ebe1e49bd090bbdf96c6107c`: Regressionstest für ungültige IDs und Fristen vor Unix-Epoch, noch vor Datenbankzugriff. **Keine Ausführung der neuen Tests bestätigt**, Flutter-CI für Test-Commit zum Dokumentationszeitpunkt noch nicht ausgewertet.
- **Blocker:** Deadline-Eingabe in Flutter fehlt, echte SQLite-Schreib-/Lese-Integration für Setter noch nicht testbestätigt, Android-Gerätetest zur Flutter-Assertion offen. Keine M1–M4-Gesamtabnahme.
- **Nächster Schritt:** CI für `bbb544c` prüfen und reparieren, Deadline-Setter mit sqflite_common_ffi persistenztesten, dann sichere Deadline-UI ergänzen; Debug-APK auf Android starten und gegebenenfalls vollständigen Stacktrace sichern. Keine Secrets oder personenbezogenen Testdaten committed.

## Einheitliches Midnight-Red-Design – 2026-11-21 (Vormittagslauf)
- README, Implementierungsplan und Status gelesen; offene Issues und PRs: jeweils 0 laut GitHub-Suche.
- Nutzerentscheidung umgesetzt: kein Violett/Lila. Zentrale dunkle Theme-Tokens in `apps/mobile/lib/planner_theme.dart` mit Anthrazit, Rubinrot, Korallrot, Bordeaux und Türkis. `PlannerApp` nutzt das Theme für Aufgabenansicht und Tagesvorschau einschließlich Dialogen. Keine Änderung an SQLite-Daten, Scheduler oder API.
- Theme-Regressionstests in `apps/mobile/test/planner_theme_test.dart` für Farbwerte und einfache Offline-Darstellung ergänzt. Wachseffekte ausdrücklich **nicht** implementiert; spätere optionale Ausbaustufe mit Performance-Fallback.
- Code-/Test-Commits: `add90583de1daba9f6c7a4904b8a4828ebc57620`, `74322023085587fd1ccfdacd7aff20cb654018c0`, `84f7e68e91b546a2e6593c6b75a44c91f99d0612`, `1bc58d5d7c7650e13f2c123d1d41fe2ca18e8e21`.
- **Testnachweis:** GitHub-Schreiboperationen bestätigt; für diese Änderungen weder lokale Flutter-Testausführung noch abgeschlossener GitHub-Actions-Erfolg nachgewiesen. Keine Android-Geräteabnahme.
- **Blocker/Nächster Schritt:** Flutter-CI für neuesten HEAD prüfen und Fehler beheben, dann Deadline-Setter mit SQLite-Integrationstest absichern und Deadline-UI ergänzen. Gemeldete Flutter-Assertion auf Gerät erneut testen. M1–M4 weiterhin offen; öffentliches Repository, keine Secrets oder persönlichen Testdaten.


## Offline-Fälligkeit in Flutter – 2026-11-21 (11:22 Europe/Berlin)
- Ausgangs-HEAD vor Änderung: `8912de54955fb9e8b338561f4ce0680dad171a9f`; offene PRs: 0; offene Issues: 0 (GitHub-Suchen).
- Implementierung: In `apps/mobile/lib/main.dart` kann eine lokale Aufgabe jetzt über den DatePicker ein Fälligkeitsdatum erhalten; eine zweite Aktion entfernt eine bestehende Fälligkeit. Die bestehende SQLite-Methode `setDeadline` speichert UTC-Epoch-Millisekunden. Ein ausgewählter Kalendertag wird als Ende des lokalen Tages interpretiert; Abbrechen ändert nichts. Schreibfehler werden angezeigt.
- Code-Commit: `d0b149d6227a3460092666d60fafae4db2434e0c`.
- **Verifikation:** GitHub-Connector bestätigte den Commit. Combined Status für Ausgangs-HEAD lieferte keine klassischen Checks; weder Flutter Analyze/Test noch Android-Build für den neuen Commit wurden in diesem Lauf ausgeführt oder als erfolgreich bestätigt. Daher **keine** grüne Abnahme behauptet.
- **Offen/Blocker:** Flutter-CI-Logs des neuen Commits prüfen; DatePicker-Grenzfälle und Persistenz mit Widget-/SQLite-Tests abdecken; Android-Geräteabnahme fehlt. Ein öffentlicher Repository-Zugriff bleibt bestehen: keine personenbezogenen Daten oder Secrets committen.
- **Nächster Schritt:** CI des neuen Commits kontrollieren, Fehler korrigieren und Offline-Fälligkeit in Tagesvorschau samt Tests sichtbar machen. M1–M4 weiterhin nicht vollständig abgenommen.


## Offline-Fälligkeitsanzeige – 2026-11-21 (Folgelauf)
- Ausgangs-HEAD: `b988300f509b69b60e07903f6c1a2262b1daadf2`; offene Issues/PRs jeweils 0. README, Implementierungsplan und Status geprüft. Combined Commit Status meldete keine klassischen Statuschecks; **kein CI-Erfolgsbeleg**.
- Flutter-Aufgabenliste zeigt gespeicherte Fälligkeit lokal als Datum, heute, morgen oder überfällig; kein Netzwerkzugriff. Die reine Darstellungsfunktion vergleicht Kalendertage UTC-normalisiert, um DST-bedingte 23-/25-Stunden-Tage nicht als falsche Tagesdifferenz zu behandeln.
- Code-Commits: `5eee44c65d8db88209a403eb7a863fbb17ad326e`, DST-Korrektur `97a5fd604c5d495e1297ece507569b5ff8c93530`, UI `5215b9c8305388fc2f2a634c0fd882b05163e589`; Test-Commit `0569f866b7dc3489fe4893f5877dff5a1cfa3a90`.
- Vier synthetische Dart-Regressionstests hinzugefügt: fehlende/ungültige Frist, heute/morgen/später, überfällig und DST-Kalendertage. **GitHub-Commits bestätigt, Testausführung/Flutter-CI für neuen HEAD nicht bestätigt.** Keine Android-Geräteabnahme.
- Blocker: Flutter-Toolchain und Gerätetests nicht in diesem Lauf verfügbar; rote Geräte-Assertion nach Lifecycle-Fix weiterhin nicht erneut nachgewiesen behoben; vollständige M1–M4-Abnahme offen.
- Nächster Schritt: Flutter-CI für Test-Commit prüfen, bei Fehlschlag korrigieren; SQLite-Setter mit FFI-Integration testen, Fälligkeit in Tagesvorschau anzeigen, Android-APK am Gerät inklusive Lifecycle-Fehler prüfen. Keine personenbezogenen Testdaten oder Secrets.

## Offline-Planungsintegrität – 2026-11-21 (Mittagslauf)
- Ausgangs-HEAD: `662d554297893d5f0ca3b9db7c8af45873179c31`; offene Issues: 0, offene PRs: 0.
- Ausgangs-CI: Scheduler tests für `662d554` erfolgreich ([Run 44895187501](https://github.com/WeA200675/life-ai-planner/actions/runs/44895187501)); Flutter offline MVP checks für vorherigen Code-HEAD `0569f866` erfolgreich ([Run 44895178023](https://github.com/WeA200675/life-ai-planner/actions/runs/44895178023)). Kein Flutter-CI-Nachweis für Ausgangs-Dokumentations-HEAD `662d554`.
- Implementierung: `previewLocalTasks` verwirft doppelte SQLite-Task-IDs explizit, auch bei Kombination aus erledigten und offenen Aufgaben. Verhindert doppelte Planung bei beschädigten/inkonsistenten Eingaberows; kein Datenbank-Schreibzugriff.
- Zwei Regressionstests für doppelte offene IDs und gemischte erledigte/offene IDs ergänzt.
- Code-Commits: `1940240feaf7737a994d4f3a33071c8c688db344`, `43d3cbbf3f74747683f731180ef6ef9214daf987`.
- **Testnachweis:** GitHub-Commits bestätigt; [Flutter-CI 44898255555](https://github.com/WeA200675/life-ai-planner/actions/runs/44898255555) und [Scheduler-CI 44898255599](https://github.com/WeA200675/life-ai-planner/actions/runs/44898255599) für `43d3cbb` waren bei Prüfung **queued**, kein erfolgreicher Lauf für die Änderung belegt. Lokaler Flutter-Test/Android-Gerätetest nicht ausgeführt.
- **Blocker:** Android-Geräteabnahme und M1–M4-Gesamtabnahme offen; öffentliches Repo erfordert Verzicht auf private Daten und Secrets.
- **Nächster Schritt:** CI-Ergebnisse für `43d3cbb` prüfen und ggf. korrigieren; danach SQLite-Deadline-Persistenz-Regression und Deadline-Konflikte in der Tagesvorschau weiter absichern.

## Offline-Deadline-Persistenzintegration – 2026-11-21 (12:41 Europe/Berlin)
- Ausgangs-HEAD: `81ea6b4d016117a4af9dadf8127dbecf9747fdc4`; vor Schreibzugriff HEAD erneut geprüft. Offene Issues/PRs: 0/0.
- Vorherige CI: Scheduler und Flutter für Code-HEAD `43d3cbb` jeweils **success** (GitHub Actions); Scheduler für Ausgangs-HEAD `81ea6b4` **success**.
- Neue Datei `apps/mobile/test/deadline_persistence_integration_test.dart`: zwei synthetische FFI-SQLite-Integrationstests prüfen persistierte UTC-Deadline nach Datenbank-Neuöffnung, Löschung einer Deadline und Weitergabe an die Offline-Tagesplanung sowie Zurückstellung abgelaufener Deadlines.
- Code-Commit: `f16a3f738d4665c58f01a1161e18e0239b27bbbc`.
- **Verifikation:** GitHub-Commit und Branch-Update bestätigt. Die neuen Tests wurden in diesem Lauf **nicht lokal ausgeführt**; GitHub Actions für den neuen Code-HEAD muss separat abgeschlossen werden. Kein erfolgreicher Testlauf ohne passenden SHA behauptet.
- **Blocker:** Android-Geräteabnahme einschließlich gemeldeter Flutter-Assertion weiterhin offen; vollständige M1–M4-Abnahme nicht belegt. Öffentliches Repository: ausschließlich synthetische Testdaten, keine Secrets.
- **Nächster Schritt:** Flutter-CI für `f16a3f7` prüfen und Fehler beheben; danach echte Deadline-Setter-Persistenz mit injizierbarer DB testen, Fälligkeitskonflikte in Tagesvorschau erklären und Android-Gerätetest durchführen.


## Offline-Tagesvorschau: erklärbare Zurückstellungen – 2026-11-21 (13:16 Europe/Berlin)
- Vor der ersten Änderung verifizierter HEAD: `91d35829700f5f3c23999c1b449699de58797c52`; vor jedem weiteren Schreibzugriff HEAD erneut geprüft. Offene Issues/PRs: jeweils 0.
- Ausgangs-CI: Flutter-Workflow [44900316721](https://github.com/WeA200675/life-ai-planner/actions/runs/44900316721) für `f16a3f7` **success**; Scheduler [44900326766](https://github.com/WeA200675/life-ai-planner/actions/runs/44900326766) für Ausgangs-HEAD **success**.
- Neu: `deferred_task_explanation.dart` übersetzt die Scheduler-Konfliktgründe Planbudget und fehlendes Zeitfenster/Fälligkeit in verständliche Offline-Erklärungen; unbekannte Gründe erhalten einen sicheren Fallback. Die Tagesvorschau zeigt die Erklärung direkt neben jeder zurückgestellten Aufgabe, ohne Aufgaben zu verändern.
- Vier neue synthetische Flutter-Tests prüfen Budget, Deadline, Nicht-Konflikt und unbekannten Grund.
- Commits: `7a67258aef53b0c4e2fa162fa5847b02ffa311de` (Helfer), `96250c111e8777af1cf67a9b8480e954f346563d` (Tests), `66fdfc77f41094ece7a6896bc8c4999081adbb6c` (UI).
- **Testnachweis:** GitHub-Commits bestätigt. Für den neuen UI-HEAD ist noch kein erfolgreicher Flutter-CI-Lauf belegt; lokale Flutter-Tests und Android-Geräteabnahme wurden nicht ausgeführt. Neue Tests sind implementiert, nicht als bestanden ausgegeben.
- **Blocker:** Android-Geräteabnahme, vollständige M1–M4-Abnahme und End-to-End-Tests ausstehend. Öffentliches Repo: keine persönlichen Daten oder Secrets.
- **Nächster Schritt:** Flutter-CI des neuen HEAD prüfen und Fehler beheben; danach UI-/Widget-Test für die Zurückstellungsanzeige und robuste Deadline-Setter-Persistenz mit injizierbarer Datenbank ergänzen.

## Flutter-Planung: Schutz vor ID-Kollisionen – 2026-11-21
- Vor Änderungen verifizierter HEAD: `a1ff35425c164f8c209d11f38ebd4a8d3ee93d53`; offene Issues 0, offene PRs 0.
- Fehlerbehebung: `planOfflineDay` weist jetzt leere, doppelte oder mit Aufgaben kollidierende Fixtermin-IDs zurück. Damit bleiben Blockkennungen in der Vorschau eindeutig und Fixtermine werden nicht versehentlich mit Aufgaben verwechselt.
- Regressionstest: `apps/mobile/test/offline_day_planner_test.dart` prüft drei Kollisionsfälle mit ausschließlich synthetischen Daten.
- Code-Commit: `e84cd0a664c40d5d0bd01a71d66e1d7dee88e748`; Test-Commit: `65a01193134bae39de49a8e3a902806fd69d166b`.
- Testnachweis: GitHub-Schreibvorgänge bestätigt; vorheriger Scheduler-CI-Lauf auf `a1ff354` war erfolgreich. Flutter-CI für den neuen Test-Commit beim Prüfen noch nicht nachgewiesen. Keine lokale Flutter-Testausführung oder Geräteabnahme behauptet.
- Blocker: Android-Gerätetest und vollständige M1–M4-Abnahme ausstehend; öffentliches Repository, keine personenbezogenen Daten/Secrets.
- Nächster Schritt: Flutter-CI für `65a0119` verifizieren, Fehler beheben und anschließend weitere Offline-Planungs-/Persistenzgrenzen testen.

## Offline-Task-Metadatenvalidierung – 2026-11-21 (14:24 Europe/Berlin)
- Ausgangs-HEAD: `0d7bab2a925d95d0ebf1c1762266ce15dcfd6717`; offene Issues: 0, offene PRs: 0.
- Ausgangs-CI: Scheduler tests für `0d7bab2` **success**; Flutter offline MVP checks für vorherigen Code-HEAD `65a0119` **success**. Nicht als Flutter-Erfolg für den neuen Code interpretiert.
- `planOfflineDay` validiert Task-Minuten (1–1440) und Priorität (0–10) entsprechend den SQLite-CHECK-Constraints, bevor geplant wird. Verhindert divergierende Offline-Planung mit nicht speicherbaren Metadaten.
- Synthetischer Regressionstest für vier ungültige Werte und gültigen Grenzwert ergänzt.
- Code-Commit: `0628f8873fc63dc4268dcfd3e770e86cbf3d25b3`.
- **Testnachweis:** GitHub-Commit/Branch-Update bestätigt; Flutter-Tests und APK/Gerätetest für den neuen Commit in diesem Lauf nicht lokal ausgeführt. CI-Ergebnis für neuen Code noch nicht als erfolgreich belegt.
- **Blocker:** Flutter- und Android-Geräteabnahme, vollständige M1–M4-Abnahme weiterhin offen. Repository öffentlich; keine privaten Daten/Secrets verwendet.
- **Nächster Schritt:** Flutter-CI für `0628f88` prüfen und Fehler beheben; danach Deadline-Setter-Persistenz und Tagesvorschau-Widgettests ergänzen.


## Offline-ID-Normalisierung – 2026-11-21 (14:36 Europe/Berlin)
- Vor Änderung HEAD `c694b90038291feb671652e3b78b4df2a8a66f63`; offene Issues/PRs jeweils 0. Vorherige Scheduler- und Flutter-CI für `0628f887` erfolgreich; Scheduler-CI für Ausgangs-HEAD ebenfalls erfolgreich.
- `apps/mobile/lib/offline_day_planner.dart`: IDs von Aufgaben und geschützten Fixterminen mit führenden/nachgestellten Leerzeichen werden explizit zurückgewiesen. Keine stille Normalisierung, keine Änderung gespeicherter Daten; verhindert uneindeutige Kennungen in der Tagesvorschau.
- `apps/mobile/test/offline_day_planner_test.dart`: synthetischer Regressionstest für beide ID-Arten, unveränderte Eingaben und gültige IDs.
- Code-Commit `3fd74dfca3215128c293dfbcbcf58f875b1bf4b0`; Test-Commit `39ce5796c30d4af227219b91b4f3bc92d0a0e991`.
- **Testnachweis:** GitHub-Schreibvorgänge bestätigt. Flutter-/Dart-Tests für diesen neuen Code-HEAD nicht lokal ausgeführt; GitHub-CI für den neuen HEAD bei Dokumentation noch nicht als erfolgreich belegt. Keine Android-Geräteabnahme.
- **Blocker:** Gerätetest, vollständige M1–M4-Abnahme, Ende-zu-Ende-Prüfung fehlen. Öffentliches Repository: keine personenbezogenen Daten oder Secrets.
- **Nächster Schritt:** Flutter-CI für `39ce5796` kontrollieren und ggf. korrigieren; anschließend echte SQLite-Deadline-Setter-Persistenz und Widgettests der Tagesvorschau priorisieren.


## Provisorische Schätzdauer: SQLite-Grenze – 2026-11-21
- Vor Änderungen verifizierter HEAD: `faf3744f6b72efa70efffec73b3dbdb034bdc1e4`; offene Issues 0, offene PRs 0.
- Fix: `previewLocalTasks` verwirft jetzt `provisionalMinutes > 1440` (wie SQLite-Schema und explizite Aufgabendauer), statt ungültige Planungsmetadaten stillschweigend zu akzeptieren. Keine SQLite-Mutation.
- Regressionstest: 1441 und -1 werfen ArgumentError; 1440 wird als gültige Schätzung akzeptiert und bei zu kleinem Tagesbudget sicher zurückgestellt.
- Code-Commit: `87670c311ca67235d635673035cfab2bbc7f4bb8`; Test-Commit: `e04068759b72949c85df6949e8adb5ffaf0c3ffc`.
- GitHub Actions zuletzt beobachtet: Scheduler tests: in_progress/pending at e040687 (run 44913004731); Flutter offline MVP checks: in_progress/pending at e040687 (run 44913004669); Scheduler tests: in_progress/pending at 87670c3 (run 44912997765); Flutter offline MVP checks: in_progress/pending at 87670c3 (run 44912997717); Scheduler tests: completed/success at faf3744 (run 44909785510). Diese Ergebnisse beweisen **keinen** erfolgreichen Testlauf des neuen Test-Commits, sofern dessen SHA nicht ausdrücklich enthalten ist.
- Testnachweis: Testquelltext committed; kein lokaler Flutter-Lauf in diesem Werkzeugzugang; neuer CI-Lauf bleibt abzuwarten. Kein APK-/Gerätetest nachgewiesen.
- Blocker: Android-Geräteabnahme, Release-Build und vollständige M1–M4-Abnahme fehlen; öffentliches Repository ohne personenbezogene Daten/Secrets.
- Nächster Schritt: Flutter-CI des neuen Commits prüfen, bei Fehler korrigieren; anschließend Widgettests der Tagesvorschau und Offline-Fälligkeitsmigration weiter absichern.


## Flutter-Fälligkeitsdialog: Datumsgrenzen – 2026-11-21 (15:44 Europe/Berlin)
- Ausgangs-HEAD `be935831463ddaaeaeb7af2c350665389b94f654`; offene Issues 0, offene PRs 0.
- Fehlerbehebung: Bestehende Fälligkeitsdaten außerhalb des vom DatePicker unterstützten Bereichs 1971–2100 führen nicht mehr zu einer ungültigen initialDate-Assertion. Der Auswahlcursor wird begrenzt; gespeicherte Fälligkeiten werden weder stillschweigend überschrieben noch verändert. Text-/Offline-Betrieb bleibt erhalten.
- Implementierung `0a5f556865f1c562448ef4f39729225743a940da`, Integration `567acb053af28df42b18d4127cc15e282b501f69`, Regressionstest `e8187569f5b372e99d6a3c7180ddbc5ff287b309` (Alt-/Zukunftsdaten, Grenzen und gültiges Datum).
- Verifizierter vorheriger CI-Erfolg: Flutter offline MVP checks bei `e040687` (Run 44913004669) **success**, Scheduler tests bei `be93583` (Run 44913017472) **success**. CI für neuen Test-HEAD bei Dokumentation nicht als erfolgreich belegt; keine lokale Flutter-Ausführung und kein Android-Gerätetest behauptet.
- Blocker: Android-Geräteabnahme, reproduzierbarer Release-Build, M1–M4-Gesamtabnahme. Öffentliches Repo: keine personenbezogenen Daten oder Secrets.
- Nächster Schritt: Flutter-CI des Test-HEAD prüfen und Fehler beheben; danach Widgettests der Tagesvorschau und Replanning/SQLite-Persistenz erweitern.


## SQLite-Typ- und Wertevalidierung – 2026-11-21 (16:20 Europe/Berlin)
- Ausgangs-HEAD: `6cbab790e2f9a5d33d97866d6228e786a3d5db7a`; offene Issues und PRs: jeweils 0.
- Ausgangs-CI: Scheduler [44915507582](https://github.com/WeA200675/life-ai-planner/actions/runs/44915507582) **success**; Flutter [44915497384](https://github.com/WeA200675/life-ai-planner/actions/runs/44915497384) **success** für vorherigen Code-Stand.
- Implementierung: `packages/storage/sqlite_store.py` verwirft nun SQLite-Typkoerzierung (bool, float, numerische Strings), ungültige Minuten außerhalb 1–1440, Prioritäten außerhalb 0–10 sowie IDs mit Rand-Leerzeichen; validiert Titel, Status und Deadline-Typ explizit vor Datenbankzugriff. Bestehende Daten werden nicht verändert.
- Regressionstests: `tests/test_sqlite_store.py` mit 14 ungültigen Eingaben und gültigen Grenzwerten inklusive Wiederöffnung. Die Tests wurden auf GitHub committed, **noch nicht erfolgreich ausgeführt nachgewiesen**.
- Code-Commit: `c6c336efd63767bbb99a4ebecdfd0b60dcc57213`; Test-Commit: `0b1f1ffb423650b428adf01dfa398ea6c73b3772`.
- CI zum Prüfzeitpunkt: [44918646448](https://github.com/WeA200675/life-ai-planner/actions/runs/44918646448) **in_progress** für Code-Commit; [44918657687](https://github.com/WeA200675/life-ai-planner/actions/runs/44918657687) **queued** für Test-Commit. Flutter-Workflow wird durch diese Python-Änderungen nicht ausgelöst. Keine lokale Testausführung behauptet.
- Blocker: Endgültige CI-Verifikation dieser Änderungen, reale Android-Geräteabnahme, vollständige M1–M4-Abnahme. Öffentliches Repo: keine privaten Daten oder Secrets.
- Nächster Schritt: Scheduler-CI des Test-Commits prüfen und Fehler korrigieren; anschließend SQLite-API-Validierung/Versionierung und Offline-Android-Widgettests priorisieren.

## API JSON-Eindeutigkeit – 2026-11-21 (16:42 Europe/Berlin)
- Ausgangs-HEAD `c76dda630a5f95c639a27db0348a332f8e5810c6`; offene PRs 0, offene Issues 0.
- Ausgangs-CI: Scheduler tests [44918673425](https://github.com/WeA200675/life-ai-planner/actions/runs/44918673425) **success**; letzte Flutter-Prüfung [44915497384](https://github.com/WeA200675/life-ai-planner/actions/runs/44915497384) **success** (älterer Code-Stand).
- `services/api/server.py`: JSON-Objekte mit doppelten Schlüsseln werden auch verschachtelt mit HTTP 400 abgewiesen; unvollständige Bodies werden explizit zurückgewiesen. Keine stillschweigende Last-Value-Wins-Verarbeitung von widersprüchlichen Task-/Plan-Parametern.
- `tests/test_local_api.py`: HTTP-Regressionstest für doppelte Top-Level-/Nested-Schlüssel, unveränderten Task-Speicher und weiterhin gültige Task-Erstellung.
- Code-Commits: `d121b6fd2bdb1d13c329904dc279e73c05745aa5`, `afad799a4b3caef72acfddd11c237724dd9de916`.
- Verifikation: GitHub-Commits nachgewiesen; Scheduler-CI [44920685414](https://github.com/WeA200675/life-ai-planner/actions/runs/44920685414) für Test-Commit zum Prüfzeitpunkt **queued**, vorheriger Lauf [44920676247](https://github.com/WeA200675/life-ai-planner/actions/runs/44920676247) **in_progress**. Kein neuer Testerfolg behauptet; keine lokale Python- oder Android-Geräteausführung.
- Blocker: M1–M4 noch nicht vollständig abgenommen, Android-Geräteabnahme fehlt; API absichtlich nur Loopback ohne TLS/Auth, Repo öffentlich – keine persönlichen Daten/Secrets eintragen.
- Nächster Schritt: neue Scheduler-CI prüfen und ggf. reparieren; danach HTTP-Eingabegrenzen und Offline-API-Fallbacks sowie Android-Widgettests weiter absichern.

## API: nichtstandardisierte JSON-Zahlen zurückweisen – 2026-11-21
- Ausgangs-HEAD: `d7a60e3ae184729a2eeee00e8609e70fc7809038`; offene Issues/PRs jeweils 0; vor jeder Änderung HEAD neu abgefragt.
- Ausgangs-CI: Scheduler [44920703100](https://github.com/WeA200675/life-ai-planner/actions/runs/44920703100) **success**. Flutter zuletzt [44915497384](https://github.com/WeA200675/life-ai-planner/actions/runs/44915497384) **success** (älterer Flutter-Code).
- `services/api/server.py`: Python-JSON-Erweiterungen `NaN`, `Infinity`, `-Infinity` werden durch `parse_constant` mit HTTP 400 abgewiesen, auch bei verschachtelten Daten; verhindert nichtstandardisierte Zahlen in Offline-API-Eingaben.
- `tests/test_local_api.py`: HTTP-Regressionstest für alle drei Tokens, unveränderten SQLite-Speicher nach Ablehnung und erfolgreiche gültige Folgeanfrage. Nur synthetische Daten.
- Code-Commit: `3ec654d731503c23082e85264d22adc12a04c69c`; Test-Commit: `59493ad8b12bf96128dfca44dd7a1cf57f4d0cb3`.
- **Testnachweis:** GitHub-Commits bestätigt; Scheduler-CI für Code [44923787363](https://github.com/WeA200675/life-ai-planner/actions/runs/44923787363) zum Prüfzeitpunkt **in_progress**, für Test [44923797782](https://github.com/WeA200675/life-ai-planner/actions/runs/44923797782) **queued**. Keine lokale Testausführung und kein neuer CI-Erfolg behauptet.
- **Blocker:** Android-Geräteabnahme, Release-Build und M1–M4-Gesamtabnahme weiterhin offen. API nur Loopback, keine produktive externe Freigabe.
- **Nächster Schritt:** CI für `59493ad8` prüfen, Fehler beheben; danach API-Schema-/HTTP-Grenzfälle und Android-Widgettests priorisieren.


## API: HTTP-Request-Framing und Content-Type – 2026-11-21
- Ausgangs-HEAD `44878935da9e1d9fd819e00bf377f953899f7205`; offene Issues 0, PRs 0. Ausgangs-CI Scheduler [44923814214](https://github.com/WeA200675/life-ai-planner/actions/runs/44923814214) **success**. Auch der vorherige neue JSON-Testlauf [44923797782](https://github.com/WeA200675/life-ai-planner/actions/runs/44923797782) ist **success**.
- `services/api/server.py` lehnt vor JSON-Verarbeitung und SQLite-Mutation nicht-JSON-Medientypen, Transfer-Encoding und doppelte Content-Length-Header mit HTTP 400 ab. Bewusst kein Chunked-Support in der lokalen Standardbibliothek-API; eindeutige Content-Length erforderlich.
- `tests/test_local_api.py`: HTTP-Regressionstest mit falschem Medientyp, Transfer-Encoding, zwei Content-Length-Headern; prüft unveränderte SQLite-Aufgaben und gültige Folgeanfrage. Ausschließlich synthetische Daten.
- Implementierung: `a098cd18dd5380952c3a2a21bb62e681490677f3`; Tests: `eeab31e85d67447d6b6dc45c70a826dd1b1dbe96`.
- **Testnachweis:** Beide GitHub-Commits bestätigt; CI für Code-Commit [44925557843](https://github.com/WeA200675/life-ai-planner/actions/runs/44925557843) beim Prüfen **in_progress**. CI für Test-Commit noch nicht nachweislich erfolgreich; kein lokaler Python- oder Android-Gerätetest behauptet.
- **Blocker:** vollständige M1–M4-Abnahme, Android-Geräteabnahme, Release-Build; API weiterhin bewusst nur Loopback ohne externe Auth/TLS-Freigabe. Öffentliches Repo: keine privaten Daten oder Secrets.
- **Nächster Schritt:** Scheduler-CI für `eeab31e8` prüfen und ggf. reparieren; anschließend API-Fehlerpfade und Android-Tagesvorschau-Widgettests absichern.

## API: Ungültiges UTF-8 sicher abweisen – 2026-11-21 (18:22 Europe/Berlin)
- Ausgangs-HEAD: `366a307814021577deb360ba19fa76a446422bc9`; offene Issues/PRs jeweils 0. Vor jeder Änderung HEAD erneut geprüft.
- Fehler: JSON-Bytes mit ungültigem UTF-8 lösten zuvor einen unbehandelten `UnicodeDecodeError` aus; die Verbindung konnte ohne HTTP-Antwort abbrechen.
- `services/api/server.py` behandelt jetzt `UnicodeError` als HTTP 400. `tests/test_local_api.py` enthält zwei fehlerhafte UTF-8-Requests und prüft unveränderte SQLite-Daten sowie anschließende gültige Erstellung. Synthetische Testdaten.
- Implementierungs-Commit: `2b83e59006a884631f289d50352e2a72035d7202`; Test-Commit: `855a37f20686dfb8ad36a72cfa169be61c0881e1`.
- Vorherige Scheduler-CI: [44925581754](https://github.com/WeA200675/life-ai-planner/actions/runs/44925581754) **success** für älteren HEAD. Aktuelle CI-Abfrage: `855a37f2` run 44929698503 in_progress/null; `2b83e590` run 44929681982 in_progress/null; `366a3078` run 44925581754 completed/success; `eeab31e8` run 44925568147 completed/success; `a098cd18` run 44925557843 completed/success. Keine lokale Python-Ausführung und kein Testerfolg für neuen Test-Commit behauptet.
- Blocker: Android-Geräteabnahme, Release-Build und vollständige M1–M4-Abnahme offen. API weiterhin nur Loopback, ohne produktive externe Auth/TLS-Freigabe.
- Nächster Schritt: Scheduler-CI für `855a37f` prüfen, bei Fehlern korrigieren; danach Flutter-Tagesvorschau-Widgettests und Replanning priorisieren.

## API-Planungszeitstempel – 2026-11-21 (18:39 Europe/Berlin)
- Ausgangs-HEAD: `91198578f86e561a7a5958ca9d1cd07e1de1c117`; vor Änderungen offene Issues: 0, PRs: 0; Scheduler-CI für Ausgangs-HEAD erfolgreich.
- Fehlerpfad behoben: `POST /plan` prüft `start`, `end` und Fixblock-Zeitstempel vor `datetime.fromisoformat` auf den exakten String-Typ. Vorher konnten JSON-Null, Zahlen, Booleans oder Arrays `TypeError` auslösen und die Verbindung ohne HTTP-Antwort abbrechen; jetzt HTTP 400 statt unbehandelter Exception.
- Implementierungs-Commit: `ad61ceb60e8ef78096242f984841a9a28085c3a1`; Regressionstest-Commit: `322099d4acb3472dfb4575247bb58217fb7b071e`.
- Regressionstest: sechs fehlerhafte Zeitstempelvarianten, unveränderter SQLite-Taskbestand, anschließend gültige Planungsanfrage. Testcode committed; **kein lokaler Testlauf behauptet**.
- CI beim Dokumentieren: Scheduler tests: in_progress/offen (https://github.com/WeA200675/life-ai-planner/actions/runs/44931270077).
- Blocker: Android-Geräteabnahme und vollständige M1–M4-Abnahme ausstehend; Repository öffentlich, daher keine privaten Testdaten oder Secrets.
- Nächster Schritt: CI für Test-HEAD prüfen und ggf. reparieren; danach Flutter-Widgettests, dynamische Umplanung und API-Fehlerpfade weiter absichern.

## API Unicode-Eingabehärtung – 2026-11-21 (19:21 Europe/Berlin)
- Ausgangs-HEAD: `3d95fb49c590433dbe35429861b6387df70c703f`; GitHub-Suche: keine offenen Issues/PRs. Scheduler-CI für Ausgangs-HEAD erfolgreich.
- Problem: JSON erlaubt per Escape lone UTF-16-Surrogates (`\\ud800`), die später beim UTF-8-Encoding für SQLite oder HTTP unbehandelte Fehler auslösen können.
- Änderung: `services/api/server.py` verwirft Surrogates rekursiv in JSON-Schlüsseln, Strings, Listen und Objekten mit HTTP 400, bevor Mutationen erfolgen. Code-Commit: `d72ddd32a138e0d6ee544c145a305c47500886dd`.
- Regressionstest in `tests/test_local_api.py`: vier fehlerhafte JSON-Payloads, unveränderter Aufgabenbestand und danach gültige Unicode-Aufgabe. Test-Commit: `0dd9b4127813b6f6c76813b97d62a9b87b1e2305`.
- **Verifikation:** Commits über GitHub bestätigt; neuer CI-Lauf/Testausführung noch nicht als erfolgreich nachgewiesen. Vorheriger CI-Lauf für Ausgangs-HEAD war erfolgreich; nicht auf neue Änderung übertragbar.
- **Blocker:** Android-Geräteabnahme, Release-Build, M1–M4-Gesamtabnahme weiterhin offen. Repository öffentlich; keine Secrets/privaten Daten.
- **Nächster Schritt:** CI des neuen Code-HEAD prüfen und bei Fehler korrigieren; dann Flutter-Tagesvorschau/Replanning mit Widgettests absichern.


## M3: Offline-Replanning-Vorschau – 2026-11-21 (19:32 Europe/Berlin)
- Vor Änderungen HEAD `bf16029463666034660fd6f50a5657070a09c7e1`, offene Issues/PRs jeweils 0; vorheriger Scheduler-CI-Lauf [44935145229](https://github.com/WeA200675/life-ai-planner/actions/runs/44935145229) erfolgreich.
- `replanOfflineDay` in `apps/mobile/lib/offline_day_planner.dart` erstellt eine **rein lesende** Offline-Neuplanung ab aktuellem Zeitpunkt. Erledigte Tasks werden ausgelassen, laufende Fixtermine bis zum ursprünglichen Ende geschützt, vergangene Fixtermine ignoriert; Zeitbudget und 70/30-Puffer werden vom bestehenden deterministischen Planer neu berechnet. Ungültige Fixtermine, unbekannte Erledigt-IDs und doppelte Task-IDs werden abgewiesen. Keine automatische Persistenz oder Kalenderänderung.
- Implementierungs-Commit `afca8fa237c431d4fcc951e4de32254bdb26066e`; Regressionstest-Commit `bf37fd3ebb8df19d1830cb746a4a412c82b3576f`. Zwei neue Dart-Tests prüfen aktive geschützte Termine, Erledigt-Ausschluss, Pufferbudget, Vergangenheit und ungültige Eingaben mit synthetischen Daten.
- **Nachweisstand bei Dokumentation:** Commits auf GitHub bestätigt; Flutter-CI für Test-HEAD [44936156398](https://github.com/WeA200675/life-ai-planner/actions/runs/44936156398) queued, Scheduler-CI [44936156351](https://github.com/WeA200675/life-ai-planner/actions/runs/44936156351) queued. **Kein erfolgreicher Testlauf für den neuen HEAD behauptet**, keine lokale Dart-/Android-Geräteausführung.
- **Blocker:** Replanning noch nicht in die Android-Tagesansicht integriert; Persistenz, Versionskontrolle/Undo und Geräteabnahme fehlen. Vollständige M1–M4-Abnahme, Release-Build und End-to-End-Tests ausstehend.
- **Nächster Schritt:** Flutter-CI des Test-HEAD prüfen, Fehler korrigieren, anschließend Replanning in Tagesvorschau mit expliziter Bestätigung und Widgettests einbinden.


## Agile delivery acceleration — 2026-11-21
- Ausgangs-HEAD: `e7777bff279ae7dc1caeca75e9ab0360371c69cc`. Offener PR #1 (`4140265`) mit SQLite-Replanning-Adapter; kein separates offenes Issue (GitHub Issues API führt PRs ebenfalls auf). PR-Head-CI: Flutter [44937153003](https://github.com/WeA200675/life-ai-planner/actions/runs/44937153003) **success**, Scheduler [44937153001](https://github.com/WeA200675/life-ai-planner/actions/runs/44937153001) **success**.
- Implementiert: [docs/DELIVERY_ACCELERATION.md](DELIVERY_ACCELERATION.md), Commit `72fd5472187a7f6dbf109e95864fd7086c478a32`. Enthält einen einzigen Integrationsverantwortlichen, HEAD-/Blob-SHA-Prüfung vor Writes, sechs vertikale Qualitäts-Gates, CI-/APK-Fallbacks, Performance-Messvorgaben und explizite Abnahmekriterien. Keine bestehende Runtime-Funktion geändert; **keine Laufzeitbeschleunigung oder vollständige Implementierung behauptet**.
- Testnachweis: GitHub-Commit bestätigt; reine Dokumentationsänderung, keine lokalen Tests. Erfolgreiche PR-CI ist nur für dessen SHA belegt, nicht als Android-Geräteabnahme.
- Blocker: PR #1 noch offen; Android-Replanning-Bestätigung, Versionshistorie/Undo, Geräteabnahme und M1–M4-Gesamtabnahme ausstehend.
- Nächster Schritt: PR #1 konfliktfrei prüfen/integrieren, anschließend Android-Replanning-UI inklusive Bestätigung/Undo und Widgettests als zusammenhängenden vertikalen Schnitt liefern.


## Scheduler gap scan optimization — 2026-11-21
- Ausgangs-HEAD `5bfc13ca0fe72dc989a3d49690947ab3a0ded39d`; PR #1 (SQLite-Replanning-Adapter) weiterhin offen, daher keine überlappende PR-Implementierung.
- Code `30c45b22bee79e979af556891ed2f176258345be`: Scheduler berechnet die Task-Dauer einmal je Aufgabe und beendet den chronologischen Gap-Scan, sobald ein Deadline-Termin für alle folgenden Gaps unerreichbar ist. Fixblöcke, 70/30-Regel und deterministische Sortierung unverändert. Algorithmus bleibt im ungünstigsten Fall O(Tasks × Gaps); keine unbelegte Laufzeitverbesserung behauptet.
- Regressionstests `406efbcd6118821bd72392143a7d0a0dc5a25bfa`: frühe Deadline trotz späterer freier Gaps; nachfolgende Aufgabe weiterhin planbar; exakte Deadline-Grenze zulässig.
- **Verifikation:** GitHub-Commits bestätigt. Neue CI und Benchmark-Ergebnisse beim Schreiben noch nicht als erfolgreich belegt; kein lokaler Testlauf und keine Android-Geräteabnahme.
- **Blocker:** M1–M4-Abnahme, Android-Gerätetest, offener PR #1. Nächster Schritt: Scheduler-CI auf Test-SHA kontrollieren; feste synthetische Benchmark-Baseline erfassen, dann PR #1 sicher integrieren und Android-Replanning-UI mit Undo fertigstellen.


## Performance-Masterplan P0–P7 – 2026-11-21
- Ausgangs-HEAD `32f939c023c4e4b1f4b0156aed63d5c015eccf8d`. Neuer dokumentierter Plan: [PERFORMANCE_MASTERPLAN.md](PERFORMANCE_MASTERPLAN.md), Commit `1fc74d6979f03dca3431a1cbfa1176b09cf13760`.
- Acht prüfbare Meilensteine: P0 reproduzierbare Baseline; P1 Scheduler; P2 SQLite; P3 Flutter; P4 Replanning; P5 Sprache/AI; P6 Stresstests/CI; P7 Release und Gerätetest. Konkrete Ziele sind ausdrücklich **Vorgaben, keine Messwerte**.
- **Nachweis:** Dokument auf GitHub committed; keine Runtime-Codeänderung und kein neuer Performance-/Android-Test. Frühere CI-Erfolge dürfen nicht als Messbeleg verwendet werden.
- **Blocker:** Benchmark-Harness und Messungen fehlen; PR #1 ist offen; Android-Geräteabnahme und M1–M4-Abnahme ausstehend.
- **Nächster Schritt:** P0 Benchmark-Harness mit synthetischen Fixtures implementieren, danach anhand realer Profile die größten Engpässe optimieren; parallel konfliktfrei P4 Android-Replanning fertigstellen.


## P0 Benchmark-Harness – 2026-11-21
- Ausgangs-HEAD `09b318ed013f1f81cc30f8bd9109d5e713d9eaef`.
- Implementiert `tools/benchmark_scheduler.py`: deterministische synthetische Lastfälle (standardmäßig 100/1000/10000 Tasks), Seed, Warmup, Wiederholungen, median/p95/min/max, JSON-Export und Laufzeitumgebung. Commit `c2c87360f2cf6f1ec428e85d1da69c10c27b6dd9`.
- Tests `tests/test_benchmark_scheduler.py`: Reproduzierbarkeit, Fixblock-Planbarkeit, Perzentilberechnung, ungültige Parameter und Metadaten. Commit `7149371fb0375968b8f4aea21f15bebbf7d740e2`.
- **Testnachweis:** Dateien auf GitHub committed. Neue CI-Resultate zum Dokumentationszeitpunkt noch nicht bestätigt. Keine gemessene Beschleunigung behauptet. Kein lokaler Android-Test.
- **Umfang:** Dies ist ein begrenzter sinnvoller Code-Schnitt und ausdrücklich **keine 8000-Zeilen-Implementierung**; Codeumfang ist kein Ersatz für Abnahmekriterien.
- **Blocker:** Baseline-Ergebnisse auf Zielgerät und CI ausstehend; PR #1 offen; M1–M4 nicht abgenommen.
- **Nächster Schritt:** CI der Tests prüfen, Benchmark-JSON als reproduzierbares Artefakt sichern, Hotspots priorisieren; Android-Replanning-UI inklusive Bestätigung und Undo fertigstellen.


## P0 CI Benchmark-Artefakt – 2026-11-21
- Ausgangs-HEAD `0b9d674a56cfb2a9398b2a3a847f85aa907f03a3`; offene PR #1 nicht verändert. Vorheriger Scheduler-CI-Lauf für Ausgangs-HEAD [44939630045](https://github.com/WeA200675/life-ai-planner/actions/runs/44939630045) completed/success.
- Implementierung `ab7439ff810036ae418839be508acd453469745e`: Scheduler-CI führt nach den Unit-Tests reproduzierbare synthetische Benchmarks für 100, 1000 und 10000 Aufgaben aus, speichert JSON mit Median/p95 und lädt es als 14 Tage verfügbares GitHub-Actions-Artefakt hoch. Keine absolute Laufzeit-Grenze auf volatilen Shared-Runners.
- **Verifikation:** Workflow-Commit bestätigt; neuer CI-Lauf zum Dokumentationszeitpunkt noch nicht nachweislich erfolgreich. Kein gemessener Speedup und kein Android-Gerätetest behauptet.
- **Blocker:** P0-Messwerte müssen aus dem neuen CI-Artefakt gelesen werden; Flutter-Replanning mit Bestätigung/Undo, M1–M4 und Geräteabnahme offen.
- **Nächster Schritt:** CI-Lauf und JSON-Artefakt prüfen; aus den realen p95-Werten konkrete Engpässe bestimmen und dann P1-Optimierungen implementieren; parallel P4 Android-Integration.


## M3 – Tagesverankerte Kalibrierung, 2026-11-21 (20:20 Europe/Berlin)
- Vor Änderung HEAD `f5cf01a06d8800cbbb87e17e8c2967126cca9f96`; README, Implementierungsplan und Status gelesen. PR #1 (`4140265cc05e7d62f4fc61a9603700cc7f6f1f5b`) weiterhin offen und nicht verändert; keine eigenständigen offenen Issues (GitHub-Issue #1 ist der PR). CI des Ausgangs-HEAD: [44939900313](https://github.com/WeA200675/life-ai-planner/actions/runs/44939900313) **success**.
- M3-Code `64276ca052129b8a5b9ccf4c829df0bafb4c6e60`: `calibrate(..., as_of=date)` verankert die 14-Tage-Auswertung an einem expliziten Konsolidierungsdatum und ignoriert zukünftige Beobachtungen; ohne `as_of` bleibt die bisherige API-Semantik erhalten. Ungültige Datumsanker werden abgelehnt. Damit ist die Berechnung bei gleichem Datenstand und Anker deterministisch, aber noch kein persistenter Nachtjob implementiert.
- Tests `eda9cf6e28d4955fa80bc69644532626f28f2579`: vier neue Fälle für Zukunftsdaten, veraltete Daten, Reihenfolgeunabhängigkeit und ungültigen Anker.
- **Tatsächliche Verifikation:** GitHub-Commits erfolgreich. CI [44940476986](https://github.com/WeA200675/life-ai-planner/actions/runs/44940476986) für Test-HEAD beim Prüfen **queued**; [44940467793](https://github.com/WeA200675/life-ai-planner/actions/runs/44940467793) für Code-HEAD **in_progress**. Keine neuen Tests als bestanden behauptet, kein lokaler Lauf/Android-Test.
- **Blocker:** persistente idempotente Nachtkonsolidierung, Android Replanning-UI/Undo und Geräteabnahme fehlen; M1–M4 nicht abgenommen.
- **Nächster Schritt:** CI des neuen HEAD kontrollieren und ggf. korrigieren; dann datumsgebundene persistente Konsolidierung mit Restart-/Idempotenztests, ohne PR #1 zu duplizieren.


## P0 Benchmark-Vergleich und Regressionserkennung – 2026-11-21
- Ausgangs-HEAD `bf5a3d78bdc95e72dfa25fc8567a5dad5ff74c76`; PR #1 unverändert offen. Scheduler-CI des Ausgangs-HEAD [44940494383](https://github.com/WeA200675/life-ai-planner/actions/runs/44940494383) **completed/success**; Benchmark-Artefakt `scheduler-benchmark-44940494383` vorhanden. Die tatsächlichen JSON-Messwerte wurden nicht heruntergeladen und daher nicht behauptet.
- Implementiert `tools/compare_scheduler_benchmarks.py` mit strengem Vergleich gleicher Python-/Plattform-/Workload-Metadaten, p95-Differenz und optionalem Exit-Code bei >10% Regression. Commits `6601846a67c092683352024667d065b6b2efd2c8` und Schwellenwert-Fix `dd68bd3fd197e417355a5ddede663eb95009de2f`.
- Tests `tests/test_compare_scheduler_benchmarks.py`, Commit `79b90ffb7767693f058b3f22c97dfb2a261f075c`: Regression, Verbesserung, Schwellenwert, Plattform- und Workload-Mismatch, Duplikate und nicht-endliche Werte. Testausführung für neue Commits noch nicht als erfolgreich bestätigt.
- **Blocker:** CI für neuen HEAD und tatsächliche Baseline-/Candidate-JSON-Auswertung noch ausstehend. Android-Replanning mit Bestätigung/Undo, Geräteabnahme und M1–M4 weiterhin offen.
- **Nächster Schritt:** neuen CI-Lauf prüfen und ggf. korrigieren; Benchmark-Artefakte von zwei vergleichbaren Läufen auswerten; P4 Android-UI fertigstellen.


## Android Resttag-Neuplanung (read-only) – 2026-11-21
- Ausgangs-HEAD `dd0cbefd14ff4474a7a8c22abd80cd39f4460889`; PR #1 weiterhin offen. Vorheriger Scheduler-CI [44940913062](https://github.com/WeA200675/life-ai-planner/actions/runs/44940913062) completed/success; CI des früheren Test-Commits `79b90ffb` war zunächst failure, Grenzwert-Fix `dd68bd3` danach success.
- Adapter `a359c3a7714150503043f61416a2416d57a6bceb`: strikt validierte, rein lesende Resttag-Vorschau aus SQLite-Task-Zeilen, erledigte Aufgaben ausgeschlossen. UI `9bc1dae283008757af96722242d6decdf9bbd2da`: Button **Resttag neu planen**, Zeitfenster jetzt bis 18:00, Anzeige geplanter/verschobener Aufgaben; nach 18:00 explizite Fehlermeldung statt ungültiger Berechnung. Regressionstests `e75e37d49345205b82c38f9a80cbf3463dca0e78` für Restzeitbudget, erledigte Tasks, unveränderte Eingabedaten und Fehlerfälle.
- **Wichtig:** UI ist nur eine Vorschau; **keine Bestätigung/Persistenz, Versionskontrolle oder Undo** implementiert. Keine stillschweigenden Kalenderänderungen. Kein tatsächlicher Performance-Gewinn behauptet.
- **Verifikation:** Commits auf GitHub bestätigt; neue Flutter-CI und Android-Gerätetest beim Schreiben nicht als erfolgreich belegt.
- **Blocker:** PR #1 muss konfliktfrei geprüft werden; Versionshistorie, Undo, Android-Geräteabnahme und M1–M4-Abnahme offen.
- **Nächster Schritt:** Flutter-CI für Test-SHA prüfen und ggf. beheben; danach versionierte Planübernahme/Undo mit expliziter Bestätigung und Widgettests integrieren.


## Android Planübernahme und Undo – 2026-11-21
- Ausgangs-HEAD `22ff922b29c64fe05e828343cc3a3add7ffcfc15`; PR #1 weiterhin offen, keine Merge-Behauptung.
- `53bd32e2eb64b67cfdc29df40685504f8acd6f32`: `plan_snapshot_store.dart` mit SQLite-Schema für versionierte Plan-Snapshots, atomaren Transaktionen, Lesezugriff und vor konkurrierenden neuen Versionen geschütztem Undo. Bestehende Aufgaben werden nicht geändert.
- `060172ed44caa0c5098a6c8e97a51dddd27e7b94`, Import-Fix `0bf149306f1b7311466d0a1674c90532f68b7a14`: Datenbankschema v4 inkl. Migration v3→v4, Dialogaktion **Plan übernehmen** und Snackbar-**Rückgängig** in der Android-Oberfläche.
- `03ba9a52c1db1a034b9cccc863bcdf5e09cc4b99`: SQLite-FFI-Tests für Snapshot-Neustart, unveränderte Tasks, Undo-Versionsschutz, ungültige Blöcke und leere Pläne.
- **Nachweis:** Commits bestätigt; neue Flutter-CI für Test-SHA zum Dokumentationszeitpunkt queued, nicht als erfolgreich belegt. Keine Android-Geräteabnahme oder Laufzeitmessung behauptet.
- **Grenze:** Undo ist aktuell über die Snackbar erreichbar, keine separate dauerhafte Historienoberfläche. Für vollständig robusten Betrieb fehlen Konfliktschutz gegen zwischen Vorschau und Bestätigung geänderte Aufgaben, UI-Tests und reale Migrationstests.
- **Nächster Schritt:** Flutter-CI abwarten und Fehler korrigieren, Snapshot-UI/Versionskonflikte und Migration testen, APK bauen und auf Android prüfen.


## Android M3 Planübernahme – Konfliktschutz, Migration und dauerhaftes Undo (2026-11-21)
- Ausgangs-HEAD `ce923bd1ba8d411bcac808670f0b5e41854b068f`.
- `5fc6287363deacc2885e36b47636065f66ff99a6`: kanonischer Aufgaben-Fingerprint und atomare SQLite-Transaktionsprüfung. Ein seit der Vorschau geänderter Task-Datensatz verhindert die Planübernahme; keine stillen Überschreibungen.
- `686b50f0f7e6d35cf7be4e297373f7b4cf0d0bc9`: UI übergibt eine unveränderliche Vorschaukopie zur Prüfung.
- `33ed496ebbf2802513480243efa1745620e37b78`: Tests für veraltete Bestätigung, unveränderte Aufgaben und deterministische Fingerprints.
- `3b1e9ca1d586cf3de776540d358f8eb10b926ade`, korrigiert durch `7069bdc88b595b734c681d93f26e8f0585d3ea58`: Migrationstest für v3-Task-Schema, wiederholbare Snapshot-Tabellenerstellung und unveränderte Tasks. **Dieser Test simuliert noch keinen echten Datei-DB-Version-Upgrade-Neustart.**
- `d926fd25c6bcfd920a588b99b33ece8ad331415f`: persistente UI zum Anzeigen des neuesten gespeicherten Plans und Undo nach App-Neustart; veraltete Undo-Versionen werden abgewiesen.
- **Verifikation:** GitHub-Commits bestätigt; Flutter-CI für neuen HEAD zum Dokumentationszeitpunkt queued, nicht als grün behauptet. Ein älterer Flutter-CI-Lauf `060172ed` scheiterte wegen fehlendem `DayPlan`-Import; Fix `0bf1493` committed. Scheduler-CI für Ausgangs-HEAD `ce923bd` war success.
- **Offene Abnahmekriterien:** aktueller Flutter-CI grün, echter SQLite-Datei-Upgrade-Test, Widgettest für Bestätigen/Undo, Release-APK und reale Android-Geräteabnahme. PR #1 weiterhin offen und nicht gemerged. Meilenstein daher **funktional erweitert, noch nicht vollständig abgenommen**.


## M3 Abnahme-Härtung – 2026-11-21
- Ausgangs-HEAD `7746f4c88a6fd9be4877d31f0b835aef3575d95b`. Flutter-CI auf `3b1e9ca` **failure**: Migrationstest versuchte bereits vorhandene Spalte `minutes` erneut anzulegen. Log [44941161287](https://github.com/WeA200675/life-ai-planner/actions/runs/44941161287). Frühere Import-Korrektur `0bf1493` ist bereits committed.
- `a749cab02844734b6afb99fe1520687c3e00a2ef`: Migrationstest ersetzt durch tatsächliche **dateibasierte** SQLite-v3→v4-Öffnung, Datenvergleich, Snapshot-Speicherung und erneuten Prozess-/DB-Neustart. Kein doppeltes Anlegen vorhandener Task-Spalten.
- `75ee5285d97cc7b39905e3220e04c989d96923ab`: Snapshot-Übernahme lehnt ungültige Kapazitätswerte, doppelte IDs und überlappende Zeitblöcke vor der Transaktion ab.
- `da7140ade0ea02ebeba45d5ec02d8ed5298ce05d`: zusätzliche SQLite-Regressionstests für Überlappung, Duplikate und unmögliche Kapazität.
- **Verifikation:** Commits vorhanden; Flutter-CI des neuen Test-HEAD zum Dokumentationszeitpunkt queued, nicht als grün behauptet. Android-Gerätetest und Release-APK weiterhin nicht nachgewiesen.
- **Abnahme offen:** aktueller Flutter-CI-Lauf (Analyse, Tests, APK) und Artefaktprüfung; echte Hardware-/Offline-Abnahme; UI-Widgettest für Übernehmen/Undo. M3 daher **nicht vollständig abgenommen**.


## M4 Offline-Planhistorie (2026-11-21)
- Ausgangs-HEAD `be1f93a84d52a3c0000a1c2fdc90137e2486f198`.
- `b5756d28c16d77d8309a22f2dce4825bb19a90cf`: begrenzte SQLite-Historienabfrage (Standard 30, Maximum 100, Offset) und rein lesender Einzelzugriff auf ältere Versionen.
- `36403d567d9278a9507490904b29cbfa57516abf`: Android-Dialog **Planhistorie** mit Anzeige der letzten 30 Planversionen und Detailansicht; kein unbeabsichtigtes Aktivieren alter Pläne.
- `9fed4df8655a24036fbf0a5791695ca57ad2b60d`: Tests für Reihenfolge, Pagination, Versionsabruf und ungültige Grenzen.
- `b82c7edd0ca323572eb72daf54f6fce341b33506`: UI-Beschriftung auf tatsächlich angezeigte 30 Einträge präzisiert.
- **CI-Nachweis:** Flutter-CI für `d926fd25` [44941182121](https://github.com/WeA200675/life-ai-planner/actions/runs/44941182121) **success**; für `a749cab0` [44941288345](https://github.com/WeA200675/life-ai-planner/actions/runs/44941288345) **success**, einschließlich GitHub-Workflow-Test-/APK-Schritten. Neuere Historien-Commits noch nicht grün bestätigt. Ein reales Android-Gerät wurde nicht geprüft.
- **Offen:** aktuelle Historien-CI, App-Abnahme auf Android-Gerät, ggf. vollständige Historien-Pagination über die ersten 30 Einträge hinaus.


## M4 Planhistorie: unbegrenztes Nachladen mit stabilem Cursor (2026-11-21)
- Ausgangs-HEAD `366527d96e48c1080d9eca7fa8a4ae801978fbcf`. Historien-CI für `b82c7edd` [44941639749](https://github.com/WeA200675/life-ai-planner/actions/runs/44941639749) **success** (Flutter-Analyse, Tests, Debug-APK im Workflow).
- `5ac0730dc29ab8f454d4c912e2660dd5683ed4a7`: Android-Dialog lädt auf Knopfdruck zusätzliche 30 Historieneinträge, mit Lade-/Fehlerzustand und Detailansicht.
- `6b41f9e6d0364aaa7c1536c588c9f3021e4ffc17`: Regressionstest für 67 gespeicherte Versionen.
- `1c07ef1885359f5ab6af212de7ad7c3df559c863`, `f2eb692d6caf47a183149486aa9729042b175773`: Cursor-Pagination statt Offset im UI; neu hinzukommende Pläne verschieben bereits geladene Seiten nicht.
- `fccefb0a66bbf7751e88095f61b308c21440e6ea`: Regressionstest für Cursor-Stabilität bei gleichzeitigem neuen Snapshot.
- **Offen:** neue Flutter-CI/Debug-APK für Cursor-HEAD, Gerätetest, UX-Abnahme. Kein Release- oder Gerätetest-Erfolg behauptet.


## CI-Abhängigkeitshärtung – 2026-11-21, 20:44 Europe/Berlin
- Ausgangs-HEAD: `c012c133a3bbed09b6345ae28f9d24a8594418de`; offene PRs: #1 (M3 SQLite-Replanning-Adapter); offene eigenständige Issues: keine (GitHub Issues listet PR #1 mit).
- Python-Scheduler-CI für Ausgangs-HEAD: [44942427508](https://github.com/WeA200675/life-ai-planner/actions/runs/44942427508) **success**.
- Flutter-Workflow [44942392543](https://github.com/WeA200675/life-ai-planner/actions/runs/44942392543) für `1c07ef18`: **failure** im Schritt `Build Android debug APK`; Job-Log belegt HTTP 403 beim Abruf von Kotlin 2.3.20 aus Maven Central über Gradle Plugin Portal. Das ist ein externer Dependency-Download-Blocker, kein Beleg für einen Flutter-Quellcodefehler.
- Commit `8db58f28dee475e1ef40e29d115f786b726b4ff2`: Android-Build führt höchstens drei Versuche mit begrenztem Backoff durch, entfernt vorab ein eventuell altes APK, prüft die APK-Datei und lässt den Job bei anhaltendem Fehler ausdrücklich fehlschlagen. Tests/Analyse laufen weiterhin vor dem Build; keine künstlich grünen Builds.
- **Nachweis:** GitHub-Commit bestätigt. Neuer Flutter-Run [44942543213](https://github.com/WeA200675/life-ai-planner/actions/runs/44942543213) beim Schreiben **queued**. Kein erfolgreicher Build für diesen Commit behauptet.
- **Nächster Schritt:** neuen CI-Run prüfen; bei dauerhaftem 403 Repository-/Runner-Netzwerk prüfen, nicht blind Kotlin-/Gradle-Versionen verändern. Anschließend PR #1 mit aktuellem main vergleichen und M3-Replanning-Abnahme fortsetzen. M1–M4 und Android-Geräteabnahme weiterhin offen.


## M5 Export historischer Pläne – 2026-11-21
- Ausgangs-HEAD `4cd7e5dc61a12b7cfeb63300ae9847d23d09df64`; parallel laufende Automationen beachten, vor jedem Commit HEAD prüfen.
- `d33b6c26af45b38a5bbbab31bb1a0d6cb9c365df`: deterministischer JSON-Export einzelner gespeicherter Planversionen, Schema `life-ai-planner-saved-plan` v1, UTC-Zeiten, Validierung auf doppelte/überlappende Blöcke; keine Netzwerkübertragung.
- `721d0944e8a06d044526a962a660d9adc4be18d4`: **JSON kopieren** in historischer Detailansicht, explizite Nutzeraktion und Fehler-Fallback.
- `fe7e4b2284f865517c23e85af30171db7a9748e7`: Tests für deterministischen Export, UTC, Whitelist-Felder, ungültige und leere Pläne.
- **Grenze:** Export kopiert nur einen Plan als Text in die Zwischenablage; noch kein Datei-Backup oder Import, keine automatische Synchronisation. Zwischenablage kann von anderen Apps gelesen werden: keine sensiblen Task-Titel im Export enthalten, nur Task-IDs und Zeitblöcke.
- **CI:** Flutter-Lauf für `8db58f28` [44942543213](https://github.com/WeA200675/life-ai-planner/actions/runs/44942543213) success. Neue Export-CI für `fe7e4b22` zum Dokumentationszeitpunkt queued, noch nicht freigegeben.


## M6 Offline-Aufgabenbackup – 2026-11-21
- Ausgangs-HEAD `20d98a1998e4d37d454c8569e932cee1a7044f5a`.
- `e449197f9ec8f1fc32a36d8856bff94a95ae0e73`, `8a6b4347cc33ce7c34eccccd285eaae3ab1af80f`: JSON-Sicherung aller Task-Spalten einschließlich IDs, Titel, Erledigtstatus, Dauer, Priorität und UTC-Deadline; Formatversion 1, strikte Validierung, max. 10.000 Tasks und 8 MiB.
- Wiederherstellung: transaktional, vollständiger Austausch **nur nach expliziter Nutzerbestätigung**; Daten-Fingerprint verhindert veraltete Bestätigung und stille Überschreibung zwischen Vorschau und Commit.
- `5573dda99ca745d9ea3fe669e196fe81cb55a270`: Tests für deterministischen Roundtrip, falsches Schema, Duplikate, veraltete Bestätigung, leere Sicherung.
- `6cf819da95d9281982c0fa3d209c06b99d2aa36b`: Android-Buttons **Aufgaben sichern** und **Backup einlesen**, Zwischenablage-Workflow, Bestätigungsdialog und Fehler-Fallback.
- **Wichtige Einschränkungen:** Backup betrifft ausschließlich Aufgaben, **nicht** Planhistorie oder eine vollständige App-Sicherung. Planhistorie bleibt beim Task-Restore erhalten, historische Task-IDs können danach andere/fehlende Aufgaben referenzieren. Zwischenablage kann sensible Titel enthalten; Nutzer muss diese selbst sicher verwahren. Noch kein Dateiexport, keine Dateiauswahl, keine automatische Synchronisierung.
- **Abnahme:** GitHub-Commits bestätigt, neue Flutter-CI und Android-APK noch nicht als grün nachgewiesen; reale Geräteprüfung ausstehend.


## M4 Restore-Rollback-Regression – 2026-11-21 (21:23 Europe/Berlin)
- Vor Änderung HEAD `b7e4bf243355b23da6379d3af276a7d3a2fa92ad`; README, Implementierungsplan und Status gelesen. Offene PR #1 (M3 SQLite-Replanning), kein eigenständiges Issue; GitHub Issues listet PR #1 ebenfalls.
- Ausgangs-CI **nachweislich grün**: [Flutter offline MVP checks 44944243782](https://github.com/WeA200675/life-ai-planner/actions/runs/44944243782) und [Scheduler tests 44944243751](https://github.com/WeA200675/life-ai-planner/actions/runs/44944243751), beide `b7e4bf24` success.
- Code-Commit `10b5e57407fc7814d74eebe96700c44b42772ce8`: zwei zusätzliche Flutter/SQLite-Regressionstests für atomaren Restore-Rollback nach durch SQL-Trigger erzwungenem Insert-Fehler sowie Ablehnung nachträglich manipulierter Backup-Daten vor Löschung. Produktivcode unverändert, da bestehende DB-Transaktion und Revalidierung gezielt abgesichert werden.
- **Verifikation neuer Änderungen:** GitHub-Commit bestätigt; Flutter-CI [44946015499](https://github.com/WeA200675/life-ai-planner/actions/runs/44946015499) und Scheduler-CI [44946015536](https://github.com/WeA200675/life-ai-planner/actions/runs/44946015536) zum Prüfzeitpunkt queued. Kein neuer grüner Testlauf behauptet.
- **Blocker/Abnahme:** Reale Android-Geräteabnahme und vollständiger Backup/Restore von Planhistorie fehlen. Zwischenablage-Backups bleiben unverschlüsselt; keine Secrets oder personenbezogenen Testdaten committed. M1–M4 nicht vollständig abgenommen.
- **Nächster Schritt:** neue Flutter-CI und APK-Artefakt prüfen; bei Fehlschlag Logs analysieren, andernfalls vollständigen versionierten Task+Planhistorie-Datei-Backup-Pfad mit sicherer Wiederherstellung und UI-Test priorisieren.


## M4 Planhistorie-Sicherung: lesender Export (2026-11-21, 21:44 Europe/Berlin)
- Ausgangs-HEAD `015d067e25b9b6ad074a619918a324bbdcaca845`; README, Implementierungsplan und Status gelesen; PR #1 (M3 SQLite-Replanning) offen, keine separaten Issues. CI am Ausgangs-HEAD: [Flutter 44946158145](https://github.com/WeA200675/life-ai-planner/actions/runs/44946158145) **success** und [Scheduler 44946158233](https://github.com/WeA200675/life-ai-planner/actions/runs/44946158233) **success**.
- `7cf6fd7e6957089b5dd42ecd59e7ab9b22a1397d`: vollständiger, transaktional konsistenter, rein lesender JSON-Export aller Plan-Snapshot-Header und Blöcke; feste Schema-Version, strenge Integritätsprüfung (Zeitfenster, Positionen, Duplikate, Orphans, Überlappungen), Grenzwerte 10.000 Snapshots / 8 MiB; bei Grenzwertverletzung kein stilles Abschneiden.
- `7b539c3b0d30a3c1dd039865984367da24b493b9`: Flutter/SQLite-Regressionstests für deterministischen Export, mehrere Versionen, History-Limit, Orphan-Blöcke und Größenlimit.
- `8229254ca7aba44a638016fedb5fdaeb85a74f07`: Android-Schaltfläche **Planhistorie sichern** kopiert den Export ausdrücklich in die Zwischenablage, ohne Daten zu ändern.
- **Verifikation:** GitHub-Commits bestätigt. Flutter-CI für UI-HEAD [44947884514](https://github.com/WeA200675/life-ai-planner/actions/runs/44947884514) beim Schreiben **queued**, Scheduler [44947884516](https://github.com/WeA200675/life-ai-planner/actions/runs/44947884516) **queued**. Kein neuer Testerfolg behauptet.
- **Einschränkungen:** Noch **kein** validierter Planhistorien-Import oder gemeinsamer atomarer Task+History-Restore; separate Zwischenablage-Exporte sind kein vollständiges App-Backup und können unverschlüsselt sein. Hardware-/Release-Abnahme und vollständige M1–M4-Abnahme weiterhin offen.
- **Nächster Schritt:** CI-Ergebnisse und Logs prüfen; bei grünem Ergebnis versionierten gemeinsamen Task+History-Backup-Import mit atomarem Restore, Konfliktprüfung und Geräteabnahme implementieren.


## M4 Planhistorie: streng validierter Restore in leere Datenbank – 2026-11-21
- Ausgangs-HEAD: `53af8fbb391707e493c0454847f4011c5e2f234d`. Vor Änderung: offene PR #1 (M3-Adapter), keine separaten offenen Issues; nicht verändert oder dupliziert.
- CI vor Änderung: Scheduler [44947898998](https://github.com/WeA200675/life-ai-planner/actions/runs/44947898998) **success** für Ausgangs-HEAD; Flutter [44947884514](https://github.com/WeA200675/life-ai-planner/actions/runs/44947884514) **success** für vorherigen Code-HEAD `8229254c`.
- Code `a9dd6a6ea3b95d6255177f0ebd91ade963af0dfb`: `plan_history_restore.dart` prüft Backup-Format, Schema, Pflichtfelder, ID-/Positionsreihenfolge, verwaiste und überlappende Blöcke, Grenzen und doppelte Task-IDs. Restore nur in eine **leere** Planhistorie und atomar in SQLite-Transaktion; niemals bestehende Historie überschreiben.
- Tests `76c32802e87f1cf42c5d74d4f3780168474815df`, Syntaxpräzisierung `8f990b7867c0565751576ea363a3edc3fcec7ce0`: Roundtrip mit IDs, Überschreibschutz, beschädigte Archive und veränderte untrusted Archivdaten.
- **Nachweis:** GitHub-Commits erfolgreich; neue Flutter-CI beim letzten Abruf noch **in progress** (für `76c32802` Run [44951054718](https://github.com/WeA200675/life-ai-planner/actions/runs/44951054718)). Kein lokaler Flutter-/Android-Lauf nachgewiesen; kein grüner neuer Build behauptet.
- **Einschränkung:** Restore bewusst nur als Bibliotheksfunktion in leere Datenbank, **nicht** als UI-Import in bestehende App integriert. Noch keine gemeinsame atomare Sicherung von Tasks und Historie, kein Verschlüsselungs-/Dateiauswahl-Workflow, keine Geräteabnahme.
- **Nächster Schritt:** neuen Flutter-CI-Lauf prüfen und ggf. korrigieren; dann sichere kombinierte Task-/Planhistorie-Sicherung mit Konsistenzprüfung und expliziter Nutzerfreigabe implementieren.
- **Abnahme:** M1–M4 nicht vollständig.


## M4 Restore-CI-Reparatur – 2026-11-21 (22:38 Europe/Berlin)
- Ausgangs-HEAD `22cb181d9e5ca5b1692401c6f12accef1540992b`; README, IMPLEMENTATION_PLAN und STATUS geprüft. Offene PR #1 (M3-Replanning), keine separaten Issues.
- Scheduler [44951078019](https://github.com/WeA200675/life-ai-planner/actions/runs/44951078019) für Ausgangs-HEAD **success**. Flutter [44951063222](https://github.com/WeA200675/life-ai-planner/actions/runs/44951063222) für `8f990b78` **failure**: Analyse grün, 82 Tests bestanden, genau ein Restore-Roundtrip-Test fehlgeschlagen (`Bad state: Plan history must be empty before restoration`); APK-Schritt deshalb übersprungen.
- Ursache anhand des Testcodes: Source und Target wurden mit `openDatabase(inMemoryDatabasePath)` geöffnet; sqflite kann bei identischem Pfad dieselbe Verbindung wiederverwenden, wodurch das angeblich leere Ziel bereits Source-Daten enthielt. Das ist eine fehlerhafte Testisolation, nicht der Beleg für einen Restore-Produktionsfehler.
- Korrektur-Commit `7ec9c94ed9037d0e759bac230fc296b1ce3950cf`: Test verwendet jetzt zwei getrennte temporäre SQLite-Dateipfade, schließt beide Verbindungen und entfernt das temporäre Verzeichnis.
- **Nachweis:** GitHub-Commit erfolgreich. CI/Flutter-Test und APK-Build für den Korrektur-Commit noch nicht als grün bestätigt; keine lokale Testausführung behauptet.
- **Nächster Schritt:** Flutter-CI dieses Commits prüfen; falls grün, kombiniertes Task+History-Backup mit atomarem Import und expliziter Bestätigung entwickeln. Weiterhin fehlen reale Android-Geräteabnahme, Release-Build, M1–M4-Gesamtabnahme.


## M4 Kombiniertes Offline-Backup: konsistenter Lese-/Validierungspfad (2026-11-21)
- Ausgangs-HEAD `48d058daf2a1bb9586e54624a3f67b2a7cafa4dc`; README, IMPLEMENTATION_PLAN und STATUS geprüft. PR #1 offen; Issues API meldet nur denselben PR, keine eigenständigen offenen Issues. Keine Doppelarbeit am PR.
- Ausgangs-CI: Flutter [44952634705](https://github.com/WeA200675/life-ai-planner/actions/runs/44952634705) **success** für `7ec9c94e`; Scheduler [44952645360](https://github.com/WeA200675/life-ai-planner/actions/runs/44952645360) **success** für `48d058da`.
- `b138c8997e93a312027486bbfc8504dcbd5bad96`, `0280a90709f8093d22fe61bb8035366d0eba95d4`: `combined_backup.dart` liest Aufgaben und Planhistorie innerhalb einer gemeinsamen SQLite-Lesetransaktion, validiert beide Teilarchive und prüft historische Task-Referenzen gegen enthaltene Task-IDs; versioniertes 8-MiB-JSON, kein Schreiben und kein Netzwerk.
- `31df4cab5ff8513384d6b42b40444fc8c3e7ba40`: Flutter/SQLite-Regressionstests für deterministischen Roundtrip, unveränderte Quelldaten, manipulierte Task-Referenzen und Ablehnung verwaister History-Referenzen.
- **Verifikation:** GitHub-Commits bestätigt. Neue Flutter-CI [44956165507](https://github.com/WeA200675/life-ai-planner/actions/runs/44956165507) und Scheduler [44956165490](https://github.com/WeA200675/life-ai-planner/actions/runs/44956165490) zum Prüfzeitpunkt **queued**. Kein lokaler Testlauf, kein grüner neuer Build behauptet.
- **Grenzen/Blocker:** Kombinierter Export ist bisher nur Bibliotheksfunktion; kein Android-UI-Button, kein atomarer kombinierter Restore, keine Dateiauswahl oder Verschlüsselung. Bestehende historische Task-IDs ohne aktuelle Task werden aus Sicherheitsgründen als inkonsistent abgewiesen; dafür ist später eine explizite Kompatibilitätsstrategie nötig. Android-Geräte-/Release-Abnahme und vollständige M1–M4-Abnahme offen.
- **Nächster Schritt:** Flutter-CI prüfen und bei Fehlern Logs analysieren; anschließend atomaren kombinierten Restore in eine leere Datenbank mit vollständiger Validierung und Regressionstests implementieren, erst nach Abnahme eine sichere UI-Freigabe.


## M4 Combined Backup: atomarer Restore in leere Datenbank (2026-11-21)
- Ausgangs-HEAD `0de852b676737b997158dc5d818ecd00d950eb74`; README, Implementierungsplan, Status, offene PRs/Issues und CI geprüft. PR #1 bleibt offen, Issues API enthält nur diesen PR.
- Ausgangs-CI: Flutter [44956165507](https://github.com/WeA200675/life-ai-planner/actions/runs/44956165507) **success** für `31df4cab`; Scheduler [44956182847](https://github.com/WeA200675/life-ai-planner/actions/runs/44956182847) **success** für `0de852b6`.
- `ad770fe9644fe47c609b2407f42971049363be31`: kombinierter Backup-Restore mit Vorabvalidierung des gesamten Task-/History-Archivs, Task-Referenzprüfung, Prüfung **aller drei Tabellen auf Leerzustand innerhalb derselben Transaktion**, danach atomarem Batch-Insert. Kein Überschreiben bestehender Nutzerdaten, keine Netzwerkübertragung.
- `1e4f1b5af78d64561675b5443b287a5c909d8ea3`: SQLite-Integrationstests mit separaten temporären Quelldatenbanken/Zieldatenbanken: Roundtrip und ID-Erhalt, Wiederholungs-/Überschreibschutz, SQL-Trigger-Fehler mit vollständigem Rollback.
- **Nachweis:** GitHub-Commits bestätigt; Flutter [44957646371](https://github.com/WeA200675/life-ai-planner/actions/runs/44957646371) und Scheduler [44957646357](https://github.com/WeA200675/life-ai-planner/actions/runs/44957646357) zum Dokumentationszeitpunkt queued. Kein grüner neuer Testlauf behauptet.
- **Blocker/Grenzen:** Noch kein UI-Import und keine Dateiauswahl/Verschlüsselung. Restore bewusst nur in vollständig leere SQLite-Tabellen, damit keine bestehende App-Datenbank unbemerkt überschrieben wird. Hardware-/Release-Abnahme und M1–M4-Gesamtabnahme fehlen.
- **Nächster Schritt:** CI für `1e4f1b5a` verifizieren und bei Fehlschlag korrigieren; anschließend sicheren Importpfad über isolierte Staging-Datenbank mit expliziter Bestätigung, atomarem Austausch und Rollback-Konzept planen.


## M4 Isolierte Backup-Staging-Datenbank – 2026-11-22 (00:24 Europe/Berlin)
- Ausgangs-HEAD `e2e00d11121615849a34d5aa124660aa3b1a9696`; README, Implementierungsplan und STATUS geprüft. Offene PR #1 (M3-Adapter), keine eigenständigen offenen Issues. Keine bestehende Implementierung ersetzt.
- Ausgangs-CI: Flutter [44957646371](https://github.com/WeA200675/life-ai-planner/actions/runs/44957646371) **success** für `1e4f1b5a`; Scheduler [44957659712](https://github.com/WeA200675/life-ai-planner/actions/runs/44957659712) **success** für `e2e00d11`.
- `67507e7d2ca7093c800d4c8c9f99ba408dbbe447`, `311ca1ac742f8c7296dd265e71bfe9d377f35ddb`: `combined_backup_staging.dart` validiert das vollständige kombinierte Archiv, erstellt eine **separate** SQLite-Zieldatenbank in einem vorhandenen privaten Verzeichnis, stellt Tasks und Historie transaktional wieder her und prüft `PRAGMA integrity_check`. Vorhandene Zieldateien werden abgewiesen, aktive App-Datenbank bleibt unangetastet. Bei Fehlern wird die im Versuch erstellte Kandidatendatei entfernt.
- `092b2aca3df4c765705f8f7a3d5d9f126595a084`: neue Flutter/SQLite-Regressionstests für erfolgreichen Staging-Roundtrip, unveränderte aktive Quelle, fehlerhaftes Archiv ohne Zieldatei und vorhandene Zieldatei ohne Überschreiben.
- **Verifikation:** GitHub-Code- und Test-Commits bestätigt. Flutter/Scheduler-CI für diesen letzten Test-HEAD zum Zeitpunkt der Abfrage noch nicht abgeschlossen; kein lokaler Test oder grüner APK-Build für diese Änderungen behauptet.
- **Sicherheitsgrenze:** Kein Umschalten der aktiven DB, kein UI-Import, kein Dateiauswahldialog, keine Verschlüsselung. Staging-Pfad muss in einem ausschließlich von der App kontrollierten Verzeichnis liegen; konkurrierende Fremdprozesse am selben Dateipfad sind nicht abgesichert. Kein automatischer Eingriff in produktive Daten.
- **Nächster Schritt:** CI für Staging-Tests prüfen und Fehler korrigieren; dann sichere, explizit bestätigte Aktivierung mit geschlossenem DB-Handle, Original-Backup und Rollback-/Neustartprüfung entwerfen und testen. Geräte-/Release-Abnahme und M1–M4-Abnahme weiter offen.


## M4 Staging-Integritätsprüfung – 2026-11-22 (00:44 Europe/Berlin)
- Ausgangs-HEAD `88f871f85dd5d8f684300394f74091b37ef1352c`; README, IMPLEMENTATION_PLAN und STATUS geprüft. PR #1 weiter offen; Issues-Endpunkt zeigt nur PR #1, keine separaten Issues.
- Vorherige CI: Flutter `092b2aca` [44961676618](https://github.com/WeA200675/life-ai-planner/actions/runs/44961676618) **success**, Scheduler `88f871f8` [44961698898](https://github.com/WeA200675/life-ai-planner/actions/runs/44961698898) **success**.
- `199727d869c81b02f81764508bc89404baeae986`: Kandidaten-DB wird jetzt mit **beiden** SQLite-Prüfungen `PRAGMA integrity_check` und `PRAGMA foreign_key_check` kontrolliert. Hintergrund: `integrity_check` erkennt verwaiste Fremdschlüssel nicht. Bei Fehlern wird die Staging-Datei wie bisher verworfen; aktive DB bleibt unberührt.
- `4b06fdbe1930fbb2b252ed69c253eb075dbf88b0`: gezielte FFI-Regressionstests für verwaiste Planblöcke trotz grünem `integrity_check` und für intaktes Schema.
- **Testnachweis:** Commits bestätigt; neue Flutter-CI für den letzten Code-HEAD noch zu verifizieren. Keine lokale Flutter-Ausführung behauptet.
- **Blocker/weiter offen:** Kein aktivierter UI-Restore und keine sichere DB-Umschaltung/Recovery. Vor einer Aktivierung: Original-DB sichern, offene Handles schließen, SQLite-WAL/SHM behandeln, atomare Aktivierung/Rollback auf Android-Gerät testen. Release- und Geräteabnahme, vollständige M1–M4-Abnahme fehlen.
- **Nächster Schritt:** neue Flutter-CI prüfen, danach isolierte Aktivierungsstrategie mit Crash-Recovery und expliziter Bestätigung implementieren.


## M4 Staging: semantischer Backup-Abgleich – 2026-11-22 (01:20 Europe/Berlin)
- Vor Änderung HEAD `0227909f50d6c8e020a5308d4dd2edd5c98a5388`; README, Implementierungsplan und STATUS gelesen. PR #1 offen (M3-Replanning), Issues-API enthält nur diesen PR, keine eigenständigen offenen Issues. Keine parallele PR-Arbeit verändert.
- Ausgangs-CI: Scheduler für `0227909f` [44963305482](https://github.com/WeA200675/life-ai-planner/actions/runs/44963305482) **success**; Flutter für `4b06fdbe` [44963287609](https://github.com/WeA200675/life-ai-planner/actions/runs/44963287609) **success**.
- Code `bb07bbfb85cece3533b3d51fa78c1f8c31bb5496`: Staging prüft nach SQLite `integrity_check` und `foreign_key_check` zusätzlich den **semantischen Inhalt** des wiederhergestellten Task- und Historienbestands gegen das strikt validierte Ursprungsarchiv. Zusätzliche, fehlende oder veränderte Datensätze verhindern eine Kandidatenfreigabe; Fehlerpfad verwirft die Kandidatendatei. Aktive Datenbank wird nicht verändert.
- Tests `cc8087a5b1157ecc549ab7647264b8dafa755ef4`: SQLite-FFI-Regressionen für erfolgreichen Inhaltsabgleich, manipulierten Task-Titel bei weiterhin intakter SQLite-Struktur und unerwarteten zusätzlichen Task.
- **Tatsächliche Prüfung:** GitHub-Commits bestätigt. Flutter [44966091001](https://github.com/WeA200675/life-ai-planner/actions/runs/44966091001) und Scheduler [44966090741](https://github.com/WeA200675/life-ai-planner/actions/runs/44966090741) für Test-HEAD beim Abruf **queued**; kein lokaler Testlauf, kein neuer grüner Build behauptet.
- **Grenzen:** Noch keine Aktivierung des Staging-Kandidaten, keine UI-Freigabe, kein sicherer SQLite-WAL/SHM-Swap und keine Recovery nach Prozessabbruch. Reale Android-Geräteabnahme und Release-Build fehlen; M1–M4 weiterhin unvollständig.
- **Nächster Schritt:** neue CI verifizieren, danach gesicherten, explizit bestätigten Aktivierungsprozess mit geschlossenem DB-Handle, Original-Sicherung, Crash-Recovery und Rollback testen, ohne produktive Daten automatisch zu überschreiben.


## M4 Staging-WAL-Sicherheit – 2026-11-22 (01:38 Europe/Berlin)
- Ausgangs-HEAD `bd146d0c1392d9def407d054f2fdee4fe5752218`. README, IMPLEMENTATION_PLAN und STATUS geprüft. PR #1 weiter offen; Issues API enthält ausschließlich diesen PR.
- Ausgangs-CI: Flutter für `cc8087a5` [44966091001](https://github.com/WeA200675/life-ai-planner/actions/runs/44966091001) **success**, Scheduler für `bd146d0c` [44966106967](https://github.com/WeA200675/life-ai-planner/actions/runs/44966106967) **success**.
- `8ac190755765b954cb7cafb7576dbb266af11561` und `d6e5ff18a712243b756aed4289a974614db4c874`: Staging führt vor Freigabe einen `PRAGMA wal_checkpoint(TRUNCATE)` durch, sofern die Kandidaten-DB im WAL-Modus ist; prüft Busy-Status und Vollständigkeit, akzeptiert SQLite-Sentinel -1/-1 für fehlendes WAL. Fehler verhindern Kandidatenfreigabe; die aktive DB wird nicht angefasst.
- `0e002f140323d3b7b52219fc079d6f5bb491e1fd`: SQLite-FFI-Tests für WAL-Checkpoint mit Schließen/Wiederöffnen sowie nicht-WAL-Fallback.
- **Nachweis:** Code-/Test-Commits auf GitHub bestätigt; neue Flutter-CI [44967631566](https://github.com/WeA200675/life-ai-planner/actions/runs/44967631566) und Scheduler-CI [44967631573](https://github.com/WeA200675/life-ai-planner/actions/runs/44967631573) beim Abruf **queued**. Keine lokale Ausführung oder grüner neuer APK-Build behauptet.
- **Blocker:** Noch keine produktive Aktivierung, kein WAL-sicherer atomarer Austausch mit Original-Backup/Crash-Recovery, keine explizite UI-Freigabe. Keine reale Geräte- oder Release-Abnahme; M1–M4 offen.
- **Nächster Schritt:** CI für `0e002f14` prüfen und ggf. Fehler beheben; anschließend kontrollierte Aktivierungsstrategie mit geschlossenem DB-Handle, Backup/Recovery-Marker und Gerätetest implementieren. Keine automatische Umschaltung ohne geprüften Rollback.


## M4 Staging-Sidecar-Schutz – 2026-11-22 (02:20 Europe/Berlin)
- Vor Änderung HEAD `215488cf355f6a089022983b7eeb5025f995b950`. README, Implementierungsplan, STATUS, PRs, Issues und CI gelesen. PR #1 weiter offen; keine separaten Issues.
- Vorherige CI: Flutter für `0e002f14` [44967631566](https://github.com/WeA200675/life-ai-planner/actions/runs/44967631566) **success**; Scheduler für `215488cf` **success**.
- `1b06a8efb439cf430411130fac4ed517d942d8a4`: isoliertes Staging lehnt vorhandene SQLite-Sidecars (`-wal`, `-shm`, `-journal`) auch ohne Hauptdatei ab. Fehler-Cleanup entfernt nach geschlossenem Handle die vom Versuch angelegten Kandidaten-/Sidecar-Dateien; bereits vorhandene Sidecars werden vor dem Versuch nicht berührt. Aktive DB bleibt unverändert.
- `42c95488bc3157e821f920cb797f24a549fbd58d`: SQLite-FFI-Regressionstest stellt sicher, dass alle drei verwaisten Sidecar-Typen unangetastet bleiben und kein Kandidat erstellt wird.
- **Prüfstatus:** Commits bestätigt; neue Flutter-CI für `42c95488` noch abzuwarten. Kein lokaler Testlauf, keine Android-Geräteabnahme behauptet.
- **Grenzen:** TOCTOU-Risiko bei externen Prozessen im Kandidatenverzeichnis bleibt; nur private app-kontrollierte Pfade zulässig. Kein aktiver DB-Swap, kein UI-Restore, kein Crash-Recovery oder Release-/Gerätetest. M1–M4 nicht vollständig abgenommen.
- **Nächster Schritt:** Flutter-CI für `42c95488` prüfen; dann Aktivierungsprotokoll mit exklusivem DB-Handle, WAL-Checkpoint, Original-Backup, Marker, Wiederanlauf und Rollback vor Freigabe implementieren.


## Durable Staging Reopen – 2026-11-22 (02:35 Europe/Berlin)
- Ausgangs-HEAD `5b25986025ee38e7dd81a33ba789d8798b5888e6`; offene PRs: #1 (SQLite Replanning), keine unabhängigen Issues (GitHub Issues listet PR #1 mit).
- Vorheriger Flutter-Lauf [44970965518](https://github.com/WeA200675/life-ai-planner/actions/runs/44970965518) für `42c95488` **success**; Scheduler-Lauf [44970976030](https://github.com/WeA200675/life-ai-planner/actions/runs/44970976030) für `5b259860` **success**. Diese Erfolge gelten **nicht** als Testnachweis für den neuen Code.
- Code-Commit `14ece4f08ee5d0ddb473ffcbcaabe3002eeaa2c8`: Nach erfolgreichem WAL-Checkpoint wird der Staging-Writer geschlossen, der Kandidat **read-only** erneut geöffnet und Struktur sowie semantischer Archivinhalt nochmals verifiziert. Bei Fehler wird der selbst angelegte Kandidat verworfen. Die aktive DB bleibt unangetastet.
- Test-Commit `2b0563165e1352bedf4361c697cfba1c65b1aa1a`: unabhängiger Read-only-Reopen-Test mit synthetischen Daten.
- **Verifikation:** GitHub-Commits vorhanden; Flutter-CI für die neue Änderung noch nicht nachweislich abgeschlossen (vorheriger Workflow [44972215456](https://github.com/WeA200675/life-ai-planner/actions/runs/44972215456) beim Abruf queued). Keine lokale Android-/Flutter-Ausführung behauptet.
- **Blocker:** Staging-Aktivierung/Crash-Recovery weiterhin nicht implementiert; kein vollständiger M1–M4-Abnahmenachweis, keine manuelle Android-Geräteabnahme oder Release-Freigabe.
- **Nächster Schritt:** CI des letzten Code-HEAD prüfen, Fehler beheben, danach Aktivierung nur bei geschlossenen SQLite-Verbindungen mit expliziter Bestätigung, Original-Backup, Crash-Recovery und WAL-Sidecar-Schutz entwerfen und testen.


## M4 Staging-Symlink-Schutz – 2026-11-22 (03:16 Europe/Berlin)
- Vor Änderung HEAD `4ea9679e05bdfffaeca0696bd99e7ea602a850a1`. README, Implementierungsplan und Status geprüft. PR #1 weiterhin offen, keine eigenständigen offenen Issues.
- Ausgangs-CI: Flutter [44972221073](https://github.com/WeA200675/life-ai-planner/actions/runs/44972221073) **success** für `2b056316`; Scheduler [44972231489](https://github.com/WeA200675/life-ai-planner/actions/runs/44972231489) **success** für `4ea9679e`.
- Code `af22b01d2f4d4a86d5abe276fac9d78f5862a816`: Staging lehnt symbolische Links auf dem unmittelbaren Elternverzeichnis sowie dem Kandidatenpfad vor Datenbanköffnung ab; insbesondere ein dangling Link darf nicht unbemerkt als neue DB behandelt werden.
- Tests `2cbcb3e216a060d24c6214b386f437c2b4f5c369`: synthetische SQLite-FFI-Regressionen für Elternverzeichnis-Symlink und dangling Kandidaten-Symlink; Windows-Symlinktests wegen unterschiedlicher Rechte übersprungen.
- **Verifikation:** Commits auf GitHub bestätigt. Flutter [44975330648](https://github.com/WeA200675/life-ai-planner/actions/runs/44975330648) und Scheduler [44975330643](https://github.com/WeA200675/life-ai-planner/actions/runs/44975330643) für Test-HEAD beim Abruf **queued**. Keine lokale Flutter-Ausführung und kein grüner neuer Build behauptet.
- **Blocker:** Die Prüfung deckt nur unmittelbare Pfadkomponenten ab; symbolische Links in weiter übergeordneten Verzeichnissen sowie TOCTOU bei konkurrierenden Prozessen sind nicht ausgeschlossen. Ausschließlich private app-kontrollierte Verzeichnisse verwenden. Noch kein aktiver DB-Swap, keine bestätigte UI-Aktivierung, kein Crash-Recovery, keine Android-Geräte-/Release-Abnahme. M1–M4 nicht vollständig.
- **Nächster Schritt:** Neue Flutter-CI prüfen und ggf. korrigieren. Danach Aktivierungskonzept mit exklusiven DB-Handles, WAL-Sicherung, Crash-Recovery-Marker und Rollback zuerst isoliert testen, bevor produktive Daten berührt werden.


## M4 Staging: dangling Sidecar-Symlinks – 2026-11-22 (03:38 Europe/Berlin)
- Ausgangs-HEAD `0f5f170b6d3345d564a1a25a85bf3376c87adbba`; README, IMPLEMENTATION_PLAN und STATUS gelesen. PR #1 offen, Issues-Liste enthält nur diesen PR.
- Ausgangs-CI: Flutter `2cbcb3e2` [44975330648](https://github.com/WeA200675/life-ai-planner/actions/runs/44975330648) **success**, Scheduler `0f5f170b` [44975339702](https://github.com/WeA200675/life-ai-planner/actions/runs/44975339702) **success**.
- Code `0f7bdb5f510384016976dd0e0cbe886c50b65b80`: Staging prüft alle vier Zielpfade einschließlich WAL/SHM/Journal nun mit `FileSystemEntity.type(..., followLinks: false)`; zuvor wurden dangling Sidecar-Symlinks von `File.exists()` übersehen. Der Versuch wird vor dem SQLite-Open abgebrochen, vorhandene Links werden nicht gelöscht.
- Test `654903e4e63b1bdd34f42769e91d4c3a8f8aba37`: Regression für dangling Symlinks bei allen drei Sidecars; Kandidat und Symlink-Ziele müssen unverändert bleiben.
- **Nachweis:** GitHub-Commits bestätigt; Flutter [44977040282](https://github.com/WeA200675/life-ai-planner/actions/runs/44977040282) und Scheduler [44977040286](https://github.com/WeA200675/life-ai-planner/actions/runs/44977040286) zum Test-HEAD bei Abfrage **queued**. Keine lokale Flutter-Testausführung, kein neuer grüner Build behauptet.
- **Blocker:** TOCTOU bei fremden Prozessen bleibt; nur private app-kontrollierte Verzeichnisse. Kein produktiver DB-Swap, keine Crash-Recovery oder Geräte-/Release-Abnahme; M1–M4 offen.
- **Nächster Schritt:** neue CI verifizieren und Fehler beheben; anschließend kontrollierte Aktivierung mit exklusiv geschlossenem DB-Handle, WAL-sicherer Original-Sicherung, persistentem Recovery-Marker und getestetem Rollback entwerfen. Bis dahin ausschließlich Staging ohne produktive Umschaltung.


## M4 Staging: Schutz aller Symlink-Vorfahren – 2026-11-22 (04:18 Europe/Berlin)
- Ausgangs-HEAD `753c6f30641c89e45647a2ceae6cb89b49542b55`; README, IMPLEMENTATION_PLAN und STATUS gelesen. PR #1 offen; Issues-Liste enthält nur diesen PR, keine unabhängigen offenen Issues.
- Ausgangs-CI: Flutter für `654903e4` [44977040282](https://github.com/WeA200675/life-ai-planner/actions/runs/44977040282) **success**; Scheduler für `753c6f30` [44977052350](https://github.com/WeA200675/life-ai-planner/actions/runs/44977052350) **success**.
- Code-Commit `1147733196afecc3b22ab7eb2ca06604168d8761`: Prüft sämtliche lexikalischen übergeordneten Verzeichnisse des Staging-Kandidaten auf Symlinks, nicht nur den unmittelbaren Elternordner. Der Kandidat bleibt unverändert geschützt; produktive Daten werden nicht berührt.
- Test-Commit `4acd23001a80bca85031c8dd5ae1d25912d8acd3`: SQLite-FFI-Regression mit Symlink zwei Verzeichnisebenen oberhalb der Kandidatendatei; muss vor Erstellung abbrechen und Zieldateien unverändert lassen. Windows-Symlinktest wegen unterschiedlicher Rechte übersprungen.
- **Tatsächliche Verifikation:** Commits über GitHub bestätigt. Beim Abruf waren Flutter [44980013389](https://github.com/WeA200675/life-ai-planner/actions/runs/44980013389) und Scheduler [44980013507](https://github.com/WeA200675/life-ai-planner/actions/runs/44980013507) für den Code-Commit `11477331` **in_progress**; die CI für den nachfolgenden Test-Commit ist noch nicht bestätigt. Kein lokaler Testlauf, kein neuer grüner Build behauptet.
- **Blocker:** TOCTOU bei konkurrierenden Prozessen und symlinkhaltigen, extern kontrollierten Pfaden bleibt möglich; ausschließlich private app-kontrollierte Verzeichnisse nutzen. Produktiver DB-Swap, Crash-Recovery, Geräte- und Release-Abnahme fehlen; M1–M4 nicht vollständig abgenommen.
- **Nächster Schritt:** Flutter-CI für den Test-Commit verifizieren und Fehler beheben. Anschließend Aktivierungsprotokoll mit geschlossenem DB-Handle, Original-Backup, persistiertem Recovery-Marker, sicherem Rollback und Tests implementieren, ohne produktive Daten automatisch zu überschreiben.
