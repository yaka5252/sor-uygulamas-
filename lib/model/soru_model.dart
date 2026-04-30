import 'package:cloud_firestore/cloud_firestore.dart';

class SoruModel {
  final String id;
  final String sahibiId;
  final String kategori;
  int derece;
  DateTime gosterilmeZamani;
  final String imageUrl;

  SoruModel({
    required this.id,
    required this.sahibiId,
    required this.kategori,
    required this.derece,
    required this.gosterilmeZamani,
    required this.imageUrl,
  });

  // 1. Veritabanından gelen veriyi (JSON/Map) Dart nesnesine çevirme
  factory SoruModel.fromMap(Map<String, dynamic> data, String documentId) {
    return SoruModel(
      id: documentId, // ID'yi direkt döküman ID'sinden alıyoruz (Daha güvenli)
      sahibiId: data['sahibiId'] ?? '',
      kategori: data['kategori'] ?? '',
      derece: data['derece']?.toInt() ?? 0,
      gosterilmeZamani: (data['gosterilmeZamani'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // 2. Dart nesnesini veritabanına yazılacak formata (JSON/Map) çevirme
  Map<String, dynamic> toMap() {
    return {
      // id'yi genelde döküman adı yaptığımız için içeri kaydetmeye gerek olmayabilir
      // ama sorgularda lazımsa diye ekliyoruz:
      'id': id,
      'sahibiId': sahibiId,
      'kategori': kategori,
      'derece': derece,
      // Veritabanına kaydederken DateTime'ı tekrar Timestamp'e çeviriyoruz
      'gosterilmeZamani': Timestamp.fromDate(gosterilmeZamani),
      'imageUrl': imageUrl,
    };
  }

  // 3. Mevcut nesnenin sadece belli alanlarını değiştirerek kopyalamak için (State yönetimi için çok faydalıdır)
  SoruModel copyWith({
    String? id,
    String? sahibiId,
    String? kategori,
    int? derece,
    DateTime? gosterilmeZamani,
    String? imageUrl,
  }) {
    return SoruModel(
      id: id ?? this.id,
      sahibiId: sahibiId ?? this.sahibiId,
      kategori: kategori ?? this.kategori,
      derece: derece ?? this.derece,
      gosterilmeZamani: gosterilmeZamani ?? this.gosterilmeZamani,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
