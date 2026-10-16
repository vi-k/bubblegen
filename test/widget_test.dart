import 'package:bubblegen/BubbleDemo.dart';
import 'package:bubblegen/Generator.dart';
import 'package:bubblegen/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the app opens on the generator', (tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Bubble generator'), findsOneWidget);
    expect(find.byType(Generator), findsOneWidget);
  });

  testWidgets('every tab builds', (tester) async {
    await tester.pumpWidget(MyApp());

    // The bubble demo starts a repeating animation: pumpAndSettle never ends.
    await tester.tap(find.text('Bubble\ndemo'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(BubbleDemo), findsOneWidget);

    await tester.tap(find.text('CustomBubble\ndemo'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Test #2'), findsOneWidget);
  });
}
