import 'package:flutter/material.dart';

const read = true;
const write = false;

class Point {
  final int x;
  final int y;

  const Point(this.x, this.y);
}

enum EnumColors {
  defaultColor(0, Color(0xFFD3D3D3)),
  possibleMove(1, Color(0xFFF5F5DC)),
  selectedTile(2, Color(0xFFD2B48C)),
  previousTile(3, Color(0xFFABABAB));

  const EnumColors(this.no, this.color);

  final int no;
  final Color color;

  Color getColor() => values[no].color;
}

enum GameResultStatus {
  unknown(0),
  playing(1),
  won(2),
  lost(3);

  const GameResultStatus(this.i);

  final int i;
}

