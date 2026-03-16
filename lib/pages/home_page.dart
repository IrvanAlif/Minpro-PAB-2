import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/rental_service.dart';
import '../services/auth_service.dart';
import 'peminjaman_card.dart';
import 'stok_page.dart';
import 'statistik_page.dart';
import 'form_page.dart';
import 'auth/login_page.dart';

class HomePage extends StatefulWidget {
  final RentalController controller;
  const HomePage({super.key, required this.controller});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  final _auth = AuthService();

  final _titles = ['Peminjaman', 'Stok Alat', 'Statistik'];
  final _icons = [
    Icons.receipt_long_rounded,
    Icons.inventory_2_rounded,
    Icons.bar_chart_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_index],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: () =>
                Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => Get.defaultDialog(
              title: 'Keluar?',
              middleText: 'Apakah kamu yakin ingin logout?',
              textCancel: 'Batal',
              textConfirm: 'Logout',
              confirmTextColor: Colors.white,
              buttonColor: Colors.red,
              onConfirm: () async {
                Get.back();
                await _auth.logout();
                Get.offAll(() => const LoginPage());
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          PeminjamanCard(controller: widget.controller),
          StokPage(controller: widget.controller),
          StatistikPage(controller: widget.controller),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: () =>
                  Get.to(() => FormPage(controller: widget.controller)),
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: const Color(0xFF2E7D32).withValues(alpha: 0.15),
        destinations: List.generate(
          3,
          (i) =>
              NavigationDestination(icon: Icon(_icons[i]), label: _titles[i]),
        ),
      ),
    );
  }
}
