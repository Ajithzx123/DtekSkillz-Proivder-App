import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class DashPathBorder extends Border {
  const DashPathBorder({
    required this.dashArray, required double radius,

  }) : super();

  factory DashPathBorder.all({
    final double radius = 20,
    required CircularIntervalList<double> dashArray,
  }) {
    return DashPathBorder(
      dashArray: dashArray,
      radius: radius,
    );
  }

  final CircularIntervalList<double> dashArray;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double radius = 20,
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    if (isUniform) {
      switch (top.style) {
        case BorderStyle.none:
          return;
        case BorderStyle.solid:
          switch (shape) {
            case BoxShape.circle:
              assert(borderRadius == null, 'A borderRadius can only be given for rectangular boxes.');
              canvas.drawPath(
                dashPath(Path()..addOval(rect), dashArray: dashArray),
                top.toPaint(),
              );
              break;
            case BoxShape.rectangle:
              // if (borderRadius != null) {
              final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius)); //20
              canvas.drawPath(
                dashPath(Path()..addRRect(rrect), dashArray: dashArray),
                top.toPaint(),
              );
              return;
          }
          return;
      }
    }

    assert(borderRadius == null, 'A borderRadius can only be given for uniform borders.');
    assert(shape == BoxShape.rectangle, 'A border can only be drawn as a circle if it is uniform.');
  }
}
