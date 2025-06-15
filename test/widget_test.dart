// This is a basic Flutter widget test for the SML Market app.

import 'package:flutter_test/flutter_test.dart';
import 'package:smlmarket/main.dart';

void main() {
  testWidgets('App loads and shows home page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the home page elements are present.
    expect(find.text('สวัสดี! 👋'), findsOneWidget);
    expect(find.text('ยินดีต้อนรับสู่ SML Market'), findsOneWidget);
    expect(find.text('ค้นหาสินค้า'), findsOneWidget);
    expect(find.text('เมนูหลัก'), findsOneWidget);

    // Verify bottom navigation bar
    expect(find.text('หน้าหลัก'), findsOneWidget);
    expect(find.text('ค้นหา'), findsOneWidget);
    expect(find.text('โปรไฟล์'), findsOneWidget);
    expect(find.text('ตั้งค่า'), findsOneWidget);
  });

  testWidgets('Navigation to search page works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Tap on the search bottom navigation item
    await tester.tap(find.text('ค้นหา'));
    await tester.pumpAndSettle(); // Verify that we're now on the search page
    expect(find.text('ค้นหาสินค้า'), findsWidgets);
    expect(find.text('ค้นหาสินค้า เช่น oil, motor, coil...'), findsOneWidget);
  });
}
