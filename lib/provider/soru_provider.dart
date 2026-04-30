import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_soru_cozum/locator/locator.dart';
import 'package:flutter_soru_cozum/model/soru_model.dart';
import 'package:flutter_soru_cozum/services/firestore_soru_services.dart';

enum ViewState { Idle, Busy }

class SoruProvider extends ChangeNotifier {
  final FirestoreSoruServices _soruServices = locator<FirestoreSoruServices>();

  ViewState _state = ViewState.Idle;
  ViewState get state => _state;

  List<SoruModel> _sorular = [];
  List<SoruModel> get sorular => _sorular;

  set state(ViewState value) {
    _state = value;
    notifyListeners();
  }

  // Kategoriye göre soruları getir (gösterilme zamanı gelmiş olanlar)
  Future<void> sorulariGetir(String kategori) async {
    try {
      state = ViewState.Busy;
      _sorular = await _soruServices.soruGetirFiltreli(
        kategori: kategori,
        gosterilmeZamani: DateTime.now(),
      );
      state = ViewState.Idle;
    } catch (e) {
      debugPrint('Sorular getirilemedi: $e');
      state = ViewState.Idle;
    }
  }

  // Random sorular getir
  Future<void> sorulariGetirRandom() async {
    try {
      state = ViewState.Busy;
      _sorular = await _soruServices.soruGetirFiltreli();
      state = ViewState.Idle;
    } catch (e) {
      debugPrint('Random sorular getirilemedi: $e');
      state = ViewState.Idle;
    }
  }

  // Soru ekle
  Future<bool> soruEkle(SoruModel soru, File imageFile) async {
    try {
      state = ViewState.Busy;
      await _soruServices.soruEkle(soru, imageFile);
      state = ViewState.Idle;
      return true;
    } catch (e) {
      debugPrint('Soru eklenemedi: $e');
      state = ViewState.Idle;
      return false;
    }
  }

  // Soru sil
  Future<bool> soruSil(String soruId, String imageUrl) async {
    try {
      await _soruServices.soruSil(soruId, imageUrl);
      _sorular.removeWhere((s) => s.id == soruId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Soru silinemedi: $e');
      return false;
    }
  }

  // Soruyu Cevapla ve Derece/Tarih Güncelle
  // (Not: UI anında kaysın diye bu metot arka planda çalışır)
  Future<bool> soruDereceGuncelle(SoruModel soru, bool dogruMu) async {
    int yeniDerece = dogruMu
        ? (soru.derece + 1).clamp(1, 3)
        : (soru.derece - 1).clamp(1, 3);

    // Yorum satırındaki kuralını koda döktük: Zaman atlama mantığı
    DateTime yeniTarih = DateTime.now();
    if (yeniDerece == 1) {
      yeniTarih = yeniTarih.add(const Duration(days: 1));
    } else if (yeniDerece == 2) {
      yeniTarih = yeniTarih.add(const Duration(days: 4));
    } else if (yeniDerece == 3) {
      yeniTarih = yeniTarih.add(const Duration(days: 12));
    }

    soru.derece = yeniDerece;
    soru.gosterilmeZamani = yeniTarih;

    try {
      await _soruServices.soruGuncelle(soru.id, soru);
      // Yerel listeyi de güncelle
      int index = _sorular.indexWhere((element) => element.id == soru.id);
      if (index != -1) {
        _sorular[index] = soru;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Derece güncellenemedi: $e');
      return false;
    }
  }
}
