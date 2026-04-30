import 'package:flutter/material.dart';
import 'package:flutter_soru_cozum/model/soru_model.dart';
import 'package:flutter_soru_cozum/pages/soru_cozum_page/soru_cozum_page_provider/soru_cozum_page_provider.dart';
import 'package:provider/provider.dart';

class SoruCozumPage extends StatelessWidget {
  final String kategori;
  final Color renk;

  const SoruCozumPage({super.key, required this.kategori, required this.renk});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = SoruCozumPageProvider();
        provider.sorulariYukle(kategori);
        return provider;
      },
      child: Consumer<SoruCozumPageProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(kategori),
              backgroundColor: renk,
              foregroundColor: Colors.white,
            ),
            body: provider.busy
                ? const Center(child: CircularProgressIndicator())
                // Eğer liste boşsa veya sorular bittiyse bitiş ekranını göster
                : provider.sorular.isEmpty || !provider.soruKaldi
                ? _bosSoruWidget()
                : _soruKartWidget(context, provider),
          );
        },
      ),
    );
  }

  Widget _bosSoruWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.done_all, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Çözecek soru kalmadı!',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _soruKartWidget(BuildContext context, SoruCozumPageProvider provider) {
    final soru = provider.mevcutSoru;
    if (soru == null) {
      return _bosSoruWidget();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // İlerleme göstergesi
          LinearProgressIndicator(
            value: (provider.mevcutSoruIndex + 1) / provider.sorular.length,
            backgroundColor: Colors.grey[300],
            color: renk,
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.mevcutSoruIndex + 1} / ${provider.sorular.length}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Kaydırmalı soru kartı
          Expanded(
            child: Dismissible(
              key: ValueKey(soru.id),
              direction: DismissDirection.horizontal,
              onDismissed: (direction) {
                // Sola kaydırılırsa false (yanlış), sağa kaydırılırsa true (doğru)
                bool dogruMu = direction == DismissDirection.endToStart
                    ? false
                    : true;

                // Provider'daki fonksiyon hem DB'yi günceller hem de indexi otomatik artırır
                provider.soruCevapla(dogruMu);
              },
              // Arka planlar (Sağa Kaydırırken Altta Çıkan DOĞRU)
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 30),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 50, color: Colors.white),
                    SizedBox(height: 4),
                    Text(
                      'DOĞRU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Arka planlar (Sola Kaydırırken Altta Çıkan YANLIŞ)
              secondaryBackground: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 30),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel, size: 50, color: Colors.white),
                    SizedBox(height: 4),
                    Text(
                      'YANLIŞ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Kartın kendisi
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Derece badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _dereceRenk(soru.derece),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${soru.derece}. Derece',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Soru resmi
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            soru.imageUrl,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 300,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              height: 300,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.broken_image,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Kaydırma ipucu
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_back,
                                color: Colors.green[700],
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '→ Doğru',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Text(
                                '→ Yanlış',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.red[700],
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _dereceRenk(int derece) {
    switch (derece) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
