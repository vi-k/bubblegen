import 'package:bubblegen/custom_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'snapshot.dart';

String _color(Color color) =>
    // toARGB32() replaces value from Flutter 3.29; the floor is 3.27.
    // ignore: deprecated_member_use
    '0x${color.value.toRadixString(16).padLeft(8, '0')}';

/// Records every call as text; a path is named by its first appearance.
class _RecordingCanvas implements Canvas {
  final calls = <String>[];
  final paths = <Path>[];

  String _arg(Object? arg) {
    if (arg == null) return 'null';
    if (arg is double) return fmt(arg);
    if (arg is Color) return _color(arg);
    if (arg is Offset) return fmtOffset(arg);
    if (arg is Rect) {
      return 'Rect(${fmt(arg.left)}, ${fmt(arg.top)},'
          ' ${fmt(arg.right)}, ${fmt(arg.bottom)})';
    }
    if (arg is Paint) {
      return 'Paint(${arg.style}, ${_color(arg.color)},'
          ' ${fmt(arg.strokeWidth)}, ${arg.strokeJoin})';
    }
    if (arg is Path) {
      var index = paths.indexWhere((path) => identical(path, arg));
      if (index < 0) {
        index = paths.length;
        paths.add(arg);
      }
      return 'path$index';
    }
    return '$arg';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name =
        RegExp('"(.*)"').firstMatch(invocation.memberName.toString())!.group(1);
    calls.add('$name(${invocation.positionalArguments.map(_arg).join(', ')})');
    return null;
  }
}

class _RecordingContext implements PaintingContext {
  _RecordingContext(this.canvas);

  @override
  final _RecordingCanvas canvas;

  @override
  void paintChild(RenderObject child, Offset offset) {
    canvas.calls.add('paintChild(${fmtOffset(offset)})');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<RenderBubble> _pump(
  WidgetTester tester,
  Widget bubble, {
  Size? tight,
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: tight == null
            ? bubble
            : SizedBox(width: tight.width, height: tight.height, child: bubble),
      ),
    ),
  );
  return tester.renderObject<RenderBubble>(find.byType(CustomBubble));
}

List<String> _layout(RenderBubble render) {
  final lines = ['size ${fmt(render.size.width)} x ${fmt(render.size.height)}'];
  if (render.child != null) {
    lines.add('child ${fmt(render.child!.size.width)}'
        ' x ${fmt(render.child!.size.height)}');
  }
  return lines;
}

/// The calls of one paint, then each path drawn over the unscaled bubble.
List<String> _paint(RenderBubble render) {
  final canvas = _RecordingCanvas();
  render.paint(_RecordingContext(canvas), const Offset(5, 7));
  final lines = List<String>.from(canvas.calls);
  final scale = render.bubble.scale;
  for (var i = 0; i < canvas.paths.length; i++) {
    lines
      ..add('path$i:')
      ..addAll(
        rasterize(
          canvas.paths[i],
          (render.size.width / scale).ceil(),
          (render.size.height / scale).ceil(),
        ),
      );
  }
  return lines;
}

/// Draft painting makes dozens of calls: only their names, runs collapsed.
List<String> _paintNames(RenderBubble render) {
  final canvas = _RecordingCanvas();
  render.paint(_RecordingContext(canvas), Offset.zero);
  final lines = <String>[];
  String? last;
  var count = 0;
  void flush() {
    if (last != null) lines.add(count == 1 ? last : '$last x$count');
  }

  for (final call in canvas.calls) {
    final name = call.substring(0, call.indexOf('('));
    if (name == last) {
      count++;
    } else {
      flush();
      last = name;
      count = 1;
    }
  }
  flush();
  return lines;
}

const _child = SizedBox(width: 20, height: 10);

const _fancyStyle = CustomBubbleStyle(
  margin: EdgeInsets.all(2),
  // topLeft + bottomLeft exceed the box height 12: all radii are halved.
  radius: BubbleRadius(
    topLeft: 20,
    topRight: 4,
    bottomRight: 4,
    bottomLeft: 4,
  ),
  hFlip: true,
  vFlip: true,
  color: Color(0xff112233),
  elevation: 2,
  shadowColor: Color(0x80000000),
  strokeColor: Color(0xff00ff00),
  strokeWidth: 1.5,
);

void main() {
  group('layout', () {
    testWidgets('margin and scale', (tester) async {
      final render = await _pump(
        tester,
        CustomBubble(
          scale: 2,
          style: const CustomBubbleStyle(
            margin: EdgeInsets.fromLTRB(1, 2, 3, 4),
          ),
          child: _child,
        ),
      );
      expectSnapshot(_snapshots, 'margin and scale', _layout(render));
    });

    testWidgets('tight constraints', (tester) async {
      final render = await _pump(
        tester,
        CustomBubble(
          scale: 2,
          style: const CustomBubbleStyle(
            margin: EdgeInsets.fromLTRB(1, 2, 3, 4),
          ),
          child: _child,
        ),
        tight: const Size(100, 50),
      );
      expectSnapshot(_snapshots, 'tight constraints', _layout(render));
    });

    testWidgets('no child', (tester) async {
      final render = await _pump(tester, CustomBubble());
      expectSnapshot(_snapshots, 'no child', _layout(render));
    });
  });

  group('paint', () {
    testWidgets('default style', (tester) async {
      final render = await _pump(tester, CustomBubble(child: _child));
      expectSnapshot(_snapshots, 'default style', _paint(render));
    });

    testWidgets('flips, scale, stroke and oversized radii', (tester) async {
      final render = await _pump(
        tester,
        CustomBubble(
          scale: 2,
          style: _fancyStyle,
          child: const SizedBox(width: 20, height: 12),
        ),
      );
      expectSnapshot(
        _snapshots,
        'flips, scale, stroke and oversized radii',
        _paint(render),
      );
    });

    testWidgets('no child', (tester) async {
      final render = await _pump(tester, CustomBubble());
      expectSnapshot(_snapshots, 'paint without child', _paint(render));
    });

    testWidgets('draft', (tester) async {
      final render = await _pump(
        tester,
        CustomBubble(
          drawDraft: true,
          inset: const Inset(
            InsetPos(InsetPosType.topLeft, Position.zero),
            InsetPos(InsetPosType.topLeft, Position(ratio: 1)),
          ),
          child: _child,
        ),
      );
      expectSnapshot(_snapshots, 'draft', _paintNames(render));
    });
  });
}

const _snapshots = <String, List<String>>{
  'margin and scale': [
    'size 48.0 x 32.0',
    'child 20.0 x 10.0',
  ],
  'tight constraints': [
    'size 100.0 x 50.0',
    'child 46.0 x 19.0',
  ],
  'no child': [
    'size 0.0 x 0.0',
  ],
  'default style': [
    'save()',
    'translate(5.0, 7.0)',
    'scale(1.0, null)',
    'drawShadow(path0, 0xff000000, 1.0, true)',
    'drawPath(path0, Paint(PaintingStyle.fill, 0xffffffff, 0.0, StrokeJoin.miter))',
    'restore()',
    'save()',
    'translate(5.0, 7.0)',
    'scale(1.0, null)',
    'paintChild((0.0, 0.0))',
    'restore()',
    'path0:',
    '..################..',
    '.##################.',
    '####################',
    '####################',
    '####################',
    '####################',
    '####################',
    '####################',
    '.##################.',
    '..################..',
  ],
  'flips, scale, stroke and oversized radii': [
    'save()',
    'translate(5.0, 7.0)',
    'translate(48.0, 0.0)',
    'scale(-1.0, 1.0)',
    'translate(0.0, 32.0)',
    'scale(1.0, -1.0)',
    'scale(2.0, null)',
    'drawShadow(path0, 0x80000000, 4.0, true)',
    'drawPath(path0, Paint(PaintingStyle.fill, 0xff112233, 0.0, StrokeJoin.miter))',
    'drawPath(path0, Paint(PaintingStyle.stroke, 0xff00ff00, 1.5, StrokeJoin.round))',
    'restore()',
    'save()',
    'translate(9.0, 11.0)',
    'scale(2.0, null)',
    'paintChild((0.0, 0.0))',
    'restore()',
    'path0:',
    '........................',
    '........................',
    '.........############...',
    '.......###############..',
    '.....#################..',
    '....##################..',
    '....##################..',
    '...###################..',
    '...###################..',
    '..####################..',
    '..####################..',
    '..####################..',
    '..####################..',
    '...##################...',
    '........................',
    '........................',
  ],
  'paint without child': [],
  'draft': [
    'save',
    'translate',
    'scale',
    'drawPath',
    'drawShadow',
    'drawPath x5',
    'drawCircle x2',
    'restore',
    'save',
    'translate',
    'scale',
    'paintChild',
    'restore',
  ],
};
