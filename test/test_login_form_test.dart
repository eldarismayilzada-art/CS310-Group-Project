import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clubhub/widgets/test_login_form.dart';

void main() {
  testWidgets('Shows error message when login input is empty',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TestLoginForm(),
            ),
          ),
        );

        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Login'), findsOneWidget);

        await tester.tap(find.text('Login'));
        await tester.pump();

        expect(find.text('Please enter email and password'), findsOneWidget);
      });

  testWidgets('Shows invalid email message for wrong email format',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TestLoginForm(),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField).at(0), 'wrongemail');
        await tester.enterText(find.byType(TextField).at(1), '123456');

        await tester.tap(find.text('Login'));
        await tester.pump();

        expect(find.text('Invalid email'), findsOneWidget);
      });
}