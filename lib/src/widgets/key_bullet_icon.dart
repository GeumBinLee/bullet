import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/key_definition.dart';

class KeyBulletIcon extends StatelessWidget {
  const KeyBulletIcon({super.key, required this.definition});

  final KeyDefinition definition;

  @override
  Widget build(BuildContext context) {
    final size = 24.0;
    if (definition.shape == KeyShape.custom && definition.svgData != null) {
      return SizedBox(
        width: size,
        height: size,
        child: SvgPicture.string(
          definition.svgData!,
          width: size,
          height: size,
          placeholderBuilder: (context) => Icon(
            Icons.brush,
            size: size,
            color: Colors.purple,
          ),
        ),
      );
    }

    Widget icon;
    switch (definition.shape) {
      case KeyShape.dot:
        icon = Icon(Icons.circle, size: size, color: Colors.black87);
        break;
      case KeyShape.check:
        icon = Icon(Icons.check, size: size, color: Colors.green);
        break;
      case KeyShape.triangle:
        icon = CustomPaint(
          size: Size(size, size),
          painter: _TrianglePainter(),
        );
        break;
      case KeyShape.arrow:
        icon = Icon(Icons.arrow_forward, size: size, color: Colors.orange);
        break;
      case KeyShape.memo:
        icon = Icon(Icons.remove, size: size, color: Colors.blue);
        break;
      case KeyShape.other:
        icon = Icon(Icons.star, size: size, color: Colors.purple);
        break;
      case KeyShape.custom:
        icon = Icon(Icons.brush, size: size, color: Colors.purple);
        break;
    }

    return SizedBox(width: size, height: size, child: icon);
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

