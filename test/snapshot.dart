import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

/// Formats [value] with at most nine decimals: platform math libraries may
/// differ in the last bits, and a snapshot must not depend on them.
String fmt(double? value) {
  if (value == null) return 'null';
  if (value.isNaN || value.isInfinite) return '$value';
  if (value.abs() < 5e-10) return '0.0';
  var text = value.toStringAsFixed(9).replaceFirst(RegExp(r'0+$'), '');
  if (text.endsWith('.')) text += '0';
  return text == '-0.0' ? '0.0' : text;
}

String fmtOffset(Offset? offset) =>
    offset == null ? 'null' : '(${fmt(offset.dx)}, ${fmt(offset.dy)})';

/// Draws [path] as text, one string per row: `#` where the pixel centre is
/// inside the path, `.` where it is not.
///
/// The point tested is a little off the centre. An edge at 45° or along an
/// axis can run exactly through pixel centres, and there the answer depends on
/// the last bits of the platform's sine; the offset decides such a pixel the
/// same way everywhere, being far larger than those bits and not along any
/// such edge. An edge that still passes within [_margin] of the point fails
/// the test instead of making the snapshot depend on the platform.
List<String> rasterize(Path path, int width, int height) {
  final rows = <String>[];
  for (var y = 0; y < height; y++) {
    final row = StringBuffer();
    for (var x = 0; x < width; x++) {
      final point = Offset(x + 0.501, y + 0.503);
      final inside = path.contains(point);
      for (final shift in _shifts) {
        if (path.contains(point + shift) != inside) {
          fail('An edge passes within $_margin of pixel ($x, $y).');
        }
      }
      row.write(inside ? '#' : '.');
    }
    rows.add(row.toString());
  }
  return rows;
}

/// Skia keeps a path in single precision, so a point of a path that is a few
/// tens across is only known to about 4e-6.
const _margin = 1e-4;

const _shifts = [
  Offset(_margin, 0),
  Offset(-_margin, 0),
  Offset(0, _margin),
  Offset(0, -_margin),
];

/// Compares [actual] with the snapshot stored under [name].
///
/// A missing snapshot fails the test and prints the actual value as a map
/// entry, every line prefixed with `@@`, ready to be pasted into [snapshots].
void expectSnapshot(
  Map<String, List<String>> snapshots,
  String name,
  List<String> actual,
) {
  final expected = snapshots[name];
  if (expected == null) {
    final buffer = StringBuffer()..writeln("@@  '$name': [");
    for (final line in actual) {
      buffer.writeln("@@    '$line',");
    }
    buffer.write('@@  ],');
    // The entry is meant to be copied from the test output.
    // ignore: avoid_print
    print(buffer);
    fail('No snapshot "$name"; the actual value is printed above.');
  }
  expect(actual, expected);
}
