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
List<String> rasterize(Path path, int width, int height) {
  final rows = <String>[];
  for (var y = 0; y < height; y++) {
    final row = StringBuffer();
    for (var x = 0; x < width; x++) {
      row.write(path.contains(Offset(x + 0.5, y + 0.5)) ? '#' : '.');
    }
    rows.add(row.toString());
  }
  return rows;
}

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
    print(buffer);
    fail('No snapshot "$name"; the actual value is printed above.');
  }
  expect(actual, expected);
}
