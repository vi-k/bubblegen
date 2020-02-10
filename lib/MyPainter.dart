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

class MyPainter extends CustomPainter {
  MyPainter({
    this.zoom = 1.0,
    @required this.topLine,
    @required this.bottomLine,
    this.boxRadius,
    this.nipWidth,
    this.nipRadius,
    this.nipYOffset,
    this.startTopAngle,
    this.finishTopPos,
    this.finishTopAngle,
    this.startBottomAngle,
    this.finishBottomPos,
    this.finishBottomAngle,
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
  final double startTopAngle;
  final double finishTopPos;
  final double finishTopAngle;
  final double startBottomAngle;
  @override
  void paint(Canvas canvas, Size size) {
    final offsetY = nipYOffset < 0 ? nipYOffset : 0.0;

    final boxCircle1R = boxRadius > size.height / 2 ? size.height / 2 : boxRadius;
    final boxCircle1X = nipWidth + boxCircle1R;
    final boxCircle1Y = boxCircle1R;

    var paint = Paint();
    var path = Path();

    var paintDraftMain = Paint();
    paintDraftMain.strokeWidth = 1;
    paintDraftMain.style = PaintingStyle.stroke;
    paintDraftMain.color = Colors.black;

    var paintDraftSecond = Paint();
    paintDraftSecond.strokeWidth = 1;
    paintDraftSecond.style = PaintingStyle.stroke;
    paintDraftSecond.color = Colors.black26;

    var paintDraftError = Paint();
    paintDraftError.strokeWidth = 1;
    paintDraftError.style = PaintingStyle.stroke;
    paintDraftError.color = Colors.red;

//    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));
    canvas.translate(0, -offsetY);

    paint.color = Colors.lightGreen;
    canvas.drawRRect(
        RRect.fromLTRBR(this.zoom * this.nipWidth, 0, this.zoom * size.width, this.zoom * size.height + offsetY,
            Radius.circular(this.zoom * boxCircle1R)),
        paint);

    canvas.drawCircle(
        Offset(this.zoom * this.nipRadius, this.zoom * (this.nipYOffset + this.nipRadius)), zoom * nipRadius, paint);

    final startTopAngle = this.startTopAngle * pi / 180;
    final startTopX = this.zoom * this.nipRadius * (1 - sin(startTopAngle));
    final startTopY = this.zoom * (this.nipYOffset + this.nipRadius * (1 - cos(startTopAngle)));

    double finishTopX;
    double finishTopY;
    if (this.finishTopPos < 0) {
      final finishTopPos = -this.finishTopPos * pi / 180;
      finishTopX = boxCircle1X - this.zoom * boxCircle1R * sin(finishTopPos);
      finishTopY = boxCircle1Y - this.zoom * boxCircle1R * cos(finishTopPos);
    } else {
      var pos = this.finishTopPos + this.nipYOffset;
      if (pos < 0) pos = 0;
      finishTopX = pos < boxCircle1R
          ? boxCircle1X - this.zoom * boxCircle1R * sin(acos(1 - pos / boxCircle1R))
          : this.zoom * this.nipWidth;
      finishTopY = this.zoom * pos;
    }
    final finishTopAngle = this.finishTopAngle * pi / 180;

    final topDirectSize = sqrt(pow(finishTopX - startTopX, 2) + pow(finishTopY - startTopY, 2)) / 3;
    final startTopDirectX = startTopX + topDirectSize * cos(startTopAngle);
    final startTopDirectY = startTopY - topDirectSize * sin(startTopAngle);
    final finishTopDirectX = finishTopX + topDirectSize * cos(finishTopAngle);
    final finishTopDirectY = finishTopY - topDirectSize * sin(finishTopAngle);

    final startBottomAngle = this.startBottomAngle * pi / 180;
    final startBottomX = this.zoom * this.nipRadius * (1 + sin(startBottomAngle));
    final startBottomY = this.zoom * (this.nipYOffset + this.nipRadius * (1 + cos(startBottomAngle)));

    double finishBottomX;
    double finishBottomY;
    if (this.finishBottomPos < 0) {
      final finishBottomPos = -this.finishBottomPos * pi / 180;
      finishBottomX = boxCircle1X - this.zoom * boxCircle1R * sin(finishBottomPos);
      finishBottomY = boxCircle1Y - this.zoom * boxCircle1R * cos(finishBottomPos);
    } else {
      var pos = this.finishBottomPos + this.nipYOffset;
      if (pos < 0) pos = 0;
      finishBottomX = pos < boxCircle1R
          ? boxCircle1X - this.zoom * boxCircle1R * sin(acos(1 - pos / boxCircle1R))
          : this.zoom * this.nipWidth;
      finishBottomY = this.zoom * pos;
    }
    final finishBottomAngle = this.finishBottomAngle * pi / 180;

    final bottomDirectSize = sqrt(pow(finishBottomX - startBottomX, 2) + pow(finishBottomY - startBottomY, 2)) / 3;
    final startBottomDirectX = startBottomX + bottomDirectSize * cos(startBottomAngle);
    final startBottomDirectY = startBottomY - bottomDirectSize * sin(startBottomAngle);
    final finishBottomDirectX = finishBottomX + bottomDirectSize * cos(finishBottomAngle);
    final finishBottomDirectY = finishBottomY - bottomDirectSize * sin(finishBottomAngle);

    path.reset();
    path.moveTo(startTopX, startTopY);
//    path.lineTo(finishTopX, finishTopY);
    path.cubicTo(startTopDirectX, startTopDirectY, finishTopDirectX, finishTopDirectY, finishTopX, finishTopY);

//    path.lineTo(finishTopX, finishTopY + this.zoom * 10);
    path.lineTo(finishBottomX, finishBottomY);
    path.cubicTo(
        finishBottomDirectX, finishBottomDirectY, startBottomDirectX, startBottomDirectY, startBottomX, startBottomY);

    path.close();
    canvas.drawPath(path, paint);

    if (this.drawDraft) {
      paint.color = Colors.black;
      paint.strokeWidth = 1 / 2.65;
      paint.style = PaintingStyle.stroke;
//      canvas.drawPath(path, paint);

      canvas.drawCircle(Offset(boxCircle1X, boxCircle1Y), boxCircle1R, paint);
      canvas.drawLine(
          Offset(boxCircle1X, boxCircle1Y - boxCircle1R), Offset(boxCircle1X, boxCircle1Y + boxCircle1R), paint);
      canvas.drawLine(
          Offset(boxCircle1X - boxCircle1R, boxCircle1Y), Offset(boxCircle1X + boxCircle1R, boxCircle1Y), paint);

      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(startTopX, startTopY), 1, paint);
      canvas.drawLine(Offset(startTopX, startTopY), Offset(startTopDirectX, startTopDirectY), paint);

      canvas.drawCircle(Offset(finishTopX, finishTopY), 1, paint);
      canvas.drawLine(Offset(finishTopX, finishTopY), Offset(finishTopDirectX, finishTopDirectY), paint);

      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(startBottomX, startBottomY), 1, paint);
      canvas.drawLine(Offset(startBottomX, startBottomY), Offset(startBottomDirectX, startBottomDirectY), paint);

      canvas.drawCircle(Offset(finishBottomX, finishBottomY), 1, paint);
      canvas.drawLine(Offset(finishBottomX, finishBottomY), Offset(finishBottomDirectX, finishBottomDirectY), paint);
    }

    final smallCircle = Circle(Offset(nipRadius, nipYOffset + nipRadius), nipRadius);

    var r = boxRadius > size.height / 2 ? size.height / 2 : boxRadius;
    final topCircle = Circle(Offset(nipWidth + r, r), r);
//    r = r;
    final bottomCircle = Circle(Offset(nipWidth + r, offsetY + size.height - r), r);

    var top = LineSegment(null, null);
    var topHasError = false;

    bool draft = true;

    //
    // Прямая линия под углом
    //
    if (topLine.posType == NipPosType.angle) {
      var alpha = topLine.pos * pi / 180; // Угол наклона линии
      var beta = alpha - pi / 2; // Точка касательной на малом круге
      top.start = smallCircle.point(beta);
      top.end = Offset(nipWidth, top.start.dy + tan(alpha) * (nipWidth - top.start.dx));

      var line = Line(top.start, alpha);

      //
      // Линия уходит к верхнему кругу и выше
      //
      if (top.end.dy < topCircle.center.dy) {
        if (draft) {
          // Четверть верхнего круга
          paintDraftSecond.style = PaintingStyle.fill;
          canvas.drawArc(
              Rect.fromCenter(center: topCircle.center, width: topCircle.diameter, height: topCircle.diameter),
              -pi / 2,
              -pi / 2,
              true,
              paintDraftSecond);
        }

        // Рассчитываем пересечение линии с верхним кругом
        var chord = line.intersectCircle(topCircle);

        //
        // Линия пересекается с дугой угла
        //
        if (!chord.isNull) {
          top.end = chord.start;

          if (draft) {
            var normal = line.normal(topCircle.center);
            paintDraftSecond.style = PaintingStyle.stroke;
            canvas.drawLine(topCircle.center, normal.end, paintDraftSecond);
            canvas.drawLine(chord.start, normal.end, paintDraftSecond);
            paintDraftSecond.style = PaintingStyle.fill;
            canvas.drawCircle(normal.end, 2, paintDraftSecond);
          }
        }
        //
        // Линия выходит за верхний круг
        // В этом случае за линию берём касательную, общую для малого и нижнего кругов
        //
        else {
          topHasError = true;

          var c2c = LineSegment(smallCircle.center, topCircle.center);
          alpha = c2c.direct - asin((topCircle.radius - smallCircle.radius) / c2c.length); // Угол наклона касательной

          beta = alpha - pi / 2;
          top.start = smallCircle.point(beta);
          top.end = topCircle.point(alpha - pi / 2);

          if (draft) {
            paintDraftSecond.style = PaintingStyle.stroke;
            canvas.drawLine(topCircle.center, top.end, paintDraftSecond);
          }
        }

        //
        // Линия уходит за круг
        //
        if (draft && top.end.dx > topCircle.center.dx) {
          paintDraftSecond.style = PaintingStyle.fill;
          canvas.drawArc(
              Rect.fromCenter(center: topCircle.center, width: topCircle.diameter, height: topCircle.diameter),
              0,
              -pi / 2,
              true,
              paintDraftSecond);
        }
      }
      //
      // Линия пересекается с ровной стороной бокса
      //
      else if (top.end.dy <= bottomCircle.center.dy) {
        if (draft) {
          path.reset();
          path.moveTo(nipWidth, topCircle.center.dy);
          path.lineTo(topCircle.center.dx, topCircle.center.dy);
          path.lineTo(bottomCircle.center.dx, bottomCircle.center.dy);
          path.lineTo(nipWidth, bottomCircle.center.dy);
          path.close();

          paintDraftSecond.style = PaintingStyle.fill;
          canvas.drawPath(path, paintDraftSecond);
        }
      }
      //
      // Линия уходит к нижнему углу и ниже
      //
      else {
        if (draft) {
          // Четверть нижнего круга
          paintDraftSecond.style = PaintingStyle.fill;
          canvas.drawArc(
              Rect.fromCenter(center: bottomCircle.center, width: bottomCircle.diameter, height: bottomCircle.diameter),
              pi / 2,
              pi / 2,
              true,
              paintDraftSecond);
        }

        // Рассчитываем пересечение линии с нижним кругом
        var chord = line.intersectCircle(bottomCircle);

        //
        // Линия пересекается с дугой угла
        //
        if (!chord.isNull) {
          top.end = chord.start;

          if (draft) {
            var normal = line.normal(bottomCircle.center);
            paintDraftSecond.style = PaintingStyle.stroke;
            canvas.drawLine(bottomCircle.center, normal.end, paintDraftSecond);
            canvas.drawLine(chord.start, normal.end, paintDraftSecond);
            paintDraftSecond.style = PaintingStyle.fill;
            canvas.drawCircle(normal.end, 2, paintDraftSecond);
          }
        }
        //
        // Линия выходит за нижний круг
        // В этом случае за линию берём касательную, общую для малого и нижнего кругов
        //
        else {
          topHasError = true;

          var c2c = LineSegment(smallCircle.center, bottomCircle.center);
          alpha =
              c2c.direct + asin((bottomCircle.radius + smallCircle.radius) / c2c.length); // Угол наклона касательной

          top.start = smallCircle.point(alpha - pi / 2);
          top.end = bottomCircle.point(alpha + pi / 2);

          if (draft) {
            paintDraftSecond.style = PaintingStyle.stroke;
            canvas.drawLine(bottomCircle.center, top.end, paintDraftSecond);
          }
        }

        //
        // Линия уходит за круг
        //
        if (top.end.dx > bottomCircle.center.dx) {
          paintDraftSecond.style = PaintingStyle.fill;
          canvas.drawArc(
              Rect.fromCenter(center: bottomCircle.center, width: bottomCircle.diameter, height: bottomCircle.diameter),
              0,
              pi / 2,
              true,
              paintDraftSecond);
        }
      }
    }
    //
    // Прямая линия к стороне бокса
    //
    else if (topLine.posType == NipPosType.side) {
      top.end = Offset(nipWidth, nipYOffset + topLine.pos);

      //
      // Линия уходит к верхнему углу
      //
      if (top.end.dy < topCircle.center.dy) {
        if (top.end.dy < topCircle.center.dy - topCircle.radius) {
          top.end = Offset(topCircle.center.dx, topCircle.center.dy - topCircle.radius);
        } else {
          top.end = topCircle.point(asin((topCircle.center.dy - top.end.dy) / topCircle.radius) - pi);
        }

        if (draft) {
          // Четверть верхнего круга
          paintDraftSecond.style = PaintingStyle.fill;
          canvas.drawArc(
              Rect.fromCenter(center: topCircle.center, width: topCircle.diameter, height: topCircle.diameter),
              -pi / 2,
              -pi / 2,
              true,
              paintDraftSecond);
        }
      }
      //
      // Линия пересекается с ровной стороной бокса
      //
      else if (top.end.dy <= bottomCircle.center.dy) {
        if (draft) {
          path.reset();
          path.moveTo(nipWidth, topCircle.center.dy);
          path.lineTo(topCircle.center.dx, topCircle.center.dy);
          path.lineTo(bottomCircle.center.dx, bottomCircle.center.dy);
          path.lineTo(nipWidth, bottomCircle.center.dy);
          path.close();

          paintDraftSecond.style = PaintingStyle.fill;
          canvas.drawPath(path, paintDraftSecond);
        }
      }
      //
      // Линия уходит к нижнему углу
      //
      else {
        if (top.end.dy > bottomCircle.center.dy + bottomCircle.radius) {
          top.end = Offset(bottomCircle.center.dx, bottomCircle.center.dy + bottomCircle.radius);
        } else {
          top.end = bottomCircle.point(asin((bottomCircle.center.dy - top.end.dy) / bottomCircle.radius) - pi);
        }

        if (draft) {
          // Четверть нижнего круга
          paintDraftSecond.style = PaintingStyle.fill;
          canvas.drawArc(
              Rect.fromCenter(center: bottomCircle.center, width: bottomCircle.diameter, height: bottomCircle.diameter),
              pi / 2,
              pi / 2,
              true,
              paintDraftSecond);
        }
      }

      var l = sqrt(pow(top.end.dx - smallCircle.center.dx, 2) + pow(top.end.dy - smallCircle.center.dy, 2));
      var a1 = asin((top.end.dy - smallCircle.center.dy) / l);
      var a2 = -atan2(l, nipRadius);

      top.start = smallCircle.point(a1 + a2);
    }
    //
    // Прямая линия к углам бокса
    //
    else if (topLine.posType == NipPosType.corner) {
      // Отрицательные значения - верхний круг, положительные - нижний
      var a = topLine.pos * pi / 180;
      top.end = topLine.pos <= 0 ? topCircle.point(a) : bottomCircle.point(a);

      var l = sqrt(pow(top.end.dx - smallCircle.center.dx, 2) + pow(top.end.dy - smallCircle.center.dy, 2));
      var a1 = asin((top.end.dy - smallCircle.center.dy) / l);
      var a2 = -atan2(l, nipRadius);

      top.start = smallCircle.point(a1 + a2);

      if (draft) {
        // Четверть верхнего круга
        if (topLine.pos <= 0) {
          paintDraftSecond.style = PaintingStyle.fill;
          canvas.drawArc(
              Rect.fromCenter(center: topCircle.center, width: topCircle.diameter, height: topCircle.diameter),
              -pi / 2,
              -pi / 2,
              true,
              paintDraftSecond);
        }
        // Четверть нижнего круга
        else {
          paintDraftSecond.style = PaintingStyle.fill;
          canvas.drawArc(
              Rect.fromCenter(center: bottomCircle.center, width: bottomCircle.diameter, height: bottomCircle.diameter),
              pi / 2,
              pi / 2,
              true,
              paintDraftSecond);
        }
      }
    }

    // Малый круг
    paintDraftSecond.style = PaintingStyle.fill;
    canvas.drawCircle(smallCircle.center, smallCircle.radius, paintDraftSecond);
    paintDraftSecond.style = PaintingStyle.stroke;
    canvas.drawLine(smallCircle.center, top.start, paintDraftSecond);
    paintDraftSecond.style = PaintingStyle.fill;
    canvas.drawCircle(smallCircle.center, 2, paintDraftSecond);

    // Линия
    var p = topHasError ? paintDraftError : paintDraftMain;
    p.style = PaintingStyle.fill;
    canvas.drawCircle(top.start, 2, p);
    canvas.drawCircle(top.end, 2, p);
    p.style = PaintingStyle.stroke;
    canvas.drawLine(top.start, top.end, p);
  }

  final double finishBottomPos;
  final double finishBottomAngle;

  final bool drawDraft;

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

  Offset _start;
  Offset _end;
  double _length;
  double _direct;

  Offset get start {
    return _start;
  }

  set start(value) {
    // При установке новой начальной точки сохраняем конечную точку и сбрасываем направление и размер
    _start = value;
    _end = end;
    _direct = null;
    _length = null;
  }

  Offset get end {
    if (_end == null && _direct != null)
      _end = Offset(start.dx + _length * cos(_direct), start.dy + _length * sin(_direct));
    return _end;
  }

  set end(value) {
    _end = value;
    _length = null;
    _direct = null;
  }

  double get length {
    if (_length == null) _length = sqrt(pow(_end.dx - start.dx, 2) + pow(_end.dy - start.dy, 2));
    return _length;
  }

  double get direct {
    if (_direct == null) _direct = atan2(_end.dy - start.dy, _end.dx - start.dx);
    return _direct;
  }

  bool get isNull => _start == null;
}

/// Линия
class Line {
  const Line(this.start, this.direct);
  //Line.toPoint(this.start, Offset end) : direct = atan2(1,2);

  final Offset start;
  final double direct;

  /// Вычисляет нормаль к линии из точки
  LineSegment normal(Offset point) {
    double distance;
    double angle;

    var tn = tan(direct);
    if (tn == 0.0) {
      distance = start.dy - point.dy;
      angle = pi / 2;
    } else {
      // Вспомогательный треугольник, гипотенуза которого находится на одной горизонтали с точкой
      var x = start.dx + (point.dy - start.dy) / tn;
      distance = sin(direct) * (point.dx - x); // Дальний катет треуголника - искомое расстояние
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
    var start = Offset(normal.end.dx - dx, normal.end.dy - dy);
    var end = Offset(normal.end.dx + dx, normal.end.dy + dy);

    return LineSegment(start, end);
  }
}

class Circle {
  const Circle(this.center, this.radius);

  final Offset center;
  final double radius;

  double get diameter => 2 * radius;

  /// Точка на окружности
  Offset point(double alpha) {
    return Offset(center.dx + radius * cos(alpha), center.dy + radius * sin(alpha));
  }
}
