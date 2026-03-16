import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/rental_service.dart';
import '../models/models.dart';
import 'form_page.dart';

class PeminjamanCard extends StatelessWidget {
  final RentalController controller;
  const PeminjamanCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.pinjamList.isEmpty) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_rounded, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Belum ada peminjaman',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.pinjamList.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) =>
            _Card(p: controller.pinjamList[i], c: controller),
      );
    });
  }
}

class _Card extends StatelessWidget {
  final Pinjam p;
  final RentalController c;
  const _Card({required this.p, required this.c});

  @override
  Widget build(BuildContext context) {
    final isKembali = p.kembali;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isKembali
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  child: Text(
                    p.nama[0].toUpperCase(),
                    style: TextStyle(
                      color: isKembali ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        p.hp,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isKembali
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isKembali ? 'Selesai' : 'Aktif',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isKembali ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _info(Icons.schedule_rounded, '${p.hari} hari'),
                const SizedBox(width: 16),
                _info(Icons.backpack_rounded, '${p.jumlahBarang()} barang'),
                const Spacer(),
                Text(
                  c.rupiah(p.totalBayar()),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _btn(
                  Icons.visibility_outlined,
                  'Detail',
                  null,
                  () => _showDetail(context),
                ),
                if (!isKembali)
                  _btn(
                    Icons.check_circle_outline,
                    'Kembali',
                    Colors.green,
                    _confirmReturn,
                  ),
                _btn(Icons.delete_outline, 'Hapus', Colors.red, _delete),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String label) => Row(
    children: [
      Icon(icon, size: 14, color: Colors.grey),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
    ],
  );

  Widget _btn(IconData icon, String label, Color? color, VoidCallback onTap) =>
      TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: color),
        label: Text(label, style: TextStyle(fontSize: 12, color: color)),
        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
      );

  void _confirmReturn() => Get.defaultDialog(
    title: 'Kembalikan?',
    middleText: '${p.nama}\nTotal: ${c.rupiah(p.totalBayar())}',
    textCancel: 'Batal',
    textConfirm: 'OK',
    confirmTextColor: Colors.white,
    buttonColor: const Color(0xFF2E7D32),
    onConfirm: () async {
      await c.returnPinjam(p);
      Get.back();
    },
  );

  void _delete() => Get.defaultDialog(
    title: 'Hapus Data?',
    middleText: 'Data ${p.nama} akan dihapus permanen.',
    textCancel: 'Batal',
    textConfirm: 'Hapus',
    confirmTextColor: Colors.white,
    buttonColor: Colors.red,
    onConfirm: () async {
      await c.removePinjam(p);
      Get.back();
    },
  );

  void _showDetail(BuildContext context) => Get.defaultDialog(
    title: 'Detail Peminjaman',
    content: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${p.nama} • ${p.hp}'),
          Text(
            'Status: ${p.kembali ? 'Selesai' : 'Aktif'}',
            style: const TextStyle(color: Colors.grey),
          ),
          const Divider(),
          Text('${p.hari} hari  •  ${p.jumlahBarang()} barang'),
          const SizedBox(height: 8),
          ...p.items.map(
            (i) => Text(
              '${i.jumlah}x ${i.nama} = ${c.rupiah(i.total() * p.hari)}',
            ),
          ),
          const Divider(),
          Text(
            'Total: ${c.rupiah(p.totalBayar())}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
    actions: [
      if (!p.kembali)
        TextButton.icon(
          onPressed: () {
            Get.back();
            Get.to(() => FormPage(controller: c, edit: p));
          },
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
        ),
      TextButton(onPressed: Get.back, child: const Text('Tutup')),
    ],
  );
}
