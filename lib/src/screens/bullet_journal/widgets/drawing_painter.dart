import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  DrawingPainter(this.paths);

  final List<List<Offset>> paths;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final path in paths) {
      if (path.length < 2) continue;
      final drawingPath = Path()..moveTo(path[0].dx, path[0].dy);
      for (var i = 1; i < path.length; i++) {
        drawingPath.lineTo(path[i].dx, path[i].dy);
      }
      canvas.drawPath(drawingPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

