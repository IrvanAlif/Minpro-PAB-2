import 'package:get/get.dart';
import '../config/supabase_client.dart';
import '../models/models.dart';

class RentalController extends GetxController {
  final _client = SupabaseConfig.client;

  final alatList = <Alat>[].obs;
  final pinjamList = <Pinjam>[].obs;
  final isLoading = false.obs;

  Future<void> init() async {
    await fetchAlat();
    await fetchPinjaman();
  }

  String rupiah(int n) {
    String s = n.toString();
    String hasil = '';
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      hasil = '${s[i]}$hasil';
      count++;
      if (count == 3 && i != 0) {
        hasil = '.$hasil';
        count = 0;
      }
    }
    return 'Rp $hasil';
  }

  // ─────────────── FETCH ALAT ───────────────
  Future<void> fetchAlat() async {
    try {
      final response = await _client.from('alat').select().order('nama');
      alatList.value = (response as List)
          .map(
            (row) => Alat(
              row['nama'] as String,
              row['stok'] as int,
              row['harga'] as int,
              id: row['id'] as String,
            ),
          )
          .toList();
    } catch (e) {
      Get.snackbar(
        'Kesalahan',
        'Gagal memuat alat: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ─────────────── READ ───────────────
  Future<void> fetchPinjaman() async {
    try {
      isLoading.value = true;

      final response = await _client
          .from('peminjaman')
          .select()
          .order('created_at', ascending: false);

      final itemsResponse = await _client.from('peminjaman_items').select();

      for (var a in alatList) {
        a.dipinjam = 0;
      }

      final List<Pinjam> result = [];
      for (final row in response as List) {
        final items = (itemsResponse as List)
            .where((item) => item['peminjaman_id'] == row['id'])
            .map(
              (itemRow) => Item(
                itemRow['nama_alat'] as String,
                itemRow['jumlah'] as int,
                itemRow['harga'] as int,
              ),
            )
            .toList();

        final pinjam = Pinjam(
          row['nama'] as String,
          row['hp'] as String,
          row['hari'] as int,
          items,
          kembali: row['kembali'] as bool,
          id: row['id'] as String,
        );

        if (!pinjam.kembali) {
          for (var item in items) {
            _updateStokLocal(item.nama, item.jumlah);
          }
        }

        result.add(pinjam);
      }

      pinjamList.value = result;
    } catch (e) {
      Get.snackbar(
        'Kesalahan',
        'Gagal memuat data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────── CREATE ───────────────
  Future<void> addPinjam(Pinjam pinjam) async {
    try {
      isLoading.value = true;

      final userId = _client.auth.currentUser!.id;

      final response = await _client
          .from('peminjaman')
          .insert({
            'nama': pinjam.nama,
            'hp': pinjam.hp,
            'hari': pinjam.hari,
            'kembali': false,
            'user_id': userId,
          })
          .select()
          .single();

      final String newId = response['id'] as String;

      final itemsPayload = pinjam.items
          .map(
            (i) => {
              'peminjaman_id': newId,
              'nama_alat': i.nama,
              'jumlah': i.jumlah,
              'harga': i.harga,
            },
          )
          .toList();

      await _client.from('peminjaman_items').insert(itemsPayload);

      for (var item in pinjam.items) {
        _updateStokLocal(item.nama, item.jumlah);
      }

      await fetchPinjaman();
    } catch (e) {
      Get.snackbar(
        'Kesalahan',
        'Gagal menyimpan data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────── UPDATE (kembali) ───────────────
  Future<void> returnPinjam(Pinjam pinjam) async {
    try {
      await _client
          .from('peminjaman')
          .update({'kembali': true})
          .eq('id', pinjam.id!);

      for (var item in pinjam.items) {
        _updateStokLocal(item.nama, -item.jumlah);
      }

      pinjam.kembali = true;
      pinjamList.refresh();
    } catch (e) {
      Get.snackbar(
        'Kesalahan',
        'Gagal update status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ─────────────── UPDATE (edit) ───────────────
  Future<void> updatePinjam(Pinjam oldPinjam, Pinjam newPinjam) async {
    try {
      isLoading.value = true;

      for (var item in oldPinjam.items) {
        _updateStokLocal(item.nama, -item.jumlah);
      }

      await _client
          .from('peminjaman')
          .update({
            'nama': newPinjam.nama,
            'hp': newPinjam.hp,
            'hari': newPinjam.hari,
          })
          .eq('id', oldPinjam.id!);

      await _client
          .from('peminjaman_items')
          .delete()
          .eq('peminjaman_id', oldPinjam.id!);

      final itemsPayload = newPinjam.items
          .map(
            (i) => {
              'peminjaman_id': oldPinjam.id,
              'nama_alat': i.nama,
              'jumlah': i.jumlah,
              'harga': i.harga,
            },
          )
          .toList();

      await _client.from('peminjaman_items').insert(itemsPayload);

      for (var item in newPinjam.items) {
        _updateStokLocal(item.nama, item.jumlah);
      }

      await fetchPinjaman();
    } catch (e) {
      Get.snackbar(
        'Kesalahan',
        'Gagal mengupdate data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────── DELETE ───────────────
  Future<void> removePinjam(Pinjam pinjam) async {
    try {
      await _client.from('peminjaman').delete().eq('id', pinjam.id!);

      if (!pinjam.kembali) {
        for (var item in pinjam.items) {
          _updateStokLocal(item.nama, -item.jumlah);
        }
      }

      pinjamList.remove(pinjam);
    } catch (e) {
      Get.snackbar(
        'Kesalahan',
        'Gagal menghapus data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ─────────────── CRUD ALAT ───────────────
  Future<void> addAlat(String nama, int stok, int harga) async {
    try {
      await _client.from('alat').insert({
        'nama': nama,
        'stok': stok,
        'harga': harga,
      });
      await fetchAlat();
    } catch (e) {
      Get.snackbar(
        'Kesalahan',
        'Gagal menambah alat',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateAlat(Alat alat, String nama, int stok, int harga) async {
    try {
      await _client
          .from('alat')
          .update({'nama': nama, 'stok': stok, 'harga': harga})
          .eq('id', alat.id!);
      await fetchAlat();
    } catch (e) {
      Get.snackbar(
        'Kesalahan',
        'Gagal mengupdate alat',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteAlat(Alat alat) async {
    try {
      await _client.from('alat').delete().eq('id', alat.id!);
      alatList.remove(alat);
    } catch (e) {
      Get.snackbar(
        'Kesalahan',
        'Gagal menghapus alat',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ─────────────── HELPER ───────────────
  void _updateStokLocal(String nama, int delta) {
    try {
      final alat = alatList.firstWhere((a) => a.nama == nama);
      alat.dipinjam += delta;
    } catch (_) {}
  }

  int sisaTersedia(Alat alat, List<CartItem> cart, {Pinjam? editPinjam}) {
    int sudahDipilih = 0;
    for (var c in cart) {
      if (c.alat.nama == alat.nama) sudahDipilih += c.qty;
    }
    if (editPinjam == null) return alat.sisa() - sudahDipilih;
    int jumlahLama = 0;
    for (var it in editPinjam.items) {
      if (it.nama == alat.nama) jumlahLama = it.jumlah;
    }
    return (alat.sisa() + jumlahLama) - sudahDipilih;
  }
}
