import 'dart:math' as math;
import 'dart:ui';

/// Большие числа превращает в infinity/-infinity
double inf(double value) {
  const max = 1000000000000000;
  if (value > max) return double.infinity;
  if (value < -max) return double.negativeInfinity;
  return value;
}

/// Точка на базе Offset
/// Только для того, чтобы вместо dx, dy использовать x, y
class Point extends Offset {
  const Point(super.x, super.y);

//  static const Point infinite = Point(double.infinity, double.infinity);

  double get x => dx;
  double get y => dy;

  @override
  String toString() => 'Point($dx, $dy)';
}

/// Линия
class Line {
  const Line(this.start, this.direct);
  //Line.toPoint(this.start, Offset end) : direct = atan2(1,2);

  final Point start;
  final double direct;

  @override
  String toString() => 'Line($start, ${direct * 180 / math.pi})';

  double tan() => inf(math.tan(direct));

  /// Точка на линии
  Point point(double distance) => Point(
        start.x + distance * math.cos(direct),
        start.y + distance * math.sin(direct),
      );

  /// Точка на линии
  Point pointByX(double x) => Point(x, start.y + (x - start.x) * tan());

  /// Точка на линии
  Point pointByY(double y) => Point(start.x + (y - start.y) / tan(), y);

  /// Вычисляет нормаль к линии из точки
  LineSegment normal(Point point) {
    double distance;
    double angle;

    final tan = this.tan();
    if (tan == 0.0) {
      distance = start.y - point.y;
      angle = math.pi / 2;
    } else {
      // Вспомогательный треугольник, гипотенуза которого находится на одной горизонтали с точкой
      final x = start.x + (point.y - start.y) / tan;
      distance = math.sin(direct) *
          (point.x - x); // Дальний катет треугольника - искомое расстояние
      angle = direct + math.pi / 2;
    }

    if (distance < 0) {
      distance = -distance;
      angle -= math.pi;
    }

    return LineSegment.direct(point, angle, distance);
  }

  /// Вычисляет пересечение линии с окружностью
  LineSegment? intersectCircle(Circle circle) {
    final normal = this.normal(circle.center);

    // Линия не пересекается с окружностью
    if (normal.length > circle.radius) return null;

    final halfChord = math.sqrt(
      circle.radius * circle.radius - normal.length * normal.length,
    ); // Половина хорды
    final dx = math.cos(direct) * halfChord;
    final dy = math.sin(direct) * halfChord;
    final start = Point(normal.end.x - dx, normal.end.y - dy);
    final end = Point(normal.end.x + dx, normal.end.y + dy);

    return LineSegment(start, end);
  }

  /// Вычисляет пересечение линии с другой линией
  Point intersectLine(Line other) {
    final thisTan = tan();
    if (thisTan == 0.0) return other.pointByY(start.y);
    if (thisTan.isInfinite) return other.pointByX(start.x);

    final mX = start.x + (other.start.y - start.y) / thisTan;
//    if (mX == this.start.x) return Point(mX, other.start.y + (mX - other.start.x) * otherTn);
    final x = other.start.x -
        (other.start.x - mX) * thisTan / (thisTan - other.tan());
    final r = (x - start.x) / math.cos(direct);
    final y = start.y + math.sin(direct) * r;

    return Point(x, y);
  }

  /// Вычисляет пересечение линии с отрезком
  Point? intersectLineSegment(LineSegment lineSegment) {
    final point = intersectLine(Line(lineSegment.start, lineSegment.direct));

    if (point.x < math.min(lineSegment.start.x, lineSegment.end.x) ||
        point.x > math.max(lineSegment.start.x, lineSegment.end.x) ||
        point.y < math.min(lineSegment.start.y, lineSegment.end.y) ||
        point.y > math.max(lineSegment.start.y, lineSegment.end.y)) {
      return null;
    }

    return point;
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
  LineSegment(this._start, Point this._end);
  LineSegment.direct(this._start, double this._direct, double this._length);

  Point _start;
  Point? _end;
  double? _length;
  double? _direct;

  Point get start => _start;

  set start(Point value) {
    // При установке новой начальной точки сохраняем конечную точку и сбрасываем направление и размер
    _start = value;
    _end = end;
    _direct = null;
    _length = null;
  }

  Point get end {
    if (_end == null && _direct != null) {
      _end = Point(
        start.x + _length! * math.cos(_direct!),
        start.y + _length! * math.sin(_direct!),
      );
    }
    return _end!;
  }

  set end(Point value) {
    _end = value;
    _length = null;
    _direct = null;
  }

  double get length {
    _length ??= math
        .sqrt(math.pow(_end!.x - start.x, 2) + math.pow(_end!.y - start.y, 2));
    return _length!;
  }

  double get direct {
    _direct ??= math.atan2(_end!.y - start.y, _end!.x - start.x);
    return _direct!;
  }

  @override
  String toString() => 'LineSegment($_start, $_end)';
}

/// Окружность
class Circle {
  const Circle(this.center, this.radius);

  final Point center;
  final double radius;

  double get diameter => 2 * radius;

  @override
  String toString() => 'Circle($center, $radius)';

  /// Точка на окружности: point(alpha)
  /// Точка на расстоянии от центра окружности: point(alpha, distance)
  Point point(double alpha, [double? distance]) {
    distance ??= radius;
    return Point(
      center.x + distance * math.cos(alpha),
      center.y + distance * math.sin(alpha),
    );
  }

  /// Касательная, общая для двух окружностей
  ///
  /// @param other Вторая окружность
  /// @param firstSide Какая часть окружности дожна быть использована: -1.0 - верх, 1.0 - низ.
  /// @param secondSide Какая часть окружности дожна быть использована: -1.0 - верх, 1.0 - низ.
  LineSegment tangentToCircle(
    Circle other,
    double firstSide,
    double secondSide,
  ) {
    // Линия, соединяющая центры
    final c2c = LineSegment(center, other.center);

    // Вспомогательный треугольник, где касательная - гипотенуза
    final alpha = math
        .asin((radius - firstSide * secondSide * other.radius) / c2c.length)
        .abs();
//    print('alpha: ${alpha / pi * 180}');

    // Угол наклона касательной
    final beta = c2c.direct + secondSide * alpha;
//    print('beta: ${beta / pi * 180}');

    final gamma1 = firstSide > 0 ? beta + math.pi / 2 : beta - math.pi / 2;
    final gamma2 = secondSide > 0 ? beta + math.pi / 2 : beta - math.pi / 2;

//    print('tanget: ${LineSegment(this.point(gamma1), other.point(gamma2))}');
    return LineSegment(point(gamma1), other.point(gamma2));
  }

  /// Касательная к окружности из точки
  ///
  /// @param point Точка, из которой проводится касательная
  /// @param side Какая часть окружности дожна быть использована: -1.0 - верх, 1.0 - низ
  ///
  /// @return null, если точка внутри окружности
  LineSegment? tangentToPoint(Point point, double side) {
    // Линия, соединяющая центр и точку
    final c2c = LineSegment(center, point);

    // Вспомогательный треугольник, где касательная - гипотенуза
    // alpha - угол между касательной и линией, соединяющей центр и точку
    final alpha = math.asin(radius / c2c.length);
//    print('radius: ${this.radius} c2c.length: ${c2c.length}');
//    print('alpha: ${alpha / math.pi * 180}');

    // Угол наклона касательной
    final beta = c2c.direct - side * alpha;
//    print('beta: ${beta / math.pi * 180}');

    // Позиция на окружности
    final gamma = side > 0 ? beta + math.pi / 2 : beta - math.pi / 2;

//    print('tanget: ${LineSegment(this.point(gamma), point)}');
    return gamma.isNaN ? null : LineSegment(this.point(gamma), point);
  }
}
