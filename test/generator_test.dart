import 'package:bubblegen/custom_bubble.dart';
import 'package:bubblegen/generator.dart';
import 'package:bubblegen/main.dart';
import 'package:bubblegen/numeric_field.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sets the field captioned [caption] as if the user had typed [value].
Future<void> _set(WidgetTester tester, String caption, double value) async {
  tester
      .widget<NumericField>(
        find.byWidgetPredicate(
          (widget) => widget is NumericField && widget.caption == caption,
          skipOffstage: false,
        ),
      )
      .onChanged(value);
  await tester.pump();
}

void main() {
  testWidgets('the inset fields change only their own value', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Press me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('inset'));
    await tester.pumpAndSettle();

    await _set(tester, 'start.pos.offset:', 2);
    await _set(tester, 'start.pos.ratio:', 0.25);
    await _set(tester, 'end.pos.offset:', 3);
    await _set(tester, 'end.pos.ratio:', 0.5);

    final inset = Generator.settings.nip.inset;
    expect(inset.start.pos, const Position(ratio: 0.25, offset: 2));
    expect(inset.end.pos, const Position(ratio: 0.5, offset: 3));
  });
}
