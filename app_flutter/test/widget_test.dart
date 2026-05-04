import 'package:flutter_test/flutter_test.dart';

import 'package:app_flutter/main.dart';

void main() {
  testWidgets('App shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(const AppFlutter());
    await tester.pump();
    expect(find.byType(AppFlutter), findsOneWidget);
  });
}
