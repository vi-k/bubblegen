import 'package:bubblegen/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BubbleStyle keeps the stroke color', () {
    const green = Color(0xff00ff00);
    const blue = Color(0xff0000ff);

    expect(const BubbleStyle(strokeColor: green).strokeColor, green);
    expect(
      const BubbleStyle(strokeColor: green)
          .copyWith(strokeWidth: 2)
          .strokeColor,
      green,
    );
    expect(const BubbleStyle().copyWith(strokeColor: blue).strokeColor, blue);
    expect(const BubbleStyle().strokeColor, Colors.orange);
  });
}
