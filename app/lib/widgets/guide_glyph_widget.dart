import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../utils/guide_theme.dart';

/// A widget that displays guide glyphs with SVG support and animated effects
class GuideGlyphWidget extends StatefulWidget {
  final GuideType guideType;
  final double size;
  final bool isSelected;
  final bool isAnimated;
  final bool showGlow;
  final VoidCallback? onTap;

  const GuideGlyphWidget({
    super.key,
    required this.guideType,
    this.size = 48.0,
    this.isSelected = false,
    this.isAnimated = true,
    this.showGlow = false,
    this.onTap,
  });

  @override
  State<GuideGlyphWidget> createState() => _GuideGlyphWidgetState();
}

class _GuideGlyphWidgetState extends State<GuideGlyphWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for glow effect
    _pulseController = AnimationController(
      duration: GuideAnimations.glowPulseDuration,
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: GuideAnimations.glowCurve,
      ),
    );

    // Rotation animation for visionary guide
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    if (widget.isAnimated) {
      _pulseController.repeat(reverse: true);
      if (widget.guideType == GuideType.visionary) {
        _rotationController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GuideGlyphWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isAnimated != oldWidget.isAnimated) {
      if (widget.isAnimated) {
        _pulseController.repeat(reverse: true);
        if (widget.guideType == GuideType.visionary) {
          _rotationController.repeat();
        }
      } else {
        _pulseController.stop();
        _rotationController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: widget.showGlow
                  ? [
                      BoxShadow(
                        color: GuideTheme.getPrimaryColor(
                          widget.guideType,
                        ).withValues(alpha: 0.3 * _pulseAnimation.value),
                        blurRadius: 20 * _pulseAnimation.value,
                        spreadRadius: 5 * _pulseAnimation.value,
                      ),
                    ]
                  : null,
            ),
            child: Transform.rotate(
              angle: widget.guideType == GuideType.visionary
                  ? _rotationAnimation.value * 2 * 3.14159
                  : 0,
              child: Transform.scale(
                scale: widget.isSelected
                    ? 1.1 * _pulseAnimation.value
                    : _pulseAnimation.value,
                child: _buildGlyphContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlyphContent() {
    // For now, we'll use the custom SVG-like designs with Flutter widgets
    // In a real implementation, you might use flutter_svg package
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: GuideTheme.getRadialGradient(widget.guideType),
      ),
      child: _buildGuideSpecificGlyph(),
    );
  }

  Widget _buildGuideSpecificGlyph() {
    switch (widget.guideType) {
      case GuideType.sage:
        return _buildSageGlyph();
      case GuideType.healer:
        return _buildHealerGlyph();
      case GuideType.mentor:
        return _buildMentorGlyph();
      case GuideType.visionary:
        return _buildVisionaryGlyph();
    }
  }

  Widget _buildSageGlyph() {
    final primary = GuideTheme.getPrimaryColor(GuideType.sage);
    final accent = GuideTheme.getAccentColor(GuideType.sage);

    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: SageGlyphPainter(
        primaryColor: primary,
        accentColor: accent,
        animationValue: _pulseAnimation.value,
      ),
    );
  }

  Widget _buildHealerGlyph() {
    final primary = GuideTheme.getPrimaryColor(GuideType.healer);
    final accent = GuideTheme.getAccentColor(GuideType.healer);

    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: HealerGlyphPainter(
        primaryColor: primary,
        accentColor: accent,
        animationValue: _pulseAnimation.value,
      ),
    );
  }

  Widget _buildMentorGlyph() {
    final primary = GuideTheme.getPrimaryColor(GuideType.mentor);
    final accent = GuideTheme.getAccentColor(GuideType.mentor);

    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: MentorGlyphPainter(
        primaryColor: primary,
        accentColor: accent,
        animationValue: _pulseAnimation.value,
      ),
    );
  }

  Widget _buildVisionaryGlyph() {
    final primary = GuideTheme.getPrimaryColor(GuideType.visionary);
    final accent = GuideTheme.getAccentColor(GuideType.visionary);

    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: VisionaryGlyphPainter(
        primaryColor: primary,
        accentColor: accent,
        animationValue: _pulseAnimation.value,
        rotationValue: _rotationAnimation.value,
      ),
    );
  }
}

/// Custom painter for Sage (Zian) glyph - interconnected knot pattern
class SageGlyphPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;
  final double animationValue;

  SageGlyphPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Outer ring
    paint.color = primaryColor.withValues(alpha: 0.6 * animationValue);
    canvas.drawCircle(center, radius, paint);

    // Interconnected knot pattern
    final path = Path();
    final knotRadius = radius * 0.6;

    // Create interconnected pattern
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90) * (3.14159 / 180);
      final x1 = center.dx + knotRadius * 0.8 * math.cos(angle);
      final y1 = center.dy + knotRadius * 0.8 * math.sin(angle);

      final nextAngle = ((i + 1) * 90) * (3.14159 / 180);
      final x2 = center.dx + knotRadius * 0.8 * math.cos(nextAngle);
      final y2 = center.dy + knotRadius * 0.8 * math.sin(nextAngle);

      if (i == 0) {
        path.moveTo(x1, y1);
      }

      // Create curved connection
      final controlX = center.dx + knotRadius * 1.2 * math.cos(angle + 0.785);
      final controlY = center.dy + knotRadius * 1.2 * math.sin(angle + 0.785);
      path.quadraticBezierTo(controlX, controlY, x2, y2);
    }

    paint.color = primaryColor;
    paint.strokeWidth = 2.5;
    canvas.drawPath(path, paint);

    // Central points (constellation effect)
    final pointPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final angle = (i * 90) * (3.14159 / 180);
      final x = center.dx + knotRadius * 0.8 * math.cos(angle);
      final y = center.dy + knotRadius * 0.8 * math.sin(angle);

      pointPaint.color = accentColor.withValues(alpha: animationValue);
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }

    // Central core
    pointPaint.color = primaryColor;
    canvas.drawCircle(center, 4, pointPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom painter for Healer (Lyra) glyph - lotus pattern
class HealerGlyphPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;
  final double animationValue;

  HealerGlyphPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    final paint = Paint()..style = PaintingStyle.fill;

    // Lotus petals
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);

      paint.color = primaryColor.withValues(alpha: 0.8 * animationValue);

      // Outer petals
      final petalPath = Path();
      final petalLength = radius * 0.8;
      final petalWidth = radius * 0.2;

      final startX = center.dx + petalWidth * math.cos(angle + 1.57);
      final startY = center.dy + petalWidth * math.sin(angle + 1.57);
      final endX = center.dx + petalLength * math.cos(angle);
      final endY = center.dy + petalLength * math.sin(angle);

      petalPath.moveTo(startX, startY);
      petalPath.quadraticBezierTo(
        endX,
        endY,
        center.dx + petalWidth * math.cos(angle - 1.57),
        center.dy + petalWidth * math.sin(angle - 1.57),
      );
      petalPath.close();

      canvas.drawPath(petalPath, paint);
    }

    // Central heart
    paint.color = primaryColor;
    canvas.drawCircle(center, radius * 0.2, paint);

    // Heart shape in center
    final heartPath = Path();
    final heartSize = radius * 0.15;
    heartPath.moveTo(center.dx, center.dy + heartSize * 0.3);
    heartPath.cubicTo(
      center.dx - heartSize * 0.5,
      center.dy - heartSize * 0.2,
      center.dx - heartSize,
      center.dy + heartSize * 0.3,
      center.dx,
      center.dy + heartSize * 0.8,
    );
    heartPath.cubicTo(
      center.dx + heartSize,
      center.dy + heartSize * 0.3,
      center.dx + heartSize * 0.5,
      center.dy - heartSize * 0.2,
      center.dx,
      center.dy + heartSize * 0.3,
    );

    paint.color = accentColor;
    canvas.drawPath(heartPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom painter for Mentor (Kael) glyph - mountain/arrow pattern
class MentorGlyphPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;
  final double animationValue;

  MentorGlyphPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    final paint = Paint()..style = PaintingStyle.fill;

    // Mountain/arrow shape
    final arrowPath = Path();
    final arrowHeight = radius * 1.2;
    final arrowWidth = radius * 0.8;

    // Arrow tip
    arrowPath.moveTo(center.dx, center.dy - arrowHeight);
    arrowPath.lineTo(
      center.dx + arrowWidth * 0.6,
      center.dy - arrowHeight * 0.3,
    );
    arrowPath.lineTo(
      center.dx + arrowWidth * 0.3,
      center.dy - arrowHeight * 0.3,
    );
    arrowPath.lineTo(
      center.dx + arrowWidth * 0.3,
      center.dy + arrowHeight * 0.5,
    );
    arrowPath.lineTo(
      center.dx - arrowWidth * 0.3,
      center.dy + arrowHeight * 0.5,
    );
    arrowPath.lineTo(
      center.dx - arrowWidth * 0.3,
      center.dy - arrowHeight * 0.3,
    );
    arrowPath.lineTo(
      center.dx - arrowWidth * 0.6,
      center.dy - arrowHeight * 0.3,
    );
    arrowPath.close();

    paint.color = primaryColor.withValues(alpha: animationValue);
    canvas.drawPath(arrowPath, paint);

    // Geometric accent lines
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    paint.color = accentColor;

    canvas.drawLine(
      Offset(center.dx - arrowWidth * 0.2, center.dy + arrowHeight * 0.2),
      Offset(center.dx + arrowWidth * 0.2, center.dy + arrowHeight * 0.2),
      paint,
    );

    // Base foundation
    paint.style = PaintingStyle.fill;
    paint.color = primaryColor.withValues(alpha: 0.8 * animationValue);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + arrowHeight * 0.6),
        width: arrowWidth * 0.8,
        height: radius * 0.2,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom painter for Visionary (Elara) glyph - cosmic eye pattern
class VisionaryGlyphPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;
  final double animationValue;
  final double rotationValue;

  VisionaryGlyphPainter({
    required this.primaryColor,
    required this.accentColor,
    required this.animationValue,
    required this.rotationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationValue * 2 * 3.14159);
    canvas.translate(-center.dx, -center.dy);

    final paint = Paint();

    // Spiral arms
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3.0;
    paint.strokeCap = StrokeCap.round;
    paint.color = primaryColor.withValues(alpha: 0.7 * animationValue);

    final spiralPath = Path();
    for (double t = 0; t < 4 * 3.14159; t += 0.1) {
      final r = radius * 0.8 * (1 - t / (4 * 3.14159));
      final x = center.dx + r * math.cos(t);
      final y = center.dy + r * math.sin(t);

      if (t == 0) {
        spiralPath.moveTo(x, y);
      } else {
        spiralPath.lineTo(x, y);
      }
    }
    canvas.drawPath(spiralPath, paint);

    // Central eye
    paint.style = PaintingStyle.fill;

    // Eye outline
    final eyeRect = Rect.fromCenter(
      center: center,
      width: radius * 0.8,
      height: radius * 0.5,
    );
    paint.color = primaryColor;
    canvas.drawOval(eyeRect, paint);

    // Iris
    final irisRect = Rect.fromCenter(
      center: center,
      width: radius * 0.5,
      height: radius * 0.3,
    );
    paint.color = accentColor;
    canvas.drawOval(irisRect, paint);

    // Pupil
    paint.color = const Color(0xFF1E1B4B);
    canvas.drawCircle(center, radius * 0.1, paint);

    // Light reflection
    paint.color = accentColor.withValues(alpha: 0.8 * animationValue);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.05, center.dy - radius * 0.05),
      radius * 0.03,
      paint,
    );

    // Cosmic particles
    paint.color = accentColor.withValues(alpha: 0.6 * animationValue);
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180);
      final distance =
          radius * (1.2 + 0.3 * math.sin(rotationValue * 2 * 3.14159 + i));
      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 2, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
