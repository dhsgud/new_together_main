import 'package:flutter/material.dart';

class CustomFABLocation extends FloatingActionButtonLocation {
  final FloatingActionButtonLocation location;
  final double offsetX; // X축(가로) 오프셋
  final double offsetY; // Y축(세로) 오프셋

  const CustomFABLocation(this.location, this.offsetX, this.offsetY);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset offset = location.getOffset(scaffoldGeometry);
    return Offset(offset.dx + offsetX, offset.dy + offsetY);
  }
}
