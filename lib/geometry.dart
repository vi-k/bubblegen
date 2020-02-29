import 'dart:math' as math;
import 'dart:ui';

/// Большие числа превращает в infinity/-infinity
double inf(double value) {
  final double max = 1e15;
  if (value > max) return double.infinity;
  if (value < -max) return double.negativeInfinity;
  return value;
}

/// Точка на базе Offset
/// Только для того, чтобы вместо dx, dy использовать x, y
class Point extends Offset {
  const Point(double x, double y) : super(x, y);

  static const Point infinite = Point(double.infinity, double.infinity);

  double get x => dx;
  double get y => dy;

  @override
  String toString() => "Point($dx, $dy)";
}

/// Линия
class Line {
  const Line(this.start, this.direct);
  //Line.toPoint(this.start, Offset end) : direct = atan2(1,2);

  final Point start;
  final double direct;

  String toString() {
    return "Line($start, ${direct * 180 / math.pi})";
  }

  double tan() => inf(math.tan(direct));

  /// Точка на линии
  Point point(double distance) {
    return Point(start.x + distance * math.cos(direct), start.y + distance * math.sin(direct));
  }

  /// Точка на линии
  Point pointByX(double x) {
    return Point(x, start.y + (x - start.x) * tan());
  }

  /// Точка на линии
  Point pointByY(double y) {
    return Point(start.x + (y - start.y) / tan(), y);
  }

  /// Вычисляет нормаль к линии из точки
  LineSegment normal(Point point) {
    double distance;
    double angle;

    var tan = this.tan();
    if (tan == 0.0) {
      distance = start.y - point.y;
      angle = math.pi / 2;
    } else {
      // Вспомогательный треугольник, гипотенуза которого находится на одной горизонтали с точкой
      var x = start.x + (point.y - start.y) / tan;
      distance = math.sin(direct) * (point.x - x); // Дальний катет треугольника - искомое расстояние
      angle = direct + math.pi / 2;
    }

    if (distance < 0) {
      distance = -distance;
      angle -= math.pi;
    }

    return LineSegment.direct(point, angle, distance);
  }

  /// Вычисляет пересечение линии с окружностью
  LineSegment intersectCircle(Circle circle) {
    var normal = this.normal(circle.center);

    // Линия не пересекается с окружностью
    if (normal.length > circle.radius) return null;

    var halfChord = math.sqrt(circle.radius * circle.radius - normal.length * normal.length); // Половина хорды
    var dx = math.cos(direct) * halfChord;
    var dy = math.sin(direct) * halfChord;
    var start = Point(normal.end.x - dx, normal.end.y - dy);
    var end = Point(normal.end.x + dx, normal.end.y + dy);

    return LineSegment(start, end);
  }

  /// Вычисляет пересечение линии с другой линией
  Point intersectLine(Line other) {
    var thisTan = this.tan();
    if (thisTan == 0.0) return other.pointByY(this.start.y);
    if (thisTan.isInfinite) return other.pointByX(this.start.x);

    final mX = this.start.x + (other.start.y - this.start.y) / thisTan;
//    if (mX == this.start.x) return Point(mX, other.start.y + (mX - other.start.x) * otherTn);
    final x = other.start.x - (other.start.x - mX) * thisTan / (thisTan - other.tan());
    final r = (x - this.start.x) / math.cos(this.direct);
    final y = this.start.y + math.sin(this.direct) * r;

    return Point(x, y);
  }

  /// Вычисляет пересечение линии с отрезком
  Point intersectLineSegment(LineSegment lineSegment) {
    Point point = intersectLine(Line(lineSegment.start, lineSegment.direct));

    if (point.x < math.min(lineSegment.start.x, lineSegment.end.x) ||
        point.x > math.max(lineSegment.start.x, lineSegment.end.x) ||
        point.y < math.min(lineSegment.start.y, lineSegment.end.y) ||
        point.y > math.max(lineSegment.start.y, lineSegment.end.y)) return null;

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
  LineSegment(this._start, this._end);
  LineSegment.direct(this._start, this._direct, this._length)
      : assert(_direct != null),
        assert(_length != null);

  Point _start;
  Point _end;
  double _length;
  double _direct;

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
      _end = Point(start.x + _length * math.cos(_direct), start.y + _length * math.sin(_direct));
    }
    return _end;
  }

  set end(Point value) {
    _end = value;
    _length = null;
    _direct = null;
  }

  double get length {
    if (_length == null) {
      _length = math.sqrt(math.pow(_end.x - start.x, 2) + math.pow(_end.y - start.y, 2));
    }
    return _length;
  }

  double get direct {
    if (_direct == null) {
      _direct = math.atan2(_end.y - start.y, _end.x - start.x);
    }
    return _direct;
  }

  String toString() {
    return "LineSegment($_start, $_end)";
  }
}

/// Окружность
class Circle {
  const Circle(this.center, this.radius);

  final Point center;
  final double radius;

  double get diameter => 2 * radius;

  String toString() {
    return "Circle($center, $radius)";
  }

  /// Точка на окружности: point(alpha)
  /// Точка на расстоянии от центра окружности: point(alpha, distance)
  Point point(double alpha, [double distance]) {
    if (distance == null) distance = radius;
    return Point(center.x + distance * math.cos(alpha), center.y + distance * math.sin(alpha));
  }

  /// Касательная, общая для двух окружностей
  ///
  /// @param other Вторая окружность
  /// @param firstSide Какая часть окружности дожна быть использована: -1.0 - верх, 1.0 - низ.
  /// @param secondSide Какая часть окружности дожна быть использована: -1.0 - верх, 1.0 - низ.
  LineSegment tangentToCircle(Circle other, double firstSide, double secondSide) {
    // Линия, соединяющая центры
    var c2c = LineSegment(this.center, other.center);

    // Вспомогательный треугольник, где касательная - гипотенуза
    var alpha = math.asin((this.radius - firstSide * secondSide * other.radius) / c2c.length).abs();
//    print('alpha: ${alpha / pi * 180}');

    // Угол наклона касательной
    var beta = c2c.direct + secondSide * alpha;
//    print('beta: ${beta / pi * 180}');

    var gamma1 = firstSide > 0 ? beta + math.pi / 2 : beta - math.pi / 2;
    var gamma2 = secondSide > 0 ? beta + math.pi / 2 : beta - math.pi / 2;

//    print('tanget: ${LineSegment(this.point(gamma1), other.point(gamma2))}');
    return LineSegment(this.point(gamma1), other.point(gamma2));
  }

  /// Касательная к окружности из точки
  ///
  /// @param point Точка, из которая проводится касательная
  /// @param side Какая часть окружности дожна быть использована: -1.0 - верх, 1.0 - низ.
  LineSegment tangentToPoint(Point point, double side) {
    // Линия, соединяющая центр и точку
    var c2c = LineSegment(this.center, point);

    // Вспомогательный треугольник, где касательная - гипотенуза
    var alpha = math.asin((this.radius) / c2c.length);
//    print('alpha: ${alpha / pi * 180}');

    // Угол наклона касательной
    var beta = c2c.direct - side * alpha;
//    print('beta: ${beta / pi * 180}');

    var gamma = side > 0 ? beta + math.pi / 2 : beta - math.pi / 2;

//    print('tanget: ${LineSegment(this.point(gamma), point)}');
    return LineSegment(this.point(gamma), point);
  }
}
