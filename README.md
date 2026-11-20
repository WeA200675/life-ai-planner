# Life AI Planner

Privater, offline-first KI-Lebens- und Zeitplaner für Android, Web und optional Oracle-Backend.

## Ziele
- Spracheingabe und strukturierte Aufgaben (mit Bestätigung unsicherer Extraktionen)
- Tagesplanung mit geschützten Fixterminen, 70/30-Kapazitätsregel und dynamischer Umplanung
- Statistische Zeitschätzung und 14-Tage-Pufferkalibrierung
- Lebensbereiche, Dashboard, optionale Biometrie und sokratische Reflexion
- Datenschutz, lokale Fallbacks, nachvollziehbare Änderungen und Tests

## Architektur
- `apps/mobile`: Flutter/Android, Offline-Daten, Benachrichtigungen und Sprache
- `apps/web`: Dashboard
- `services/api`: Python/FastAPI, REST/WebSocket, Authentifizierung
- `packages/scheduler`: deterministischer Planer ohne LLM-Abhängigkeit
- `packages/contracts`: gemeinsame Schemas und Validierung
- `infra`: Docker Compose, Migrationen, CI, Backups
- `docs`: Spezifikation, Architektur, Entscheidungen, Testprotokolle

## Prinzipien
1. Lokaler Betrieb ohne Netzwerk muss für Kernplanung funktionieren.
2. Externe KI ist optional; kein Cloud- oder LLM-Ausfall darf Aufgaben löschen.
3. Keine stillschweigende Verschiebung geschützter Termine; Konflikte transparent anzeigen.
4. Gesundheitsdaten nur nach Opt-in, sparsam und getrennt speichern; keine Diagnosen.
5. Automatisierung nur mit nachweisbaren Tests und dokumentierten Ergebnissen; keine erfundenen Erfolgswerte.
6. Keine Secrets im Repository; CI ohne kostenpflichtige Abhängigkeiten.

Siehe [Implementierungsplan](docs/IMPLEMENTATION_PLAN.md).
