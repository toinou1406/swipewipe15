import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';
import 'package:myapp/permissions_screen.dart';

void main() {
  testWidgets('Permissions screen shows up initially', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the PermissionsScreen is displayed.
    expect(find.byType(PermissionsScreen), findsOneWidget);

    // Verify the presence of the title and the button.
    expect(find.text('Welcome to Photo Manager Pro'), findsOneWidget);
    expect(find.text('Grant Permission'), findsOneWidget);
  });
}
