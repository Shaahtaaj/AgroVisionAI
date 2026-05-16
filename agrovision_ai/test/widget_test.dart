import 'package:agrovision_ai/app/agrovision_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AgroVision app starts with splash screen', (tester) async {
    await tester.pumpWidget(const AgroVisionApp());

    expect(find.text('AgroVision AI'), findsOneWidget);
  });
}
