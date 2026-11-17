
import 'package:flutter_test/flutter_test.dart';
import 'package:online_shop_app/main.dart';

void main() {
  testWidgets('Online Shop menampilkan halaman login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MyApp(isLoggedIn: false),
    );

    expect(find.text('Online Shop'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
