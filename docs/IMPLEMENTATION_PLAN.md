# Implementierungsplan und autonomes Arbeitsprotokoll

## Arbeitsauftrag
Entwickle die vom Nutzer beschriebene vollständige Lösung iterativ, ohne Rückfragen zu Routineentscheidungen. Arbeite bei jedem Lauf an der nächsten überprüfbaren, priorisierten Aufgabe. Committe funktionierende Zwischenstände; teste, dokumentiere, behebe Fehler und setze beim nächsten Lauf fort. Behaupte keine Fertigstellung ohne Evidenz.

## M1 Fundament
- Repo-Struktur, README, Lizenzentscheidung (privat zunächst keine öffentliche Lizenz), .gitignore, SECURITY.md, CONTRIBUTING.md
- Python API, Pydantic-Verträge, SQLite-Lokalbetrieb und PostgreSQL-Backend, Alembic-Migrationen
- Modelle Task, LifeDomain, BufferLog, BiometricState, ReflectionSession, CalendarEvent, PlanVersion, Incident, SyncOutbox
- Tests, Ruff, Pytest, GitHub Actions; Health/Readiness, Logging, Datenschutzkonzept

## M2 Nutzbares MVP
- Flutter Android mit lokalen Aufgaben, Eingabe und Tagesansicht
- Offline STT soweit Geräteunterstützung, Text-Fallback, optionale Cloud-STT mit Einwilligung
- NLP-Extraktion mit Schema-Validierung, Rückfragen bei Mehrdeutigkeit
- deterministischer statischer Planer mit festen Terminen, Pausen, Abhängigkeiten, Zeitzonen und Erinnerungen
- Alarm-/Kalenderberechtigungen, Benachrichtigungskanäle, Android-Hintergrundrestriktionen berücksichtigen

## M3 Dynamik und Kalibrierung
- Scheduling mit festen und flexiblen Blöcken, Prioritäten, Deadlines, realen Kapazitätsgrenzen
- 70% Zielbelegung, 30% freie Reserve; Ausnahmefälle explizit kennzeichnen
- Replanning bei Verzögerungen, Ad-hoc-Aufgaben, Ausfällen; Idempotenz, Versionskontrolle, Undo
- Soll-Ist-Statistik, MAE, Unterbrechungen, 14-Tage-Kalibrierung mit Grenzen und Mindeststichprobe
- nächtliche Konsolidierung und Entwurf für Folgetag, fehlertolerant und wiederholbar

## M4 Gesamtsystem
- Web/Android-Dashboard, Lebensrad, konfigurierbare Gewichte und Puffertrends
- Health Connect auf Android als bevorzugte Health-Datenschnittstelle; nur nach expliziter Zustimmung
- Reflexionsagent mit optional lokalem Modell und optional Oracle-Service; kritische Fragen, Unsicherheitsangaben, keine medizinischen Diagnosen
- Standort-Erinnerungen mit Opt-in, Akkuschonung und Offline-Fallback
- Ende-zu-Ende-Tests, Backup/Restore, Migrations-/Rollback-Proben, Android-Release-Build und Dokumentation

## Sicherheits- und Abnahmeregeln
- Keine produktiven personenbezogenen Daten in Tests oder Logs; niemals Secrets committen.
- Kein automatisches Löschen oder Überschreiben von Kalendereinträgen ohne Freigabe.
- Biometrie ist optional; fehlende Daten dürfen keine Funktion blockieren.
- Fahrtmodus: keine ablenkende Bedienung; Sprachsteuerung nur im Rahmen der Plattformregeln.
- Qualität messen: STT/NLP >92% unter definiertem Fahrgeräusch-Testkorpus; Planabbrüche -35% gegenüber Baseline; Schätz-MAE -25% nach 30 Tagen; keine Kennzahl ohne echte Messung behaupten.
- CI grün, relevante Unit-/Integrationstests, reproduzierbarer Build, dokumentierte Einschränkungen und manuelle Geräteabnahme vor 'fertig'.

## Fortsetzungsalgorithmus je Lauf
1. Repo HEAD, Issues, PRs und CI lesen, Zustand feststellen.
2. Offene Arbeit nach M1→M4 und Abhängigkeiten priorisieren; keine doppelten Aufgaben anlegen.
3. Einen möglichst großen, aber überprüfbaren vertikalen Schnitt implementieren.
4. Tests ausführen, Fehler beheben, Ergebnisse dokumentieren, Änderungen committen (bei Risiko über PR).
5. `docs/STATUS.md` mit SHA, Testbelegen, erledigten/offenen Punkten und nächstem konkreten Schritt aktualisieren.
6. Bei fehlenden Zugriffsrechten oder Infrastruktur: sichere Alternative im Repo umsetzen und Blocker dokumentieren.
7. Nur bei tatsächlich nachgewiesener vollständiger Abnahme die Entwicklung als abgeschlossen melden.

## Status
Initialisierung am 2026-11-20. Implementierung und Tests stehen noch aus.
