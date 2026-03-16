class Alat {
  String? id;
  String nama;
  int stok, harga, dipinjam;
  Alat(this.nama, this.stok, this.harga, {this.dipinjam = 0, this.id});
  int sisa() => stok - dipinjam;
}

class Item {
  String nama;
  int jumlah, harga;
  Item(this.nama, this.jumlah, this.harga);
  int total() => jumlah * harga;
}

class Pinjam {
  String? id;
  String nama, hp;
  int hari;
  List<Item> items;
  bool kembali;

  Pinjam(
    this.nama,
    this.hp,
    this.hari,
    this.items, {
    this.kembali = false,
    this.id,
  });

  int totalBayar() {
    int t = 0;
    for (var i in items) {
      t += i.total() * hari;
    }
    return t;
  }

  int jumlahBarang() {
    int j = 0;
    for (var i in items) {
      j += i.jumlah;
    }
    return j;
  }
}

class CartItem {
  Alat alat;
  int qty;
  CartItem(this.alat, this.qty);
}
