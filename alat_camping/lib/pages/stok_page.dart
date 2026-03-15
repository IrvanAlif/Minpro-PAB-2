import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/rental_service.dart';
import '../models/models.dart';

class StokPage extends StatelessWidget {
  final RentalController controller;
  const StokPage({super.key, required this.controller});

  RentalController get c => controller;

  void _showForm({Alat? edit}) {
    final namaCtrl = TextEditingController(text: edit?.nama ?? '');
    final stokCtrl = TextEditingController(
      text: edit != null ? '${edit.stok}' : '',
    );
    final hargaCtrl = TextEditingController(
      text: edit != null ? '${edit.harga}' : '',
    );

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(Get.context!).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  edit == null ? 'Tambah Alat' : 'Edit Alat',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: Get.back),
              ],
            ),
            const SizedBox(height: 12),
            _sheetField(
              namaCtrl,
              'Nama Alat',
              Icons.backpack_rounded,
              TextInputType.text,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _sheetField(
                    stokCtrl,
                    'Stok',
                    Icons.inventory_rounded,
                    TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _sheetField(
                    hargaCtrl,
                    'Harga/hari',
                    Icons.payments_outlined,
                    TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () async {
                  final nama = namaCtrl.text.trim();
                  final stok = int.tryParse(stokCtrl.text) ?? 0;
                  final harga = int.tryParse(hargaCtrl.text) ?? 0;
                  if (nama.isEmpty || stok <= 0 || harga <= 0) {
                    Get.snackbar(
                      'Lengkapi Data',
                      'Semua field wajib diisi dengan benar',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  Get.back();
                  if (edit == null) {
                    await c.addAlat(nama, stok, harga);
                  } else {
                    await c.updateAlat(edit, nama, stok, harga);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  edit == null ? 'Tambah' : 'Simpan',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(Alat a) => Get.defaultDialog(
    title: 'Hapus Alat?',
    middleText: '"${a.nama}" akan dihapus permanen.',
    textCancel: 'Batal',
    textConfirm: 'Hapus',
    confirmTextColor: Colors.white,
    buttonColor: Colors.red,
    onConfirm: () async {
      Get.back();
      await c.deleteAlat(a);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final total = c.alatList.fold(0, (s, a) => s + a.stok);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _summaryItem(
                      Icons.category_rounded,
                      '${c.alatList.length}',
                      'Jenis Alat',
                    ),
                    const VerticalDivider(width: 32),
                    _summaryItem(
                      Icons.inventory_rounded,
                      '$total',
                      'Total Unit',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...c.alatList.map((a) {
              final sisa = a.sisa();
              final persen = a.stok > 0 ? sisa / a.stok : 0.0;
              final habis = sisa == 0;
              final color = habis
                  ? Colors.red
                  : sisa / a.stok < 0.3
                  ? Colors.orange
                  : Colors.green;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.backpack_rounded,
                              color: color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  '${c.rupiah(a.harga)}/hari',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$sisa / ${a.stok}',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                              Text(
                                habis ? 'Habis' : '${a.dipinjam} dipinjam',
                                style: TextStyle(fontSize: 11, color: color),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: persen,
                          minHeight: 6,
                          color: color,
                          backgroundColor: color.withValues(alpha: 0.1),
                        ),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _showForm(edit: a),
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text(
                              'Edit',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _confirmDelete(a),
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Colors.red,
                            ),
                            label: const Text(
                              'Hapus',
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _summaryItem(IconData icon, String value, String label) => Expanded(
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _sheetField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    TextInputType type,
  ) => TextField(
    controller: ctrl,
    keyboardType: type,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      isDense: true,
    ),
  );
}
