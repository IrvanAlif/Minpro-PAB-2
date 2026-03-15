import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/rental_service.dart';

class StatistikPage extends StatelessWidget {
  final RentalController controller;
  const StatistikPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final all = controller.pinjamList;
      final aktif = all.where((p) => !p.kembali).length;
      final selesai = all.where((p) => p.kembali).length;
      final pendapatan = all
          .where((p) => p.kembali)
          .fold<int>(0, (s, p) => s + p.totalBayar());
      final potensi = all
          .where((p) => !p.kembali)
          .fold<int>(0, (s, p) => s + p.totalBayar());

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Total Pendapatan',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  controller.rupiah(pendapatan),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Dari $selesai transaksi selesai',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                if (potensi > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Potensi masuk: ${controller.rupiah(potensi)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statCard(
                'Total',
                '${all.length}',
                Icons.people_rounded,
                Colors.blue,
              ),
              const SizedBox(width: 10),
              _statCard(
                'Aktif',
                '$aktif',
                Icons.pending_rounded,
                Colors.orange,
              ),
              const SizedBox(width: 10),
              _statCard(
                'Selesai',
                '$selesai',
                Icons.check_circle_rounded,
                Colors.green,
              ),
            ],
          ),
          if (all.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'Belum ada data transaksi',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _statCard(String label, String value, IconData icon, Color color) =>
      Expanded(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
}
