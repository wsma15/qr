import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qrwr/main.dart';

void main() {
  testWidgets('عرض تبويبات القراءة والإنشاء', (tester) async {
    await tester.pumpWidget(const QRWRApp());

    expect(find.text('قراءة'), findsOneWidget);
    expect(find.text('إنشاء'), findsOneWidget);

    await tester.tap(find.text('إنشاء'));
    await tester.pumpAndSettle();

    expect(find.text('الرابط الإلكتروني'), findsOneWidget);
    expect(find.text('إنشاء الرمز'), findsOneWidget);
  });

  testWidgets('إنشاء رمز QR يعرض خيارات النسخ', (tester) async {
    await tester.pumpWidget(const QRWRApp());

    await tester.tap(find.text('إنشاء'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField),
      'https://flutter.dev',
    );

    await tester.tap(find.text('إنشاء الرمز'));
    await tester.pumpAndSettle();

    expect(find.text('نسخ الرابط'), findsOneWidget);
    expect(find.byType(SelectableText), findsWidgets);
  });
}

