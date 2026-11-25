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
          Expanded(child: Text('MIDNIGHT FLOW 3D',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800, letterSpacing: 1.4))),
          const Text('OFFLINE', style: TextStyle(
            color: PlannerTheme.coral, fontSize: 10)),
        ])),
      LayoutBuilder(builder: (context, size) {
        final available = (size.maxWidth - 20).clamp(0.0, double.infinity).toDouble();
        final w = available < 340 || MediaQuery.textScalerOf(context).scale(16) > 24
            ? available : (available - 14) / 2;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const RadialGradient(
              center: Alignment(-.55, -.8), radius: 1.35,
              colors: [Color(0xFF302528), Color(0xFF181416), Color(0xFF100E10)],
              stops: [0, .55, 1],
            ),
            border: Border.all(color: const Color(0xFF392A2D)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Wrap(spacing: 14, runSpacing: 4, children: [
          SizedBox(width: w, child: _Tile('OFFEN', '$open', Icons.bolt_outlined,
            0, const [PlannerTheme.bordeaux, PlannerTheme.ruby],
            enabled ? onPreview : null)),
          SizedBox(width: w, child: _Tile('ERLEDIGT', '$completed',
            Icons.check_circle_outline, 1,
            const [Color(0xFF79252B), Color(0xFF30090D)],
            enabled ? onHistory : null)),
          SizedBox(width: w, child: _Tile('TAGESPLAN', 'Planen',
            Icons.calendar_month_outlined, 2,
            const [Color(0xFFA12D35), Color(0xFF38090F)],
            enabled ? onPreview : null)),
          SizedBox(width: w, child: _Tile('DYNAMIK', 'Neu planen',
            Icons.autorenew, 3,
            const [Color(0xFF521019), Color(0xFF9A202D)],
            enabled ? onReplan : null)),
        ]),
          ),
        );
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
    return Semantics(
      button: true,
      enabled: tap != null,
      label: '$label: $value',
      child: RepaintBoundary(
        child: CustomPaint(
          painter: FloatingWaxShadowPainter(shape),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(3, 4, 7, 30),
            child: CustomPaint(
        painter: WaxSurfacePainter(shape, colors.first, colors.last),
        child: ClipPath(
        clipper: WaxDropClipper(shape),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: tap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 34, 28, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 19, color: Colors.white70),
                    const SizedBox(height: 8),
                    Text(value, style: const TextStyle(
                      color: Colors.white, fontSize: 21,
                      fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(label, style: const TextStyle(
                      color: Colors.white70, fontSize: 10,
                      letterSpacing: 1.1)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
          ),
        ),
      ),
    );
  }
}

/// An irregular wax-drop silhouette, not merely a rounded rectangle.
/// Coordinates are normalized, keeping the path responsive to tile size.
class WaxDropClipper extends CustomClipper<Path> {
  const WaxDropClipper(this.variant);
  final int variant;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final flip = variant.isOdd;
    final path = Path();
    if (variant == 2) {
      path.moveTo(w * .23, h * .025);
      path.cubicTo(w * .48, h * .09, w * .69, -h * .04, w * .86, h * .08);
      path.cubicTo(w, h * .17, w * .91, h * .40, w * .96, h * .57);
      path.cubicTo(w, h * .80, w * .83, h * .96, w * .61, h * .91);
      path.cubicTo(w * .39, h * .86, w * .24, h * 1.06, w * .10, h * .91);
      path.cubicTo(-w * .04, h * .75, w * .10, h * .53, w * .04, h * .36);
      path.cubicTo(-w * .02, h * .16, w * .09, h * .01, w * .23, h * .025);
    } else if (variant == 3) {
      path.moveTo(w * .12, h * .08);
      path.cubicTo(w * .32, -h * .06, w * .49, h * .10, w * .72, h * .035);
      path.cubicTo(w * .97, -h * .02, w, h * .23, w * .91, h * .44);
      path.cubicTo(w * .83, h * .65, w * 1.04, h * .80, w * .84, h * .94);
      path.cubicTo(w * .67, h * 1.03, w * .48, h * .89, w * .30, h * .96);
      path.cubicTo(w * .04, h * 1.02, -w * .01, h * .80, w * .055, h * .57);
      path.cubicTo(w * .11, h * .35, -w * .04, h * .22, w * .12, h * .08);
    } else if (!flip) {
      path.moveTo(w * .14, 0);
      path.cubicTo(w * .38, -h * .015, w * .55, h * .055, w * .79, h * .01);
      path.cubicTo(w * .96, -h * .005, w, h * .13, w * .985, h * .32);
      path.cubicTo(w * .965, h * .49, w * .94, h * .55, w * .975, h * .74);
      path.cubicTo(w, h * .96, w * .86, h, w * .68, h * .98);
      path.cubicTo(w * .45, h * .95, w * .30, h * 1.015, w * .13, h * .98);
      path.cubicTo(-w * .025, h * .95, 0, h * .80, w * .015, h * .63);
      path.cubicTo(w * .035, h * .45, -w * .015, h * .34, w * .025, h * .18);
      path.cubicTo(w * .045, h * .075, w * .065, 0, w * .14, 0);
    } else {
      path.moveTo(w * .18, h * .015);
      path.cubicTo(w * .40, h * .06, w * .57, -h * .02, w * .83, h * .005);
      path.cubicTo(w * .98, h * .02, w, h * .18, w * .975, h * .35);
      path.cubicTo(w * .94, h * .52, w, h * .70, w * .97, h * .85);
      path.cubicTo(w * .94, h, w * .82, h, w * .63, h * .975);
      path.cubicTo(w * .42, h * .94, w * .30, h * 1.01, w * .13, h * .985);
      path.cubicTo(-w * .015, h * .96, 0, h * .78, w * .03, h * .62);
      path.cubicTo(w * .06, h * .46, 0, h * .32, w * .025, h * .17);
      path.cubicTo(w * .045, h * .055, w * .10, 0, w * .18, h * .015);
    }
    return path..close();
  }

  @override
  bool shouldReclip(covariant WaxDropClipper oldClipper) =>
      oldClipper.variant != variant;
}

/// Cast shadows on a separate ground plane, outside the interactive silhouette.
class FloatingWaxShadowPainter extends CustomPainter {
  const FloatingWaxShadowPainter(this.variant);
  final int variant;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width - 10;
    final h = size.height - 34;
    if (w <= 0 || h <= 0) return;
    final footprint = WaxDropClipper(variant).getClip(Size(w, h));
    final center = Offset(3 + w * .53, 4 + h + 12);
    final glow = Rect.fromCenter(center: center, width: w * .98, height: 30);
    canvas.drawOval(glow, Paint()..shader = const RadialGradient(
      colors: [Color(0x44B92A24), Color(0x00B92A24)],
    ).createShader(glow));
    canvas.save();
    canvas.translate(10, 19);
    canvas.drawPath(footprint, Paint()
      ..color = const Color(0x99000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
    canvas.restore();
    canvas.save();
    canvas.translate(9, 16);
    canvas.drawPath(footprint, Paint()
      ..color = const Color(0xB8000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    canvas.restore();
    final core = Rect.fromCenter(center: center.translate(4, -1),
      width: w * .72, height: 10);
    canvas.drawOval(core, Paint()
      ..color = const Color(0x99000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
  }

  @override
  bool shouldRepaint(covariant FloatingWaxShadowPainter oldDelegate) =>
      variant != oldDelegate.variant;
}

/// Layered, resolution-independent wax lighting; no textures or GPU shaders.
class WaxSurfacePainter extends CustomPainter {
  const WaxSurfacePainter(this.variant, this.light, this.dark);
  final int variant;
  final Color light, dark;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final path = WaxDropClipper(variant).getClip(size);
    final rect = Offset.zero & size;
    // The separate ground painter owns the cast shadow.
    canvas.save();
    canvas.translate(0, 5);
    canvas.drawPath(path, Paint()..color = const Color(0xFF310609));
    canvas.restore();
    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(path, Paint()..shader = LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [const Color(0xFFF05A58), light, dark, const Color(0xFF190408)],
      stops: const [0, .28, .72, 1],
    ).createShader(rect));
    canvas.drawPath(path, Paint()..shader = const RadialGradient(
      center: Alignment(-.65, -.9), radius: 1.15,
      colors: [Color(0x77FFB8A0), Color(0x11FF7868), Color(0x00000000)],
      stops: [0, .42, 1],
    ).createShader(rect));
    canvas.drawPath(path, Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0x00FFFFFF), Color(0x00000000), Color(0x990D0003)],
      stops: [0, .52, 1],
    ).createShader(rect));
    canvas.drawPath(path, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..shader = const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xAAFFD0B8), Color(0x33FF7060), Color(0xAA200005)],
      ).createShader(rect));
    // Curved studio softbox reflections follow the molten surface.
    final w = size.width;
    final h = size.height;
    final highlight = Path()
      ..moveTo(w * .12, h * .17)
      ..cubicTo(w * .22, h * .015, w * .52, h * .13, w * .77, h * .075)
      ..cubicTo(w * .86, h * .055, w * .91, h * .12, w * .91, h * .17)
      ..cubicTo(w * .66, h * .12, w * .42, h * .25, w * .19, h * .22)
      ..quadraticBezierTo(w * .12, h * .21, w * .12, h * .17)
      ..close();
    canvas.drawPath(highlight, Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xF0FFF3E6), Color(0xA0FFB8A6), Color(0x00FFB8A6)],
        stops: [0, .35, 1],
      ).createShader(Rect.fromLTWH(0, h * .05, w, h * .20)));
    final gleam = Path()
      ..moveTo(w * .10, h * .30)
      ..cubicTo(w * .055, h * .18, w * .13, h * .095, w * .27, h * .09);
    canvas.drawPath(gleam, Paint()
      ..color = const Color(0xDDFFF0DE)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2);
    final bounce = Path()
      ..moveTo(w * .17, h * .89)
      ..cubicTo(w * .36, h * .96, w * .68, h * .88, w * .85, h * .90);
    canvas.drawPath(bounce, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(colors: [
        Color(0x00FF6655), Color(0xAAFF6655), Color(0x00FF6655),
      ]).createShader(rect));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WaxSurfacePainter oldDelegate) =>
      variant != oldDelegate.variant || light != oldDelegate.light || dark != oldDelegate.dark;
}
