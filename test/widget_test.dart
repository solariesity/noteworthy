import 'package:flutter_test/flutter_test.dart';

import 'package:noteworthy/app.dart';

void main() {
  testWidgets('App renders module selector', (WidgetTester tester) async {
    await tester.pumpWidget(const NoteworthyApp());

    expect(find.text('词'), findsOneWidget);
    expect(find.text('弦'), findsOneWidget);
    expect(find.text('Noteworthy'), findsOneWidget);
  });
}
