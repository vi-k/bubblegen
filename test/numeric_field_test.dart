import 'package:bubblegen/numeric_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Taps the button labelled [label] once on a fresh field holding [value]
/// and returns what the field reports.
Future<double?> _tap(
  WidgetTester tester,
  String label, {
  required double value,
  required double step,
  required int fractionDigits,
}) async {
  double? reported;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: NumericField(
          key: UniqueKey(),
          caption: 'field:',
          value: value,
          step: step,
          fractionDigits: fractionDigits,
          onChanged: (value) => reported = value,
        ),
      ),
    ),
  );
  await tester.tap(find.text(label));
  await tester.pump();
  return reported;
}

void main() {
  group('The buttons', () {
    testWidgets('step from -0.4 by one tenth', (tester) async {
      expect(
        await _tap(tester, '+', value: -0.4, step: 0.1, fractionDigits: 1),
        -0.3,
      );
      expect(
        await _tap(tester, '–', value: -0.4, step: 0.1, fractionDigits: 1),
        -0.5,
      );
    });

    // 0.57 * 100 == 56.99999999999999 and -2.22 * 100 == -222.00000000000003:
    // flooring the product takes either value for one below its own grid line.
    testWidgets('step from a value whose product with 100 is inexact',
        (tester) async {
      expect(
        await _tap(tester, '+', value: 0.57, step: 0.1, fractionDigits: 2),
        0.67,
      );
      expect(
        await _tap(tester, '–', value: 0.57, step: 0.1, fractionDigits: 2),
        0.47,
      );
      expect(
        await _tap(tester, '+', value: -2.22, step: 0.1, fractionDigits: 2),
        -2.12,
      );
      expect(
        await _tap(tester, '–', value: -2.22, step: 0.1, fractionDigits: 2),
        -2.32,
      );
    });

    testWidgets('align a value off the grid before stepping', (tester) async {
      expect(
        await _tap(tester, '+', value: 0.578, step: 0.1, fractionDigits: 2),
        0.67,
      );
      expect(
        await _tap(tester, '–', value: 0.578, step: 0.1, fractionDigits: 2),
        0.57,
      );
    });
  });
}
