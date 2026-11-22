# Release-Abnahme – 2026-11-22

## Stand und Nachweise
- Ausgangs-HEAD: `2ea5ca4bb5e119b9b9bac6744ae872fea12ae038`.
- CI-Workflow für Release-Kandidaten: `.github/workflows/release-acceptance.yml` (Commit `9ff3e24ba5ce134991d2703fd7a48ef70e4af886`).
- Workflow-Gates: Python unittest discovery, Flutter-Abhängigkeiten, Analyzer, Flutter-Tests mit Coverage, Android-Release-APK, ZIP-Integrität, SHA-256, Artifact-Upload.
- Workflow wurde auf GitHub committed; **kein erfolgreicher Lauf für diesen Commit nachgewiesen**. Es gibt keinen lokalen Android-Geräte-Testnachweis.
- Das erzeugte APK ist **nur ein Release-Kandidat**, nicht automatisch ein produktiv signiertes oder installierbares Release. Flutter-Standardtemplates können eine Debug-Signatur für Release-Builds verwenden; Signatur/Package-ID müssen explizit geprüft werden.

## Freigabesperren
- CI-Gates müssen für exakt denselben Commit erfolgreich abgeschlossen sein.
- Python-Abhängigkeiten und unittest-Discovery müssen gegen das tatsächliche Repository geprüft und ggf. korrigiert werden.
- APK-Signatur mit apksigner prüfen, Release-Keystore sicher außerhalb des Repos konfigurieren; keine Secrets committen.
- Android-Gerät: Offline-Start, SQLite-Aufgaben und Replanning, Sprache/Textfallback, Neustart, Backup/Restore und Rollback, Berechtigungen, Dashboard und optionales Biometrie-Opt-in manuell mit synthetischen Daten prüfen.
- Restore-Aktivierung bleibt deaktiviert, bis Crash-Recovery, exklusiver Zugriff und Rollback belegt sind.
- Quantitative Qualitätsziele aus IMPLEMENTATION_PLAN.md benötigen reale Messungen; keine fiktiven Erfolgsquoten.
- M1–M4: **NICHT ABGENOMMEN**.

## Nächster Schritt
GitHub Actions für den neuen HEAD auswerten, alle CI-Fehler korrigieren und anschließend Signatur- und Geräteabnahme durchführen. Erst danach Freigabe entscheiden.
