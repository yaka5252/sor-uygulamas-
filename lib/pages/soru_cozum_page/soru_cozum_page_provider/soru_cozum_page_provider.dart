import 'package:flutter/foundation.dart';
import 'package:flutter_soru_cozum/locator/locator.dart';
import 'package:flutter_soru_cozum/model/soru_model.dart';
import 'package:flutter_soru_cozum/provider/soru_provider.dart';

class SoruCozumPageProvider extends ChangeNotifier {
  final SoruProvider _soruProvider = locator<SoruProvider>();

  int _mevcutSoruIndex = 0;
  int get mevcutSoruIndex => _mevcutSoruIndex;

  // Soruları ana provider'dan çekiyoruz
  List<SoruModel> get sorular => _soruProvider.sorular;

  // Ekrandaki güncel soru
  SoruModel? get mevcutSoru =>
      (sorular.isNotEmpty && _mevcutSoruIndex < sorular.length)
      ? sorular[_mevcutSoruIndex]
      : null;

  bool get soruKaldi => _mevcutSoruIndex < sorular.length;
  bool get busy => _soruProvider.state == ViewState.Busy;

  // Soruları yükle
  Future<void> sorulariYukle(String kategori) async {
    _mevcutSoruIndex = 0;
    await _soruProvider.sorulariGetir(kategori);
    notifyListeners();
  }

  // Soruyu kaydırdığında ÇAĞRILACAK TEK METOT
  void soruCevapla(bool dogruMu) {
    if (mevcutSoru != null) {
      // 1. Veritabanı güncellemesini arka plana at (Arayüz donmasın)
      _soruProvider.soruDereceGuncelle(mevcutSoru!, dogruMu);

      // 2. Anında indexi artırıp sonraki soruya geç
      _mevcutSoruIndex++;
      notifyListeners();
    }
  }

  // Durumu sıfırla (Kategori değiştirilirken kullanılabilir)
  void sifirla() {
    _mevcutSoruIndex = 0;
    notifyListeners();
  }
}
