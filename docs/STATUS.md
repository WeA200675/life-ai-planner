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


## M4 CI dependency resilience – 2026-11-22 (04:41 Europe/Berlin)
- Ausgangs-HEAD `3b774666a196bfb065414f940f4cb9d992f92bc6`. README, Implementierungsplan, STATUS, offene PRs/Issues und CI geprüft. PR #1 bleibt offen; keine separaten offenen Issues.
- Flutter [44980019269](https://github.com/WeA200675/life-ai-planner/actions/runs/44980019269) für `4acd2300` **failure** im Schritt `Build Android debug APK`; Job-Log nennt HTTP **429 Too Many Requests** von Maven Central beim Abruf `org.jetbrains.kotlin:kotlin-gradle-plugins-bom:2.2.20`. Das ist ein externer Dependency-Downloadfehler, **kein nachgewiesener Dart-Testfehler**. Scheduler für `3b774666` [44980030254](https://github.com/WeA200675/life-ai-planner/actions/runs/44980030254) **success**.
- Code-Commit `f7f3f0712975619618e3170fcba911abc30fb18c`: `.github/workflows/flutter.yml` aktiviert `gradle/actions/setup-gradle@v4` mit read-only Cache bei PRs, um wiederholte Maven-Downloads und Rate-Limits zu reduzieren. Die bestehende begrenzte Retry-Schleife, APK-Integritätsprüfung und das harte Fehlschlagen bei anhaltendem Downloadfehler bleiben erhalten.
- **Verifikation:** GitHub-Commit bestätigt; noch kein abgeschlossener Flutter-CI-Nachweis für `f7f3f071`, keine lokale Android-Ausführung. Caching kann HTTP 429 bei einem Cache-Miss nicht vollständig verhindern. Keine personenbezogenen Testdaten/Secrets hinzugefügt.
- **Blocker:** M1–M4-Abnahme weiterhin offen; kein produktiver DB-Swap mit Crash-Recovery, keine Android-Geräte- und Release-Abnahme. Externe Maven-Verfügbarkeit kann Build weiterhin blockieren.
- **Nächster Schritt:** Flutter-CI für `f7f3f071` auswerten und gegebenenfalls Fehler beheben. Danach isolierte, absturzsichere Aktivierungslogik mit geschlossenen Handles, Original-Backup, Recovery-Marker, Rollback und synthetischen Tests umsetzen; keine automatische produktive Umschaltung.


## M4 Read-only Aktivierungs-Vorprüfung – 2026-11-22 (05:15 Europe/Berlin)
- Ausgangs-HEAD `5bf1e5d040ee924aacc5b75293238008695e4614`; README, Implementierungsplan und STATUS gelesen; PR #1 weiterhin offen, Issues-Liste enthält nur PR #1. M1–M4 nicht vollständig abgenommen.
- Ausgangs-CI: Flutter für `f7f3f071` [44981805615](https://github.com/WeA200675/life-ai-planner/actions/runs/44981805615) **success**, Scheduler für `5bf1e5d0` [44981814142](https://github.com/WeA200675/life-ai-planner/actions/runs/44981814142) **success**. Maven-429-Störung damit beim Folgelauf nicht erneut aufgetreten.
- Implementierung `f27e740933f3438236b689037531adfa0debdedb`: `inspectStagedCandidate` prüft eine bereits existierende Kandidaten-DB ausschließlich read-only auf Archivübereinstimmung, SQLite-Integrität, Fremdschlüssel, Symlink-Vorfahren und Sidecar-Abwesenheit. Keine Aktivierung oder Veränderung der aktiven Datenbank.
- Tests `a9945eb7fb69ee561a1ff3ce88a65902886eeab7`, Korrektur `d33841ce20801079dcbc35518883c54302d82311`: synthetische SQLite-FFI-Regressionen für intakten Kandidaten, Sidecar-Ablehnung und inhaltlich manipulierten Kandidaten. Keine personenbezogenen Daten.
- **Tatsächlicher Prüfstand:** GitHub-Commits bestätigt; Flutter [44984275629](https://github.com/WeA200675/life-ai-planner/actions/runs/44984275629) und Scheduler [44984275635](https://github.com/WeA200675/life-ai-planner/actions/runs/44984275635) für letzten Test-HEAD beim Abruf **queued**. Keine lokale Flutter-Ausführung und kein neuer grüner APK-Build behauptet.
- **Blocker:** Kein exklusiver Zugriff auf produktive SQLite-Verbindungen, kein transaktionales Aktivierungs-/Rollback-Protokoll mit Crash-Recovery-Marker, keine explizite UI-Freigabe, kein Android-Geräte- oder Release-Test. Pfadprüfungen schließen TOCTOU bei externen Prozessen nicht aus; nur private App-Verzeichnisse zulässig.
- **Nächster Schritt:** Flutter-CI für `d33841ce` verifizieren und Fehler beheben; anschließend geschlossenes DB-Handle, Original-Sicherung und crash-sicheres Aktivierungs-/Rollback-Protokoll mit synthetischen Fehler-Injektionstests umsetzen.


## M4 Geschlossene Aktivdatenbank: Read-only-Preflight – 2026-11-22 (05:41 Europe/Berlin)
- Ausgangs-HEAD `8edbae804dab5a2e8fc4db68943bbbf9a66cb06b`. README, IMPLEMENTATION_PLAN und STATUS geprüft; PR #1 offen, keine unabhängigen Issues.
- Ausgangs-CI: Flutter [44984275629](https://github.com/WeA200675/life-ai-planner/actions/runs/44984275629) **success** für `d33841ce`, Scheduler [44984288796](https://github.com/WeA200675/life-ai-planner/actions/runs/44984288796) **success** für `8edbae80`.
- Code `7eba50416d44ea48704789412a0862e2101ad504`: `inspectClosedActiveDatabase` prüft die bestehende aktive SQLite-Datei read-only mit eigenständiger Verbindung, Symlink-Vorfahren, Integritäts-/Fremdschlüsselprüfung und verweigert WAL/SHM/Journal sowie reservierte Recovery-Artefakte. **Kein Swap, keine produktive Mutation.** Der Aufrufer muss alle Writer vor dem Aufruf schließen.
- Tests `c403ab77d3d11549eed3fc07fe4656e9b59ec089`: synthetische SQLite-FFI-Tests für lesbare Daten, Sidecar-/Recovery-Artefakt-Verweigerung und fehlende/ungültige Pfade.
- **Verifikation:** Code und Tests auf GitHub committed. Der neue Flutter-CI-Lauf ist zum Dokumentationszeitpunkt noch nicht als erfolgreich bestätigt; keine lokale Flutter-Ausführung oder Geräteabnahme behauptet.
- **Blocker:** Die Prüfung kann nicht beweisen, dass fremde Prozesse/Handles geschlossen sind; TOCTOU bleibt. Ein exklusiver Aktivierungs-Lock, atomarer Swap mit persistentem Marker, Rollback und explizite UI-Freigabe fehlen. M1–M4 nicht vollständig abgenommen.
- **Nächster Schritt:** Flutter-CI des Test-Commits prüfen, ggf. Fehler beheben; danach isoliertes Recovery-Protokoll mit Crash-Injektion und dauerhaftem Original-Backup entwickeln, ohne automatische produktive Umschaltung.


## M4 Read-only Restore-Paarprüfung – 2026-11-22 (06:18 Europe/Berlin)
- Ausgangs-HEAD `40b98429639d71e7464ad5b9c2f2e7c463eeb139`; README, IMPLEMENTATION_PLAN, STATUS, PRs, Issues und CI geprüft. PR #1 offen, keine eigenständigen offenen Issues. Keine vollständige M1–M4-Abnahme.
- Ausgangs-CI: Flutter für `c403ab77` **success**, Scheduler für `40b98429` **success** (GitHub Actions API).
- Implementierung `5063293a643cd1e29bae6720217e00c50bbe5474`: `inspectRestorePair` prüft beide vorhandenen Datenbanken ohne Schreiboperation, weist gleiche Dateisystemidentität (auch Alias/Hardlink) vor Öffnung zurück und führt die vorhandenen Einzel-Preflights aus. Kein Swap und keine automatische Aktivierung.
- Tests `0ec8a783ed7dab01e477f0ceb9e014d2119f467a`: synthetischer Alias-Ablehnungstest und erfolgreicher Read-only-Paarcheck; keine privaten Daten.
- **Verifikation:** Commits auf GitHub bestätigt. Neue CI-Ergebnisse zum Test-HEAD siehe GitHub Actions; zum Zeitpunkt des Schreibens noch nicht als erfolgreich belegt. Kein lokaler Flutter-Lauf, keine Android-Geräteabnahme behauptet.
- **Blocker:** Exklusiver DB-Lock, dauerhaftes Original-Backup, atomarer Swap mit persistentem Recovery-Marker, Crash-Injektion, Rollback und UI-Bestätigung fehlen. TOCTOU durch fremde Prozesse bleibt; nur private App-Verzeichnisse.
- **Nächster Schritt:** Neue Flutter-CI auswerten; bei Fehler korrigieren. Anschließend isoliertes Recovery-Protokoll mit absturzsicherem Original-Backup und Fehler-Injektion implementieren, ohne die produktive DB automatisch zu ersetzen.


## M4 Restore-Kandidaten: Recovery-Artefakte verweigern – 2026-11-22 (06:40 Europe/Berlin)
- Ausgangs-HEAD: `f757cec4a110bd159416d07fd894de0a443e9b44`; README, Implementierungsplan, Status, offene PRs/Issues und Actions geprüft. PR #1 offen; keine unabhängigen offenen Issues.
- Ausgangs-CI: Scheduler [44988867490](https://github.com/WeA200675/life-ai-planner/actions/runs/44988867490) für Ausgangs-HEAD **success**. Ein neuer Flutter-Erfolg für die hier vorgenommenen Änderungen ist noch nicht bestätigt.
- Code-Commit `36f4d7ae9afc526ab2a05cdf3b78f4ff0dd1b34a`: `inspectStagedCandidate` lehnt zusätzlich vorhandene `.restore-backup`, `.restore-marker` und `.restore-pending`-Artefakte ab; kein automatisches Löschen und keine Aktivierung. Damit gilt die Recovery-Artefakt-Sperre auch für den Kandidaten des Restore-Paars.
- Test-Commit `91984bd3630734c59ee887f5a840ca628aed3c73`: synthetischer SQLite-FFI-Test für alle drei Artefakte, unveränderte Artefakte, Ablehnung sowohl des Kandidaten- als auch Paar-Preflights und erfolgreichen erneuten Kandidaten-Preflight nach manueller Bereinigung.
- **Verifikation:** GitHub-Schreiboperationen erfolgreich. Flutter-CI für den neuen Test-HEAD noch nicht als erfolgreich nachgewiesen; keine lokale Testausführung, kein Android-Geräte-/Release-Test behauptet.
- **Blocker:** Produktive Aktivierung bleibt deaktiviert: exklusive geschlossene DB-Handles, persistenter Recovery-Marker, Original-Backup, Crash-Recovery, Rollback und ausdrückliche Freigabe fehlen. M1–M4 nicht abgenommen.
- **Nächster Schritt:** Flutter-CI für Test-HEAD prüfen und ggf. reparieren. Danach nicht-destruktive Recovery-Protokolltests mit simuliertem Abbruch vor einer späteren Aktivierung.

## M4 Restore-Journal-Vertrag (2026-11-22, Folgelauf)
- Vor Beginn HEAD `6a0b376d5069577191717a4ef2db0f38e76bbd92`; README, Implementierungsplan und STATUS gelesen; PR #1 offen, keine separaten offenen Issues. Vorherige Flutter-CI [44990453854](https://github.com/WeA200675/life-ai-planner/actions/runs/44990453854) für `91984bd36` **success**; Scheduler [44990462174](https://github.com/WeA200675/life-ai-planner/actions/runs/44990462174) für `6a0b376d` **success**.
- Code-Commit `f46fe835a056d7580d6bc8afdd88f8f4aead4c9a`: `apps/mobile/lib/restore_journal.dart` definiert einen streng versionierten JSON-Vertrag für eine spätere persistierte Recovery-Markierung. Unbekannte Felder, Phasen, Versionen, kollidierende Pfadstrings und ungültige Operationskennungen werden abgewiesen. Phasen lassen sich nur vorwärts um genau einen Schritt fortschalten. **Keine Dateioperation, keine Datenbankaktivierung.**
- Test-Commit `3b1ecb2463ad73969cb9cf5e1d5ad5988e09cbc7`: vier synthetische Flutter-Tests für Roundtrip, Phasenübergänge, defekte/fremde Formate und Pfadkollisionen.
- **Tatsächliche Verifikation:** GitHub-Commits erfolgreich. Flutter-CI für neuen Test-Commit zum Zeitpunkt dieser Dokumentation **nicht als bestanden nachgewiesen**; keine lokale Dart-/Flutter-Ausführung oder Android-Geräteabnahme. GitHub Actions nach Commit kontrollieren und ggf. reparieren.
- **Grenzen/Blocker:** Das Journal ist bislang ein reiner Datenvertrag, kein durables Recovery-Protokoll. Es erkennt keine Dateisystem-Aliasse, garantiert keine fsync-Dauerhaftigkeit und autorisiert keinen produktiven Swap. Geschlossene Handles, exklusiver Lock, atomare Sicherung, Recovery nach Crash, Rollback, ausdrückliche UI-Freigabe und Gerätetests fehlen. M1–M4 nicht abgenommen.
- **Nächster Schritt:** Neue Flutter-CI verifizieren; danach persistentes Marker-Schreiben mit atomarer Veröffentlichung und Fehler-Injektion, isoliert in privaten Verzeichnissen und ohne automatischen produktiven Datenbanktausch.


## M4 Restore-Marker-Persistenz – 2026-11-22 (07:40 Europe/Berlin)
- Vor Beginn letzter gelisteter HEAD `09d4ffdea1e78639424fd1ebdd9c36b908ede865`; README, Implementierungsplan und STATUS gelesen. GitHub-Suche: keine offenen PRs und keine offenen Issues zum Abfragezeitpunkt (frühere Einträge nennen PR #1; dieser Status wurde nicht ungeprüft übernommen).
- Implementierung `e1989cd3a435dc9609fcb1b89159359125e6e6d9`: `apps/mobile/lib/restore_journal_store.dart` schreibt streng validierte Restore-Marker exklusiv mit `FileMode.writeOnlyExclusive`, flush und ohne Überschreiben. Ungültige/teilweise geschriebene Marker werden beim Lesen abgelehnt; keine automatische Bereinigung und keinerlei produktiver SQLite-Swap.
- Tests `8154575bda8b42bbed6a5957bc848ab05e9cf793`: synthetische Flutter-Dateisystemtests für exklusives Erstellen und Wiederlesen, unvollständige Marker und ungültige Journaldaten.
- **Verifikation:** GitHub-Commits bestätigt. Für den neuen Test-Commit liefert die verfügbare PR-Workflow-Abfrage keine Läufe; das ist **kein** grüner CI-Nachweis. Keine lokale Dart-/Flutter-Ausführung in diesem Lauf, keine Android-Geräteprüfung.
- **Grenzen:** Exklusives Erstellen + Flush allein garantiert keine Directory-fsync-Dauerhaftigkeit, keine atomare mehrstufige Aktivierung, keinen Lock über andere DB-Nutzer und keinen Rollback. Bei Schreibfehlern bleibt ein möglicherweise partieller Marker absichtlich bestehen (fail closed). Nur private App-Verzeichnisse verwenden; keine automatischen produktiven Änderungen.
- **Nächster Schritt:** Flutter-CI der Commits prüfen und ggf. korrigieren. Danach isolierte Recovery-/Crash-Injektionstests und eine sichere Journal-Phasenpersistenz mit ausdrücklich bestätigter, exklusiver Aktivierung entwickeln. M1–M4 weiterhin **nicht abgenommen**.


## M4 Begrenztes Restore-Marker-Lesen – 2026-11-22 (08:16 Europe/Berlin)
- Ausgangs-HEAD vor Codeänderung: `26f300aa0bc1821de05dd24177aa49e90775de0c`; README, Implementierungsplan, STATUS sowie offene PRs/Issues geprüft: PR #1 offen, keine eigenständigen offenen Issues.
- Implementierung `88c10b1fe22573f7990d7c84d9b7ac7f7dee38bf`: Restore-Marker werden beim Lesen auf maximal 16.384 Bytes begrenzt. Überlange Dateien werden abgelehnt, ohne sie zu ändern; unbeschränktes Einlesen entfällt. Keine Aktivierung oder produktive SQLite-Mutation.
- Regressionstest `d879ff93eaf0b572ca143f7956bf291b335f2ea2`: synthetischer überlanger Marker muss FormatException auslösen, unverändert bleiben und darf nicht überschrieben werden.
- **Tatsächliche Tests:** GitHub-Commits bestätigt. PR-gefilterte Workflow-Abfrage für Test-Commit ergab keine Läufe; **kein erfolgreicher Flutter-Test, Analyze oder APK-Build für diesen Commit nachgewiesen**. Keine lokale Dart-Toolchain-Ausführung in diesem Lauf.
- **Blocker:** GitHub-Actions-Ergebnis prüfen; Symlink-/TOCTOU-Risiken bei Marker-Dateien, atomare Phasenpersistenz, exklusiver Datenbank-Lock, Crash-Recovery, Rollback und Android-Geräteabnahme bleiben offen. M1–M4 nicht vollständig abgenommen.
- **Nächster Schritt:** CI des neuen HEAD auswerten und bei Fehler korrigieren; anschließend atomare Journal-Phasenpersistenz und gezielte Crash-Injektionstests implementieren, ohne produktive Datenbank automatisch auszutauschen.


## M4 Restore-Marker-Schreibgrenze – 2026-11-22 (08:45 Europe/Berlin)
- README, Implementierungsplan und STATUS gelesen. GitHub-Suche: PR #1 offen, keine eigenständigen offenen Issues. Die vorangegangene STATUS-Fortsetzung dokumentiert den Ausgangs-HEAD `26f300aa0bc1821de05dd24177aa49e90775de0c`; ein neuer HEAD wurde vor dieser Änderung nicht unabhängig über eine Branch-Ref abgefragt. Vor dem Schreiben wurden die betroffenen Dateien frisch gelesen.
- Code-Commit `3f88fcb0a9a8cbe5dee5b3b1214e2f586e9f63fb`: auch beim **Erstellen** wird das UTF-8-kodierte Restore-Journal vor dem Öffnen auf höchstens 16.384 Bytes begrenzt. Bisher konnte ein formal valides, überlanges Journal eine Marker-Datei erzeugen, die `read` anschließend verweigert. Bei Überschreitung entsteht nun keine Marker-Datei.
- Test-Commit `e5609eef6b53ba9a2a92a406092804f07a6a3c5b`: synthetischer Regressionstest für überlange gültige Pfade, fehlende Marker-Datei nach Ablehnung und anschließende normale Marker-Erstellung.
- **Testnachweis:** GitHub-Schreiboperationen bestätigt. Weder lokale Flutter-Tests noch ein abgeschlossener Actions-Lauf für den neuen Test-Commit nachgewiesen; **kein grüner CI-Status behauptet**. Letzter hier separat geprüfter Scheduler-Job [44988867490](https://github.com/WeA200675/life-ai-planner/actions/runs/44988867490) war erfolgreich, gehört aber zu einem älteren Stand.
- **Blocker:** Keine sichere atomare Journal-Phasenpersistenz mit Crash-Recovery und Directory-fsync, kein exklusiver SQLite-Lock, kein produktiver Swap/Rollback, keine Android-Geräte- und Release-Abnahme. Repo öffentlich; keine privaten Testdaten.
- **Nächster Schritt:** Aktuelle Flutter-CI des neuen HEAD prüfen und ggf. reparieren; danach sichere Phasenpersistenz in isoliertem Verzeichnis mit Fehler-Injektion, ohne produktive Datenbankaktivierung. M1–M4 weiterhin offen.


## M4 Restore-Marker: Symlink-Pfadprüfung – 2026-11-22 (09:17 Europe/Berlin)
- Vor Änderungen: GitHub-HEAD `906f2d83e2c2e083abe2cd66968b4b1341dec019`; README, Implementierungsplan, STATUS, offene PRs und Issues geprüft. PR #1 offen, keine eigenständigen Issues; keine vollständige Abnahme.
- Code-Commit `e2032ff8e1b269b9bea8cf1206e8ca298f85a67e`: `RestoreJournalStore` verweigert nun beim Erstellen und Lesen symbolische Links im Markerpfad sowie in allen Vorfahren (nofollow). Kein produktiver Datenbanktausch.
- Test-Commit `ee157a753a45ab95732b2d8e5fe6282eb8f13d7d`: zwei synthetische Dateisystem-Regressionstests für verlinkte Elternverzeichnisse und Markerdateien; auf Windows übersprungen.
- **Tatsächliche Verifikation:** Beide GitHub-Commits bestätigt; HEAD unmittelbar nach Test-Commit erneut geprüft. PR-gefilterte Workflow-Abfrage ergab keine Läufe, **kein** CI-Erfolg nachgewiesen. Keine lokale Flutter-Testausführung oder Geräteabnahme.
- **Grenzen/Blocker:** Pfadprüfung ist kein atomarer Schutz gegen TOCTOU durch fremde Writer; nur private App-Verzeichnisse verwenden. Exklusiver SQLite-Lock, crash-durable Phasenpersistenz, Original-Sicherung, Rollback, UI-Freigabe und Android-Release-/Gerätetests fehlen. M1–M4 weiterhin nicht abgenommen.
- **Nächster Schritt:** Flutter-CI des Test-Commits über GitHub Actions prüfen, bei Fehler korrigieren; danach isolierte atomare Journal-Phasenpersistenz mit Crash-Injektion implementieren, ohne produktive Aktivierung.


## Recovery-Phasenjournal – 2026-11-22 (09:37 Europe/Berlin)
- Ausgangs-HEAD laut Commit-Suche: `f9d73ee0fbd1632892ae73363515d53cf57768ec`. Offene PR: #1 (SQLite-Replanning); keine offenen eigenständigen Issues.
- Neue isolierte Bibliothek `packages/storage/recovery_phase.py`: strikt validierte Phasenfolge `prepared → original_saved → candidate_activated → verified`, Restore-ID-Prüfung, Ablehnung fehlender/ungültiger/überlanger Journale und Symlink-Pfade, atomarer Ersatz mit Datei- und Verzeichnis-fsync. **Keine produktive Datenbankumschaltung aktiviert.**
- Code-Commit: `19759b9ec64e809cfbd4bbee335ccbf5ec2eeee4`; fünf synthetische Regressionstests: `5a51abcbdc71383345f5845b9d48d26afe0363d6`.
- **Testnachweis:** fünf Tests mit äquivalentem lokalem Modul in isolierter Python-3-Umgebung erfolgreich (`python -m unittest discover -s tests -p test_recovery_phase.py -v`: 5/5 OK). Repository-weite CI für die neuen Commits **nicht bestätigt**. Git-Klon per DNS-Fehler (`Could not resolve host: github.com`) blockiert; GitHub-Connector-Schreiboperationen erfolgreich.
- **Wichtiger Blocker:** Der Phasenwechsel benötigt eine externe prozessübergreifende Sperre. Er ist keine Compare-and-swap-Operation; er darf erst mit einem getesteten Restore-Koordinator für exklusive SQLite-Verbindungen, WAL-Checkpoint, Backup, Crash-Recovery und Rollback verbunden werden. Plattform-/Geräteabnahme fehlt.
- **Nächster Schritt:** CI für neuen HEAD prüfen; externen Restore-Lock und Unterbrechungs-/Rollbacktests implementieren, dann erst produktive Aktivierung freigeben.
- **Abnahme:** M1–M4 weiterhin offen; keine vollständige Freigabe.


## M4 Exklusiver Recovery-Journal-Lock – 2026-11-22 (Folgelauf)
- README, docs/IMPLEMENTATION_PLAN.md und docs/STATUS.md gelesen. Ausgangs-HEAD vor Änderung: `525786e6baf93850b4878e2156147e2a1af5e270`. PR #1 offen, keine separaten offenen Issues. PR-gefilterte Actions-Abfrage für `5a51abc...` lieferte keine Läufe und ist **kein** CI-Erfolgsnachweis.
- Code-Commit `1036eaae8d1a419166fb98a1a859ad938b4581e9`: `packages/storage/recovery_lock.py` mit POSIX-`flock` (exklusiv, nicht blockierend), Symlink-/Inode-Prüfung, verweigert nicht-reguläre Lockdateien, behält Lock-Inode nach Freigabe bei; `advance_phase_locked` kapselt den bestehenden Phasenwechsel unter der Sperre. Auf nicht unterstützten Plattformen wird sicher abgebrochen.
- Test-Commit `24b855287f9c28bb9cf6cc94769ec4d0c477ccd5`: vier synthetische Tests für Sperrkonflikt, erneute Sperre, Journal-Fortschritt, Symlink-Schutz und unveränderten Lock-Inode.
- **Tatsächliche Verifikation:** GitHub bestätigte beide Commits. Lokaler Repository-Klon scheiterte mit `Could not resolve host: github.com`; deshalb **keine lokale Testausführung**, kein bestätigter CI-Erfolg und keine Android-Abnahme für diese Änderung. Die Tests sind geschrieben, aber noch nicht als bestanden nachgewiesen.
- **Grenzen:** Advisory Lock schützt nur kooperierende Prozesse mit identischem Lockpfad. Bestehende ungesperrte `advance_phase`-Aufrufer bleiben möglich; kein SQLite-Handle-Lock, keine produktive Datenbankaktivierung, kein Rollback. Windows wird bewusst nicht unterstützt, statt eine falsche Sicherheit zu suggerieren. M1–M4 nicht abgenommen.
- **Nächster Schritt:** CI für `24b8552` über Actions prüfen, Fehler korrigieren, Lock in einen vollständigen Restore-Koordinator mit WAL-Checkpoint, Original-Backup, Crash-Recovery und Rollback integrieren; erst nach Geräte-/Release-Abnahme aktivieren.

## M4 Drei-Themen-Lauf: Restore-Kandidatenprüfung – 2026-11-22
- Vor Codeänderung HEAD `ddaae8ba5790a385f524c0af6ea32df8ae8fe6ad`; README, Implementierungsplan und STATUS gelesen. PR #1 offen, keine eigenständigen offenen Issues; keine vollständige M1–M4-Abnahme.
- **Thema 1 / Integrität:** `packages/storage/recovery_preflight.py` prüft SQLite-Kandidaten ausschließlich lesend per `PRAGMA integrity_check`, Schema-Version und Tabellenübersicht. Implementierungs-Commit `ed404f5162377f576d313a36649bc8fb28455e09`.
- **Thema 2 / Sicherheit:** Symlinks, Mehrfach-Hardlinks, fehlende oder ungeeignete Dateien, übergroße Dateien sowie vorhandene SQLite-WAL/SHM/Journal-Sidecars werden verweigert. `immutable=1` wird nur bei Sidecar-freien Kandidaten eingesetzt; kein Datenbanktausch, keine produktive Mutation.
- **Thema 3 / Regression:** `tests/test_recovery_preflight.py` enthält sechs synthetische Tests für unveränderte gültige Kandidaten, falsche Schemaversion, Korruption, Sidecars, Symlinks und ungültige Eingaben. Test-Commit `f2843e21db1421154d88cea91ae15f8fe58f4cdb`.
- **Tatsächliche Verifikation:** Ein äquivalenter lokaler Python-3-Testlauf im isolierten Arbeitsverzeichnis ergab **6/6 OK** (`python -m unittest discover -s tests -p test_recovery_preflight.py -v`). Ein vollständiger Checkout und repo-weiter CI-Lauf wurden in diesem Lauf nicht nachgewiesen; die Tests des GitHub-HEAD sind daher noch nicht als CI-grün bestätigt. Kein Android-Build oder Gerätetest.
- **Grenzen/Blocker:** Prüfung ist nicht TOCTOU-sicher gegen einen nicht kooperierenden Writer; der Koordinator muss exklusiven Zugriff und geschlossene SQLite-Handles garantieren. Keine automatische Aktivierung, kein Original-Backup, kein Crash-Rollback, keine Geräteabnahme. Der Kandidat wird nicht in Betrieb genommen.
- **Nächster Schritt:** GitHub Actions für Test-HEAD prüfen; Preflight mit exklusivem Restore-Koordinator und WAL-/Original-Backup sowie Fault-Injection/Crash-Recovery verbinden. Anschließend Android-MVP-Integration und echte Geräteabnahme priorisieren.

## M2 Android-Vorschau: konfliktfeste Planübernahme – 2026-11-22
- Ausgangs-HEAD `3d26ecd1294756c3ca0cf8b38ba1a52b0969ba0d`; vorhandene Flutter-Tagesvorschau, PlanSnapshotStore und Scheduler gelesen. Bereits vorhanden: Vorschau, explizite Übernahme, SQLite-Transaktion und Undo; keine redundante Neuimplementierung.
- Commit `6d0bbb4fe749797faaa1178f3a84727758634d09`: Übernahme aus der Vorschau setzt nun den UI-Busy-Zustand bis zum Abschluss zurück, verhindert parallele UI-Aktionen und zeigt bei einem veralteten Aufgaben-Snapshot eine verständliche Neuplanungsaufforderung. Die bestehende atomare Task-Fingerprint-Prüfung im PlanSnapshotStore bleibt maßgeblich.
- **Nachweis:** GitHub-Commit bestätigt. Keine Flutter-Toolchain-/Widgettest-Ausführung und kein grüner CI-/APK-Nachweis für diesen Commit. Keine Geräteabnahme.
- **Blocker:** Eine echte Integration der offenen M3-PR #1, automatisierte Flutter-Widgettests, Android-Release und Gerätetest stehen aus; M1–M4 nicht vollständig abgenommen.
- **Nächster Schritt:** Flutter-CI auf dem neuen HEAD prüfen, Widgettests für Vorschau, veraltete Übernahme und Undo ergänzen; danach Android-Build und Geräteprüfung.


## M4 Restore-Preflight: Fremdschlüsselprüfung – 2026-11-22
- Vor Änderung letzter Commit laut GitHub-Suche: `2f27f7c13994265454a1ce0689645d1d6e90cb53`. README, Implementierungsplan, Status, PRs und Issues gelesen: PR #1 offen; keine eigenständigen offenen Issues.
- Code-Commit `e7693406a83130c88931ea060bfbbcc22267356c`: `inspect_candidate` prüft zusätzlich zu `PRAGMA integrity_check` nun `PRAGMA foreign_key_check` und verweigert Kandidaten mit verwaisten Fremdschlüsselreferenzen. Keine produktive Datenbankänderung oder automatische Umschaltung.
- Test-Commit `801ef8f4f82eabbd850ddc12279e13aa87992a7c`: zwei synthetische Regressionstests für ungültige und gültige Fremdschlüssel sowie unveränderte Kandidatendatei im Fehlerfall.
- **Verifikation:** GitHub bestätigte beide Schreiboperationen. Isolierter Python-3/SQLite-Nachweis für zwei Fälle (verwaister und gültiger Fremdschlüssel): 2/2 erfolgreich. **Kein Repository-Testlauf**: Git-Klon blockiert durch DNS `Could not resolve host: github.com`. GitHub-Actions-Erfolg für neuen HEAD nicht bestätigt.
- **Blocker:** End-to-End-Backup-Aktivierung, exklusive SQLite-Verbindungen, WAL/Crash-Rollback, Android-Geräte-/Release-Abnahme ausstehend. Öffentliches Repo: keine persönlichen Testdaten oder Secrets.
- **Nächster Schritt:** GitHub-Actions-Lauf für neuen HEAD prüfen, Repository-Regressionstests ausführen; danach Restore-Koordinator mit Fail-Closed-Lock, Original-Sicherung und Fault-Injection integrieren. M1–M4 nicht abgenommen.

## M4 Restore-Preflight: Anwendungsschema-Guard – 2026-11-22
- Ausgangs-HEAD vor Codeänderung: `691d7d43ed22c202f5e3c94f47ec8b70e5026c39`. README, Implementierungsplan, STATUS, PR #1 und Issues geprüft. PR #1 weiterhin offen; keine eigenständigen offenen Issues. M1–M4 nicht abgenommen.
- Code-Commit `76eb245bb0d239820af422762872247efd14d51e`: `inspect_candidate(..., required_tables=...)` kann nun erwartete Anwendungstabellen strikt validieren; fehlende Tabellen und ungültige Tabellennamen führen zu fail-closed-Abbruch. Die neue Prüfung ist optional, sodass vorhandene Aufrufer kompatibel bleiben. Keine SQLite-Aktivierung, kein Datenbanktausch.
- Test-Commit `67aae3fdead08b051cf633ed3bef9ae05c294569`: drei synthetische Regressionstests für vorhandene Tabellen, fehlende Tabellen ohne Dateimutation und ungültige Eingaben.
- **Tatsächliche Verifikation:** Beide GitHub-Commits bestätigt. GitHub-Workflow-Abfrage für den Test-SHA lieferte keine PR-getriggerten Läufe; daraus folgt **kein** CI-Erfolg oder CI-Fehler. Lokaler Git-Zugriff scheiterte mit `Could not resolve host: github.com`; Flutter ist in der lokalen Umgebung nicht installiert. Daher **keine tatsächliche Ausführung der neu geschriebenen Tests**, kein vollständiger Repository-Testlauf, keine APK-/Geräteabnahme.
- **Grenzen:** Der Aufrufer muss die erforderlichen Tabellen explizit übergeben; die Prüfung allein bestätigt weder Spaltenschema noch migrationsfähigen Datenbestand. Exklusiver Restore-Koordinator, Original-Backup, WAL-/Crash-Recovery, Rollback und Android-Geräteabnahme fehlen.
- **Nächster Schritt:** Repository-CI/Tests für `67aae3f` nachholen; anschließend den erforderlichen Tabellenvertrag aus der tatsächlichen App-Schema-Version ableiten und den Restore-Koordinator mit Original-Backup, Fault-Injection und Rollback isoliert testen. Parallel Android-Widgettests und Release-Build priorisieren.


## M4 Restore-Preflight: Sidecar-Race-Guard – 2026-11-22 (11:45 Europe/Berlin)
- Ausgangs-HEAD laut GitHub-Commit-Suche: `f9f9cfac83f7c4c0652868f5352e78d1ea265034`. README, Implementierungsplan und STATUS gelesen; PR #1 offen, keine eigenständigen offenen Issues.
- Implementierung `9ea6ee63a041de158237f6d53939b355a56e4dbd`: `inspect_candidate` prüft SQLite-Sidecars nicht nur vor, sondern auch nach dem lesenden Integritätscheck. Erscheint zwischenzeitlich eine WAL-/SHM-/Journal-Datei, wird die Kandidatenfreigabe verweigert. Keine Datenbankumschaltung, keine Dateilöschung.
- Regressionstest `798ea0570a6fcf8ffddea10a1946603b90e871fd`: simuliert das Erscheinen einer synthetischen WAL-Datei während `sqlite3.connect` und fordert fail-closed-Abbruch sowie Erhalt des Sidecars.
- **Testnachweis:** GitHub bestätigte Code- und Test-Commit. Vollständiger lokaler Repository-Testlauf war blockiert: `git clone` meldete `Could not resolve host: github.com`. Der neue Test wurde **nicht ausgeführt**; CI für den Test-HEAD ist **nicht bestätigt**. GitHub-Connector bietet in diesem Lauf keine belastbare Actions-Run-Auswertung; kein grüner CI-Status behauptet.
- **Sicherheitsgrenze:** Die zusätzliche Prüfung verkleinert nur das Race-Fenster; sie ist kein atomarer Schutz vor unkooperierenden Schreibern oder TOCTOU. Exklusiver Zugriff und geschlossene SQLite-Handles bleiben Voraussetzung. Produktive Aktivierung bleibt deaktiviert.
- **Nächster Schritt:** Actions-Lauf für `798ea057` verifizieren, Regression tatsächlich ausführen, anschließend exklusiven Restore-Koordinator mit Original-Sicherung, Fault-Injection und Rollback integrieren; Android-Release und Geräteabnahme bleiben ausstehend. M1–M4 nicht vollständig abgenommen.

## M4 Restore-Preflight: SQLite-Handle-Lifecycle – 2026-11-22
- README.md, docs/IMPLEMENTATION_PLAN.md, docs/STATUS.md, HEAD, PRs und Issues vor Änderung geprüft. Ausgangs-HEAD `934e03f7b98e8cacaa7a1a98458631f33f73302c`. PR #1 offen; keine eigenständigen offenen Issues; keine vollständige M1–M4-Abnahme.
- Code-Commit `2fe3358c64d13f84f859a678c8b6178c03348d4e`: Read-only-Preflight-Verbindung mit `contextlib.closing` explizit schließen. Der bisherige SQLite-Connection-Context-Manager schloss die Verbindung nicht. Die Änderung wirkt auch auf Fehlerpfade innerhalb der Prüfung; weiterhin keine produktive Aktivierung.
- Test-Commit `b72fbddd56e51f51101ff01b716fd65b0d4a506f`: Test mit instrumentierten SQLite-Verbindungen für erfolgreichen Check und Schema-Ablehnung; beide Handles müssen geschlossen sein.
- **Verifikation:** GitHub bestätigte Code- und Test-Commit. Die neue Repository-Testdatei wurde in diesem Lauf **nicht ausgeführt**; kein grüner CI-, Flutter- oder APK-Nachweis. Testausführung und Actions-Status stehen aus.
- **Blocker:** Exklusiver Restore-Koordinator, Crash-/WAL-Rollback, Android-Release und Geräteabnahme fehlen. Die reine Preflight-Prüfung ersetzt keine exklusive Sperre gegen konkurrierende Schreibzugriffe.
- **Nächster Schritt:** Repository-Python-Tests und CI verifizieren; anschließend Android-Widgettests und reproduzierbaren Release-Build priorisieren.

## M4 Restore-Preflight: Kandidaten verschwinden/Dateityp-Wechsel – 2026-11-22 12:20 Europe/Berlin
- README, Implementierungsplan, STATUS, HEAD, offene PRs und Issues vor dem Lauf gelesen. Ausgangs-HEAD `6bf1e305ab46e970592d12607116946bf48a57ea`; PR #1 offen; keine eigenständigen offenen Issues. Vollständige M1–M4-Abnahme weiterhin nicht nachgewiesen.
- Implementierung `74483d5144d41500d9aaa51d9b0e00d29f451d25`: Nach der lesenden SQLite-Prüfung führt das Verschwinden des Kandidaten nun zu `RecoveryPreflightError` statt rohem `OSError`. Zusätzlich werden Nicht-Regulärdateien und Mehrfach-Hardlinks im Abschlusscheck verworfen. Kein produktiver Restore.
- Test `8606780668c30556abea248d7b4b0723a6974aee`: synthetischer Test simuliert `FileNotFoundError` beim letzten `Path.lstat`; ursprüngliche Datei bleibt unverändert.
- **Verifikation:** Beide GitHub-Commits bestätigt. Isolierter lokaler Python-Nachweis für die Fehlerumwandlung ausgeführt: 1/1 PASS, allerdings **nicht** die vollständige Repository-Testdatei; diese neue Regression ist im Repository noch nicht tatsächlich ausgeführt. CI/Flutter/APK nicht als erfolgreich nachgewiesen.
- **Blocker:** Kein nachgewiesener Actions-Lauf für diesen HEAD, kein Android-Release/Gerätetest, kein exklusiver Restore-Koordinator und Crash-Rollback. Unkooperative konkurrierende Schreiber bleiben außerhalb der Garantie des Preflight.
- **Nächster Schritt:** Neue Regression mit Repository-Testumgebung und CI ausführen; Restore-Koordinator und Android-Widget-/Release-Tests priorisieren.

## M4 Restore-Preflight: ctime-Race-Guard – 2026-11-22 (12:44 Europe/Berlin)
- README, Implementierungsplan, STATUS und aktuelle Commits geprüft. Ausgangs-HEAD laut GitHub-Commit-Suche: `8de3ee147568222b2b1b733479459675c94708ad`. PR #1 offen, keine eigenständigen offenen Issues.
- Code-Commit `5ba0b2fecbc68beef219981df85cac982cd48fe2`: `inspect_candidate` vergleicht bei der abschließenden Identitätsprüfung zusätzlich `st_ctime_ns`. Ein gleich großer Schreibzugriff, der die ursprüngliche mtime wiederherstellt, kann so auf unterstützten Dateisystemen erkannt und sicher abgewiesen werden.
- Test-Commit `0f4e1030083ca9a329535002e851933791ea931d`: synthetischer Regressionstest schreibt während des Preflights ein unverändertes Byte, stellt mtime wieder her und verlangt einen fail-closed-Abbruch ohne Änderung des Dateiinhalts.
- **Verifikation:** GitHub bestätigte beide Commits. Der Repository-Klon scheiterte lokal erneut an DNS (`Could not resolve host: github.com`); die neue Testdatei wurde **nicht ausgeführt**. Die verfügbare Commit-Workflow-Abfrage liefert ausschließlich PR-getriggerte Läufe und gab für den Test-SHA keine Treffer zurück; **kein CI-Erfolg nachgewiesen**.
- **Grenzen:** ctime-Erkennung ist keine vollständige TOCTOU-Sicherung; Zeitstempelauflösung, privilegierte Manipulationen und unkooperative Schreiber bleiben Risiken. Exklusive SQLite-Handles, WAL-Checkpoint, Original-Sicherung, Crash-Recovery und Rollback fehlen. Produktive Aktivierung bleibt deaktiviert.
- **Nächster Schritt:** CI/Repository-Regression auf dem Test-SHA ausführen und ggf. korrigieren; anschließend Restore-Koordinator mit exklusiver Sperre und Fault-Injection/Crash-Rollback implementieren. Android-Release und Geräteabnahme fehlen. M1–M4 weiterhin nicht abgenommen.

## M2 SQLite-Planannahme: widersprüchliche Aufgaben-IDs – 2026-11-22
- Vor Änderung README, IMPLEMENTATION_PLAN, STATUS, HEAD, PRs und Issues gelesen; Ausgangs-HEAD `813369df8d72a5c6c0a36b11de078bf22910ee48`; PR #1 offen, keine eigenständigen offenen Issues.
- Code-Commit `18ce309487f037cfbf331e5b5fa05319d05390b9`: `PlanSnapshotStore.accept` lehnt vor Beginn der SQLite-Transaktion doppelte, leere oder nicht normalisierte zurückgestellte Task-IDs sowie IDs ab, die zugleich als Zeitblock eingeplant sind. Der vorhandene atomare Schreibpfad bleibt unverändert.
- **Verifikation:** GitHub-Commit bestätigt. Flutter-/Dart-Tests wurden in diesem Lauf nicht ausgeführt; kein CI-/APK-Erfolg bestätigt. Ein dedizierter Regressionstest für die neue Guard-Bedingung ist noch nachzureichen.
- **Blocker:** PR #1 nicht integriert; Android-Widgettests, Release-Build und Geräteabnahme fehlen. Kein produktiver Restore-Koordinator.
- **Nächster Schritt:** Pure-Dart-Validierung in eigenständige testbare Funktion extrahieren, Unit-Tests für widersprüchliche IDs ergänzen und Flutter-CI prüfen; danach Android-Release und manuelle Geräteabnahme.

## M2/M3 größerer Test-Meilenstein: Offline-Tagesplanung – 2026-11-22
- Nutzerpriorität: künftig größere zusammenhängende Implementierungsschritte mit Android-Nutzbarkeit, nicht nur einzelne Restore-Guards.
- README, Implementierungsplan, STATUS, aktueller HEAD, PR #1 und offene Issues geprüft. Ausgangs-HEAD `120dbb08509063740ce26e4794d281d61c41f592`. PR #1 weiterhin offen; keine eigenständigen Issues. Keine vollständige Abnahme.
- Bereits vorhandene M2-Änderung `18ce309487f037cfbf331e5b5fa05319d05390b9` verhindert widersprüchliche oder doppelte Deferred-IDs vor atomarer Planübernahme; dokumentiert in `120dbb0`. Keine erneute Änderung daran.
- Test-Commit `9c868276d8ead5ac8456193ef73d5b674e27510f`: neue Flutter-Testdatei `apps/mobile/test/offline_day_planner_milestone_test.dart` mit **neun** Szenarien: 70/30-Kapazität, Prioritäten, unveränderliche Fixtermine, Budgetüberschreitung, Deadline-Konflikte, Resttag-Neuplanung, Fixtermin-Überlappung, doppelte/ungültige IDs, unbekannte erledigte IDs sowie unveränderte Eingaben (ein Szenario umfasst mehrere Assertions).
- **Verifikation:** GitHub bestätigt den Test-Commit. Flutter-Tests konnten in diesem Lauf nicht ausgeführt werden; CI-/APK-/Geräte-Erfolg nicht nachgewiesen. Tests sind neue Prüffälle, kein Beleg für grüne Tests.
- **Blocker:** Vollständige Android-Integration, Flutter-Testlauf, offener M3-PR #1, reproduzierbarer APK-Build, Geräteabnahme, Restore-Koordinator und Rollback fehlen.
- **Nächster großer Schritt:** Flutter-Testumgebung/CI bereitstellen und diese neun Szenarien tatsächlich ausführen; anschließend Android-Widget- und SQLite-Integrationstests mit Installations-APK in einem gebündelten Meilenstein umsetzen.

## M3 Android: Validierung aller Fixtermine vor Resttag-Neuplanung – 2026-11-22 (13:22 Europe/Berlin)
- README.md, docs/IMPLEMENTATION_PLAN.md, docs/STATUS.md, HEAD, PR #1 und Issues geprüft. Ausgangs-HEAD `1e88c2a5642d0f6698090eff8a719bd636fa68e5`. PR #1 weiterhin offen; keine eigenständigen offenen Issues; M1–M4 nicht vollständig abgenommen.
- Code-Commit `841d156937c94c67b1daf49c4190e8ff7fa2f172`: `replanOfflineDay` validiert vor dem Abschneiden vergangener Termine nun alle Fixtermin-IDs, Überschneidungen, gültige Zeitspannen und Kollisionen mit Aufgaben-IDs, auch bei bereits erledigten Aufgaben. Fehlerhafte Vergangenheit wird nicht mehr still verworfen. Die bisherige Funktion, gültige vergangene Termine aus dem Resttag auszublenden, bleibt erhalten.
- Test-Commit `b3652e7dc2ca9ac07e1239d3127fc5962b9d0762`: vier neue Flutter-Regressionstests für vergangene überlappende Termine, doppelte vergangene Termin-IDs, ID-Kollision mit erledigter Aufgabe und unveränderte gültige Resttagplanung. Die Datei umfasst jetzt 13 Tests.
- **Tatsächliche Testlage:** In der verfügbaren lokalen Umgebung sind weder `flutter` noch `dart` installiert (`command -v` ohne Treffer); deshalb **0/13 Flutter-Tests ausgeführt**. GitHub combined status für Test-Commit lieferte `statuses: []`; PR-gefilterte Workflow-Abfrage `workflow_runs: []`. Das bestätigt **keinen** grünen oder roten CI-Lauf. GitHub bestätigte beide Commits.
- **Blocker:** Flutter-SDK/CI-Ausführung, Android-Release-Build, Gerätetest, PR #1 und vollständiger Restore-/Rollback-Koordinator ausstehend.
- **Nächster großer Schritt:** Flutter-SDK in reproduzierbarer CI bereitstellen, 13 Regressionstests und bestehende Tests ausführen, Fehler korrigieren; anschließend M2/M3 SQLite- und Widget-Integration und APK-Build verifizieren.

## Fortsetzung 2026-11-22 (13:44 Europe/Berlin)
- Vor Änderung letzter per Commit-Suche bestätigter HEAD: `29f9b9c936988d820e1e235bd594484dab6da4d6`. GitHub Actions Scheduler-Tests Run [45021970523](https://github.com/WeA200675/life-ai-planner/actions/runs/45021970523) für diesen SHA: `completed/success`. Offene PRs: #1; eigenständige Issues: keine.
- Sicherheitskorrektur: `recovery_lock` weist bereits vorhandene Lock-Dateien mit Gruppen-/Weltrechten zurück, statt potentiell unsichere Rechte stillschweigend zu akzeptieren. Der vorhandene Inhalt wird nicht geändert. Code-Commit `09787773331370961021056ce6a1527b6ff66c00`.
- Zwei synthetische Regressionstests für unsichere Alt-Datei (Ablehnung, keine Modifikation) und private Neuanlage (0600) ergänzt. Test-Commit `3df2de79cabe3e58e909f5500317e70eb35f6434`.
- **Nachweisgrenze:** GitHub-Schreiboperationen bestätigt; vollständiger lokaler Testlauf nicht möglich: `git ls-remote` meldete `Could not resolve host: github.com`. Der zuvor grüne CI-Lauf gehört ausdrücklich zum Ausgangs-HEAD, nicht zu diesen Änderungen. Neuer CI-Status muss separat bestätigt werden.
- **Nächster Schritt:** Actions für den neuen HEAD auswerten und Fehler korrigieren; danach prozessübergreifende Lock- und Absturztests sowie sichere Restore-Koordination vor produktiver Aktivierung. Android-Geräte-/Release-Abnahme fehlt; M1–M4 weiterhin offen.

## M2/M3 integrierte Offline-Planung: Validierung und Testkorrektur – 2026-11-22 (14:23 Europe/Berlin)
- README.md, docs/IMPLEMENTATION_PLAN.md und docs/STATUS.md, HEAD, PRs und Issues gelesen. Ausgangs-HEAD `29778db770d900d32f2a3a252ed6e3005ec9f22f`; PR #1 offen, keine eigenständigen Issues. M1–M4 nicht vollständig abgenommen.
- **Korrektur vorhandener Tests:** `4caa7c2c1a1a269cb329016ed42aab82b1d84b6e` korrigiert die chronologische Erwartung im Fixtermin-Test: eine 90-Minuten-Aufgabe kann nicht in die 60-Minuten-Lücke vor 09:00 passen und wird erst nach dem 09:00–10:00-Termin eingeplant. Der alte Test hätte die korrekte Planung fälschlich abgelehnt.
- **M3-Code:** `b13c768cce217e9eb2f47fcdaf6033ab43777a1f` zentralisiert die Aufgabenvalidierung und prüft in `replanOfflineDay` auch bereits erledigte Aufgaben *vor* dem Filtern. Ungültige Dauer, Priorität oder IDs erledigter Aufgaben werden nicht mehr stillschweigend übergangen. Keine Aufgabenmutation, kein Cloud-Zwang.
- **Tests:** `1dd7fb9de2ef5a5fb337b9fabbeccbbaf53c855b` ergänzt drei Regressionstests (ungültige Metadaten, ungültige IDs erledigter Aufgaben, gültige Filterung). Insgesamt 16 Testfälle in der Flutter-Meilensteindatei.
- **Verifikation:** GitHub bestätigte alle drei Schreib-Commits. GitHub combined statuses für `1dd7fb9`: `statuses: []`; PR-gefilterte Workflow-Abfrage: `workflow_runs: []`. **Kein CI-Erfolg nachgewiesen.** Flutter/Dart-Testausführung und APK-Build in diesem Lauf **nicht durchgeführt**; keine Behauptung grüner Tests.
- **Blocker:** Flutter-SDK/Test-Runner, vollständige SQLite-/Widget-Integration, PR #1, reproduzierbarer Android-Release-Build und Gerätetest sowie vollständiger Restore-/Rollback-Koordinator fehlen.
- **Nächster großer Schritt:** Flutter-CI tatsächlich ausführen, alle 16 Szenarien und bestehende Tests reparieren; anschließend Android-SQLite-Integration, Widget-Flows und installierbaren Release-Build gemeinsam verifizieren.

## M3 Regression: rekursiver Flutter-Validator repariert – 2026-11-22 (14:43 Europe/Berlin)
- README, Implementierungsplan, STATUS, letzte GitHub-Commits, offene PRs und Issues geprüft. Ausgangs-HEAD vor Änderung: `d0ad6e098ef896a293ac67b75f7396105bcbc751`. PR #1 offen, keine eigenständigen offenen Issues.
- **Kritischer Befund:** `_validateTasks` in `apps/mobile/lib/offline_day_planner.dart` rief sich ohne Abbruchbedingung selbst auf. Jeder `replanOfflineDay`-Aufruf konnte deshalb in einen Stack Overflow laufen. `planOfflineDay` verwendete bisher eine zweite, duplizierte Validierung.
- **Code-Commit:** `2609bda911e2b8aa93654a3224f4a9e6fee3e0f6`. Ersetzt die Rekursion durch vollständige ID-/Dauer-/Prioritätsprüfung und nutzt dieselbe Validierung für Erstplanung und Replanning.
- **Test-Commit:** `13b6d63d94ac17c25351e4136917af76685ab4b8`. Neuer Regressionstest prüft beide Einstiegspunkte mit gültigen Tasks, Ausschluss erledigter Tasks und Ablehnung doppelter IDs. Die bestehende Meilenstein-Testdatei enthält nun 17 Testfälle.
- **Nachweisgrenze:** GitHub bestätigte beide Schreiboperationen. Combined statuses für Test-Commit: leere Liste; PR-gefilterte Workflow-Abfrage: leere Liste. Dies ist **kein** grüner CI-Nachweis. Flutter-/Dart-Ausführung, APK-Build und Gerätetest in diesem Lauf nicht durchgeführt; Regressionstests noch unbestätigt.
- **Blocker:** Flutter-CI-Ausführung und Android-Geräte-/Release-Abnahme, PR #1, Restore-Koordinator mit Rollback weiterhin offen. Keine personenbezogenen Daten oder Secrets verwendet.
- **Nächster Schritt:** Flutter-CI für neuen HEAD kontrollieren, alle 17 Meilenstein- und weiteren Flutter-Tests ausführen und ggf. korrigieren; danach Android SQLite-/Widget-Integration und Release-Build nachweisen. M1–M4 noch nicht abgenommen.

## M3 Pufferkapazität: Sekundenpräzision und Regression – 2026-11-22 (15:20 Europe/Berlin)
- Vor Änderung README.md, docs/IMPLEMENTATION_PLAN.md, docs/STATUS.md, HEAD, PR #1 und Issues geprüft. Ausgangs-HEAD `a94f0972d37d06d517cf85067b82f46c1daf5bc6`; PR #1 offen, keine eigenständigen offenen Issues. Workflow `.github/workflows/flutter.yml` existiert und definiert Analyze, Test, Debug-APK und Artifact-Upload.
- **Bug:** `planOfflineDay` rundete die Dauer jedes Fixtermins einzeln auf volle Minuten ab und subtrahierte diese gerundeten Werte von der Gesamtkapazität. Bei zwei Terminen zu je 30 Sekunden entstand eine um eine Minute zu hohe freie Kapazität und möglicherweise ein zu großes 70/30-Budget.
- Code-Commit `fed51162f79229309faaf09b688d95bac60fa9e9`: Exakte `Duration` aller Fixtermine aufsummieren und erst die resultierende freie Zeit einmalig in Minuten umrechnen. Geschützte Termine bleiben unverändert, keine Datenbankmutation.
- Test-Commit `518592c3f2538e6b9a38a72e0f8e62815c4b2368`: zwei Flutter-Regressionstests für sekundenpräzise Fixtermine (59 freie Minuten, Budget 41) und reguläre Ganzminutentermine (480 freie Minuten, Budget 336). Die Meilensteindatei enthält jetzt 19 `test(...)`-Fälle.
- **Tatsächliche Verifikation:** GitHub bestätigt beide Commits. Für Test-SHA `518592c3` ergaben Combined Status und PR-gefilterte Workflow-Abfrage jeweils leere Listen. Das belegt **keinen CI-Erfolg**; die Flutter-Tests wurden in diesem Lauf **nicht ausgeführt**, kein APK-/Gerätetest durchgeführt.
- **Blocker:** Flutter-/Android-CI-Resultate und Geräteabnahme fehlen; PR #1, SQLite-Integration und Restore-Koordinator mit Rollback weiter offen. M1–M4 nicht vollständig abgenommen.
- **Nächster Schritt:** Flutter-Workflow-Ergebnisse auf aktuellem HEAD prüfen, alle 19 Meilensteinfälle und übrigen Flutter-Tests ausführen, ggf. korrigieren; danach SQLite-Widget-Integration und nachweisbaren APK-Build bündeln.

## M3: Pufferbudget ohne vorzeitige Minutenrundung – 2026-11-22 (15:45 Europe/Berlin)
- Ausgangs-HEAD aus GitHub-Commit-Suche: `19495177c99ff23bdcdd754867fa6292a11b05e4`. README, Implementierungsplan, STATUS und Flutter-Planer gelesen. PR #1 offen; keine eigenständigen offenen Issues. PR-gefilterte Workflow-Abfrage für Ausgangs-HEAD: `workflow_runs: []` (kein CI-Erfolgsnachweis).
- **Befund:** Nach der bereits korrigierten sekundengenauen Berechnung der freien Zeit wurde `available = freeDuration.inMinutes` noch **vor** Anwendung des 70/30-Faktors abgerundet. Bei 2:59 Minuten freier Zeit ergibt das fälschlich 1 statt 2 Minuten Aufgabenbudget.
- **Code-Commit:** `885e4c0f1d9a651dd0d3dc260df77e30db064bac`. Der Pufferfaktor wird jetzt auf die freie Dauer in Mikrosekunden angewandt; erst das Ergebnis wird auf ganze Minuten abgerundet. Die berichtete Ganzminuten-Kapazität und Reserve bleiben unverändert definiert.
- **Test-Commit:** `02035df9f5aa41cff43d681eeb333887760220fe`. Zwei synthetische Flutter-Regressionstests für 2:59 Minuten freies Fenster und 4:00 Minuten Fenster mit 1:01 Minuten Fixtermin.
- **Testnachweis:** GitHub bestätigte beide Commits. Die neuen Flutter-Tests wurden in diesem Lauf **nicht ausgeführt**; kein grüner CI-Lauf, Android-Build oder Gerätetest für diesen HEAD belegt. CI muss auf dem neuen SHA separat kontrolliert werden.
- **Blocker und nächster Schritt:** Flutter-CI ausführen, Tests/Analyse und Debug-APK verifizieren und Fehler beheben; anschließend SQLite-/Widget-Integration und Restore-/Rollback-Koordinator prüfen. PR #1 offen; vollständige M1–M4-Abnahme ausstehend.

## M2/M3: Flutter-CI-Nachweis und Kapazitätsinvarianten – 2026-11-22
- Vor Beginn README, Implementierungsplan, STATUS, HEAD, offenen PR #1, Issues, Flutter-Workflow, pubspec und Planer gelesen. Ausgangs-HEAD `85f504e743caf3e7ebe1830c1203ccb7b4fd1f75`; keine eigenständigen offenen Issues, M1–M4 nicht abgenommen.
- CI-Commit `c8d010e4335c88f936177e8844d9b5d1aeee512d`: minimale GitHub-Actions-Leseberechtigung, 60-Minuten-Joblimit, Flutter-Test mit Coverage und ausführlicher Testausgabe; Coverage-Artefakt wird unabhängig vom späteren Android-Build hochgeladen, falls erzeugt. Der vorhandene Debug-APK-Build und SHA-256-Upload bleiben bestehen.
- Test-Commit `a3d641702273ea840403fd62f40a3497c20ded9f`: deterministischer Flutter-Regressionstest über **600 Planungsfenster** für 70/30-Budget, Reservenerhaltung, Task-Vollständigkeit, überschneidungsfreie Blöcke und wiederholbare Reihenfolge.
- **Tatsächliche Verifikation:** Beide GitHub-Schreiboperationen bestätigt. Vorherige PR-gefilterte GitHub-Workflow-Abfrage für Ausgangs-HEAD ergab `workflow_runs: []`; das ist **kein** Beleg für einen fehlgeschlagenen oder erfolgreichen Push-Workflow. Flutter-/Dart-SDK im ausführbaren Lauf nicht bereitgestellt, daher **keine tatsächliche Flutter-Testausführung**, kein grüner CI-Lauf, kein APK-/Gerätetest nachgewiesen. Coverage-Upload ist eine Pipeline-Konfiguration, noch kein erzeugtes Artefakt.
- **Blocker:** Flutter-Workflow auf dem neuen SHA ausführen und die Ergebnisse auswerten, offene PR #1 nach CI prüfen, SQLite-Widget-Integration und Android-Geräteabnahme; Restore-/Rollback-Koordinator weiterhin offen.
- **Nächster Schritt:** GitHub-Actions-Push-Lauf prüfen, `flutter analyze`, `flutter test --coverage --reporter expanded` und Debug-APK nachweisbar grün bekommen; anschließend auf reale SQLite-/Widget-Integration und Gerätetest konzentrieren.

## Flutter CI-Fehlerbehebung – 2026-11-22 (16:45 Europe/Berlin)
- Verifizierter Ausgangs-HEAD: `a9aee844533bb03492bfaffe021ccdac6a4ff641`.
- Offene PRs: #1 (SQLite-Replanning); eigenständige offene Issues: 0.
- Scheduler-CI für Ausgangs-HEAD: Run [45037539440](https://github.com/WeA200675/life-ai-planner/actions/runs/45037539440) **success**.
- Flutter-CI Run [45037515646](https://github.com/WeA200675/life-ai-planner/actions/runs/45037515646) **failure** im Schritt `flutter analyze --no-fatal-infos`. Job-Log: `FileMode.writeOnlyExclusive` existiert in Dart nicht (`lib/restore_journal_store.dart:47`); Tests und APK-Build wurden übersprungen. Die übrigen Analyzer-Meldungen waren Hinweise, nicht der belegte Blocker.
- Fix: exklusives, atomisches No-Clobber-Anlegen des Markers mit `File.create(exclusive: true)`, danach Schreiben und Flush über `FileMode.writeOnly`. Bestehende Marker werden nicht überschrieben; unvollständige Marker werden beim Lesen weiterhin abgelehnt. Annahme: privates Restore-Verzeichnis ohne fremde Schreibberechtigung; kein vollständiges crash-durables Restore-Protokoll.
- Code-Commit: `3a063ade028949f73117b863f961c80073ffa89d`.
- Verifikation: GitHub-Commit bestätigt; Flutter-Run [45040107426](https://github.com/WeA200675/life-ai-planner/actions/runs/45040107426) und Scheduler-Run [45040107518](https://github.com/WeA200675/life-ai-planner/actions/runs/45040107518) zum Zeitpunkt der Kontrolle **queued**. Kein lokaler Flutter-Lauf oder APK-Nachweis. Der neue CI-Lauf muss erst erfolgreich abschließen.
- Nächster Schritt: Flutter-Analyzer/Test/APK-Ergebnisse des neuen HEAD auswerten; bei Erfolg zusätzliche Konkurrenz-/Absturztests für die Marker-Erstellung und Restore-Sperren; danach Android-Geräte- und Release-Abnahme.
- M1–M4 nicht vollständig abgenommen. Produktive Restore-Umschaltung bleibt deaktiviert.

## M4 Restore-Marker: Konkurrenz- und Crash-Regression – 2026-11-22 (17:20 Europe/Berlin)
- README, Implementierungsplan, STATUS, aktueller HEAD, offener PR #1 und Issues vor der Änderung geprüft. Ausgangs-HEAD `b2134722168a8b34b0c8681303f69b52b4b065f4`; keine eigenständigen offenen Issues. M1–M4 weiterhin nicht abgenommen.
- Bestehende Implementierung `restore_journal_store.dart` verwendet `File.create(exclusive: true)`, bewahrt vorhandene Marker und verwirft beschädigte Einträge. Keine redundante Implementierung oder automatische Restore-Aktivierung.
- Test-Commit `4fc39671ad599d9b8ce1861a571e54126128ca19`: drei zusätzliche Flutter-Regressionstests: zwölf konkurrierende Marker-Ersteller (exakt ein Gewinner), leere/abgeschnittene Marker bleiben erhalten und werden abgewiesen, sowie unterschiedliche Restore-Operationen dürfen den vorhandenen Marker nicht überschreiben.
- **Tatsächliche Verifikation:** GitHub bestätigte den Test-Commit. `git ls-remote` im Ausführungscontainer scheiterte mit `Could not resolve host: github.com`; Flutter/Dart hier nicht verfügbar. Der Connector liefert für Commit-Workflow-Abfragen nur PR-getriggerte Runs; für `3a063ade` wurde `workflow_runs: []` zurückgegeben. **Die neuen Tests wurden nicht ausgeführt; weder CI-Erfolg noch APK nachgewiesen.** Der in der vorherigen Statussektion dokumentierte frühere Analyzer-Fehler wurde mit `3a063ade` adressiert, aber dessen grüner Folgelauf bleibt unbestätigt.
- **Blocker:** Flutter-Push-CI samt Analyzer, Tests und APK auswerten; reale Android-Geräteabnahme, Restore-Koordinator mit exklusiver Sperre, Rollback und Crash-Recovery weiterhin ausstehend. Tests verwenden ausschließlich synthetische Daten; keine Secrets.
- **Nächster Schritt:** GitHub-Actions-Push-Lauf auf aktuellem HEAD prüfen und Fehler beheben; erst nach grünen Tests den nächsten großen Android-/SQLite-Integrationsmeilenstein samt Release-Build bearbeiten.


## Flutter SQLite-Öffnung gegen konkurrierende Zugriffe abgesichert – 2026-11-22 (17:38 Europe/Berlin)
- Ausgangs-HEAD: `2e2f131f9b5388580e7b4ee718b6da05c7b863cb`; README, IMPLEMENTATION_PLAN und STATUS gelesen; PR #1 offen, keine eigenständigen offenen Issues.
- Änderung in `apps/mobile/lib/main.dart`: `LocalTasks.database` teilt nun ein einziges laufendes Open-Future unter gleichzeitigen Aufrufern, statt mehrere konkurrierende `openDatabase`-Aufrufe und Migrationen zu starten. Fehlgeschlagene Öffnungen werden nicht dauerhaft gecacht; `close()` wartet auf eine laufende Öffnung und schließt deren Handle.
- Code-Commit: `88d1c650222ccd1dc0f78d2fc952a8762af3a1e1`.
- **Nachweis:** GitHub bestätigte den Schreib-Commit; statische Prüfung der ersetzten Getter-/Close-Pfade anhand des Quelltexts. Kein Dart-/Flutter-Testlauf in dieser Umgebung; keine neue Testausführung und kein grüner APK-Build behauptet. Die commitbezogene Actions-Abfrage lieferte nur `workflow_runs: []` (Connector filtert PR-Runs), also **keinen** belastbaren Push-CI-Status.
- **Risiko/Blocker:** Konkurrenz- und Retry-Verhalten benötigt Flutter-/sqflite-Integrationstests (insbesondere parallele Öffnung und Schließen bei laufendem Open); Android-Gerätetest, Release-Build und Restore-Rollback fehlen. Produktive Restore-Umschaltung bleibt deaktiviert. Keine personenbezogenen Testdaten oder Secrets.
- **Nächster Schritt:** Flutter-CI-Push-Läufe samt Analyzer/Test/APK verifizieren und ggf. korrigieren; gezielte parallele SQLite-Open-/Retry-Tests mit kontrollierter DB-Factory ergänzen. Danach Android-Release-/Geräteabnahme. M1–M4 weiterhin offen.

## M4 SQLite-Restore: Anwendungsspalten-Vertrag – 2026-11-22 (18:21 Europe/Berlin)
- README, docs/IMPLEMENTATION_PLAN.md und docs/STATUS.md gelesen; HEAD vor jedem Schreibzugriff erneut per GitHub abgefragt. Ausgangs-HEAD `c7ff0a7d6857d8d85f307bb488bf77263d9e9c03`. PR #1 offen, keine eigenständigen offenen Issues; M1–M4 nicht abgenommen.
- Code-Commit `5f4108a5ae326bdf0095691b6459728246de91b1`: `inspect_candidate(..., required_columns=...)` prüft erwartete Anwendungsspalten read-only; ungültige Tabellen-/Spaltennamen, leere Verträge und fehlende Spalten werden fail-closed abgewiesen. Optionaler Parameter wahrt bestehende Aufruferkompatibilität. Keine produktive DB-Aktivierung.
- Test-Commit `8d8c2150b0df92e80ffb708e7276b1a077844cff`: vier synthetische unittest-Szenarien zu gültigen Spalten, fehlenden Tabellen/Spalten, ungültigen Vertragswerten und View-vs-Table-Verhalten.
- Korrektur-Commit `744ab62f85db29a8419a2f1a365eb9353c3e59f2`: erforderliche Spalten werden nur in echten SQLite-Anwendungstabellen akzeptiert, nicht in Views. Vor Korrektur konnte `PRAGMA table_info` auch Views liefern.
- **Tatsächliche Verifikation:** GitHub bestätigte die drei Code-/Test-Commits. GitHub-Connector meldete für `744ab62` `workflow_runs: []`; der Endpunkt filtert PR-getriggerte Läufe, daher **kein Nachweis für erfolgreichen oder fehlgeschlagenen Push-CI-Lauf**. `git ls-remote` im Container scheiterte mit `Could not resolve host: github.com`; Flutter nicht verfügbar. Neue Tests **nicht ausgeführt**; kein grüner Test-/APK-Nachweis.
- **Sicherheitsgrenzen:** Der optionale Vertrag muss vom Restore-Aufrufer mit den tatsächlichen Anwendungstabellen und Spalten versorgt werden; keine automatische Prüfung aller SQLite-Constraints, Migrationen oder App-Versionen. Exklusive Sperre, WAL-/Crash-Rollback, Android-Geräteabnahme weiterhin offen. Keine Secrets oder personenbezogenen Testdaten.
- **Nächster großer Schritt:** Tatsächlichen Android-v4-Schema-Vertrag in einen isolierten Restore-Koordinator integrieren, SQLite-/Flutter-Integrationstests und CI ausführen, anschließend reproduzierbaren Release-Build und Geräteabnahme.

## 2026-11-22 – Python SQLite-FK-Prüfung (Folgelauf)
- Ausgangs-HEAD main: `8ad158d4b33c8da31e96144790effdd85ffd771f`. Scheduler Actions [45049026075](https://github.com/WeA200675/life-ai-planner/actions/runs/45049026075) für diesen HEAD: success.
- Offene PRs: #1 (Offline SQLite Replanning); offene eigenständige Issues: keine.
- `packages/storage/backup.py`: zusätzlich zu `PRAGMA quick_check` wird `PRAGMA foreign_key_check` ausgeführt. Damit werden verwaiste Referenzen auch in Erweiterungstabellen bei Backup und Restore abgewiesen. Commit `357f3ec23356cfd3cd9e5ab1c2603576aa5f3fc0`.
- `tests/test_backup.py`: zwei synthetische Negativtests für Backup und Restore mit verwaisten Fremdschlüsseln. Commit `6f6268a064cc113a1b2d0c5d2b567cdf67326598`.
- **Testnachweis:** GitHub-Schreiboperationen bestätigt. Lokaler Klon und unittest-Aufruf scheiterten vor Teststart mit `Could not resolve host: github.com`. Neue Tests **nicht ausgeführt**; CI-Ergebnis für neuen HEAD noch offen.
- **Nächster Schritt:** GitHub Actions des neuen HEAD prüfen, gegebenenfalls Tests korrigieren; dann Flutter-SQLite-Restore-Konkurrenz-/Crash-Tests und Android-Build-/Geräteabnahme.
- **Abnahme:** M1–M4 nicht vollständig; produktive SQLite-Restore-Umschaltung bleibt deaktiviert. Keine personenbezogenen Testdaten.

## M4 Android-v4-Schema-Vertrag für Restore-Preflight – 2026-11-22 (19:15 Europe/Berlin)
- README.md, docs/IMPLEMENTATION_PLAN.md, docs/STATUS.md und Android-Schemaquellen gelesen. Ausgangs-HEAD `eccf9faa02601e24cf73a8c3f6a18fe96b97a736`; PR #1 offen, keine eigenständigen offenen Issues. Keine vollständige M1–M4-Abnahme.
- Code-Commit `ae008581b232bcb685bcb97981ec44c16e6e3bfd`: `packages/storage/android_schema_contract.py` bindet `inspect_candidate` an die tatsächliche Flutter-SQLite-Version 4 mit drei erforderlichen Tabellen (`tasks`, `plan_snapshots`, `plan_snapshot_blocks`) und sämtlichen in `local_task_schema.dart`/`plan_snapshot_store.dart` definierten Anwendungsspalten. Rein lesende Validierung; keine automatische Restore-Aktivierung, keine Datenlöschung.
- Test-Commit `441d40a635590de21f53695eca5dbdf4801f892e`: sieben synthetische unittest-Szenarien für gültige v4-DB ohne Mutation, falsche Version, fehlende Snapshot-Tabelle, fehlende Task-/Blockspalten, Korruption und SQLite-Sidecar. Keine privaten Daten.
- **Tatsächliche Testlage:** GitHub hat beide Commits bestätigt. `git ls-remote` scheiterte lokal mit `Could not resolve host: github.com`; Repository-Tests wurden **nicht ausgeführt**. GitHub-Commit-Workflow-Abfrage für `441d40a` meldete `workflow_runs: []`, ist jedoch auf PR-Events beschränkt: **kein belastbarer Push-CI-Status**. Kein grüner Testlauf und keine APK behauptet.
- **Sicherheitsgrenzen:** Der Schema-Vertrag validiert Spaltenpräsenz, nicht Datentypen, CHECK-/FK-Constraints oder vollständige Migrationen. Exklusiver Restore-Koordinator, Original-Sicherung, WAL-/Crash-Recovery und Rollback fehlen; produktive Aktivierung bleibt deaktiviert.
- **Nächster großer Schritt:** CI/Python-Tests für `441d40a` ausführen und korrigieren; danach den exklusiven Restore-Koordinator mit Original-Backup, Crash-Fault-Injection und Rollback implementieren. Flutter-SQLite-Integration, APK-Build und reale Geräteabnahme weiterhin ausstehend.


## M4 Android v4 SQLite restore preflight – 2026-11-22 19:39 CET
- Ausgangs-HEAD: `1bddaa0c185d17a8bbce4d72506b630393fd6460` (GitHub-Commit-Suche); offener PR #1, keine eigenständigen offenen Issues.
- Die vorhandene Android-v4-Validierung prüfte Tabellen und Spalten, aber nicht die Primärschlüssel. Ein synthetisches Schema mit passenden Spalten ohne PK wäre akzeptiert worden.
- `packages/storage/recovery_preflight.py`: optionaler, expliziter Primärschlüsselvertrag über `PRAGMA table_info`; die Reihenfolge zusammengesetzter Schlüssel wird geprüft.
- `packages/storage/android_schema_contract.py`: PK-Vertrag für `tasks(id)`, `plan_snapshots(id)` und `plan_snapshot_blocks(snapshot_id, position)`.
- `tests/test_android_schema_contract.py`: zwei synthetische Regressionstests für fehlenden und vertauschten Primärschlüssel.
- Commits: `4333e3681bacb22f0ac60009d4a7d38885235122`, `e8a7c90f2b581c6093d0a59669b58c5372837ec7`, `8395ecd83b6d5ea1f6b4259d69f673af62da4653`.
- **Nachweisgrenze:** GitHub-Schreiboperationen bestätigt; lokaler Klon scheitert an DNS (`Could not resolve host: github.com`). Neue Tests und CI für diesen Stand **nicht** als bestanden bestätigt. Die Commit-bezogene Actions-Abfrage für den Ausgangs-HEAD lieferte keine PR-Workflow-Runs, was keinen CI-Erfolg belegt.
- **Nächster Schritt:** Tests und CI für den neuen HEAD ausführen, bei Fehlern korrigieren; danach vollständigen Android-v4-Schemaabgleich und gesperrten Restore-/Rollback-Koordinator prüfen. Kein produktiver Restore aktiviert.
- **Abnahme:** M1–M4 offen, Android-Release-/Geräteabnahme fehlt. Keine personenbezogenen Testdaten oder Secrets verwendet.


## M4 SQLite Android-v4 NOT-NULL-/FK-Preflight – 2026-11-22 (19:44 CET)
- Vorab README, Implementierungsplan, STATUS, HEAD `a25461146044431d5a66a5e0c713d6000ed421c2`, Issues und PRs geprüft. PR #1 weiterhin offen; der Issue #1 ist mit dem PR verknüpft. Ausgangs-CI Scheduler [45056368598](https://github.com/WeA200675/life-ai-planner/actions/runs/45056368598) erfolgreich.
- `9e179772e77ccd4adb631e372878c90147fbeb81`: optionaler, fail-closed SQLite-Schema-Vertrag für explizite NOT-NULL-Spalten und deklarierte FK-Kanten in `inspect_candidate`. Bestehende Aufrufer ohne optionale Parameter bleiben kompatibel.
- `55fdf2e307002366eedd599e8145edc065b4cb59`: Android-v4-Vertrag fordert NOT NULL für die in Flutter deklarierten Pflichtfelder sowie `plan_snapshot_blocks.snapshot_id -> plan_snapshots.id`.
- `6058666e7fbab5f6d68a422a2c5d56fe1e99bd8f`: drei neue synthetische Negativtests (nullable Titel, fehlender FK, falsches FK-Ziel).
- **Nachweis:** GitHub-Commits bestätigt; neue Scheduler-CI [45056821027](https://github.com/WeA200675/life-ai-planner/actions/runs/45056821027) und Android-v4-Vertrag-CI [45056820926](https://github.com/WeA200675/life-ai-planner/actions/runs/45056820926) beim letzten Abruf queued. Tests für den neuen Stand nicht als erfolgreich behauptet. Während der Änderungen erschien ein paralleler Commit `a7ae0c671`; HEAD muss vor weiteren Änderungen neu gelesen werden.
- **Grenzen:** Schema-Prüfung ist read-only und keine produktive Restore-Aktivierung. CHECK-Constraints, Transaktions-/WAL-Rollback und exklusiver Android-DB-Zugriff weiterhin nicht nachgewiesen. Flutter-Geräteabnahme, Release-Build und M1–M4-Abnahme ausstehend.
- **Nächster Schritt:** CI prüfen und ggf. Fehler reparieren; danach CHECK-Constraint-/Index-Validierung und sicherer exklusiver Restore-Koordinator mit Fault-Injection, ohne produktive Daten umzuschalten.


## Release R1 Integrationslauf – 2026-11-22 (19:45 CET)
- Ausgangslage: README.md, docs/IMPLEMENTATION_PLAN.md, docs/STATUS.md, Flutter-Workflow, Android-Schema und zugehörige Tests geprüft. PR #1 offen; keine eigenständigen offenen Issues. M1–M4 nicht abgenommen.
- Neuer dedizierter GitHub-Actions-Workflow `.github/workflows/android-schema-contract.yml` für Python-3.12-Syntaxprüfung und Android-v4-Schema-/Restore-Preflight-Regressionstests, bei passenden Push-/PR-Änderungen sowie manuell auslösbar. Commits `a7ae0c671dc7a339b04ede61f74c1afa46a6af1b` und `ffb0e76536c69f92ed455f1129828c0105f722b5` (unittest discovery unabhängig von tests-Paketlayout).
- **Nachweis:** GitHub hat beide Schreiboperationen bestätigt. Weder ein erfolgreicher Workflow-Lauf noch Testausgaben, Flutter-Build, APK oder Gerätetest wurden in diesem Lauf nachgewiesen. Workflow-Prüfung kann bei CI-Fehlern weitere Anpassungen erfordern.
- **Blocker:** Kein verfügbarer lokaler Flutter-/Android-Build mit Gerätezugriff; Android-v4-Restore-Koordinator mit exklusivem Lock, Original-Backup und Crash-Rollback weiterhin ausstehend. Kein produktiver Restore aktiviert.
- **Nächster Schritt:** Neuen Python-Workflow tatsächlich ausführen/Ergebnis prüfen und Fehler korrigieren; anschließend Android SQLite Widget-/Integrationstests, reproduzierbare APK und Geräteabnahme priorisieren. HEAD vor jedem Schreibvorgang neu prüfen und konkurrierende Automationen berücksichtigen.


## Release R1 – Offline-Planung und SQLite-Integration (2026-11-22)
- Vor Schreibvorgängen HEAD geprüft; Integrationsarbeit auf dem aktuellen Default-Branch, PR #1 bleibt offen. Keine vollständige M1–M4-Abnahme.
- Neue Datei `apps/mobile/test/offline_sqlite_integration_release_test.dart`: fünf synthetische Flutter/sqflite-ffi-Integrationstests für Vorschau→atomare Snapshot-Annahme→Verlauf→Undo ohne Task-Mutation, veraltete Vorschau, zwei konkurrierende append-only-Annahmen, überlappende Blöcke ohne Teilpersistenz und Schema-v3-Datenübernahme in Snapshot-Tabellen.
- Code-Commits `628b15178b9fddfb3c0a4725bf9d61f9316128f1`, `1d7657314a3b02a2685fd24ffb05d84f947cf161` (plattformunabhängiger In-Memory-Test).
- **Wichtig:** Konkurrenztest beweist keine Request-Idempotenz; derzeit werden zwei gültige Accepts als zwei Versionen gespeichert. Migrationstest prüft Schema-DDL und Datenerhalt, nicht den kompletten onUpgrade-Callback. Keine produktive Restore-Aktivierung.
- **Testnachweis:** GitHub-Commits bestätigt. Flutter-Tests in diesem Lauf nicht ausgeführt; CI-Lauf und APK nicht bestätigt. Neue Tests gelten ausdrücklich als UNVERIFIZIERT, bis Flutter CI erfolgreich läuft.
- **Nächster Schritt:** Flutter-CI und APK-Artefakt prüfen, ggf. fehlschlagende Tests korrigieren; anschließend echte Upgrade-/Restore-/Crash-Integration, UI-Widget-Tests und Geräteabnahme. Keine Secrets oder privaten Daten.


## M3 Release R1 – SQLite-Idempotenz für Planannahme (2026-11-22)
- Vor jedem Schreibvorgang HEAD erneut geprüft. Ausgangs-HEAD `e039649fe12fab882d9337b6a7176a86f02efeef`; PR #1 weiterhin offen, keine eigenständigen offenen Issues bei der letzten Abfrage.
- `apps/mobile/lib/plan_snapshot_store.dart`: additive Tabelle `plan_accept_requests` mit eindeutigem request_key, snapshot_id und Payload-Fingerprint. Optionaler requestKey bei `accept`: innerhalb derselben SQLite-Transaktion werden identische Retries auf dieselbe Snapshot-ID aufgelöst; widersprüchliche Wiederverwendung wirft StateError. Undo löscht Schlüsselzuordnung transaktional vor Snapshot-Löschung. Ohne requestKey bleibt das bisherige append-only-Verhalten erhalten.
- `apps/mobile/lib/main.dart`: idempotentes `createPlanSnapshotSchema` bei `onOpen`, damit bereits installierte v4-Datenbanken die neue Tabelle ohne Task-/Snapshot-Datenverlust erhalten. Die UI übergibt noch keinen requestKey; Ende-zu-Ende-Idempotenz der UI ist daher noch offen.
- `apps/mobile/test/offline_sqlite_integration_release_test.dart`: vier synthetische Tests für konkurrierende identische Anfragen, Schlüssel-Kollision, Undo/Retry und additive Schema-Erstellung. Commits: `d7cbbcebd436942d9cb8d8f64fe5c9463a2a303e`, `4aca21b7f18947f8c8eb17a2d00408c8af9c44a9`, `2057dff88e84c3f1d7f293863786c888dafe208e`.
- **Nachweisgrenze:** GitHub-Commits bestätigt; Flutter-Tests, CI und APK für diesen Stand nicht erfolgreich nachgewiesen. Die neuen Testfälle sind noch nicht ausgeführt. Keine produktive Restore-Umschaltung oder Geräteabnahme.
- **Nächster Schritt:** Flutter CI auf dem aktuellen HEAD ausführen und eventuelle Fehler korrigieren; requestKey bis zur UI durchreichen und bei Doppeltaps/retries stabil halten; SQLite-Migrations-/Restore-Tests, Android APK und reale Geräteabnahme.


## M3 Release R1 – Android-UI-Idempotenz integriert (2026-11-22)
- Vor Schreibvorgängen HEAD erneut geprüft; Ausgangs-HEAD `1d6ccd2858e2ea062df0c3c98b9e561629c3951a`. PR #1 weiterhin offen, keine eigenständigen offenen Issues bei letzter Abfrage.
- `apps/mobile/lib/main.dart`: `LocalTasks.acceptPlan` reicht optionalen requestKey an `PlanSnapshotStore.accept` weiter. Die Tagesplan-/Resttag-Vorschau erzeugt einmalig einen 128-Bit-Schlüssel aus `Random.secure()` und verwendet diesen beim Übernehmen; neue Vorschauen bekommen eigene Schlüssel. Damit ist der Schlüssel an den UI-Bestätigungsvorgang gekoppelt und nicht global geteilt.
- Commit `9190081bbed6ab7de5c398aa02ece2079cffc632`.
- **Teststatus:** GitHub-Commit bestätigt; Flutter-Tests, CI und APK für diesen Stand nicht nachgewiesen. UI-Retry nach App-Neustart verwendet noch keine persistierte Operation-ID; keine Behauptung vollständiger Crash-Retry-Garantie. Keine produktive Restore-Umschaltung.
- **Nächster Schritt:** Flutter CI tatsächlich prüfen, Test-/Buildfehler beheben, Widget-Test für Vorschau/Annahme ergänzen, APK-Artefakt erzeugen und Geräteabnahme durchführen.


## Release R1 – Testabdeckung und CI-Sichtung (2026-11-22)
- Aktuellen HEAD vor Änderungen geprüft. `apps/mobile/test/offline_sqlite_integration_release_test.dart` um zwei Tests erweitert: erneute idempotente Annahme nach Neuerstellen des `PlanSnapshotStore` mit derselben SQLite-Verbindung; ungültige Request-Schlüssel (leer, Whitespace, über 128 Zeichen) werden ohne Schreiboperation abgewiesen.
- Commits `6e3c3c37d04d85955f2d7eb8d40fad4be511adf1`, `7bd39a257d2736d8c017ad8690974efaadef5eab` (gültige Dart-Erzeugung des langen Testschlüssels).
- `.github/workflows/flutter.yml` geprüft: Flutter analyze, Tests mit Coverage, Debug-APK-Build, ZIP-Integritätsprüfung, SHA-256 und Upload sind definiert. `fetch_commit_workflow_runs` lieferte für den zuvor geprüften HEAD keine PR-Workflow-Läufe; dieser Endpunkt deckt Push-Läufe nicht vollständig ab. **Keine Behauptung, dass CI grün oder eine APK vorhanden ist.**
- **Noch nicht ausgeführt:** Flutter-Tests, APK-Build und Geräteabnahme. Store-Neuerstellung ist kein Prozessneustart oder SQLite-Datei-Neuöffnung; dafür ist weitere Persistenzprüfung erforderlich.
- **Nächster Schritt:** Tatsächliche CI-Logs/Build-Artefakte verifizieren, Fehler korrigieren, persistente SQLite-Datei-Neuöffnung und Crash-/Restore-Abnahme ergänzen.


## M3 Release R1 – persistente SQLite-Neuöffnung (2026-11-22)
- README, Implementierungsplan und STATUS sowie HEAD, offene PRs/Issues und Flutter-CI-Konfiguration gelesen. Ausgangs-HEAD `683a097992b1ca1a6ae637b4f9250d1116372d2f`; PR #1 weiterhin offen; keine eigenständigen offenen Issues gefunden. Keine vollständige Abnahme.
- **Implementiert:** Neuer Test in `apps/mobile/test/offline_sqlite_integration_release_test.dart` verwendet eine temporäre echte SQLite-Datei (statt nur in-memory), erzeugt synthetische Taskdaten, akzeptiert eine Planversion mit requestKey, schließt die Datenbank, öffnet dieselbe Datei neu und prüft, dass identischer Retry dieselbe Snapshot-ID zurückliefert, die Historie nur einen Eintrag enthält und Taskdaten unverändert sind. Temporärverzeichnis wird im finally bereinigt. Commit `693e93cc475a1271a54867661ee3825caa34f094`.
- **Nachweise:** GitHub bestätigte Commit. Der Connector `fetch_commit_workflow_runs` lieferte für diesen Commit keine PR-Workflow-Läufe; Push-Läufe werden von diesem Endpunkt nicht vollständig erfasst. Flutter-Tests, Analyse, APK und Geräteabnahme konnten hier nicht ausgeführt bzw. als erfolgreich belegt werden; neuer Teststatus **UNVERIFIZIERT**. Keine privaten Daten/Secrets verwendet.
- **Blocker/nächster Schritt:** Push-CI unter GitHub Actions direkt prüfen und ggf. fehlschlagende Jobs/Logs bearbeiten; Android-APK mit SHA-256-Artefakt nachweisen; anschließend Crash-/Restore-/Rollback-Abnahme und manuelle Geräteprüfung. Kein produktiver Restore aktiviert.


## M4 Backup-Quellpfade – 2026-11-22 (20:40 Europe/Berlin)
- Ausgangs-HEAD: `7a56546c0de47ed694f2989a123076946d1b2a5a`; offene PRs: #1, offene eigenständige Issues: 0.
- Vorherige Scheduler-CI: [45060003255](https://github.com/WeA200675/life-ai-planner/actions/runs/45060003255) für Ausgangs-HEAD: **success**; dies bestätigt nicht die neuen Änderungen.
- Backup/Restore lehnt jetzt symlinked und mehrfach hartverlinkte SQLite-Quelldateien vor `resolve()` ab, statt deren Umleitung stillschweigend zu akzeptieren. Zielpublikation bleibt exklusiv.
- Code-Commit: `c057fead95a9a792f270203a221fb8c39185ea87`; drei synthetische Regressionstests: `722d9f2756bb4b31298539f128e552b6d33dd6e9`.
- **Testnachweis:** GitHub-Commits bestätigt; lokaler Git-Klon wegen `Could not resolve host: github.com` fehlgeschlagen. Die neuen Tests und CI sind zum Dokumentationszeitpunkt **nicht** als bestanden verifiziert.
- **Grenze:** Die neue Prüfung schützt gegen bereits vorhandene Symlinks/Hardlinks, ist aber keine vollständige Race-/TOCTOU-Sicherung gegen konkurrierende Pfadänderungen. Produktive Restore-Umschaltung bleibt deaktiviert.
- **Nächster Schritt:** GitHub Actions für neuen HEAD prüfen, ggf. Fehler beheben; anschließend sichere Deskriptor-basierte Pfadöffnung und Flutter-/Android-Release-/Geräteabnahme.
- **Abnahme:** M1–M4 noch nicht vollständig.

- **CI-Korrektur desselben Laufs:** Android-Schema-Workflow [45062126699](https://github.com/WeA200675/life-ai-planner/actions/runs/45062126699) scheiterte nach erfolgreicher Syntaxprüfung mit Exit 2: YAML faltete zwei `python -m unittest`-Kommandos zu einem einzigen ungültigen Aufruf (`unrecognized arguments: -m`). Workflow-Skriptblock auf `run: |` korrigiert, Commit `af537467bf788dcdc73248ac5db5b5ecdf6fc78e`. Neuer CI-Lauf muss separat bestätigt werden.


## M4 – realer SQLite-v3→v4-Upgrade-Test (2026-11-22, Lauf 20)
- README, `docs/IMPLEMENTATION_PLAN.md`, STATUS, HEAD und offene PRs/Issues geprüft: Ausgangs-HEAD `bae5d3f57905d65cb137cb7f71bf7b959e0454aa`; PR #1 offen, keine separaten offenen Issues. M1–M4 nicht abgenommen. CI-Stand: dokumentierter fehlgeschlagener Android-Schema-Lauf `45062126699`; Korrektur `af537467bf788dcdc73248ac5db5b5ecdf6fc78e` ist noch nicht als erfolgreich verifiziert. PR-gefilterte Commit-Workflow-Abfrage für HEAD lieferte keine Läufe und ist keine vollständige Push-CI-Sicht.
- **Neuer vertikaler Test:** `apps/mobile/test/offline_sqlite_integration_release_test.dart` legt eine temporäre echte SQLite-Datei als v3 mit synthetischer Task an, schließt sie, öffnet sie als v4 mit Upgrade-Callback erneut, erstellt die Snapshot-Struktur additiv und prüft Upgrade-Callback, unveränderte Tasks, akzeptierten Plan und Historie. Aufräumen im `finally`. Code-Commit `17abd83021f7aef06084ec704e6d11380bff5375`.
- **Tatsächliche Testausführung:** Flutter/Dart im verfügbaren Container nicht installiert; `git ls-remote` scheiterte an DNS (`Could not resolve host: github.com`). GitHub-Connector bestätigte den Code-Commit, aber kein erfolgreicher Flutter-Test, CI-Lauf oder APK-Build für diesen Commit nachgewiesen. Teststatus **UNVERIFIZIERT**.
- **Blocker:** Flutter-Laufzeit und vollständige GitHub-Actions-Push-Job-Einsicht fehlen hier; Geräteabnahme und produktive Restore-Umschaltung weiterhin offen. Keine Secrets/privaten Daten verwendet.
- **Nächster Schritt:** GitHub Actions Flutter-Workflow auf aktuellem HEAD samt Job-Logs und APK-Artefakt verifizieren, Fehler beheben; danach echten Android-v4-Restore mit Crash-Rollback und Geräteabnahme prüfen.


## M4 – Restore-Schema der idempotenten Planannahme (2026-11-22)
- Ausgangs-HEAD: `cf7019a89cd4aa26acc8c0acc0e24fbf88ad7f94`; PR #1 offen, keine eigenständigen offenen Issues. README, Implementierungsplan und STATUS gelesen.
- **Fehlerbild:** Der Android-v4-Restore-Preflight prüfte bisher nur drei Tabellen. Die seitdem produktiv verwendete Tabelle `plan_accept_requests` fehlte im Restore-Vertrag; ein Backup ohne diese Tabelle hätte die Prüfung bestehen können und spätere idempotente Planannahmen gefährdet.
- **Korrektur:** `packages/storage/android_schema_contract.py` verlangt nun die vierte Tabelle samt Spalten, Primärschlüssel, NOT-NULL-Feldern und Fremdschlüssel auf `plan_snapshots`. Commit `63925ffb4bd8be824f0cf2f21c3012655d6ddb3f`.
- **Tests:** Bestehende synthetische v4-Fixture um die vierte Tabelle erweitert; drei Regressionstests für fehlende Tabelle, Fingerprint-Spalte und Fremdschlüssel ergänzt. Commit `476534926e78fd18f23578a803b62c17af4c4f51`.
- **Nachweisgrenze:** GitHub bestätigte die Schreiboperationen. Ein erfolgreicher Python-/Flutter-Testlauf oder CI-Lauf für diesen Stand ist **nicht** belegt. Der GitHub-Connector liefert bei `fetch_commit_workflow_runs` nur PR-gefilterte Ergebnisse; leere Resultate belegen keinen Push-CI-Erfolg. Die produktive Restore-Umschaltung bleibt deaktiviert.
- **Nächster Schritt:** Android-Schema-Workflow auf dem neuen HEAD mit Logs prüfen und gegebenenfalls reparieren; danach vollständige SQLite-v4-Wiederherstellung mit exklusivem Koordinator, Crash-Rollback und Android-Geräteabnahme. M1–M4 nicht vollständig abgenommen.


## M4 – Release-Kandidat: Signatur-Nachweis statt irreführendem „unsigned“ (2026-11-22, 22:19 Europe/Berlin)
- README, Implementierungsplan und STATUS geprüft; Ausgangs-HEAD `b593bf78f234dec06f47e6ef67c29f086e7fdfec`. PR #1 offen, keine eigenständigen offenen Issues in der Abfrage. M1–M4 nicht abgenommen. PR-gefilterte Commit-Workflow-Abfrage ergab für HEAD keine Läufe; keine vollständige Push-CI-Einsicht.
- **Befund:** `.github/workflows/release-acceptance.yml` bezeichnete das Flutter-Release-APK als „unsigned“, obwohl `flutter build apk --release` nicht belegt, ob die generierte Android-Konfiguration mit Debug- oder Release-Key signiert. Dies ist eine sicherheitsrelevante Fehletikettierung.
- **Änderung:** Release-Artefakt wird neutral als `life-ai-planner-release-mode-candidate-signing-unverified` bezeichnet. Nach Build und SHA-256-Prüfung muss das Android-SDK-`apksigner verify --print-certs` erfolgreich sein; Signaturzertifikatsinformationen werden als Build-Artefakt gespeichert und bei erkennbarer Debug-Signatur wird ausdrücklich gewarnt. Es werden keine Schlüssel oder privaten Daten ins Repo geschrieben. Commits `7aceafd1ee4d8072da06cb467d797a1101bb2ad8`, `1ff7b9e177040ca09ba7ef383af6a2e801009650`.
- **Nachweis:** GitHub bestätigte beide Commits. In dieser Ausführung wurde weder der neue GitHub-Actions-Workflow noch Flutter-/Android-Build oder Gerätetest erfolgreich ausgeführt; Signaturprüfung ist daher **UNVERIFIZIERT**. Die Warnung ist kein Produktionssignatur-Nachweis. Bei fehlendem `apksigner` scheitert der Job explizit.
- **Nächster Schritt:** Workflow-Ausführung auf neuem HEAD und Build-Artefakte inklusive Zertifikatsdatei prüfen, Fehler korrigieren; erst danach Release-Signing-Konfiguration und sichere APK-Verteilung entscheiden. Restore/Crash-Rollback und Geräteabnahme bleiben offen.


## Release-Abnahme CI-Härtung – 2026-11-22 (Folgelauf)
- Ausgangs-HEAD: `e8f3e674cd9bd3143eecf99b85d4c14cfc1ee988`; GitHub-Suche: keine offenen Issues/PRs.
- Commit `7a99ce064a0474dec8065d82458b15f4919447b5`: Release-Acceptance-Workflow läuft nun auch bei Änderungen an `docs/STATUS.md` und `docs/RELEASE_ACCEPTANCE_*.md`, verhindert überlappende Läufe desselben Branches und prüft die APK-Signatur-Schemes mit `apksigner verify --verbose --print-certs`.
- Nachweis: GitHub-Commit bestätigt; **keine erfolgreich abgeschlossenen Backend-/Flutter-/APK-Tests für den neuen HEAD nachgewiesen**. Der Workflow muss in Actions geprüft werden.
- Sicherheit: Release-Modus ist nicht gleich produktive Signatur. Debug-Signatur bleibt ausdrücklich nicht freigabefähig; keine Schlüssel im Repository.
- Blocker: kein nachgewiesener Android-Gerätetest, keine produktive Signatur, kein vollständiger Crash-Rollback-Test. M1–M4 bleiben NICHT ABGENOMMEN.
- Nächster Schritt: GitHub-Actions-Lauf für diesen HEAD auswerten und ggf. korrigieren; Release-Keystore außerhalb des Repos und Geräteabnahme separat nachweisen.


## M4 – transaktionaler SQLite-Fehlerfall und Wiederholung (2026-11-22, Lauf 20)
- README, Implementierungsplan, STATUS, HEAD, PRs/Issues und Flutter-/Release-CI-Definition gelesen. Ausgangs-HEAD `981dd7487a2e19726a407990649c8763248e9567`; PR #1 offen; keine separaten offenen Issues. Keine M1–M4-Gesamtabnahme.
- **Priorität:** Datenverlustfreie Planannahme bei einem tatsächlichen SQLite-Schreibfehler nach bereits begonnener Transaktion. Der neue synthetische Integrationstest `SQLite trigger failure rolls back header, blocks and request key` in `apps/mobile/test/offline_sqlite_integration_release_test.dart` injiziert mit einem SQLite-Trigger einen Abbruch beim zweiten Blockinsert. Er fordert vollständiges Rollback aller Snapshot-/Block-/Idempotenz-Zeilen und unveränderte Aufgaben. Nach Entfernen des Triggers wird dieselbe Request-ID erneut versucht und die genau einmalige erfolgreiche Speicherung geprüft.
- **Code-Commit:** `ca1b1c9737b1b554e28cb9ba8177d96c973222cd` (GitHub-Schreibbestätigung).
- **Tatsächliche Prüfung:** `command -v flutter` und `command -v dart` lieferten keine Installation; `git ls-remote` scheiterte an DNS (`Could not resolve host: github.com`). Der GitHub-Connector lieferte für den vorherigen HEAD keine PR-gefilterten Workflow-Läufe, was Push-CI nicht abdeckt. Der neue Test wurde daher **NICHT AUSGEFÜHRT**, weder Flutter-CI noch APK oder Gerätetest wurden für den neuen Stand als erfolgreich bestätigt. Keine Erfolgskennzahlen behauptet.
- **Blocker:** Flutter/Android-Toolchain bzw. verifizierbare Push-CI-Logs/Artefakte und Gerätezugriff fehlen; produktive Restore-Umschaltung, Crash-Rollback-Abnahme und Release-Signing bleiben offen.
- **Nächster Schritt:** Neuen Flutter-Workflow auf Commit `ca1b1c9737b1b554e28cb9ba8177d96c973222cd` in GitHub Actions auswerten, Testausgabe prüfen und gegebenenfalls korrigieren; danach Restore-/Crash-Szenarien, APK-SHA-256, Signatur und Geräteabnahme verifizieren. Keine Secrets oder echten Nutzerdaten.


## Release-CI: Testbelege auch bei Fehlschlägen – 2026-11-22
- Ausgangs-HEAD `27caf245d3e758a0350aaeb5cd218967c227d113`; README, Implementierungsplan, STATUS und Release-CI geprüft. GitHub-Issue-Suche ergab keine offenen Issues/PRs zum Abfragezeitpunkt.
- Implementierung: `.github/workflows/release-acceptance.yml` bewahrt Python-Kompilierungs- und unittest-Ausgaben sowie Flutter-Testausgabe und Coverage als GitHub-Actions-Artefakte auf, **auch wenn der jeweilige Testschritt fehlschlägt**. `set -euo pipefail` verhindert, dass `tee` fehlgeschlagene Tests als erfolgreich maskiert. Commit `bd7027844265ec130fd296bc091476e70ba7d992`.
- Testnachweis: GitHub-Schreiboperation bestätigt. Weder CI-Ausführung noch Flutter/Android-Geräteprüfung für diesen Commit in diesem Lauf nachgewiesen. Der GitHub-Connector stellt keine vollständige Liste von Push-Workflow-Runs bereit. **Keine Testfreigabe**.
- Blocker: CI-Logs/Artefakte müssen aus Actions geprüft werden; produktives Signing, Restore-Rollback und echte Geräteabnahme fehlen. M1–M4 bleiben offen.
- Nächster Schritt: Release-Actions-Lauf auf neuem HEAD prüfen, Artefakte auswerten und konkrete Fehler korrigieren; danach signierten Android-Build und Gerätetest abnehmen.


## M4 – SQLite-Fremdschlüssel beim Android-Öffnen aktivieren (2026-11-23)
- README, Implementierungsplan, STATUS, HEAD, offene PRs und Issues gelesen. Ausgangs-HEAD `31914d6f06770ed7f543406cf32a20e51c5b2aee`; PR #1 offen, keine eigenständigen offenen Issues. M1–M4 nicht vollständig abgenommen. PR-gefilterte Workflow-Abfrage für Ausgangs-HEAD lieferte keine Runs, dies ist **keine** vollständige Push-CI-Sicht.
- **Befund:** `plan_snapshot_blocks` und `plan_accept_requests` besitzen SQLite-Foreign-Key-Verweise, aber Androids `LocalTasks._openDatabase` aktivierte bisher `PRAGMA foreign_keys` nicht ausdrücklich. SQLite kann Fremdschlüssel pro Verbindung standardmäßig deaktiviert haben; DDL allein erzwingt dann keine Integrität.
- **Änderung:** `apps/mobile/lib/main.dart` setzt `PRAGMA foreign_keys = ON` über `onConfigure` vor `onCreate`/`onUpgrade`/`onOpen` für jede App-Datenbanköffnung. Commit `ffd65d3cfef62554a675e5ecf6a8ed6404e3bdd3`.
- **Tests ergänzt:** Zwei echte temporäre SQLite-Datei-Integrationstests in `apps/mobile/test/offline_sqlite_integration_release_test.dart` prüfen aktivierte Fremdschlüssel, Abweisung verwaister Block-/Request-Zeilen, Cascade-Löschung der Kindzeilen und unveränderte Tasks. Commit `299e6344b798d9fb277919bc215ed5c0c19e792f`.
- **Tatsächlich ausgeführt:** Container hat kein `flutter` und kein `dart`. Python-SQLite-Sanitycheck auf SQLite 3.46.1: `PRAGMA foreign_keys` vor Aktivierung = 0, nach Aktivierung = 1. Dies bestätigt nur die SQLite-Eigenschaft, **nicht** die Flutter-Tests. GitHub bestätigte beide Code-Commits. CI, APK und Android-Geräteabnahme für diese Commits **UNVERIFIZIERT**.
- **Grenzen:** Vorhandene verwaiste Altzeilen werden durch Aktivierung nicht automatisch bereinigt; produktive Datenbank vor Restore/Release mit `PRAGMA foreign_key_check` prüfen und bei Befund ohne Datenverlust abbrechen. Produktive Restore-Umschaltung und Release-Signing weiterhin offen.
- **Nächster Schritt:** Flutter-/Release-CI auf neuem HEAD mit tatsächlichen Logs/Artefakten prüfen und Testfehler beheben; anschließend FK-Integritäts-Preflight für bestehende Datenbanken, Crash-Restore/Undo und APK-/Geräteabnahme.


## M4 – Android Legacy-FK-Preflight (2026-11-23)
- Ausgangs-HEAD `226204e945abb632614d9736b914a4dc228338ef`; README, Implementierungsplan, STATUS und Release-CI geprüft. GitHub-Issue-Suche `is:open`: keine Treffer (einschließlich PRs).
- Befund: `PRAGMA foreign_keys=ON` schützt künftige Schreiboperationen, entdeckt aber bereits bestehende verwaiste Zeilen nicht automatisch.
- Implementierung: `apps/mobile/lib/main.dart` prüft in `onOpen` nach additiver Schemaerstellung `PRAGMA foreign_key_check`. Bei Befund wird mit `StateError` ohne automatische Löschung oder Restore-Umschaltung abgebrochen. Code-Commit `16e484282b7526f322403fbe1b155ac0f2513d87`.
- Nachweis: GitHub-Änderung bestätigt; **keine Flutter-Testausführung, kein grüner Push-CI-Lauf, kein Android-Release-Build und keine Geräteabnahme für diesen Stand nachgewiesen**. Der Connector für Commit-Workflow-Runs filtert nur PR-Events; klassische Combined-Statuschecks sind kein vollständiger Actions-Nachweis.
- Blocker: Verifikation mit Flutter-Toolchain und CI-Logs/Artefakten; sichere Restore-/Crash-Rollback-Abnahme; Release-Signing und reale Geräteprüfung. M1–M4 NICHT ABGENOMMEN.
- Nächster Schritt: gezielten Regressionstest für das Öffnen einer Legacy-Datenbank mit verwaisten Kindzeilen hinzufügen und ausführen; CI-Fehler beheben, dann signierten Release-Build und Geräteabnahme belegen.


## M4 – Legacy-SQLite-FK-Preflight als Integrationstest (2026-11-23, Lauf 20)
- README.md, docs/IMPLEMENTATION_PLAN.md, docs/STATUS.md und HEAD geprüft. Ausgangs-HEAD `d79bbf842c02b00bf78230cfd449545c984e604f`; offene PR #1 (M3-Replanning), keine eigenständigen offenen Issues. Keine vollständige M1–M4-Abnahme.
- **Implementierung:** `apps/mobile/lib/sqlite_integrity.dart` extrahiert die nicht-destruktive `PRAGMA foreign_key_check`-Prüfung; Android-`LocalTasks.onOpen` verwendet denselben Prüfpfad. Semantik bleibt unverändert: bestehende verwaiste Datensätze führen zu `StateError`, keine automatische Löschung.
- **Regressionstests:** Zwei zusätzliche synthetische Datei-SQLite-Tests in `apps/mobile/test/offline_sqlite_integration_release_test.dart`: (1) Legacy-Verbindung ohne FK-Enforcement erzeugt absichtlich einen verwaisten Planblock; nach Schließen und erneuter Öffnung mit FK-Enforcement weist der produktiv genutzte Prüfpfad die Datenbank zurück, danach werden unveränderte Tasks/Kindzeilen geprüft; (2) gültige Datenbank lässt sich mit derselben Prüfung erneut öffnen.
- **Code-Commits:** `6c5d696a69d9ef1ee84afae32cd7bfa6c18b71e1`, `b49575d2eaae2b144065648b3243c1bfbf0e2ee1`, `5ebc5221753728221e0f30d28cb046ad05785852` (GitHub-Schreibbestätigungen).
- **Tatsächlich ausgeführt:** `command -v flutter` und `command -v dart` lieferten keinen Pfad. Python sqlite3 3.46.1: absichtlich verwaister FK-Eintrag wird mit `PRAGMA foreign_key_check` erkannt (1 Treffer); `PRAGMA foreign_keys=ON` ergibt 1. Dies ist nur ein SQLite-Sanitycheck, **kein ausgeführter Flutter-Test**.
- **CI:** GitHub-Connector lieferte für HEAD `5ebc5221753728221e0f30d28cb046ad05785852` keine PR-gefilterten Workflow-Runs; Push-Runs sind über diese Abfrage nicht vollständig sichtbar. Flutter-CI, APK, Signatur, Restore-/Crash-Rollback und Android-Geräteabnahme **NICHT NACHGEWIESEN**.
- **Blocker:** Fehlende Flutter-/Dart-Toolchain hier; CI-Logs/Build-Artefakte und reale Geräteabnahme fehlen. Keine produktive Restore-Umschaltung. Keine privaten Daten/Secrets.
- **Nächster Schritt:** Flutter-CI auf aktuellem HEAD prüfen, neue Integrationstests tatsächlich ausführen und Fehler beheben; APK-Artefakt/Signatur nachweisen, danach sichere Backup-/Restore-/Crash-Abnahme und Android-Gerätetest.


## M4 – Release-Signing-Fail-Closed (2026-11-23)
- Ausgangs-HEAD: `61f8a4128bfe807ddbe3508ca2906ef00342a90e`; README, Implementierungsplan, STATUS und Release-Workflow gelesen; offene Issue-/PR-Suche ergab 0 Treffer zum Prüfzeitpunkt.
- Befund: Der Release-Workflow meldete eine erkannte Android-Debug-Signatur nur als Warnung. Ein grüner Job hätte deshalb trotz nicht produktiv freigabefähiger Signatur entstehen können.
- Änderung: `.github/workflows/release-acceptance.yml` beendet den Signing-Prüfschritt bei erkannter Debug-Signatur mit Fehlercode 1. Das APK-/Prüfsummen-/Zertifikatsartefakt wird über `if: always()` soweit vorhanden auch im Fehlerfall als Diagnose gesichert. Fehlende Artefakte erzeugen keinen zweiten, irreführenden Upload-Fehler.
- Code-Commit: `35c641590a12610cb9d0a2ccb36bbf1225928fec` (GitHub bestätigt).
- Verifikation: GitHub-Schreibbestätigung für YAML-Änderung; **keine Ausführung des geänderten Workflows, kein Flutter-/APK-Build, keine Signatur- oder Geräteprüfung für neuen HEAD nachgewiesen**. GitHub-Connector bietet keine vollständige Push-Actions-Run-Liste. Keine Produktionsfreigabe.
- Blocker: Sicheres Release-Signing mit außerhalb des Repos verwahrtem Keystore, erfolgreicher CI-Lauf, Android-Geräteabnahme und Crash-Restore-/Rollback-Nachweis fehlen.
- Nächster Schritt: GitHub-Actions-Run und Signing-Artefakt des neuen HEAD prüfen, ggf. Buildfehler beheben und produktive Signatur über GitHub Secrets/geschützte Umgebung einrichten. M1–M4 **NICHT ABGENOMMEN**.


## M4 – Fail-closed Legacy-Open vor Schemaänderungen (2026-11-23, Lauf 20)
- README, Implementierungsplan, Status, HEAD und CI-Workflow gelesen; Ausgangs-HEAD `b766e8bb19adc171d1c054e12569ef9738893766`. PR #1 offen, keine eigenständigen offenen Issues. Keine vollständige M1–M4-Abnahme.
- **Befund:** `LocalTasks.onOpen` führte `createPlanSnapshotSchema` aus, bevor `PRAGMA foreign_key_check` verwaiste Legacy-Datensätze erkannte. Damit konnten bei einer korrupten Alt-Datenbank neue Tabellen angelegt werden, obwohl der Öffnungsvorgang anschließend fail-closed abbrach.
- **Korrektur:** `apps/mobile/lib/main.dart` prüft Foreign Keys jetzt **vor** additiver DDL und danach erneut. Eine bereits inkonsistente Datenbank wird ohne Schemaerweiterung abgewiesen. Commit `2c2a701929c7834564e8362257ff9431102d47c2`.
- **Regression:** Bestehenden Datei-SQLite-Test um Legacy-v4-Situation ohne `plan_accept_requests` erweitert: absichtlich verwaister Kinddatensatz, abgewiesene Öffnung und Nachweis, dass die fehlende Tabelle **nicht** angelegt wurde. Commit `d40036b8a8d88270ef99e6d16ab82cfb477a7d28`.
- **Tatsächlich ausgeführt:** Python sqlite3 3.46.1 mit temporärer Datei: 1 absichtlich verwaister FK-Eintrag erkannt, keine additive Tabelle bei Ablehnung; PASS. Das ist ein isolierter SQLite-Sanitycheck, **kein Flutter-Integrationstest**. `flutter` und `dart` lokal nicht verfügbar.
- **CI:** Commit-Workflow-Abfrage für `d40036b8a8d88270ef99e6d16ab82cfb477a7d28` lieferte keine PR-gefilterten Läufe; Push-Runs werden davon nicht vollständig erfasst. Kein grüner Flutter-CI-Lauf, APK-Artefakt, produktives Signing oder Gerätetest nachgewiesen.
- **Blocker:** Flutter-/Android-Testumgebung und verifizierte Actions-Logs/Artefakte fehlen; Restore-/Crash-Rollback- und Geräteabnahme stehen aus. Keine produktiven Nutzerdaten oder Secrets verwendet.
- **Nächster Schritt:** Flutter-Test auf echtem v4-Datei-Upgrade und Korruptionspfad in CI ausführen; Testfehler beheben, danach reproduzierbare APK samt SHA-256/Signatur und Geräteabnahme belegen. Kein Release-Freigabestatus.


## M4 – Zertifikat-Pinning im Release-Gate (2026-11-23)
- Ausgangs-HEAD `428eb18081c71a19e92b488aff30570e9d15388d`. README, Implementierungsplan, STATUS und Release-Workflow geprüft. Offene Issue-/PR-Suche ergab keine Treffer zum Abfragezeitpunkt.
- **Befund:** Die bisherige Release-CI lehnte zwar Zertifikate mit „Android Debug“ ab, akzeptierte jedoch prinzipiell jedes andere selbstsignierte Zertifikat. Das wäre keine verlässliche Produktionsidentität.
- **Implementierung:** `.github/workflows/release-acceptance.yml` fordert nun den explizit freigegebenen SHA-256-Fingerabdruck `ANDROID_RELEASE_CERT_SHA256` aus GitHub Actions Variables. Der aus `apksigner verify --print-certs` gelesene Signer-#1-Fingerabdruck muss exakt übereinstimmen. Fehlende, fehlerhafte oder abweichende Fingerabdrücke führen fail-closed zum Abbruch. Keine privaten Schlüssel im Repository. Code-Commit `cf838e5cbcf6e1e468e88123603a53f36c5b472f`.
- **Tatsächlich ausgeführt:** Isolierter Python-Sanitycheck mit synthetischem Fingerabdruck: Format, Übereinstimmung und Abweichung geprüft (PASS). **Kein** Android-/Flutter-Test und **keine** Ausführung der GitHub-Actions-YAML nachgewiesen. PR-gefilterte GitHub-Workflow-Abfrage liefert keine vollständige Push-CI-Übersicht.
- **Blocker:** Der freigegebene Release-Zertifikatsfingerabdruck muss in den Repository-Variablen hinterlegt werden; der produktive Signierschlüssel muss geschützt außerhalb des Repos bereitgestellt werden. Release-APK, CI-Logs, Restore-/Crash-Rollback und Geräteabnahme sind nicht nachgewiesen. M1–M4 **NICHT ABGENOMMEN**.
- **Nächster Schritt:** Release-Workflow auf neuem HEAD ausführen und Logs/Artefakte prüfen, tatsächliche Signing-Konfiguration mit geschütztem Keystore einrichten und APK-Zertifikat gegen den Pin prüfen; danach Geräte- und Restore-Abnahme.


## M4 – Flutter-CI-Diagnoseartefakte (2026-11-23, Lauf 20)
- README, Implementierungsplan, STATUS, HEAD und Flutter-/Release-CI gelesen; Ausgangs-HEAD `658e7349fbfc3277da7c7a212cb27e5808d6bda7`. Offene Issue-/PR-Suche ergab keine Treffer in diesem Lauf. Keine vollständige Abnahme M1–M4.
- **Befund:** `.github/workflows/flutter.yml` archivierte Coverage, aber weder Flutter-Analyse-/Testfehlerausgabe noch Android-Build-Logs als Artefakte. Bei CI-Fehlschlägen war die Diagnose außerhalb des flüchtigen Job-Logs erschwert.
- **Implementierung:** Analyse und Tests schreiben über `tee` mit `set -euo pipefail` in `apps/mobile/acceptance-evidence/`; die Logs werden mit Coverage über `if: always()` hochgeladen. Der Debug-APK-Build schreibt pro Versuch ein separates Diagnoseprotokoll und lädt vorhandene Logs auch nach Fehlschlägen hoch. Die bestehenden drei begrenzten Versuche und der fail-closed Endfehler bleiben erhalten; es wird kein APK-Erfolg vorgetäuscht. Code-Commit `7c389d0600a19d680b7fa620c62d4e24ad015283` (GitHub-Schreibbestätigung).
- **Tatsächliche Verifikation:** Der Workflow-Quelltext wurde vor dem Commit gelesen und die GitHub-Änderung bestätigt. Die Commit-Workflow-Abfrage für den Ausgangs-HEAD lieferte keine PR-gefilterten Runs; Push-Läufe werden von diesem Endpunkt nicht vollständig abgedeckt. **Kein ausgeführter Flutter-Test, kein CI-Green, keine APK und kein Android-Gerätetest in diesem Lauf nachgewiesen.** Es wurden keine privaten Daten oder Secrets verarbeitet.
- **Blocker:** Ausführbare GitHub-Actions-Logs/Artefakte bzw. lokale Flutter-/Android-Toolchain, geschütztes Release-Signing, Restore-/Crash-Rollback- und Geräteabnahme fehlen. M1–M4 nicht vollständig abgenommen.
- **Nächster Schritt:** Neuen Flutter-Actions-Lauf auf dem aktualisierten HEAD auswerten, `life-ai-planner-flutter-test-evidence` und `life-ai-planner-android-build-diagnostics` prüfen, konkrete Test-/Buildfehler korrigieren und APK samt Prüfsumme/Signatur und Gerätetest nachweisen.


## M4 – Mehrfachsignatur-Fail-Closed (2026-11-23)
- Ausgangs-HEAD `5e0369b6967990801185070ed799b7118ecd5abd`; README, Implementierungsplan, STATUS und Release-Workflow gelesen; offene Issues/PRs: keine Treffer in GitHub-Suche.
- **Befund:** Release-CI verglich bisher nur den SHA-256-Fingerabdruck von Signer #1. Ein APK mit zusätzlichen, nicht freigegebenen Signern konnte die Identitätsprüfung bestehen.
- **Korrektur:** `.github/workflows/release-acceptance.yml` verlangt exakt eine Zertifikats-Fingerabdruckzeile von `apksigner`; 0 oder mehrere Signer führen zum Fehler. Code-Commit `60c231c07d884390f336f53b8b04ee1497371fae`.
- **Tatsächlich ausgeführt:** Isolierter Bash-Sanitycheck der gleichen `grep -Ec`-Zählregel mit synthetischen 0/1/2-Signer-Ausgaben: 0 abgelehnt, 1 akzeptiert, 2 abgelehnt. Kein echter APK-Test und keine erfolgreiche CI-Ausführung behauptet.
- **CI-Limit:** GitHub-Connector bietet keine vollständige Push-Workflow-Laufliste. Signierter Release-Build, Restore-/Rollback-Prüfung und Android-Geräteabnahme nicht nachgewiesen.
- **Nächster Schritt:** Release-Actions-Lauf samt Signatur-Artefakt auf neuem HEAD prüfen; Produktions-Keystore und Zertifikatspin sicher konfigurieren; Android-Geräteabnahme mit synthetischen Daten durchführen. M1–M4 **NICHT ABGENOMMEN**.


## M4 – Release-CI-Diagnose und sicherer Variablentransport (2026-11-23, Lauf 20)
- Ausgangs-HEAD `457909fa6c32f7797bb32ffa8847289212fa4616`; README, Implementierungsplan, STATUS, Flutter- und Release-CI gelesen. GitHub-Suche `repo:WeA200675/life-ai-planner is:open` ergab keine Treffer. Vollständige Abnahme fehlt.
- **Änderung:** Release-Actions-Workflow bewahrt jetzt `flutter pub get`-, Analyse- und Release-APK-Build-Ausgaben als Diagnoseartefakte auch bei Fehlschlägen auf. Bash-`pipefail` verhindert, dass `tee` fehlgeschlagene Prüfungen grün erscheinen lässt. Die freigegebene Zertifikats-SHA-256-Variable wird als Umgebungsvariable an das Signatur-Prüfskript übergeben statt direkt in Bash-Quelltext interpoliert. Code-Commit `bd08639c1674ae61a4a9bc5677cf196b40edef2b`.
- **Tatsächlich geprüft:** Geänderte Workflow-Datei erneut über GitHub gelesen; Textprüfungen für alle drei Logpfade, `pipefail`, Environment-Pin und Wegfall der direkten Inline-Interpolation bestanden. **Keine Workflow-Ausführung, keine Flutter-Tests, kein signierter APK-Build und kein Android-Gerätetest nachgewiesen.** Die lokale Umgebung besitzt keine Flutter-/Dart-CLI. Die GitHub-Commit-Workflow-Abfrage ist auf PR-Runs begrenzt und beweist keine Push-CI.
- **Blocker:** Release-Signing mit geschützt hinterlegtem Keystore und korrekt konfiguriertem `ANDROID_RELEASE_CERT_SHA256`, echte CI-/APK-Artefakte, Crash-/Restore-/Rollback- und Geräteabnahme. M1–M4 **NICHT ABGENOMMEN**.
- **Nächster Schritt:** Release-Actions-Run und `life-ai-planner-release-build-diagnostics` auswerten, Fehler aus Logs korrigieren, Signatur-Pin/Keystore extern konfigurieren und Geräteabnahme dokumentieren.


## M4 – SQLite structural preflight (2026-11-23)
- Ausgangs-HEAD: `f1808e5f2eaa63576d50a80f486ae340e168450a`. README, Implementierungsplan, STATUS und Release-Workflow gelesen; GitHub-Suche nach offenen Issues/PRs: 0 Treffer.
- **Befund:** `foreign_key_check` entdeckt verwaiste Beziehungen, aber keine allgemeinen SQLite-Strukturschäden. Die Android-Datenbank konnte deshalb additive Schemaänderungen versuchen, bevor ein struktureller Defekt erkannt wurde.
- **Implementierung:** `apps/mobile/lib/sqlite_integrity.dart` prüft nun `PRAGMA quick_check` strikt auf genau eine `ok`-Zeile, ohne Fehlerdetails oder Nutzerdaten zu protokollieren. `LocalTasks.onOpen` führt den strukturellen Check vor und nach additiver DDL aus. Bestehender Fremdschlüssel-Check bleibt erhalten. Commits: `ee7b73e715f6f9272cc371e26687949be3f72b7b`, `696bf45ecbbc2bd5804731353e90114d362353c6`.
- **Regression:** `apps/mobile/test/sqlite_quick_check_test.dart` enthält Tests für gültige, leere, beschädigte und mehrdeutige Resultate; Commit `037695db24def0548b64843a89a5ad6091d2566c`.
- **Tatsächlich geprüft:** GitHub-Schreibbestätigungen; isolierter Python-sqlite3-Sanitycheck `PRAGMA quick_check` auf In-Memory-DB gab `ok` zurück. **Keine Dart-/Flutter-Testausführung:** Flutter und Dart sind in dieser Laufzeit nicht installiert. Kein grüner CI-Lauf oder Android-Gerätetest für neuen HEAD nachgewiesen. Die Connector-Workflow-Abfrage deckt Push-Runs nicht vollständig ab.
- **Sicherheitsgrenze:** `quick_check` ist kein Ersatz für `integrity_check`, Restore-Proben oder transaktionale Crash-Recovery. Bei Fehlern wird fail-closed abgebrochen, ohne Daten zu löschen.
- **Blocker:** CI- und Geräteabnahme, Release-Signing/Keystore, APK-Nachweis, Restore-/Rollback-Proben. M1–M4 **NICHT ABGENOMMEN**.
- **Nächster Schritt:** Flutter-Regression in GitHub Actions tatsächlich ausführen, ggf. Dart-Typ-/Buildfehler korrigieren, danach strukturelle Korruptions- und Restore-/Rollback-Integrationstests auf Datei-SQLite und Android-Gerät nachweisen.


## M4 – Integritätsprüfung vor SQLite-Version-Upgrades (2026-11-23, 05:20 Europe/Berlin)
- Ausgangs-HEAD `3dff88065150c6b35eac8593de2efdeb7ba90144`; README, Implementierungsplan, STATUS, offene Issues/PRs und GitHub-Actions-Push-Läufe gelesen. Offene PR #1 (M3) vorhanden, keine separaten offenen Issues.
- **Befund:** Der bestehende strukturelle und Fremdschlüssel-Preflight lief nur in `onOpen`, während sqflite `onUpgrade` davor aufruft. Beschädigte ältere Datenbanken konnten dadurch vor der Prüfung Schemaänderungen erhalten.
- **Änderung:** `LocalTasks.onUpgrade` führt `requireValidSqliteStructure` und `requireValidForeignKeys` vor jeglicher Migration/DDL aus. Fail-closed ohne automatische Datenlöschung. Code-Commit `6e0c83b8933245b0ada8c06d818be4b96b137523`.
- **Regression:** Neuer synthetischer sqflite-FFI-Test `sqlite_upgrade_preflight_test.dart` erzeugt eine verwaiste Legacy-Beziehung und verlangt Ablehnung vor dem Anlegen einer weiteren Tabelle. Test-Commits `667e483f9934e091dc80efed178d89129c5bb9f2`, `a6e2e766ce486354973b79316cae6bfbd93cc43b`.
- **Tatsächliche Verifikation:** GitHub hat die Code-/Test-Commits bestätigt. Scheduler-Actions-Run [45107603734](https://github.com/WeA200675/life-ai-planner/actions/runs/45107603734) für den vorherigen HEAD `3dff880` war erfolgreich. Flutter-, Release- und Scheduler-Push-Runs für `6e0c83b` wurden als `queued` beobachtet; sie belegen **keinen** Erfolg für den neuen Code. Der neue Flutter-Test wurde hier nicht lokal ausgeführt; Teststatus offen.
- **Blocker:** Flutter-CI für den Test-HEAD auswerten, ggf. Regression korrigieren; APK-/Signaturprüfung, Restore-/Crash-Rollback und Geräteabnahme fehlen. Release R1 und M1–M4 **nicht vollständig abgenommen**.
- **Nächster Schritt:** Aktuellen Flutter-Actions-Lauf samt Testprotokoll und APK-Artefakt prüfen; reale Dateidatenbank-Upgrades mit absichtlich beschädigten synthetischen Daten testen, danach Restore und Geräteabnahme.


## M4 – Release-Artefakte strikt an Signaturfreigabe binden (2026-11-23)
- Ausgangs-HEAD: `e61f7e08454f332b980b17918eb891cbcd7a1f87`; README, Implementierungsplan, STATUS und Release-Workflow gelesen; GitHub-Suche `repo:WeA200675/life-ai-planner is:open` ergab keine Treffer (Suchergebnis kann zeitversetzt sein).
- **Befund:** `release-acceptance.yml` lud mit `if: always()` auch bei fehlgeschlagener Signaturprüfung eine APK hoch. Dadurch konnte ein nicht freigegebener Release-Mode-Kandidat als Download-Artefakt erscheinen.
- **Implementiert:** Signaturdiagnostik bleibt mit `if: always()` verfügbar; die APK samt SHA-256 wird nur noch mit `if: success()` nach sämtlichen Backend-, Flutter-, Build- und Signatur-Gates veröffentlicht. Fehlende APK/Prüfsumme lassen den Artefakt-Schritt fehlschlagen (`if-no-files-found: error`). Commit `dedf5eff3ee3dc9d977980234407f9f9e30f3aac`.
- **Nachweis:** GitHub-Update bestätigt und exakter Workflow-Textvergleich für die ersetzte Upload-Sektion durchgeführt. **Keine GitHub-Actions-Ausführung oder APK-/Geräteprüfung in diesem Lauf nachgewiesen.** Ein Workflow-Textvergleich ist kein CI-Test.
- **Blocker:** CI-Ausführung und Logs/Artefakte des neuen HEAD, Release-Keystore und Zertifikatspin, SQLite-Restore-/Crash-Rollback sowie Android-Geräteabnahme. M1–M4 **NICHT ABGENOMMEN**.
- **Nächster Schritt:** GitHub-Actions-Release-Lauf für den neuen HEAD auswerten; fehlerhafte Checks reparieren, Signierung sicher konfigurieren und die Geräteabnahme mit synthetischen Daten durchführen.


## M4 – Release-CI nicht durch reine Status-Commits abbrechen (2026-11-23, 06:24 Europe/Berlin)
- Ausgangs-HEAD `4527ab913a3c5f04619636bbfd01f86610a5ffd3`; README, Implementierungsplan, STATUS, Release-/Flutter-Workflow, offene PRs/Issues und GitHub-Actions-Läufe geprüft. Offene PR: #1 (M3), keine separaten offenen Issues. M1–M4 weiterhin nicht abgenommen.
- **Befund:** `release-acceptance.yml` löste auch bei Änderungen ausschließlich an `docs/STATUS.md` aus. Durch `concurrency.cancel-in-progress: true` konnten rein dokumentarische Folgecommits laufende teure Release-Abnahmen abbrechen. Mehrere vorangegangene Release-Läufe waren tatsächlich `cancelled` (u. a. 45113580795, 45111307048).
- **Korrektur:** `docs/STATUS.md` aus den Push-Pfadfiltern der Release-Abnahme entfernt. Änderungen an App, Packages, Services, Tests, Release-Workflow oder Release-Abnahmedokumenten starten weiterhin die Release-CI. Code-Commit `5962d284cdfd04aab08509c4aff09f829c21ec51`.
- **Tatsächlich geprüft:** GitHub-Commit bestätigt; neuer HEAD nach Codeänderung `5962d284cdfd04aab08509c4aff09f829c21ec51`. Scheduler-Run 45113590481 für vorherigen HEAD `4527ab9` war `success`. Release-Run [45113590501](https://github.com/WeA200675/life-ai-planner/actions/runs/45113590501) für denselben vorherigen HEAD war bei der Prüfung noch `in_progress`: Backend-Job `success`, Flutter-Tests im Android-Job noch laufend. **Kein vollständiger Release-Erfolg und kein erfolgreicher Geräte-/Signaturtest behauptet.** Die Workflow-Pfadfilteränderung selbst ist noch nicht durch einen abgeschlossenen neuen Release-Lauf validiert.
- **Blocker:** vollständige Flutter-/Release-CI-Auswertung, freigegebene Produktionssignatur/Keystore, APK-Artefakt und Geräteabnahme sowie Restore-/Crash-Rollback-Nachweise. Repository öffentlich: keine Secrets oder personenbezogenen Daten.
- **Nächster Schritt:** Run 45113590501 und die nach dem Code-Commit gestartete Release-Abnahme bis zum Abschluss auswerten, Fehler anhand der Artefakte beheben; anschließend Signatur, APK und Geräte-Restore-Abnahme nachweisen.

## Release-Workflow-Policy-Regression – 2026-11-23
- Ausgangs-HEAD: `8adb4e01c8fe426e0929d0fecd40e9ac4c78563e`; offene Issues/PRs: keine laut GitHub-Issue-Suche.
- Neu: `tests/test_release_workflow_policy.py` prüft mit unittest die Release-Publikationssperre, APK-Hash/Integrität, Fail-Closed-Signatur, Abhängigkeit der Jobs und Diagnostik bei Fehlern. Code-Commit: `cf46c01944c98c2cb6cabc81fd4da99a2c51c870`.
- Verifikation: GitHub-Commit bestätigt; lokaler vollständiger Klon scheiterte an `Could not resolve host: github.com`. **Keine erfolgreiche Ausführung der neuen Tests oder des Release-Workflows nachgewiesen.**
- CI-Status: Aus GitHub-Connector derzeit kein vollständiger Push-Workflow-Run-Index verfügbar; kein grüner CI-Status behauptet.
- Blocker: Flutter/Android-Release-Workflow und echte Signierung noch nicht verifiziert; Android-Geräteabnahme, Restore-Rollback und quantitative M1–M4-Kriterien offen.
- Nächster Schritt: GitHub Actions für aktuellen Code-HEAD auswerten, Fehler beheben; Produktionskeystore sicher konfigurieren und Geräteabnahme durchführen. M1–M4 **nicht abgenommen**.


## M4 – installierbarer Debug-APK-Fallback bei blockierter Produktionssignatur (2026-11-23)
- Ausgangs-HEAD: `533dc1cc877a30fe35fcd8af64fd4d5d71c4f1e9`; README, Implementierungsplan, Release-Workflow und Release-Policy-Tests geprüft; GitHub-Suche nach offenen Issues/PRs ohne Treffer.
- Tatsächliche CI-Evidenz: älterer Release-Actions-Run [45113590501](https://github.com/WeA200675/life-ai-planner/actions/runs/45113590501) hat `backend-tests: success`, aber `android-release: cancelled` während `Flutter tests`; somit **kein** Android-/Release-Erfolg. Kein vollständiger Push-Run-Index für den aktuellen HEAD über den Connector verfügbar.
- Priorität P0: Ohne freigegebenes Produktionszertifikat war bisher auch kein installierbares APK-Artefakt aus dem Release-Workflow verfügbar. Neuer separater Debug-Build nach erfolgreichen Flutter-Tests mit `flutter build apk --debug`, Dateigrößen- und ZIP-Integritätsprüfung, SHA-256-Digest sowie Artefakt `life-ai-planner-debug-test-only`. Debug-Build-Protokoll wird auch bei Fehlern hochgeladen. Debug-APK **niemals** als produktiv signierte Release-APK ausgeben; unveränderte Signatur-/Zertifikatpin-Sperre für Release.
- Code-Commit: `4506809bbd33278216165aeaafafd21fd1756b54`; Regressionstest-Commit: `69b02324be272db575a981ac39f3ecead3d792d8`. Neuer Policy-Test kontrolliert Debug-Build, Hash, Reihenfolge, isoliertes Artefakt und Release-Trennung.
- Verifikation: GitHub-Commits bestätigt; Workflow- und Testquelltext vor Commit statisch auf Anker/Reihenfolge geprüft. **Python-/Flutter-Tests, neuer Actions-Lauf, Debug-APK und SHA-256 sind noch nicht ausgeführt/nachgewiesen**. Es gibt keine vorgetäuschte APK-Freigabe.
- Blocker: Actions-Lauf des neuen Code-HEAD und Test-/Build-Artefakte prüfen; echte Produktionssignierung, SQLite-Restore/Crash-Rollback und physische Android-Geräteabnahme fehlen; quantitative M1–M4-Ziele noch nicht nachgewiesen.
- Nächste automatisch gewählte Priorität: neuen Actions-Run auswerten und bei Fehlern korrigieren; anschließend reale SQLite-Datei-Restore-/Crash-Rollback-Regression und Installation des Debug-APK auf Android-Gerät.


## P0 – Dateibasierter SQLite-Migrations-Preflight (2026-11-23, 08:45 Europe/Berlin)
- Ausgangs-HEAD `c87a4d2b220731565723b666e28db0930b520aa4`; HEAD vor Statusschreibvorgang erneut geprüft: `3e77495d4ab2142a62e84843d13385cb78c15b02`. README, IMPLEMENTATION_PLAN, STATUS, Release-Workflow und Policy-Tests gelesen. Offene PR: [#1](https://github.com/WeA200675/life-ai-planner/pull/1) (M3); keine separaten offenen Issues aus kombinierter Suche. PR bleibt unberührt.
- P0-Befund: `sqlite_upgrade_preflight_test.dart` prüfte bisher nur eine In-Memory-Sequenz, nicht den tatsächlichen `onUpgrade`-Callback mit persistierter SQLite-Datei. Ein erfolgreiches Preflight ohne Migration/Versionierung beweist keinen sicheren Datei-Upgrade.
- Implementiert: `apps/mobile/test/sqlite_file_upgrade_guard_test.dart` mit zwei synthetischen, dateibasierten sqflite-FFI-Regressionen: (1) gültige v1-Datei migriert nach v2 und erhält ID, Titel, Status und Integrität; (2) Legacy-Fremdschlüsselverletzung verhindert `onUpgrade`, `user_version` und Schema bleiben unverändert, Datensatz bleibt erhalten. Testdatei-Commit `3e77495d4ab2142a62e84843d13385cb78c15b02`.
- Tatsächliche Ausführung: isolierter Python-`sqlite3`-Sanitycheck mit synthetischer verwaister Beziehung, `quick_check`, `foreign_key_check` und unverändertem Schema: **PASS**. Dies ist **kein** Flutter-Test und kein Beleg für sqflite-FFI oder Android. Flutter/Dart nicht im ausführenden Container installiert; `git ls-remote` scheiterte an DNS (`Could not resolve host: github.com`). GitHub-Commit wurde bestätigt. Neuer Flutter-Test **nicht ausgeführt**, CI für Code-HEAD noch nicht verifiziert.
- Verifizierte ältere CI: [Release-Run 45113590501](https://github.com/WeA200675/life-ai-planner/actions/runs/45113590501) für HEAD `4527ab9`: Backend `success`, Android `cancelled` während Flutter-Tests; Artefakte nur Flutter-/Backend-Evidenz, keine APK. Kein aktueller Push-Run-Index über verfügbaren GitHub-Connector.
- Nächste dynamische P0-Priorität: Flutter-CI für `3e77495d` auswerten, bei Testfehlern korrigieren; Debug-APK mit SHA256 und SQLite-Restore/Crash-Rollback auf realer Datei nachweisen. Produktionssignierung, physischer Gerätetest und quantitative Qualitätsziele weiterhin blockiert. M1–M4 **nicht abgenommen**.


## P0 – Dateibasierter Crash-/Transaktions-Rollback (2026-11-23, 09:45 Europe/Berlin)
- Ausgangs-HEAD: `2eed5a21b300157c948b36977191f689029cf200`; README, Implementierungsplan, Status, Release-Workflow, Flutter-Workflow und offene GitHub-Issues/PR-Suche geprüft (Suche ohne Treffer; vorher dokumentierte PR #1 nicht als geschlossen bestätigt).
- Neu: `apps/mobile/test/sqlite_file_upgrade_guard_test.dart` simuliert eine unterbrochene **explizite** sqflite-Transaktion nach Schema-DDL und Datensatzänderung, schließt die Datenbank und prüft nach erneutem Öffnen auf Datenträger: Schema v1, Originaltitel, unveränderte ID, `quick_check` und `foreign_key_check`. Code-Commit `db0dc08db3771d59f68e060023748222f30b5678`.
- Verifikation: Ein zunächst ausgeführter Python-`sqlite3`-Sanitycheck **schlug fehl**, weil Python ohne explizites BEGIN das ALTER TABLE außerhalb einer Transaktion ausführte. Danach wurde der Sanitycheck mit `BEGIN IMMEDIATE` korrigiert und **PASS** für DDL+DML-Rollback auf echter SQLite-Datei erzielt. Der neue Dart/sqflite-FFI-Test wurde **nicht ausgeführt** (Flutter/Dart-Toolchain hier nicht verfügbar). Python-Erfolg ist ausdrücklich kein Dart-/Android-Testnachweis.
- CI-Evidenz: älterer Actions-Run [45113590501](https://github.com/WeA200675/life-ai-planner/actions/runs/45113590501): Backend `success`, Android `cancelled` bei Flutter-Tests; **kein** aktueller grüner CI-Run, keine APK/Hash-Artefakte bestätigt.
- Offene P0-Blocker: Flutter-FFI-Test für neuen Code-HEAD tatsächlich ausführen und Fehler beheben; vollständige aktuelle CI/Debug-APK samt SHA256 nachweisen; Restore aus verifiziertem Backup, produktive Signatur, physischer Android-Gerätetest und quantitative M1–M4-Abnahme fehlen.
- Nächste autonome Priorität: aktuellen Flutter-CI-Lauf und Debug-APK-Artefakte prüfen, danach reale Backup-/Restore- und Crash-Wiederanlauf-Tests mit synthetischen Daten implementieren. M1–M4 **nicht abgenommen**.


## P0 – laufende Release-Abnahmen nicht mehr bei Folge-Push abbrechen (2026-11-23, 10:37 Europe/Berlin)
- Ausgangs-HEAD: `9adcbd4157a63ec9a023ceea91a76cd60804e832`; README, Implementierungsplan, STATUS, Release-Workflow, vorhandene Regressionstests und offene Issue/PR-Suche gelesen. Die kombinierte Suche lieferte keine Treffer, widerspricht aber älterer PR-#1-Dokumentation; PR-Zustand nicht unabhängig bestätigt.
- Befund: `concurrency.cancel-in-progress: true` im Release-Workflow konnte laufende, teure Flutter-/Android-Abnahmen bei jedem nachfolgenden Push abbrechen und damit Debug-APK-/Testnachweise verhindern. Ein älterer Run [45113590501](https://github.com/WeA200675/life-ai-planner/actions/runs/45113590501) hatte Backend `success`, Android `cancelled`.
- Implementiert: `cancel-in-progress: false` mit Begründung, damit SHA-spezifische CI-Läufe ihre Nachweise bis zum Ende sammeln. Code-Commit `a689b3a412248a3c777ae146559d35d87da83f0c`. Neuer Regressionstest in `tests/test_release_workflow_policy.py` gegen erneute Aktivierung der Abbruchregel; Test-Commit `bd5571f42196dc2041e7831894b1ccbde9c78781`, Regex-Korrektur `5eac14928f2328b6359017d91bdee199ef98733c`.
- Tatsächlich geprüft: GitHub-Commits bestätigt; drei Regex-Assertions mit repräsentativem YAML isoliert in Python ausgeführt: PASS. **Nicht** als Ausführung der Repository-Testdatei ausgegeben. Der Connector liefert für Push-HEAD keinen vollständigen Workflow-Run-Index; kein grüner aktueller CI-Lauf, keine APK und keine Signatur behauptet. Mehrere parallele CI-Runs können zusätzliche Minuten verbrauchen, aber nicht gegenseitig Nachweise zerstören.
- Blocker: aktuelle GitHub-Actions-Push-Runs samt Flutter-/Debug-APK-Artefakten tatsächlich auswerten; Flutter-sqflite-Dateitests, verifizierter Restore, produktive Signatur und physischer Gerätetest bleiben offen.
- Nächste autonome Priorität: echten CI-Lauf samt Artefakten und Fehlerlogs verifizieren und reparieren; danach Restore-/Wiederanlauf-Nachweise mit synthetischen Daten. M1–M4 **NICHT abgenommen**.


## P0 – Cold-backup/Restore und beschädigte Sicherung (2026-11-23, 11:45 Europe/Berlin)
- Ausgangs-HEAD `0dc0fdf40b32d2011e40d58bc14d345390187cfb`; README, Implementierungsplan, STATUS, Release-Workflow und offene Issue-/PR-Suche geprüft (Suche ohne Treffer, ältere PR #1 nicht unabhängig als geschlossen verifiziert).
- Neue Datei `apps/mobile/test/sqlite_file_restore_guard_test.dart` (Code-Commit `123363e011e9b359bc885ed783b1a6931f0fa82b`): synthetische dateibasierte sqflite-FFI-Cold-Backup-Wiederherstellung nach Daten- und Schemaänderung sowie Ablehnung einer beschädigten Backup-Datei vor Änderung der Live-Datenbank. Integritäts- und Fremdschlüsselprüfungen nach Restore. Backup wird nur bei geschlossener Datenbank kopiert; dies ist **kein** WAL-/Online-Backup und **keine** produktive Restore-API.
- Ausführung: isolierter Python-`sqlite3`-Sanitycheck mit echter Datei, Kopie, Änderung, Restore, `quick_check` und beschädigter Sicherung: **PASS**. Flutter/Dart lokal nicht vorhanden; neue Dart-Tests **nicht ausgeführt**. Keine APK/Hash/Android-Installation nachgewiesen.
- CI-Abfrage für vorherigen HEAD `0dc0fdf4`: Combined-Status leer; PR-Workflow-Run-Abfrage leer (diese Schnittstelle deckt Push-Runs nicht zuverlässig ab). **Kein grüner CI-Nachweis**.
- Blocker: echte Flutter-CI-Ausführung, verifizierter Backup-/Restore-Produktpfad inklusive WAL und atomarer Wiederherstellung, Debug-APK samt SHA256, produktive Signierung, physischer Android-Test und quantitative M1–M4-Abnahme.
- Nächste autonome P0-Priorität: Flutter-Tests im GitHub-Actions-Runner tatsächlich ausführen und korrigieren, anschließend sichere Backup-/Restore-Funktion mit WAL-Snapshot/atomarem Austausch implementieren und integrieren. M1–M4 **NICHT abgenommen**.


## P0 – WAL-aware SQLite snapshot and guarded cold restore (2026-11-23, 12:40 Europe/Berlin)
- Ausgangs-HEAD: `96b81acf1ff265e2c6aaf3ce546fdb660ee006c3`. README, Implementierungsplan, Status und Release-Workflow geprüft; GitHub-Issue-Suche ohne Treffer (früher dokumentierte PR #1 nicht unabhängig als geschlossen bestätigt).
- Implementiert: `packages/storage/sqlite_backup.py` erstellt per SQLite-Online-Backup-API einen konsistenten Snapshot einschließlich committeter WAL-Daten, prüft `quick_check` und `foreign_key_check`, veröffentlicht per `os.replace` auf demselben Dateisystem. `restore_cold` prüft das Backup vor Änderung, verweigert vorhandene WAL/SHM/Journal-Sidecars und ersetzt erst nach validiertem Staging atomar. Code-Commit `5c80161f6124e2d27e50beae7a62633cf2c34892`.
- Regressionen: `tests/test_sqlite_backup.py` mit WAL-Snapshot/Wiederherstellung, beschädigtem Backup ohne Änderung der Live-Datenbank und Sidecar-Sperre. Test-Commit `c9a65700449eed7c960b284929d3cfc2ae061a95`.
- Ausführung: Drei äquivalente lokale Python-3.13-Tests mit echten temporären SQLite-Dateien **PASS** nach Korrektur eines durch nicht geschlossene SQLite-Verbindungen verursachten Test-Locks. Die finalen GitHub-Dateien selbst wurden noch nicht als vollständiger Repository-CI-Lauf ausgeführt. Älterer Release-Run 45113590501: Backend success, Android cancelled; keine aktuelle grüne APK nachgewiesen.
- Grenzen: Python-Utility ist noch nicht in den Flutter-Android-Lebenszyklus integriert; `restore_cold` setzt externe Exklusivsperre, geschlossene Verbindungen und separate Recovery-Kopie voraus. Keine Online-Restore-Freigabe, keine Geräteabnahme, keine produktive Signatur. M1–M4 **NICHT ABGENOMMEN**.
- Nächste autonome Priorität: vollständige CI der neuen HEAD-Version prüfen, Flutter-Backup/Restore-Lebenszyklus sicher integrieren, Debug-APK mit SHA256 verifizieren und Android-Gerätetest durchführen.


## P0 – SQLite-Recovery-Snapshot gegen Überschreiben geschützt (2026-11-23, 13:41 Europe/Berlin)
- Ausgangs-HEAD: `28783671f3de42499bac6164b89f12a16908a5b5`. README, Implementierungsplan, STATUS, GitHub Actions, Release-/Flutter-Workflow und offene PRs geprüft. Offene PR [#1](https://github.com/WeA200675/life-ai-planner/pull/1) bleibt unangetastet.
- CI-Ausgangslage: Scheduler-Run [45167557562](https://github.com/WeA200675/life-ai-planner/actions/runs/45167557562) für Ausgangs-HEAD **success**. Release-Run [45167534953](https://github.com/WeA200675/life-ai-planner/actions/runs/45167534953) für vorherigen Code-HEAD `c9a65700`: Backend-Job **success**, Android-Job zum Prüfzeitpunkt **in_progress** bei Flutter-Tests. Kein Android-Build-/APK-Nachweis.
- P0-Risiko: `snapshot()` in `packages/storage/sqlite_backup.py` nutzte `os.replace` und konnte ein bereits existierendes, möglicherweise einziges älteres Recovery-Backup still überschreiben. Geändert auf fail-closed: vorhandenes Ziel wird abgewiesen, Veröffentlichung per atomarem `os.link` im selben Verzeichnis, temporäre Datei im `finally` entfernt. Kein Eingriff in `restore_cold` und kein Android-Produktions-Restore behauptet.
- Code-Commit: [18609d28](https://github.com/WeA200675/life-ai-planner/commit/18609d2877e33faabd2bdf3af42601de762949c2). Regressionstest-Commit: [9eb3e7cb](https://github.com/WeA200675/life-ai-planner/commit/9eb3e7cbd4463354fd3bb4230d96321b74683b87) mit zwei neuen synthetischen Tests für existierende SQLite- und Nicht-SQLite-Sicherungsdateien.
- Verifikation: Ein **isolierter** lokaler Python-/SQLite-Hardlink-Sanitycheck für atomare Veröffentlichung und Überschreibverweigerung: PASS. Die tatsächliche Repository-Testdatei wurde hier nicht ausgeführt. CI für `9eb3e7cb`: Scheduler [45176810381](https://github.com/WeA200675/life-ai-planner/actions/runs/45176810381) queued, Release [45176810593](https://github.com/WeA200675/life-ai-planner/actions/runs/45176810593) pending zum Prüfzeitpunkt. Keine grüne neue CI behauptet.
- Einschränkung: `os.link` erfordert Hardlink-Unterstützung des Dateisystems; bei fehlender Unterstützung schlägt das Backup sicher fehl statt ein bestehendes Backup zu überschreiben. Der Aufrufer muss eindeutige Snapshot-Namen vergeben. Keine Signierung, Geräteabnahme oder quantitative M1–M4-Abnahme nachgewiesen.
- Nächste autonome Priorität: Flutter-Test-/Release-CI-Lauf bis zum Ergebnis prüfen, bei Fehlern Logs auswerten und korrigieren; danach Debug-APK samt SHA256 nachweisen und sichere Android-Datenbank-Lifecycle-Integration priorisieren. M1–M4 **nicht abgenommen**.


## P0 – Dauerhafte Veröffentlichung von SQLite-Recovery-Snapshots (2026-11-23, 14:43 Europe/Berlin)
- Ausgangs-HEAD: `072b5c992e0a6736e4f6a1e6b9e3a422afe3ddc6`; README, Implementierungsplan, Status, GitHub-Actions-Runs, offene PR #1 und Issues geprüft. Scheduler-CI für Ausgangs-HEAD: [45176854449](https://github.com/WeA200675/life-ai-planner/actions/runs/45176854449) **success**. Release-CI [45167534953](https://github.com/WeA200675/life-ai-planner/actions/runs/45167534953) war bei Prüfung noch im Flutter-Testschritt; ein neuerer Release-Run [45176810593](https://github.com/WeA200675/life-ai-planner/actions/runs/45176810593) wurde **cancelled**. Keine APK/Signatur oder Android-Geräteabnahme bestätigt.
- Sicherheitslücke: `snapshot()` veröffentlichte die SQLite-Datei per atomarem Hardlink, ohne Dateiinhalt und Verzeichniseintrag ausdrücklich auf dauerhaften Speicher zu synchronisieren. Bei plötzlichem Stromverlust war die Persistenz eines als erfolgreich gemeldeten Recovery-Punktes nicht garantiert.
- Änderung: `packages/storage/sqlite_backup.py` synchronisiert die geprüfte temporäre Datenbank per `fsync` vor der atomaren Veröffentlichung und danach das Zielverzeichnis. Ein Fehler beim zweiten Sync lässt die bereits veröffentlichte Sicherung bewusst bestehen und wird an den Aufrufer weitergegeben (Durabilität nicht bestätigt); keine stille Erfolgsmeldung.
- Regression: `tests/test_sqlite_backup.py` ergänzt einen synthetischen Test für beide Sync-Aufrufe und lesbare Sicherungsdaten. Code-Commits `77d6f36a4cab4658a64d9e39c5cdcea7c079d726` und `a5cb424a9fc9ce0f9fa6a76adb07c5c039837528`.
- **Teststatus:** Die neuen Tests wurden in diesem Lauf nicht lokal ausgeführt. Scheduler-Run [45186886456](https://github.com/WeA200675/life-ai-planner/actions/runs/45186886456) für Test-HEAD war beim Schreiben **queued**; Release-Run [45186886281](https://github.com/WeA200675/life-ai-planner/actions/runs/45186886281) **pending**. Kein grüner CI-Nachweis für die neuen Commits. M1–M4 **NICHT ABGENOMMEN**.
- **Nächste autonome Priorität:** Aktuelle CI bis zum Abschluss prüfen und bei Flutter-Tests/Android-Build konkret reparieren; sichere Android-Backup/Restore-Integration mit exklusivem DB-Zugriff und Recovery-Rollback; Debug-APK samt SHA256 und physische Geräteprüfung. Release-Signierung bleibt fail-closed.


## P0 – Durable Cold-Restore-Veröffentlichung (2026-11-23, 15:38 Europe/Berlin)
- Ausgangs-HEAD `31aa8462d586579603c10a8b0732a93d037293af`; README, Implementierungsplan, STATUS, Release-CI und Code geprüft. Offene Gesamt-Abnahme M1–M4 weiterhin NO-GO.
- P0-Fix: `restore_cold()` synchronisiert nun das vollständig geprüfte, vorbereitete SQLite-Abbild per `fsync` vor `os.replace` und anschließend das Zielverzeichnis per `fsync`. Fehler werden nicht als erfolgreicher Restore gemeldet. Commit `e9188afa22df43f860e81bb5a4c854f47255f968`.
- Neuer synthetischer Regressionstest prüft zwei Synchronisationsaufrufe und die wiederhergestellten Datensätze. Commit `2dce21395953c9a1e44c753906238f7e8b61ba58`.
- Verifikation: Quellcode geprüft, aber neuer Regressionstest lokal **nicht ausgeführt**; aktueller Commit-CI-Nachweis steht aus. Release-Run [45186886281](https://github.com/WeA200675/life-ai-planner/actions/runs/45186886281) für älteren HEAD: Backend **success**, Android beim letzten Abruf noch **in_progress** im Schritt Flutter tests. Keine APK/SHA256 oder Geräteabnahme bestätigt.
- Einschränkungen: `restore_cold` verlangt weiterhin extern garantierten exklusiven Datenbankzugriff und eine separate Recovery-Kopie; bei `fsync`-Fehler nach `os.replace` ist die Veröffentlichung erfolgt, aber ihre Durabilität unbestätigt. Kein automatischer Android-Lifecycle oder produktiver Rollback-Koordinator behauptet.
- Priorisierter Backlog: **P0 Test**: neuer Python-CI-Lauf und Android-Flutter-Tests/APK; **P0 offen**: Android-Lifecycle-Integration, exklusiver Restore und Rollback; **P0 blockiert**: physisches Gerät und Release-Signatur; **P1 offen**: E2E SQLite/Scheduler/API/Flutter; **P2 offen**: qualitative M4-Abnahme. Nächster Schritt: konkrete CI-Fehler aus Logs beheben, anschließend APK+SHA256 nachweisen.


## P0 – Symlink-Schutz der SQLite-Recovery-Pfade (2026-11-23, 16:43 Europe/Berlin)
- Vor Schreiben erneut geprüfter HEAD: `84a2e3ddfb26f4f3dd63529b26c5d59700231af3`; vor STATUS-Schreiben HEAD `01eb009dbb75d8b3a86ad760472e90a08a800bf1`. README, Implementierungsplan, STATUS und offene PRs geprüft; PR #1 bleibt offen.
- Sicherheitsfix `a64fea62a9b2eeb91adc6c587d5503c1805c2de9`: `snapshot()` und `restore_cold()` weisen symbolische Links als Quelle oder Ziel vor Dateioperationen zurück. Dies reduziert versehentliche Pfadumleitungen; ein externer exklusiver Lock und Schutz gegen TOCTOU-Rennen bleiben zwingend.
- Regressionen `01eb009dbb75d8b3a86ad760472e90a08a800bf1`: zwei synthetische Tests für Backup-Ziel-Symlink sowie Restore-Quell-/Ziel-Symlinks und unveränderte Nutzdaten.
- **Nachweis:** GitHub-Commits bestätigt; neue Tests **nicht lokal ausgeführt**. Die PR-gefilterte Workflow-Abfrage für den vorherigen HEAD ergab keine Runs und erlaubt ausdrücklich **keine** Aussage über Push-CI. CI-Run für neuen HEAD, Android-Build und APK-Artefakt nicht nachgewiesen.
- **Backlog:** P0 **Test**: aktuelle Python-/Flutter-CI inklusive Debug-APK und SHA256; P0 **offen**: Android-DB-Lifecycle/Recovery-Rollback und exklusive Sperre; P0 **blockiert**: signierter Release und physische Geräteabnahme; P1 **offen**: E2E SQLite ↔ Scheduler ↔ API ↔ Flutter; P2 **offen**: M4-Funktions-/Qualitätsabnahme; P3 **zurückgestellt**: 3D-/Rot-Design.
- **Nächste autonome Priorität:** echten Push-Workflow-Run/Job-Logs/Artefakte auswerten und Buildfehler korrigieren; bei ausbleibender CI sichere Android-Recovery-Integration entwickeln. M1–M4 weiterhin **NO-GO**.


## P0 – Cold-Restore-Symlink-Regression behoben (2026-11-23, 17:43 Europe/Berlin)
- Ausgangs-HEAD `a8e8c852f28dd3fc466294c72c1b3f69e846d857`; vor STATUS-Schreiben erneut HEAD geprüft: `95c05af3f597290204eb8ffaab2f3e178046efa0`. README, Implementierungsplan, Status, Flutter-Workflow und offene PR/Issues geprüft. PR #1 offen, Issues 0.
- Konkreter Fehler: Der vorherige Symlink-Schutz war nur in `snapshot()` implementiert, nicht in `restore_cold()`. Der bereits eingecheckte Test `test_cold_restore_rejects_symlink_backup_and_target` hätte daher nicht bestanden und ein Symlink-Ziel konnte auf eine andere Datenbank umgeleitet werden.
- Fix: `restore_cold()` weist nun sowohl symbolische Backup-Quellen als auch symbolische Zielpfade vor `_validate`, Staging und `os.replace` zurück. Code-Commit `95c05af3f597290204eb8ffaab2f3e178046efa0`. Bestehende Regression deckt beide Fälle und Unverändertheit der Live-Daten ab; kein redundanter Test ergänzt.
- **Testnachweis:** Repository-Tests hier nicht ausführbar: Git-Klon scheitert an DNS (`Could not resolve host: github.com`). GitHub-Workflow-Abfrage nach Commit liefert nur PR-assoziierte Runs und ist kein Nachweis für Push-CI. Daher Test/CI für Fix **nicht als grün** markiert. Keine APK oder SHA256 verifiziert.
- **Backlog:** P0 **Test**: echten Flutter-/Python-Push-CI-Lauf einschließlich bestehenden Symlink-Regressionstests und Debug-APK/SHA256 prüfen; P0 **offen**: sicherer Android-DB-Lifecycle/Restore mit exklusiver Sperre und Rollback; P0 **blockiert**: physische Android-Abnahme, produktive Signierung; P1 **offen**: SQLite↔Scheduler↔API↔Flutter-E2E; P2 **offen**: M4-Qualitätsabnahme; P3 **zurückgestellt**: dunkelrote 3D-Optik.
- **Nächste autonome Priorität:** CI-Fehler anhand vollständiger Push-Run-Logs beheben, sonst unabhängigen Android-Recovery-Integrationsschnitt bearbeiten. M1–M4 **NO-GO**.


## P0 – Dangling-Sidecar-Symlink-Guard (2026-11-23, 19:43 Europe/Berlin)
- Ausgangs-HEAD `4cd6436016bb869425d16abbd0cd62e14797e246`; README, Implementierungsplan, STATUS, offene Issues (0) und CI-Job-Logs geprüft. PR #1 bleibt unberührt.
- CI-Run [45186886281](https://github.com/WeA200675/life-ai-planner/actions/runs/45186886281) für älteren SHA `a5cb424a`: Backend-Job success, Android-Job cancelled. Flutter-Tester meldete Segmentation Fault beim Laden von `offline_day_planner_test.dart`; Build/Signatur wurden übersprungen. Ursache noch nicht isoliert. Keine APK im geprüften Artefaktbestand.
- P0-Code-Fix `469f62cb3f24ce4e8b475d8c63787b3be6d8f3e5`: Cold-Restore weist jetzt auch *dangling* Symlinks der SQLite-Sidecars (-wal/-shm/-journal) ab; `Path.exists()` allein erkennt diese nicht. Synthetischer Regressionstest `8b274163ca95ce41602607fd64efe6f361a11702` schützt die unveränderte Live-Datenbank.
- **Nachweis:** Isolierter lokaler Python-Sanitycheck für dangling Symlink-Erkennung PASS. Repository-Regression und neuer Commit-CI noch **nicht ausgeführt/bestätigt**; daher kein grünes Gate behauptet.
- **Backlog:** P0 **Test**: neuen Python-Regressionstest und Flutter-CI mit isoliertem `offline_day_planner_test.dart` ausführen, Segfault beheben, Debug-APK plus SHA256 erzeugen; P0 **offen**: exklusiver Android-DB-Restore und Recovery-Rollback; P0 **blockiert**: physische Geräteabnahme und produktive Signierung; P1 **offen**: SQLite/Scheduler/API/Flutter-E2E; P2 **offen**: M4-Qualitätsabnahme; P3 **zurückgestellt**: dunkelrote 3D-Oberfläche. M1–M4 **NO-GO**.
- **Nächste autonome Priorität:** Flutter-Tester-Segfault reproduzierbar isolieren und CI-/APK-Gate reparieren, ohne Tests zu deaktivieren.


## P0 – Flutter-Tester-Crash in Release-CI eingrenzen (2026-11-23, Abend)
- Ausgangs-HEAD: `1996dff047dc92087498fc86710be4b8a04d42a0`; unmittelbar vor Status-Schreiben erneut geprüft: `593d451990557a68e8f134dd92c922ea943f33ee`.
- Tatsächlicher Nachweis: Release-Run [45186886281](https://github.com/WeA200675/life-ai-planner/actions/runs/45186886281), Android-Job `137738650635`: `offline_day_planner_test.dart` verursachte einen nativen `flutter_tester`-Segmentation-Fault bei +150 Tests. Der Runner lief danach bis zur Cancellation; Debug-APK-Schritt wurde übersprungen. Backend-Job war erfolgreich.
- CI-Korrektur [593d4519](https://github.com/WeA200675/life-ai-planner/commit/593d451990557a68e8f134dd92c922ea943f33ee): Flutter-Testgeräte werden seriell gestartet (`--concurrency=1`), einzelne Tests auf 2 Minuten und gesamte Suite auf 20 Minuten begrenzt. Exitstatus des Flutter-Prozesses wird durch `PIPESTATUS[0]` trotz `tee` erhalten; Testlogs werden auch bei Fehlern hochgeladen. Keine Tests deaktiviert, kein automatisches Grün nach Crash.
- Verifikation: geänderten Workflowtext aus GitHub zurückgelesen und auf Befehle/Fehlerpfad geprüft; **keine tatsächliche Flutter-Ausführung** und kein erfolgreicher neuer Actions-Run bestätigt. Diese Maßnahme begrenzt den Schaden eines nativen Crashes; dessen eigentliche Ursache ist weiterhin offen.
- Priorisierter Backlog: P0 **Test**: neuen CI-Run und Flutter-Log prüfen, gegebenenfalls nativen Crash reproduzieren und beheben; P0 **offen**: Debug-APK mit SHA256, Offline-Start, SQLite-Android-Restore und Crash-Rollback; P1 **offen**: E2E Scheduler/API/Flutter, Sprache/Textfallback, Undo; P2 **offen**: UI und Dashboard; P0 **blockiert**: signiertes Produktionsrelease und physische Geräteabnahme ohne Credentials/Gerät.
- M1–M4: **NO-GO**, kein APK-Artefakt nachgewiesen.
