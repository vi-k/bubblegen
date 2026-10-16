import 'dart:math' as math;

import 'package:bubblegen/geometry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'snapshot.dart';

String _segment(LineSegment? segment) => segment == null
    ? 'null'
    : '${fmtOffset(segment.start)} -> ${fmtOffset(segment.end)}'
        ' length ${fmt(segment.length)} direct ${fmt(segment.direct)}';

void main() {
  test('inf', () {
    expectSnapshot(_snapshots, 'inf', [
      fmt(inf(5)),
      fmt(inf(10000000000000000)),
      fmt(inf(-10000000000000000)),
    ]);
  });

  test('Line', () {
    const line = Line(Point(1, 2), math.pi / 6);
    const horizontal = Line(Point(0, 3), 0);
    expectSnapshot(_snapshots, 'Line', [
      'tan ${fmt(line.tan())}',
      'point ${fmtOffset(line.point(10))}',
      'pointByX ${fmtOffset(line.pointByX(5))}',
      'pointByY ${fmtOffset(line.pointByY(5))}',
      'normal ${_segment(line.normal(const Point(5, 0)))}',
      'normal of horizontal ${_segment(horizontal.normal(const Point(4, 7)))}',
      'intersectCircle ${_segment(const Line(Point(0, 0), 0.3).intersectCircle(const Circle(Point(5, 3), 2.5)))}',
      'intersectCircle miss ${_segment(const Line(Point(0, 0), 0.3).intersectCircle(const Circle(Point(5, 9), 2.5)))}',
      'intersectLine ${fmtOffset(line.intersectLine(const Line(Point(10, 0), 2 * math.pi / 3)))}',
      'intersectLine horizontal ${fmtOffset(horizontal.intersectLine(line))}',
      'intersectLineSegment ${fmtOffset(line.intersectLineSegment(LineSegment(const Point(4, 0), const Point(4, 8))))}',
      'intersectLineSegment miss ${fmtOffset(line.intersectLineSegment(LineSegment(const Point(4, 0), const Point(4, 2))))}',
    ]);
  });

  test('LineSegment', () {
    expectSnapshot(_snapshots, 'LineSegment', [
      'by points ${_segment(LineSegment(const Point(0, 0), const Point(3, 4)))}',
      'direct ${_segment(LineSegment.direct(const Point(1, 1), math.pi / 3, 4))}',
    ]);
  });

  test('Circle', () {
    const circle = Circle(Point(5, 5), 2);
    const other = Circle(Point(15, 5), 1);
    final lines = [
      'diameter ${fmt(circle.diameter)}',
      'point ${fmtOffset(circle.point(math.pi / 4))}',
      'point at 3 ${fmtOffset(circle.point(math.pi / 4, 3))}',
    ];
    for (final first in [-1.0, 1.0]) {
      for (final second in [-1.0, 1.0]) {
        lines.add('tangentToCircle ${fmt(first)} ${fmt(second)}'
            ' ${_segment(circle.tangentToCircle(other, first, second))}');
      }
    }
    for (final side in [-1.0, 1.0]) {
      lines.add('tangentToPoint ${fmt(side)}'
          ' ${_segment(circle.tangentToPoint(const Point(12, 9), side))}');
    }
    lines.add('tangentToPoint inside'
        ' ${_segment(circle.tangentToPoint(const Point(5.5, 5.5), 1))}');
    expectSnapshot(_snapshots, 'Circle', lines);
  });
}

const _snapshots = <String, List<String>>{
  'inf': [
    '5.0',
    'Infinity',
    '-Infinity',
  ],
  'Line': [
    'tan 0.577350269',
    'point (9.660254038, 7.0)',
    'pointByX (5.0, 4.309401077)',
    'pointByY (6.196152423, 5.0)',
    'normal (5.0, 0.0) -> (3.133974596, 3.232050808) length 3.732050808 direct 2.094395102',
    'normal of horizontal (4.0, 7.0) -> (4.0, 3.0) length 4.0 direct -1.570796327',
    'intersectCircle (3.424139571, 1.059210493) -> (7.396465923, 2.287995029) length 4.158038971 direct 0.3',
    'intersectCircle miss null',
    'intersectLine (6.883974596, 5.397114317)',
    'intersectLine horizontal (2.732050808, 3.0)',
    'intersectLineSegment (4.0, 3.732050808)',
    'intersectLineSegment miss null',
  ],
  'LineSegment': [
    'by points (0.0, 0.0) -> (3.0, 4.0) length 5.0 direct 0.927295218',
    'direct (1.0, 1.0) -> (3.0, 4.464101615) length 4.0 direct 1.047197551',
  ],
  'Circle': [
    'diameter 4.0',
    'point (6.414213562, 6.414213562)',
    'point at 3 (7.121320344, 7.121320344)',
    'tangentToCircle -1.0 -1.0 (4.8, 3.010025126) -> (14.9, 4.005012563) length 10.148891565 direct 0.098196761',
    'tangentToCircle -1.0 1.0 (5.6, 3.092121597) -> (14.7, 5.953939201) length 9.539392014 direct 0.304692654',
    'tangentToCircle 1.0 -1.0 (5.6, 6.907878403) -> (14.7, 4.046060799) length 9.539392014 direct -0.304692654',
    'tangentToCircle 1.0 1.0 (4.8, 6.989974874) -> (14.9, 5.994987437) length 10.148891565 direct -0.098196761',
    'tangentToPoint -1.0 (6.392030729, 3.563946224) -> (12.0, 9.0) length 7.810249676 direct 0.769833037',
    'tangentToPoint 1.0 (4.469507732, 6.928361469) -> (12.0, 9.0) length 7.810249676 direct 0.268459191',
    'tangentToPoint inside null',
  ],
};
