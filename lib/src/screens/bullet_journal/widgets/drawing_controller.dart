import 'package:flutter/material.dart';

class DrawingController {
  final List<List<Offset>> paths = [];

  void addPoint(Offset point) {
    if (paths.isEmpty) {
      paths.add([point]);
    } else {
      paths.last.add(point);
    }
  }

  void endStroke() {
    if (paths.isNotEmpty && paths.last.isNotEmpty) {
      paths.add([]);
    }
  }

  void clear() {
    paths.clear();
  }

  String toSvg() {
    if (paths.isEmpty) {
      return '<svg width="24" height="24" xmlns="http://www.w3.org/2000/svg"></svg>';
    }

    const sourceSize = 200.0;
    const targetSize = 24.0;
    const scale = targetSize / sourceSize;

    final buffer = StringBuffer(
      '<svg width="24" height="24" xmlns="http://www.w3.org/2000/svg">',
    );
    for (final path in paths) {
      if (path.length < 2) continue;
      buffer.write('<path d="M');
      for (var i = 0; i < path.length; i++) {
        if (i > 0) buffer.write(' L');
        final scaledX = (path[i].dx * scale).toStringAsFixed(2);
        final scaledY = (path[i].dy * scale).toStringAsFixed(2);
        buffer.write('$scaledX,$scaledY');
      }
      buffer.write(
        '" stroke="black" stroke-width="1.5" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
      );
    }
    buffer.write('</svg>');
    return buffer.toString();
  }
}

