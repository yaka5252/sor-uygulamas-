import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_soru_cozum/locator/locator.dart';
import 'package:flutter_soru_cozum/model/soru_model.dart';
import 'package:flutter_soru_cozum/provider/soru_provider.dart';
import 'package:flutter_soru_cozum/provider/user_provider.dart';
import 'package:image_picker/image_picker.dart';

class HomePageProvider extends ChangeNotifier {
  final SoruProvider _soruProvider = locator<SoruProvider>();
  final UserProvider _userProvider = locator<UserProvider>();

  bool _busy = false;
  bool get busy => _busy;

  File? _secilenFoto;
  File? get secilenFoto => _secilenFoto;

  String _secilenKategori = 'Matematik';
  String get secilenKategori => _secilenKategori;

  final List<String> kategoriler = ['Matematik', 'Türkçe', 'Tarih', 'Coğrafya'];

  // Fotoğraf çek
  Future<void> fotoCek() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      _secilenFoto = File(pickedFile.path);
      notifyListeners();
    }
  }

  // Galeri'den seç
  Future<void> galeridenSec() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      _secilenFoto = File(pickedFile.path);
      notifyListeners();
    }
  }

  // Kategori seç
  void kategoriSec(String kategori) {
    _secilenKategori = kategori;
    notifyListeners();
  }

  // Fotoğrafı temizle
  void fotoTemizle() {
    _secilenFoto = null;
    notifyListeners();
  }

  // Soru kaydet
  Future<bool> soruKaydet() async {
    if (_secilenFoto == null) return false;

    _busy = true;
    notifyListeners();

    try {
      final soru = SoruModel(
        id: '',
        sahibiId: _userProvider.userModel?.id ?? '',
        kategori: _secilenKategori,
        derece: 1,
        gosterilmeZamani: DateTime.now(),
        imageUrl: '',
      );

      bool sonuc = await _soruProvider.soruEkle(soru, _secilenFoto!);

      if (sonuc) {
        _secilenFoto = null;
      }

      _busy = false;
      notifyListeners();
      return sonuc;
    } catch (e) {
      debugPrint('Soru kaydedilemedi: $e');
      _busy = false;
      notifyListeners();
      return false;
    }
  }
}
