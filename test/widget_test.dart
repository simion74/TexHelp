import 'package:flutter_test/flutter_test.dart';
import 'package:texhelp/main.dart';

void main() {
  testWidgets('TexHelp home screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const TexHelpApp());
    expect(find.text('TexHelp'), findsOneWidget);
  });
}
