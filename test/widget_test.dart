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

  testWidgets('HomeScreen smoke test for UNASSIGNED role shows waiting notice and hides cards & bottom nav', (WidgetTester tester) async {
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

    // Verify User Banner displays greeting and unassigned badge & lapak
    expect(find.text('Halo, Budi Santoso 👋'), findsOneWidget);
    expect(find.text('Belum Ditugaskan'), findsNWidgets(2)); // Role badge and Lapak info row
    expect(find.text('Belum Ditugaskan (UNASSIGNED)'), findsOneWidget); // Status in info card

    // Verify unassigned notice & account info
    expect(find.text('Menunggu Penugasan'), findsOneWidget);
    expect(find.text('Informasi Akun Anda'), findsOneWidget);
    expect(find.text('Periksa Status Penugasan'), findsOneWidget);
    expect(find.text('Keluar dari Akun'), findsOneWidget);

    // Verify 6 cards are HIDDEN
    expect(find.text('Absen\nMasuk'), findsNothing);
    expect(find.text('Terima\nBarang'), findsNothing);
    expect(find.text('Stok &\nPenjualan'), findsNothing);
    expect(find.text('Nota\nPengeluaran'), findsNothing);
    expect(find.text('Closing\nHarian'), findsNothing);
    expect(find.text('Slip\nGaji'), findsNothing);

    // Verify bottom nav is HIDDEN
    expect(find.text('Beranda'), findsNothing);
    expect(find.text('Riwayat'), findsNothing);
    expect(find.text('Profil'), findsNothing);
  });

  testWidgets('HomeScreen smoke test for ASSIGNED role shows all 6 cards and bottom nav', (WidgetTester tester) async {
    const testUser = UserModel(
      id: 'test_spg_456',
      nama: 'Siti Rahma',
      username: 'sitirahma',
      email: 'siti@pot.com',
      role: 'spg',
      lapakId: '2',
      noHp: '08129876543',
      status: 'active',
      authProvider: 'password',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(user: testUser),
      ),
    );

    // Verify User Banner displays greeting, role badge, and Lapak
    expect(find.text('Halo, Siti Rahma 👋'), findsOneWidget);
    expect(find.text('SPG'), findsOneWidget);
    expect(find.text('Lapak 2'), findsOneWidget);

    // Verify all 6 operational cards are DISPLAYED
    expect(find.text('Absen\nMasuk'), findsOneWidget);
    expect(find.text('Terima\nBarang'), findsOneWidget);
    expect(find.text('Stok &\nPenjualan'), findsOneWidget);
    expect(find.text('Nota\nPengeluaran'), findsOneWidget);
    expect(find.text('Closing\nHarian'), findsOneWidget);
    expect(find.text('Slip\nGaji'), findsOneWidget);

    // Verify bottom navigation bar is DISPLAYED
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    // Verify unassigned notice is HIDDEN
    expect(find.text('Menunggu Penugasan'), findsNothing);
  });
}
