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
