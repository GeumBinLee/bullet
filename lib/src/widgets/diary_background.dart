import 'package:flutter/material.dart';
import '../models/diary.dart';

class DiaryBackground extends StatelessWidget {
  const DiaryBackground({
    super.key,
    required this.theme,
    required this.child,
  });

  final DiaryBackgroundTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    switch (theme) {
      case DiaryBackgroundTheme.grid:
        return _GridBackground(child: child);
      case DiaryBackgroundTheme.lined:
        return _LinedBackground(child: child);
      case DiaryBackgroundTheme.plain:
        return child;
    }
  }
}

class _GridBackground extends StatelessWidget {
  const _GridBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPaperPainter(),
      child: child,
    );
  }
}

class _GridPaperPainter extends CustomPainter {
  static const double _gridSize = 20.0;
  static const Color _gridColor = Color(0xFFE8E8E8);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _gridColor
      ..strokeWidth = 0.5;

    // 수평선
    for (double y = 0; y < size.height; y += _gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // 수직선
    for (double x = 0; x < size.width; x += _gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LinedBackground extends StatelessWidget {
  const _LinedBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinedPaperPainter(),
      child: child,
    );
  }
}

class _LinedPaperPainter extends CustomPainter {
  static const double _lineHeight = 24.0;
  static const double _margin = 16.0;
  static const Color _lineColor = Color(0xFFE0E0E0);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _lineColor
      ..strokeWidth = 1.0;

    final startX = _margin;
    final endX = size.width - _margin;
    
    // 수평선 그리기
    for (double y = _lineHeight; y < size.height; y += _lineHeight) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        paint,
      );
    }
    
    // 왼쪽 여백선 (빨간선)
    final marginPaint = Paint()
      ..color = const Color(0xFFFF6B6B)
      ..strokeWidth = 1.0;
    
    canvas.drawLine(
      Offset(_margin - 8, 0),
      Offset(_margin - 8, size.height),
      marginPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

