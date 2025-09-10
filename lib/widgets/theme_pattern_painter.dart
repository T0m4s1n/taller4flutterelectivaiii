import 'dart:math';
import 'package:flutter/material.dart';

class ThemePatternPainter extends CustomPainter {
  final String patternType;
  final double animationValue;
  final List<Color> colors;

  ThemePatternPainter({
    required this.patternType,
    required this.animationValue,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (patternType) {
      case 'waves':
        _paintWaves(canvas, size);
        break;
      case 'ripples':
        _paintRipples(canvas, size);
        break;
      case 'leaves':
        _paintLeaves(canvas, size);
        break;
      case 'stars':
        _paintStars(canvas, size);
        break;
      case 'hearts':
        _paintHearts(canvas, size);
        break;
      case 'bubbles':
        _paintBubbles(canvas, size);
        break;
      case 'nature':
        _paintNature(canvas, size);
        break;
      case 'flames':
        _paintFlames(canvas, size);
        break;
      case 'constellation':
        _paintConstellation(canvas, size);
        break;
      case 'northern_lights':
        _paintNorthernLights(canvas, size);
        break;
      case 'cosmic':
        _paintCosmic(canvas, size);
        break;
      default:
        _paintStatic(canvas, size);
    }
  }

  void _paintWaves(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors[0].withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 30.0;
    final waveLength = size.width / 3;

    path.moveTo(0, size.height * 0.7);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.7 +
          waveHeight * 
          sin(animationValue * 2 * pi + x / waveLength) *
          (1 + 0.5 * sin(animationValue * 4 * pi + x / waveLength));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _paintRipples(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors[1].withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2;

    for (int i = 0; i < 5; i++) {
      final radius = (maxRadius * (animationValue + i * 0.2)) % maxRadius;
      final opacity = (1 - (radius / maxRadius)) * 0.6;
      
      paint.color = colors[i % colors.length].withOpacity(opacity);
      canvas.drawCircle(center, radius, paint);
    }
  }

  void _paintLeaves(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors[0].withOpacity(0.4)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = (size.width * (i / 20.0) + animationValue * 50) % size.width;
      final y = size.height * 0.3 + sin(animationValue * 2 * pi + i) * 20;
      final leafSize = 15.0 + sin(animationValue * 3 * pi + i) * 5;
      
      _drawLeaf(canvas, Offset(x, y), leafSize, paint);
    }
  }

  void _drawLeaf(Canvas canvas, Offset center, double leafSize, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - leafSize);
    path.quadraticBezierTo(
      center.dx + leafSize, center.dy - leafSize / 2,
      center.dx, center.dy + leafSize,
    );
    path.quadraticBezierTo(
      center.dx - leafSize, center.dy - leafSize / 2,
      center.dx, center.dy - leafSize,
    );
    canvas.drawPath(path, paint);
  }

  void _paintStars(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors[2].withOpacity(0.8)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final x = (size.width * (i / 50.0) + animationValue * 20) % size.width;
      final y = size.height * (i / 50.0) + sin(animationValue * 2 * pi + i) * 30;
      final twinkle = sin(animationValue * 4 * pi + i) * 0.5 + 0.5;
      
      paint.color = colors[i % colors.length].withOpacity(0.3 + twinkle * 0.4);
      _drawStar(canvas, Offset(x, y), 3.0 + twinkle * 2, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double starSize, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) + animationValue * pi;
      final x = center.dx + cos(angle) * starSize;
      final y = center.dy + sin(angle) * starSize;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _paintHearts(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors[0].withOpacity(0.4)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = (size.width * (i / 15.0) + animationValue * 30) % size.width;
      final y = size.height * 0.2 + sin(animationValue * 2 * pi + i) * 40;
      final heartSize = 12.0 + sin(animationValue * 3 * pi + i) * 3;
      
      _drawHeart(canvas, Offset(x, y), heartSize, paint);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double heartSize, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + heartSize / 4);
    path.cubicTo(
      center.dx - heartSize / 2, center.dy - heartSize / 4,
      center.dx - heartSize / 2, center.dy + heartSize / 4,
      center.dx, center.dy + heartSize,
    );
    path.cubicTo(
      center.dx + heartSize / 2, center.dy + heartSize / 4,
      center.dx + heartSize / 2, center.dy - heartSize / 4,
      center.dx, center.dy + heartSize / 4,
    );
    canvas.drawPath(path, paint);
  }

  void _paintBubbles(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors[1].withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 25; i++) {
      final x = (size.width * (i / 25.0) + animationValue * 40) % size.width;
      final y = size.height - (animationValue * 100 + i * 20) % size.height;
      final radius = 5.0 + sin(animationValue * 2 * pi + i) * 3;
      
      paint.color = colors[i % colors.length].withOpacity(0.2 + sin(animationValue * 3 * pi + i) * 0.2);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _paintNature(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors[0].withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Draw grass-like patterns
    for (int i = 0; i < 30; i++) {
      final x = size.width * (i / 30.0);
      final height = 20.0 + sin(animationValue * 2 * pi + i) * 10;
      
      paint.color = colors[i % colors.length].withOpacity(0.3);
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x, size.height - height),
        paint..strokeWidth = 2,
      );
    }
  }

  void _paintFlames(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors[0].withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final x = size.width * (i / 8.0) + sin(animationValue * 2 * pi + i) * 10;
      final height = 60.0 + sin(animationValue * 3 * pi + i) * 20;
      
      paint.color = colors[i % colors.length].withOpacity(0.4 + sin(animationValue * 4 * pi + i) * 0.3);
      _drawFlame(canvas, Offset(x, size.height - height), height, paint);
    }
  }

  void _drawFlame(Canvas canvas, Offset base, double height, Paint paint) {
    final path = Path();
    path.moveTo(base.dx - 5, base.dy);
    path.quadraticBezierTo(
      base.dx - 3, base.dy - height / 3,
      base.dx, base.dy - height,
    );
    path.quadraticBezierTo(
      base.dx + 3, base.dy - height / 3,
      base.dx + 5, base.dy,
    );
    canvas.drawPath(path, paint);
  }

  void _paintConstellation(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors[2].withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Draw stars
    for (int i = 0; i < 30; i++) {
      final x = size.width * (i / 30.0);
      final y = size.height * (i / 30.0);
      final twinkle = sin(animationValue * 4 * pi + i) * 0.5 + 0.5;
      
      paint.color = colors[i % colors.length].withOpacity(0.4 + twinkle * 0.4);
      canvas.drawCircle(Offset(x, y), 1.0 + twinkle, paint);
    }

    // Draw constellation lines
    paint.color = colors[1].withOpacity(0.3);
    paint.strokeWidth = 1;
    for (int i = 0; i < 10; i++) {
      final startX = size.width * (i / 10.0);
      final startY = size.height * (i / 10.0);
      final endX = size.width * ((i + 1) / 10.0);
      final endY = size.height * ((i + 1) / 10.0);
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  void _paintNorthernLights(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors[0].withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.3);

    for (double x = 0; x <= size.width; x += 2) {
      final y = size.height * 0.3 +
          sin(animationValue * 2 * pi + x / 50) * 40 +
          sin(animationValue * 3 * pi + x / 30) * 20;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Create gradient effect
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        colors[0].withOpacity(0.8),
        colors[1].withOpacity(0.4),
        colors[2].withOpacity(0.2),
      ],
    );
    
    paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
  }

  void _paintCosmic(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors[0].withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Draw planets
    for (int i = 0; i < 5; i++) {
      final x = size.width * (i / 5.0) + sin(animationValue * 2 * pi + i) * 20;
      final y = size.height * 0.3 + cos(animationValue * 2 * pi + i) * 30;
      final radius = 15.0 + sin(animationValue * 3 * pi + i) * 5;
      
      paint.color = colors[i % colors.length].withOpacity(0.4);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw stars
    for (int i = 0; i < 100; i++) {
      final x = size.width * (i / 100.0);
      final y = size.height * (i / 100.0);
      final twinkle = sin(animationValue * 6 * pi + i) * 0.5 + 0.5;
      
      paint.color = colors[2].withOpacity(0.3 + twinkle * 0.4);
      canvas.drawCircle(Offset(x, y), 0.5 + twinkle, paint);
    }
  }

  void _paintStatic(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors[0].withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
