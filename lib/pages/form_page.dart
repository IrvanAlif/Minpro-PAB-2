import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/rental_service.dart';
import '../models/models.dart';

class FormPage extends StatefulWidget {
  final Pinjam? edit;
  final RentalController controller;
  const FormPage({super.key, this.edit, required this.controller});
  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  late final RentalController ctrl;
  final nama = TextEditingController();
  final hp = TextEditingController();
  int hari = 1;
  List<CartItem> cart = [];

  bool get isEdit => widget.edit != null;
  int get estimasi => cart.fold(0, (s, c) => s + c.alat.harga * c.qty * hari);

  @override
  void initState() {
    super.initState();
    ctrl = widget.controller;
    if (isEdit) {
      nama.text = widget.edit!.nama;
      hp.text = widget.edit!.hp;
      hari = widget.edit!.hari;
      for (var it in widget.edit!.items) {
        for (var a in ctrl.alatList) {
          if (a.nama == it.nama) cart.add(CartItem(a, it.jumlah));
        }
      }
    }
  }

  void simpan() {
    if (nama.text.isEmpty || hp.text.isEmpty || cart.isEmpty) {
      Get.snackbar(
        'Lengkapi Data',
        'Nama, HP, dan barang wajib diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    final p = Pinjam(
      nama.text,
      hp.text,
      hari,
      cart.map((c) => Item(c.alat.nama, c.qty, c.alat.harga)).toList(),
    );
    isEdit ? ctrl.updatePinjam(widget.edit!, p) : ctrl.addPinjam(p);
    Get.back();
  }

  void _showSheet() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            'Pilih Alat',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          child: ListView(
            children: ctrl.alatList
                .where(
                  (a) =>
                      ctrl.sisaTersedia(a, cart, editPinjam: widget.edit) > 0,
                )
                .map((a) {
                  final ada = cart.any((c) => c.alat.nama == a.nama);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(
                        0xFF2E7D32,
                      ).withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.backpack_rounded,
                        color: Color(0xFF2E7D32),
                        size: 18,
                      ),
                    ),
                    title: Text(a.nama),
                    subtitle: Text(
                      '${ctrl.rupiah(a.harga)}/hari  •  sisa ${ctrl.sisaTersedia(a, cart, editPinjam: widget.edit)} unit',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: ada
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.add_circle_outline),
                    onTap: () {
                      if (!ada) {
                        setState(() => cart.add(CartItem(a, 1)));
                        Navigator.pop(context);
                      }
                    },
                  );
                })
                .toList(),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Peminjaman' : 'Pinjam Baru',
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(
            nama,
            'Nama Peminjam',
            Icons.person_outline,
            TextInputType.text,
          ),
          const SizedBox(height: 12),
          _field(hp, 'Nomor HP', Icons.phone_outlined, TextInputType.phone),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  const Text('Jumlah Hari', style: TextStyle(fontSize: 15)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: hari > 1 ? () => setState(() => hari--) : null,
                  ),
                  Text(
                    '$hari',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() => hari++),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Barang${cart.isNotEmpty ? ' (${cart.length})' : ''}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              FilledButton.icon(
                onPressed: _showSheet,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (cart.isEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Belum ada barang',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ...cart.asMap().entries.map((e) {
            final idx = e.key;
            final c = e.value;
            final maks =
                c.qty +
                ctrl.sisaTersedia(c.alat, cart, editPinjam: widget.edit);
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(
                    Icons.backpack_rounded,
                    color: Color(0xFF2E7D32),
                    size: 18,
                  ),
                ),
                title: Text(
                  c.alat.nama,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  ctrl.rupiah(c.alat.harga * c.qty * hari),
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 12,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: c.qty > 1
                          ? () => setState(() => cart[idx].qty--)
                          : null,
                    ),
                    Text(
                      '${c.qty}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: c.qty < maks
                          ? () => setState(() => cart[idx].qty++)
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                      onPressed: () => setState(() => cart.removeAt(idx)),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (cart.isNotEmpty) ...[
            const SizedBox(height: 4),
            Card(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estimasi Total',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      ctrl.rupiah(estimasi),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: simpan,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isEdit ? 'Simpan Perubahan' : 'Simpan Peminjaman',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: Get.back,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Batal'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _field(
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
    ),
  );
}
