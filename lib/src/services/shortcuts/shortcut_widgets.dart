import 'package:flutter/material.dart';
import 'dart:math' as math;

// Custom Icon Painters
class BikeIconPainter extends CustomPainter {
  final Color color;

  BikeIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Wheel properties
    final rearWheelCenter = Offset(size.width * 0.25, size.height * 0.7);
    final frontWheelCenter = Offset(size.width * 0.75, size.height * 0.7);
    final wheelRadius = size.width * 0.14;

    // Draw rear wheel
    canvas.drawCircle(rearWheelCenter, wheelRadius, paint);
    canvas.drawCircle(rearWheelCenter, wheelRadius * 0.4, paint);

    // Draw front wheel
    canvas.drawCircle(frontWheelCenter, wheelRadius, paint);
    canvas.drawCircle(frontWheelCenter, wheelRadius * 0.4, paint);

    // Main frame path
    final framePath = Path();

    // Seat (horizontal line at top)
    framePath.moveTo(size.width * 0.2, size.height * 0.35);
    framePath.lineTo(size.width * 0.42, size.height * 0.35);

    // Rear frame - from seat to rear wheel
    framePath.moveTo(size.width * 0.25, size.height * 0.35);
    framePath.lineTo(size.width * 0.25, size.height * 0.56);

    // Swingarm to rear wheel
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.56),
      rearWheelCenter,
      paint,
    );

    // Fuel tank curve
    final tankPath = Path();
    tankPath.moveTo(size.width * 0.42, size.height * 0.35);
    tankPath.quadraticBezierTo(
        size.width * 0.5, size.height * 0.42,
        size.width * 0.55, size.height * 0.48
    );

    // Down tube from tank to engine area
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.42),
      Offset(size.width * 0.4, size.height * 0.56),
      paint,
    );

    // Engine block (solid filled rectangle for visibility)
    final enginePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final engineRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.35,
        size.height * 0.54,
        size.width * 0.2,
        size.height * 0.1,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(engineRect, enginePaint);

    // Engine detail lines
    canvas.drawLine(
      Offset(size.width * 0.38, size.height * 0.54),
      Offset(size.width * 0.38, size.height * 0.64),
      paint..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(size.width * 0.42, size.height * 0.54),
      Offset(size.width * 0.42, size.height * 0.64),
      paint..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(size.width * 0.46, size.height * 0.54),
      Offset(size.width * 0.46, size.height * 0.64),
      paint..strokeWidth = 1.5,
    );

    // Exhaust pipe
    final exhaustPath = Path();
    exhaustPath.moveTo(size.width * 0.52, size.height * 0.59);
    exhaustPath.quadraticBezierTo(
        size.width * 0.6, size.height * 0.64,
        size.width * 0.68, size.height * 0.64
    );
    canvas.drawPath(exhaustPath, paint..strokeWidth = 2.5);

    // Exhaust muffler end
    canvas.drawCircle(
      Offset(size.width * 0.68, size.height * 0.64),
      3,
      paint..style = PaintingStyle.fill,
    );

    // Front fork
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.38),
      frontWheelCenter,
      paint..style = PaintingStyle.stroke..strokeWidth = 2.5,
    );

    // Handlebars
    final handlebarPath = Path();
    handlebarPath.moveTo(size.width * 0.58, size.height * 0.32);
    handlebarPath.lineTo(size.width * 0.72, size.height * 0.32);

    // Handlebar stem
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.32),
      Offset(size.width * 0.65, size.height * 0.38),
      paint..strokeWidth = 2.5,
    );

    // Connect tank to front
    canvas.drawLine(
      Offset(size.width * 0.55, size.height * 0.48),
      Offset(size.width * 0.65, size.height * 0.38),
      paint..strokeWidth = 2.5,
    );

    // Rear fender
    canvas.drawArc(
      Rect.fromCircle(
        center: rearWheelCenter,
        radius: wheelRadius + 5,
      ),
      math.pi * 0.55,
      math.pi * 0.9,
      false,
      paint..strokeWidth = 2.5,
    );

    // Front fender
    canvas.drawArc(
      Rect.fromCircle(
        center: frontWheelCenter,
        radius: wheelRadius + 5,
      ),
      math.pi * 0.55,
      math.pi * 0.9,
      false,
      paint..strokeWidth = 2.5,
    );

    // Headlight
    canvas.drawCircle(
      Offset(size.width * 0.68, size.height * 0.42),
      3,
      paint..style = PaintingStyle.fill,
    );

    // Draw all paths
    canvas.drawPath(framePath, paint..style = PaintingStyle.stroke..strokeWidth = 2.5);
    canvas.drawPath(tankPath, paint..strokeWidth = 2.5);
    canvas.drawPath(handlebarPath, paint..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ShoppingBagIconPainter extends CustomPainter {
  final Color color;

  ShoppingBagIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Bag body
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.25,
        size.height * 0.35,
        size.width * 0.5,
        size.height * 0.5,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(rect, paint);

    // Handle
    final handlePath = Path();
    handlePath.moveTo(size.width * 0.38, size.height * 0.35);
    handlePath.cubicTo(
      size.width * 0.38,
      size.height * 0.2,
      size.width * 0.62,
      size.height * 0.2,
      size.width * 0.62,
      size.height * 0.35,
    );

    canvas.drawPath(handlePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BriefcaseIconPainter extends CustomPainter {
  final Color color;

  BriefcaseIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Main briefcase body
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.4,
        size.width * 0.6,
        size.height * 0.45,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, paint);

    // Top handle section
    final handlePath = Path();
    handlePath.moveTo(size.width * 0.35, size.height * 0.4);
    handlePath.lineTo(size.width * 0.35, size.height * 0.25);
    handlePath.lineTo(size.width * 0.65, size.height * 0.25);
    handlePath.lineTo(size.width * 0.65, size.height * 0.4);

    canvas.drawPath(handlePath, paint);

    // Center line detail
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.55),
      Offset(size.width * 0.8, size.height * 0.55),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SpeedometerIconPainter extends CustomPainter {
  final Color color;

  SpeedometerIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height * 0.7);
    final radius = size.width * 0.38;

    // Arc (180 degrees from bottom left to bottom right)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      paint,
    );

    // Tick marks
    for (int i = 0; i <= 4; i++) {
      final angle = math.pi + (i * math.pi / 4);
      final startRadius = radius - 8;
      final endRadius = radius;

      canvas.drawLine(
        Offset(
          center.dx + startRadius * math.cos(angle),
          center.dy + startRadius * math.sin(angle),
        ),
        Offset(
          center.dx + endRadius * math.cos(angle),
          center.dy + endRadius * math.sin(angle),
        ),
        paint,
      );
    }

    // Needle pointing to top right
    final needleAngle = math.pi * 1.25;
    canvas.drawLine(
      center,
      Offset(
        center.dx + (radius - 10) * math.cos(needleAngle),
        center.dy + (radius - 10) * math.sin(needleAngle),
      ),
      paint..strokeWidth = 2.0,
    );

    // Center dot
    canvas.drawCircle(center, 4, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FlagIconPainter extends CustomPainter {
  final Color color;

  FlagIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Flag pole
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.2),
      Offset(size.width * 0.25, size.height * 0.85),
      paint,
    );

    // Checkered flag pattern (simplified)
    final flagPath = Path();
    flagPath.moveTo(size.width * 0.25, size.height * 0.2);
    flagPath.lineTo(size.width * 0.75, size.height * 0.35);
    flagPath.lineTo(size.width * 0.75, size.height * 0.55);
    flagPath.lineTo(size.width * 0.25, size.height * 0.4);
    flagPath.close();

    canvas.drawPath(flagPath, paint);

    // Checkered pattern lines
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.275),
      Offset(size.width * 0.5, size.height * 0.475),
      paint..strokeWidth = 1.5,
    );

    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.3),
      Offset(size.width * 0.75, size.height * 0.45),
      paint..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CalendarIconPainter extends CustomPainter {
  final Color color;

  CalendarIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Calendar body
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.3,
        size.width * 0.6,
        size.height * 0.55,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, paint);

    // Top separator line
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.45),
      Offset(size.width * 0.8, size.height * 0.45),
      paint,
    );

    // Binding rings
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.2),
      Offset(size.width * 0.35, size.height * 0.35),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.2),
      Offset(size.width * 0.65, size.height * 0.35),
      paint,
    );

    // Date dots (grid pattern)
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        canvas.drawCircle(
          Offset(
            size.width * (0.35 + col * 0.15),
            size.height * (0.55 + row * 0.1),
          ),
          1.5,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class VerifiedIconPainter extends CustomPainter {
  final Color color;

  VerifiedIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Shield outline
    final shieldPath = Path();
    shieldPath.moveTo(size.width * 0.5, size.height * 0.2);
    shieldPath.lineTo(size.width * 0.75, size.height * 0.35);
    shieldPath.lineTo(size.width * 0.75, size.height * 0.6);
    shieldPath.cubicTo(
      size.width * 0.75,
      size.height * 0.72,
      size.width * 0.65,
      size.height * 0.8,
      size.width * 0.5,
      size.height * 0.85,
    );
    shieldPath.cubicTo(
      size.width * 0.35,
      size.height * 0.8,
      size.width * 0.25,
      size.height * 0.72,
      size.width * 0.25,
      size.height * 0.6,
    );
    shieldPath.lineTo(size.width * 0.25, size.height * 0.35);
    shieldPath.close();

    canvas.drawPath(shieldPath, paint);

    // Checkmark
    final checkPath = Path();
    checkPath.moveTo(size.width * 0.38, size.height * 0.52);
    checkPath.lineTo(size.width * 0.46, size.height * 0.6);
    checkPath.lineTo(size.width * 0.62, size.height * 0.43);

    canvas.drawPath(checkPath, paint..strokeWidth = 2.0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TyreIconPainter extends CustomPainter {
  final Color color;

  TyreIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.35;
    final innerRadius = size.width * 0.18;

    // Outer circle
    canvas.drawCircle(center, outerRadius, paint);

    // Inner circle
    canvas.drawCircle(center, innerRadius, paint);

    // Spokes (6 spokes)
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      canvas.drawLine(
        Offset(
          center.dx + innerRadius * math.cos(angle),
          center.dy + innerRadius * math.sin(angle),
        ),
        Offset(
          center.dx + outerRadius * math.cos(angle),
          center.dy + outerRadius * math.sin(angle),
        ),
        paint..strokeWidth = 2.0,
      );
    }

    // Center hub
    canvas.drawCircle(center, 3, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StorefrontIconPainter extends CustomPainter {
  final Color color;

  StorefrontIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Awning
    final awningPath = Path();
    awningPath.moveTo(size.width * 0.15, size.height * 0.35);
    awningPath.lineTo(size.width * 0.5, size.height * 0.25);
    awningPath.lineTo(size.width * 0.85, size.height * 0.35);
    awningPath.lineTo(size.width * 0.85, size.height * 0.45);
    awningPath.lineTo(size.width * 0.15, size.height * 0.45);
    awningPath.close();

    canvas.drawPath(awningPath, paint);

    // Awning stripes
    for (int i = 1; i < 4; i++) {
      final x = size.width * (0.15 + i * 0.175);
      canvas.drawLine(
        Offset(x, size.height * 0.35),
        Offset(x, size.height * 0.45),
        paint..strokeWidth = 1.5,
      );
    }

    // Store front
    final storePath = Path();
    storePath.moveTo(size.width * 0.15, size.height * 0.45);
    storePath.lineTo(size.width * 0.15, size.height * 0.8);
    storePath.lineTo(size.width * 0.85, size.height * 0.8);
    storePath.lineTo(size.width * 0.85, size.height * 0.45);

    canvas.drawPath(storePath, paint..strokeWidth = 2.5);

    // Door
    final doorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.42,
        size.height * 0.55,
        size.width * 0.16,
        size.height * 0.25,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(doorRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}