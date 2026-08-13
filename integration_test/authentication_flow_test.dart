import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:community_care_hub/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Test', () {
    testWidgets('verify register, signout, and login flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Onboarding screen
      final getStartedButton = find.text('Get Started');
      if (getStartedButton.evaluate().isNotEmpty) {
        await tester.tap(getStartedButton);
        await tester.pumpAndSettle();
      }

      // We are on Login Screen now.
      expect(find.text('Welcome Back'), findsOneWidget);

      // Navigate to Register Screen
      final registerButton = find.text('Register Now');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);

      // Fill out registration form
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(4)); // Name, Email, Phone, Password

      await tester.enterText(textFields.at(0), 'Integration User');
      await tester.enterText(textFields.at(1), 'integration_${DateTime.now().millisecondsSinceEpoch}@example.com');
      await tester.enterText(textFields.at(2), '1234567890');
      await tester.enterText(textFields.at(3), 'Password123!');
      await tester.pumpAndSettle();

      final signUpButton = find.widgetWithText(ElevatedButton, 'Sign Up');
      await tester.tap(signUpButton);

      // Wait for network response (Firebase Emulator)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // We should be on Role Selection Screen
      expect(find.text('Choose Your Role'), findsOneWidget);
    });
  });
}
