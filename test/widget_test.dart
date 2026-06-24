import 'package:flutter_test/flutter_test.dart';

import 'package:rizzmusicapp/main.dart';

void main() {
  testWidgets('shows signed-out landing screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });
}
