import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cooli_partner/core/widgets/cooli_buttons.dart';
import 'package:cooli_partner/core/widgets/status_badge.dart';
import 'package:cooli_partner/core/widgets/online_status_toggle.dart';
import 'package:cooli_partner/core/widgets/cooli_card.dart';

void main() {
  group('COOLI PARTNER - Design System Widget Tests', () {
    testWidgets('CooliPrimaryButton renders label and triggers tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CooliPrimaryButton(
              label: 'ACCEPT JOB',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('ACCEPT JOB'), findsOneWidget);
      await tester.tap(find.text('ACCEPT JOB'));
      expect(tapped, isTrue);
    });

    testWidgets('StatusBadge displays correct text and verified icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge.verified('Verified DL'),
          ),
        ),
      );

      expect(find.text('Verified DL'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('OnlineStatusToggle displays online text and toggles', (WidgetTester tester) async {
      bool status = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return OnlineStatusToggle(
                  isOnline: status,
                  onToggle: (val) {
                    setState(() {
                      status = val;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('YOU ARE ONLINE'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(status, isFalse);
    });

    testWidgets('CooliCard renders child with proper decoration', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CooliCard(
              child: Text('Card Content Test'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content Test'), findsOneWidget);
    });
  });
}
