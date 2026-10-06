import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pot_apps/core/models/user_model.dart';
import 'package:pot_apps/main.dart';
import 'package:pot_apps/screens/home/home_screen.dart';

void main() {
  testWidgets('Login screen smoke test and navigate to register', (WidgetTester tester) async {
    await tester.pumpWidget(const PotApp());

    expect(find.text('POT'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Login dengan Google'), findsOneWidget);
    final registerLinkFinder = find.byWidgetPredicate(
      (w) => w is RichText && w.text.toPlainText().contains('Belum punya akun?'),
    );
    expect(registerLinkFinder, findsOneWidget);

    // Tap "Belum punya akun? Daftar" to navigate directly to RegisterScreen
    await tester.tap(registerLinkFinder);
    await tester.pumpAndSettle();

    // Verify RegisterScreen is displayed
    expect(find.text('Daftar Akun Baru'), findsOneWidget);
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Konfirmasi Password'), findsOneWidget);
    expect(find.text('Daftar dengan Google'), findsOneWidget);
  });

  testWidgets('HomeScreen smoke test displays halo nama and logout', (WidgetTester tester) async {
    const testUser = UserModel(
      id: 'test_uid_123',
      nama: 'Budi Santoso',
      username: 'budisantoso',
      email: 'budi@pot.com',
      role: 'unassigned',
      noHp: '08123456789',
      status: 'active',
      authProvider: 'password',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(user: testUser),
      ),
    );

    // Verify halo $nama text
    expect(find.text('halo Budi Santoso'), findsOneWidget);
    expect(find.text('Informasi Akun'), findsOneWidget);
    expect(find.text('Logout dari Akun'), findsOneWidget);
  });
}
