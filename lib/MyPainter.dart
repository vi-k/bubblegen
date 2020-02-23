import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

enum NipPosType { angle, side, corner }
enum NipLineType { line, lineR, arc, isosceles, triangle, curve }

class NipPos {
  const NipPos(this.posType, this.pos);

  final NipPosType posType;
  final double pos;
}

class NipLine {
  const NipLine._internal(
    this.posType,
    this.pos, {
    this.h = 0.0,
    this.a1,
    this.a2,
    this.sz1,
    this.sz2,
  }) : assert(pos != null);

  const NipLine.line(double lineAngle) : this._internal(NipPosType.angle, lineAngle);
  const NipLine.lineTo(double sidePos) : this._internal(NipPosType.side, sidePos);
  const NipLine.lineToCorner(double cornerPos) : this._internal(NipPosType.corner, cornerPos);

  const NipLine.arc(double lineAngle, height) : this._internal(NipPosType.angle, lineAngle, h: height);
  const NipLine.arcTo(double sidePos, height) : this._internal(NipPosType.side, sidePos, h: height);
  const NipLine.arcToCorner(double cornerPos, height) : this._internal(NipPosType.corner, cornerPos, h: height);

  const NipLine.curve(double lineAngle, {angle1, angle2, size1 = 2 / 3, size2 = 2 / 3})
      : this._internal(
          NipPosType.angle,
          lineAngle,
          a1: angle1,
          a2: angle2,
          sz1: size1,
          sz2: size2,
        );

  const NipLine.curveTo(double sidePos, {angle1, angle2, size1 = 2 / 3, size2 = 2 / 3})
      : this._internal(
          NipPosType.side,
          sidePos,
          a1: angle1,
          a2: angle2,
          sz1: size1,
          sz2: size2,
        );

  const NipLine.curveToCorner(double cornerPos, {angle1, angle2, size1 = 2 / 3, size2 = 2 / 3})
      : this._internal(
          NipPosType.corner,
          cornerPos,
          a1: angle1,
          a2: angle2,
          sz1: size1,
          sz2: size2,
        );

  final NipPosType posType;
  final double pos;
  final double h; // arc's radius
  final double a1; // curve's α₁
  final double a2; // curve's α₂
  final double sz1; // curve's sz₁
  final double sz2; // curve's sz₂
}

enum DraftType { Draft, Main, Error }

class DraftLineSegment {
  DraftLineSegment(Point start, Point end, [this.type = DraftType.Draft]) : this.lineSegment = LineSegment(start, end);
  final DraftType type;
  final LineSegment lineSegment;
}

class DraftPoint {
  DraftPoint(this.point, [this.type = DraftType.Draft]);
  final DraftType type;
  final Point point;
}

class DraftInfo {
  DraftInfo();

  bool showNip = true;
  bool showTopSide = false;
  bool showLeftSide = false;
  bool showBottomSide = false;
  bool showTopCorner = false;
  bool showBottomCorner = false;

  static final Color draftColor = Colors.black26;
  static final Color mainColor = Colors.black;
  static final Color errorColor = Colors.red;

  List<DraftLineSegment> lineSegments = [];
  List<DraftPoint> points = [];

  void paint(Canvas draftCanvas, Circle nipCircle, Rect box, Circle ltCircle, Circle lbCircle, Circle rtCircle,
      Circle rbCircle) {
    var draftPath = Path();

    var paint = Paint();
    paint.strokeWidth = 1;

    paint.style = PaintingStyle.fill;
    paint.color = draftColor;

    // Малый круг
    if (showNip) {
      draftCanvas.drawCircle(nipCircle.center, nipCircle.radius, paint);
    }

    // Верхняя сторона
    if (showTopSide) {
      draftPath.reset();
      draftPath.moveTo(ltCircle.center.x, box.top);
      draftPath.lineTo(rtCircle.center.x, box.top);
      draftPath.lineTo(rtCircle.center.x, box.top + 2);
      draftPath.lineTo(ltCircle.center.x, box.top + 2);
      draftPath.close();

      draftCanvas.drawPath(draftPath, paint);
    }

    // Левая сторона
    if (showLeftSide) {
      draftPath.reset();
      draftPath.moveTo(box.left, ltCircle.center.y);
      draftPath.lineTo(box.left + 2, ltCircle.center.y);
      draftPath.lineTo(box.left + 2, lbCircle.center.y);
      draftPath.lineTo(box.left, lbCircle.center.y);
      draftPath.close();

      draftCanvas.drawPath(draftPath, paint);
    }

    // Верхний угол
    if (showTopCorner) {
      draftCanvas.drawArc(Rect.fromCenter(center: ltCircle.center, width: ltCircle.diameter, height: ltCircle.diameter),
          -pi / 2, -pi / 2, true, paint);
    }

    // Нижний угол
    if (showBottomCorner) {
      draftCanvas.drawArc(Rect.fromCenter(center: lbCircle.center, width: lbCircle.diameter, height: lbCircle.diameter),
          pi / 2, pi / 2, true, paint);
    }

    // Линии
    paint.style = PaintingStyle.stroke;
    DraftType.values.forEach((type) {
      paint.color = type == DraftType.Error ? errorColor : type == DraftType.Main ? mainColor : draftColor;

      lineSegments.forEach((item) {
        if (item.type == type) {
          draftCanvas.drawLine(item.lineSegment.start, item.lineSegment.end, paint);
        }
      });
    });

    // Точки
    paint.style = PaintingStyle.fill;
    DraftType.values.forEach((type) {
      paint.color = type == DraftType.Error ? errorColor : type == DraftType.Main ? mainColor : draftColor;

      points.forEach((item) {
        if (item.type == type) {
          draftCanvas.drawCircle(item.point, 2, paint);
        }
      });
    });
  }
}

class MyPainter extends CustomPainter {
  MyPainter({
    this.zoom = 1.0,
    @required this.topLine,
    @required this.bottomLine,
    this.boxRadius,
    this.nipWidth,
    this.nipRadius,
    this.nipYOffset,
    this.drawDraft,
  }) : //assert(pos >= -1.0 && pos <= 1.0),
        super();

  final double zoom;
  final NipLine topLine;
  final NipLine bottomLine;
  final double boxRadius;
  final double nipWidth;
  final double nipRadius;
  final double nipYOffset;
  final bool drawDraft;

  Point addLine(NipLine nipLine, bool inverse, Path path, Circle nipCircle, Rect box, Circle ltCircle, Circle lbCircle,
      Circle rtCircle, Circle rbCircle,
      [DraftInfo draft]) {
    bool ok = true;
    var top = LineSegment(null, null);

    //
    // Прямая линия под углом
    //
    if (nipLine.posType == NipPosType.angle) {
      var alpha = nipLine.pos * pi / 180; // Угол наклона линии
      var beta = inverse ? alpha + pi / 2 : alpha - pi / 2; // Точка касательной на малом круге
      top.start = nipCircle.point(beta);

      // Точка на левой стороне бокса
      top.end = Point(box.left, top.start.y + (box.left - top.start.x) * inf(tan(alpha)));

      //
      // Линия уходит к левому верхнему кругу и выше
      //
      if (top.end.y < ltCircle.center.y) {
        var processed = false;

        // Линия падает сверху на верхнюю сторону бокса
        if (top.start.y < box.top) {
          var tn = inf(tan(alpha));
          top.end = Point(top.start.x + (box.top - top.start.y) / tn, box.top);
          if (top.end.x >= ltCircle.center.x || tn < 0) {
            processed = true;

            if (top.end.x > rtCircle.center.x || tn < 0) {
              ok = false;

              top.end = Point(rtCircle.center.x, box.top);

              var c2c = LineSegment(nipCircle.center, top.end);
              alpha = c2c.direct +
                  asin((inverse ? -nipCircle.radius : nipCircle.radius) / c2c.length); // Угол наклона касательной

              beta = inverse ? alpha + pi / 2 : alpha - pi / 2;
              top.start = nipCircle.point(beta);
            }

            draft?.showTopSide = true;
          }
        }

        if (!processed) {
          draft?.showTopCorner = true;

          // Рассчитываем пересечение линии с верхним кругом. Получаем хорду
          var line = Line(top.start, alpha);
          var chord = line.intersectCircle(ltCircle);

          //
          // Линия пересекается с дугой угла
          //
          if (chord.isNotNull) {
            top.end = chord.start;

            if (draft != null) {
              var normal = line.normal(ltCircle.center);
              draft.lineSegments.add(DraftLineSegment(ltCircle.center, normal.end));
              draft.lineSegments.add(DraftLineSegment(chord.start, normal.end));
              draft.points.add(DraftPoint(normal.end));
            }
          }
          //
          // Линия выходит за верхний круг
          // В этом случае за линию берём касательную, общую для малого и нижнего кругов
          //
          else {
            ok = false;

            var c2c = LineSegment(nipCircle.center, ltCircle.center);
            alpha = c2c.direct -
                asin((inverse ? ltCircle.radius + nipCircle.radius : ltCircle.radius - nipCircle.radius) /
                    c2c.length); // Угол наклона касательной

            beta = inverse ? alpha + pi / 2 : alpha - pi / 2;
            top.start = nipCircle.point(beta);
            top.end = ltCircle.point(alpha - pi / 2);

            draft?.lineSegments?.add(DraftLineSegment(ltCircle.center, top.end));
          }

          //
          // Линия уходит за круг
          //
//          if (draftCanvas != null && top.end.x > ltCircle.center.x) {
//            draftSecondPaint.style = PaintingStyle.fill;
//            draftCanvas.drawArc(
//                Rect.fromCenter(center: ltCircle.center, width: ltCircle.diameter, height: ltCircle.diameter),
//                0,
//                -pi / 2,
//                true,
//                draftSecondPaint);
//          }
        }
      }
      //
      // Линия пересекается с ровной стороной бокса
      //
      else if (top.end.y <= lbCircle.center.y) {
        draft?.showLeftSide = true;
      }
      //
      // Линия уходит к нижнему углу и ниже
      //
      else {
        draft?.showBottomCorner = true;

        // Рассчитываем пересечение линии с нижним кругом
        var line = Line(top.start, alpha);
        var chord = line.intersectCircle(lbCircle);

        //
        // Линия пересекается с дугой угла
        //
        if (!chord.isNull) {
          top.end = chord.start;

          if (draft != null) {
            var normal = line.normal(lbCircle.center);
            draft.lineSegments.add(DraftLineSegment(lbCircle.center, normal.end));
            draft.lineSegments.add(DraftLineSegment(chord.start, normal.end));
            draft.points.add(DraftPoint(normal.end));
          }
        }
        //
        // Линия выходит за нижний круг
        // В этом случае за линию берём касательную, общую для малого и нижнего кругов
        //
        else {
          ok = false;

          var c2c = LineSegment(nipCircle.center, lbCircle.center);
          alpha = c2c.direct +
              asin((inverse ? lbCircle.radius - nipCircle.radius : lbCircle.radius + nipCircle.radius) /
                  c2c.length); // Угол наклона касательной

          top.start = nipCircle.point(inverse ? alpha + pi / 2 : alpha - pi / 2);
          top.end = lbCircle.point(alpha + pi / 2);

          draft?.lineSegments?.add(DraftLineSegment(lbCircle.center, top.end));
        }

        //
        // Линия уходит за круг
        //
//        if (draftCanvas != null && top.end.x > lbCircle.center.x) {
//          draftSecondPaint.style = PaintingStyle.fill;
//          draftCanvas.drawArc(
//              Rect.fromCenter(center: lbCircle.center, width: lbCircle.diameter, height: lbCircle.diameter),
//              0,
//              pi / 2,
//              true,
//              draftSecondPaint);
//        }
      }
    }
    //
    // Прямая линия к левой стороне бокса
    //
    else if (nipLine.posType == NipPosType.side) {
      top.end = Point(box.left, nipYOffset + nipLine.pos);

      //
      // Линия уходит к верхнему углу
      //
      if (top.end.y < ltCircle.center.y) {
        if (top.end.y < ltCircle.center.y - ltCircle.radius) {
          top.end = Point(ltCircle.center.x, ltCircle.center.y - ltCircle.radius);
        } else {
          top.end = ltCircle.point(asin((ltCircle.center.y - top.end.y) / ltCircle.radius) - pi);
        }

        if (draft != null) {
          draft.showTopCorner = true;
          draft.lineSegments.add(DraftLineSegment(top.end, Point(ltCircle.center.x, top.end.y)));
        }
      }
      //
      // Линия пересекается с ровной стороной бокса
      //
      else if (top.end.y <= lbCircle.center.y) {
        draft?.showLeftSide = true;
      }
      //
      // Линия уходит к нижнему углу
      //
      else {
        if (top.end.y > lbCircle.center.y + lbCircle.radius) {
          top.end = Point(lbCircle.center.x, lbCircle.center.y + lbCircle.radius);
        } else {
          top.end = lbCircle.point(asin((lbCircle.center.y - top.end.y) / lbCircle.radius) - pi);
        }

        if (draft != null) {
          draft.showBottomCorner = true;
          draft.lineSegments.add(DraftLineSegment(top.end, Point(lbCircle.center.x, top.end.y)));
        }
      }

      var l = sqrt(pow(top.end.x - nipCircle.center.x, 2) + pow(top.end.y - nipCircle.center.y, 2));
      var a1 = asin((top.end.y - nipCircle.center.y) / l);
      var a2 = -atan2(l, nipRadius);

      top.start = nipCircle.point(a1 + a2);
    }
    //
    // Прямая линия к углам бокса
    //
    else if (nipLine.posType == NipPosType.corner) {
      // Отрицательные значения - верхний круг, положительные - нижний
      var a = nipLine.pos * pi / 180;
      top.end = nipLine.pos <= 0 ? ltCircle.point(a) : lbCircle.point(a);

      var l = sqrt(pow(top.end.x - nipCircle.center.x, 2) + pow(top.end.y - nipCircle.center.y, 2));
      var a1 = asin((top.end.y - nipCircle.center.y) / l);
      var a2 = -atan2(l, nipRadius);

      top.start = nipCircle.point(a1 + a2);

      if (draft != null) {
        // Четверть верхнего круга
        if (nipLine.pos <= 0) {
          draft.showTopCorner = true;
          draft.lineSegments.add(DraftLineSegment(ltCircle.center, top.end));
        }
        // Четверть нижнего круга
        else {
          draft.showBottomCorner = true;
          draft.lineSegments.add(DraftLineSegment(lbCircle.center, top.end));
        }
      }
    }

    // Малый круг
    if (draft != null) {
      draft.showNip = true;
      draft.lineSegments.add(DraftLineSegment(nipCircle.center, top.start));
      if (inverse) draft.points.add(DraftPoint(nipCircle.center));

      // Линия
      var type = ok ? DraftType.Main : DraftType.Error;
      draft.lineSegments.add(DraftLineSegment(top.end, top.start, type));
      draft.points.add(DraftPoint(top.start, type));
      draft.points.add(DraftPoint(top.end, type));
    }

    if (inverse) {
      path.lineTo(top.end.x, top.end.y);
      path.lineTo(top.start.x, top.start.y);
    } else {
      path.moveTo(top.start.x, top.start.y);
      path.lineTo(top.end.x, top.end.y);
    }

    return top.start;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final offsetY = nipYOffset < 0 ? nipYOffset : 0.0;

    size = Size(size.width / 4, size.height);
    final boxCircle1R = boxRadius > size.height / 2 ? size.height / 2 : boxRadius;

    var paint = Paint();
    var path = Path();

//    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));
    canvas.translate(0, -offsetY);

    paint.color = Colors.lightGreen;
    canvas.drawRRect(
        RRect.fromLTRBR(this.zoom * this.nipWidth, 0, this.zoom * size.width, this.zoom * size.height + offsetY,
            Radius.circular(this.zoom * boxCircle1R)),
        paint);

    final box = Rect.fromLTRB(nipWidth, 0, size.width, size.height + offsetY);
    final nipCircle = Circle(Point(nipRadius, nipYOffset + nipRadius), nipRadius);

    var r = boxRadius > size.height / 2 ? size.height / 2 : boxRadius;
    final ltCircle = Circle(Point(box.left + r, r), r);
    final lbCircle = Circle(Point(box.left + r, box.bottom - r), r);
    final rtCircle = Circle(Point(box.right - r, r), r);
    final rbCircle = Circle(Point(box.right - r, box.bottom - r), r);

    DraftInfo draft = this.drawDraft ? DraftInfo() : null;
    path.reset();
    addLine(topLine, false, path, nipCircle, box, ltCircle, lbCircle, rtCircle, rbCircle, draft);
    addLine(bottomLine, true, path, nipCircle, box, ltCircle, lbCircle, rtCircle, rbCircle, draft);
    path.close();
    path.addOval(Rect.fromCenter(center: nipCircle.center, width: nipCircle.diameter, height: nipCircle.diameter));

    canvas.drawPath(path, paint);
    if (draft != null) draft.paint(canvas, nipCircle, box, ltCircle, lbCircle, rtCircle, rbCircle);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// Отрезок
///
/// Конструируется либо через две точки:
///   LineSegment(Offset(0, 0), Offset(100, 0))
/// Либо по направлению и длине:
///   LineSegment.direct(Offset(0, 0), pi/4, 100)
///
/// При запросе не заданных параметров они вычисляются и сохраняются в переменных.
class LineSegment {
  LineSegment(this._start, this._end);
  LineSegment.direct(this._start, this._direct, this._length)
      : assert(_direct != null),
        assert(_length != null);

  Point _start;
  Point _end;
  double _length;
  double _direct;

  Point get start => _start;

  set start(value) {
    // При установке новой начальной точки сохраняем конечную точку и сбрасываем направление и размер
    _start = value;
    _end = end;
    _direct = null;
    _length = null;
  }

  Point get end {
    if (_end == null && _direct != null)
      _end = Point(start.x + _length * cos(_direct), start.y + _length * sin(_direct));
    return _end;
  }

  set end(value) {
    _end = value;
    _length = null;
    _direct = null;
  }

  double get length {
    if (_length == null) _length = sqrt(pow(_end.x - start.x, 2) + pow(_end.y - start.y, 2));
    return _length;
  }

  double get direct {
    if (_direct == null) _direct = atan2(_end.y - start.y, _end.x - start.x);
    return _direct;
  }

  bool get isNull => _start == null;
  bool get isNotNull => _start != null;
}

/// Линия
class Line {
  const Line(this.start, this.direct);
  //Line.toPoint(this.start, Offset end) : direct = atan2(1,2);

  final Point start;
  final double direct;

  /// Точка на линии
  Point point(double distance) {
    return Point(start.x + distance * cos(direct), start.y + distance * sin(direct));
  }

  /// Точка на линии
  Point pointByX(double x) {
    var tn = inf(tan(direct));
    return Point(x, start.y + (x - start.x) * tn);
  }

  /// Точка на линии
  Point pointByY(double y) {
    var tn = inf(tan(direct));
    return Point(start.x + (y - start.y) / tn, y);
  }

  /// Вычисляет нормаль к линии из точки
  LineSegment normal(Point point) {
    double distance;
    double angle;

    var tn = inf(tan(direct));
    if (tn == 0.0) {
      distance = start.y - point.y;
      angle = pi / 2;
    } else {
      // Вспомогательный треугольник, гипотенуза которого находится на одной горизонтали с точкой
      var x = start.x + (point.y - start.y) / tn;
      distance = sin(direct) * (point.x - x); // Дальний катет треугольника - искомое расстояние
      angle = direct + pi / 2;
    }

    if (distance < 0) {
      distance = -distance;
      angle -= pi;
    }

    return LineSegment.direct(point, angle, distance);
  }

  /// Вычисляет пересечение линии с окружностью
  LineSegment intersectCircle(Circle circle) {
    var normal = this.normal(circle.center);

    // Линия не пересекается с окружностью
    if (normal.length > circle.radius) return LineSegment(null, null);

    var halfChord = sqrt(circle.radius * circle.radius - normal.length * normal.length); // Половина хорды
    var dx = cos(direct) * halfChord;
    var dy = sin(direct) * halfChord;
    var start = Point(normal.end.x - dx, normal.end.y - dy);
    var end = Point(normal.end.x + dx, normal.end.y + dy);

    return LineSegment(start, end);
  }

  /// Вычисляет пересечение линии с другой линией
  Point intersectLine(Line other) {
    final thisTn = inf(tan(this.direct));
    if (thisTn == 0.0) return other.pointByY(this.start.y);
    if (thisTn.isInfinite) return other.pointByX(this.start.x);

    final otherTn = inf(tan(other.direct));

    final mX = this.start.x + (other.start.y - this.start.y) / thisTn;
//    if (mX == this.start.x) return Point(mX, other.start.y + (mX - other.start.x) * otherTn);
    final x = other.start.x - (other.start.x - mX) * thisTn / (thisTn - otherTn);
    final r = (x - this.start.x) / cos(this.direct);
    final y = this.start.y + sin(this.direct) * r;

    return Point(x, y);
  }

  /// Вычисляет пересечение линии с окружностью
  Point intersectLineSegment(LineSegment lineSegment) {
    double x;
    double y;

    return Point(x, y);
  }
}

class Circle {
  const Circle(this.center, this.radius);

  final Point center;
  final double radius;

  double get diameter => 2 * radius;

  /// Точка на окружности: point(alpha)
  /// Точка на расстоянии от центра окружности: point(alpha, distance)
  Point point(double alpha, [double distance]) {
    if (distance == null) distance = radius;
    return Point(center.x + distance * cos(alpha), center.y + distance * sin(alpha));
  }
}

/// Большие числа превращает в infinity/-infinity
double inf(double value) {
  final double max = 1e15;
  if (value > max) return double.infinity;
  if (value < -max) return double.negativeInfinity;
  return value;
}

class Point extends Offset {
  const Point(double x, double y) : super(x, y);

  double get x => dx;
  double get y => dy;

  @override
  String toString() => "Point($dx, $dy)";
}
