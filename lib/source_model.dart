import 'package:flutter/material.dart';

class Item {
  // Private fields
  String _name;
  dynamic _icon;
  String _image;
  String _desc;
  String _spec;
  String _harga;

  // Getter
  String get name => _name;
  dynamic get icon => _icon;
  String get image => _image;
  String get desc => _desc;
  String get spec => _spec;
  String get harga => _harga;

  // Setter (opsional)
  set name(String value) => _name = value;
  set icon(dynamic value) => _icon = value;
  set image(String value) => _image = value;
  set desc(String value) => _desc = value;
  set spec(String value) => _spec = value;
  set harga(String value) => _harga = value;

  Item(this._name, this._icon, this._image, this._desc, this._spec, this._harga);

  String getDetail() => '$_desc\nSpesifikasi: $_spec\nHarga: $_harga';
}

// Inheritance
class VapeItem extends Item {
  String _vapeType;
  String get vapeType => _vapeType;
  set vapeType(String value) => _vapeType = value;

  VapeItem(
    String name,
    dynamic icon,
    String image,
    String desc,
    String spec,
    String harga,
    String vapeType, // parameter konstruktor
  ) : _vapeType = vapeType, // inisialisasi field private
      super(name, icon, image, desc, spec, harga);

  @override
  String getDetail() => 'Tipe: $_vapeType\n${super.getDetail()}';
}

// Daftar barang
final List<Item> items = [
  VapeItem(
    'Vape',
    Icons.smoking_rooms,
    'assets/images/vape.png',
    'Vape MOD HEXOHM.',
    'Power: 200W, Potensio',
    'Rp 3.000.000',
    'Mod',
  ),
  VapeItem(
    'AIO',
    Icons.bolt,
    'assets/images/aio.png',
    'AIO DOT.',
    'Power:  80W',
    'Rp 1.000.000',
    'All In One',
  ),
  Item(
    'Pod',
    Icons.bubble_chart,
    'assets/images/pod.png',
    'Pod simple dan praktis.',
    'Kapasitas: 2ml, Baterai: 1000mAh',
    'Rp 350.000',
  ),
  Item(
    'Kapas',
    Icons.cloud,
    'assets/images/kapas.png',
    'Kapas Bacon untuk vape.',
    'Isi: 10g, Material: Organik',
    'Rp 85.000',
  ),
  Item(
    'Baterai',
    Icons.battery_full,
    'assets/images/baterai.png',
    'Baterai Vrk series untuk vape.',
    'Kapasitas: mulai 2500mAh, Tipe: 18650 dan 21700',
    'Rp 120.000-150.000',
  ),
  Item(
    'Liquid',
    Icons.opacity,
    'assets/images/liquid.png',
    'liquid lunar ice cream',
    'kapasitas: 60ml & 30ml Nikotin: 3mg, 6mg, 15mg, dan 30mg',
    'Rp 155.000 & 120.000',
  ),
  Item(
    'Coil',
    Icons.all_inclusive,
    'assets/images/coil.png',
    'Coil awet dan mudah dipasang.',
    'Ukuran: 2.5mm dan 3mm',
    'Rp 50.000',
  ),
];