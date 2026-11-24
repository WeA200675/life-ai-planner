import 'package:flutter/material.dart';
import 'planner_theme.dart';

/// Organic dashboard; all callbacks retain the existing offline behavior.
class FlowDashboard extends StatelessWidget {
  const FlowDashboard({super.key, required this.open, required this.completed,
    required this.enabled, required this.onPreview, required this.onReplan,
    required this.onSaved, required this.onHistory, required this.onBackup,
    required this.onRestore});
  final int open, completed;
  final bool enabled;
  final VoidCallback onPreview, onReplan, onSaved, onHistory, onBackup, onRestore;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          const Icon(Icons.auto_awesome, color: PlannerTheme.coral),
          const SizedBox(width: 8),
          Expanded(child: Text('MIDNIGHT FLOW',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800, letterSpacing: 1.4))),
          const Text('OFFLINE', style: TextStyle(
            color: PlannerTheme.turquoise, fontSize: 10)),
        ])),
      LayoutBuilder(builder: (context, size) {
        final w = (size.maxWidth - 10) / 2;
        return Wrap(spacing: 10, runSpacing: 10, children: [
          SizedBox(width: w, child: _Tile('OFFEN', '$open', Icons.bolt_outlined,
            0, const [PlannerTheme.bordeaux, PlannerTheme.ruby],
            enabled ? onPreview : null)),
          SizedBox(width: w, child: _Tile('ERLEDIGT', '$completed',
            Icons.check_circle_outline, 1,
            const [Color(0xFF343944), Color(0xFF20252F)],
            enabled ? onHistory : null)),
          SizedBox(width: w, child: _Tile('TAGESPLAN', 'Planen',
            Icons.calendar_month_outlined, 2,
            const [Color(0xFF78283A), Color(0xFF3C202B)],
            enabled ? onPreview : null)),
          SizedBox(width: w, child: _Tile('DYNAMIK', 'Neu planen',
            Icons.autorenew, 3,
            const [Color(0xFF49333C), Color(0xFF932D41)],
            enabled ? onReplan : null)),
        ]);
      }),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 2, children: [
        ActionChip(label: const Text('Letzter Plan'),
          onPressed: enabled ? onSaved : null),
        ActionChip(label: const Text('Historie'),
          onPressed: enabled ? onHistory : null),
        ActionChip(label: const Text('Sichern'),
          onPressed: enabled ? onBackup : null),
        ActionChip(label: const Text('Einlesen'),
          onPressed: enabled ? onRestore : null),
      ]),
    ],
  );
}

class _Tile extends StatelessWidget {
  const _Tile(this.label, this.value, this.icon, this.shape, this.colors, this.tap);
  final String label, value;
  final IconData icon;
  final int shape;
  final List<Color> colors;
  final VoidCallback? tap;

  @override
  Widget build(BuildContext context) {
    const shapes = [
      BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(13),
        bottomLeft: Radius.circular(12), bottomRight: Radius.circular(38)),
      BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(38),
        bottomLeft: Radius.circular(33), bottomRight: Radius.circular(13)),
      BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(13),
        bottomLeft: Radius.circular(19), bottomRight: Radius.circular(29)),
      BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(30),
        bottomLeft: Radius.circular(40), bottomRight: Radius.circular(12)),
    ];
    return Semantics(button: true, enabled: tap != null,
      label: '$label: $value', child: Material(color: Colors.transparent,
        child: InkWell(onTap: tap, borderRadius: shapes[shape],
          child: Ink(height: 102,
            decoration: BoxDecoration(borderRadius: shapes[shape],
              gradient: LinearGradient(colors: colors),
              border: Border.all(color: const Color(0x22FFFFFF))),
            child: Padding(padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Icon(icon, size: 19, color: Colors.white70),
                  Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white,
                      fontSize: 21, fontWeight: FontWeight.w800)),
                  Text(label, style: const TextStyle(color: Colors.white70,
                    fontSize: 10, letterSpacing: 1.1)),
                ]))))));
  }
}
