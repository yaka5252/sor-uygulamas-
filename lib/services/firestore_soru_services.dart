import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_soru_cozum/model/soru_model.dart';

class FirestoreSoruServices {
  final FirebaseFirestore _firebaseStore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> _uploadImage(File imageFile) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    Reference ref = _storage.ref().child('sorular').child(fileName);

    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;

    return await snapshot.ref.getDownloadURL();
  }

  Future<void> soruEkle(SoruModel soru, File imageFile) async {
    String imageUrl = await _uploadImage(imageFile);

    final yeniSoru = SoruModel(
      id: _firebaseStore.collection('sorular').doc().id,
      sahibiId: soru.sahibiId,
      kategori: soru.kategori,
      derece: soru.derece,
      gosterilmeZamani: DateTime.now(),
      imageUrl: imageUrl,
    );

    await _firebaseStore
        .collection('sorular')
        .doc(yeniSoru.id)
        .set(yeniSoru.toMap());
  }

  Future<SoruModel?> soruGetir(String soruId) async {
    final doc = await _firebaseStore.collection('sorular').doc(soruId).get();

    if (doc.exists && doc.data() != null) {
      return SoruModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Filtreli soru getirme (parametre geçilmezse random getirir)
  Future<List<SoruModel>> soruGetirFiltreli({
    DateTime? gosterilmeZamani,
    String? sahibiId,
    String? kategori,
    int limit = 10,
  }) async {
    if (gosterilmeZamani == null && sahibiId == null && kategori == null) {
      return _soruGetirRandom(limit);
    }

    Query query = _firebaseStore.collection('sorular');

    if (sahibiId != null) {
      query = query.where('sahibiId', isEqualTo: sahibiId);
    }
    if (kategori != null) {
      query = query.where('kategori', isEqualTo: kategori);
    }
    if (gosterilmeZamani != null) {
      query = query.where(
        'gosterilmeZamani',
        isLessThanOrEqualTo: Timestamp.fromDate(gosterilmeZamani),
      );
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs.map((doc) {
      return SoruModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  // Random soru getirir
  Future<List<SoruModel>> _soruGetirRandom(int limit) async {
    final querySnapshot = await _firebaseStore.collection('sorular').get();

    if (querySnapshot.docs.isEmpty) return [];

    final docs = List.of(querySnapshot.docs)..shuffle(Random());
    final selectedDocs = docs.take(limit).toList();

    return selectedDocs.map((doc) {
      return SoruModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  // Soru sil (Firestore + Storage)
  Future<void> soruSil(String soruId, String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {
      // Resim zaten silinmiş olabilir
    }
    await _firebaseStore.collection('sorular').doc(soruId).delete();
  }

  // Soru güncelle
  Future<void> soruGuncelle(String soruId, SoruModel guncelVeri) async {
    await _firebaseStore
        .collection('sorular')
        .doc(soruId)
        .update(guncelVeri.toMap());
  }

  // Real-time stream (UI'da anlık güncelleme için)
  Stream<List<SoruModel>> soruStreamFiltreli({
    String? sahibiId,
    String? kategori,
    int limit = 20,
  }) {
    Query query = _firebaseStore.collection('sorular');

    if (sahibiId != null) {
      query = query.where('sahibiId', isEqualTo: sahibiId);
    }
    if (kategori != null) {
      query = query.where('kategori', isEqualTo: kategori);
    }

    return query.limit(limit).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SoruModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Soru sayısı getir
  Future<int> soruSayisiGetir({String? sahibiId, String? kategori}) async {
    Query query = _firebaseStore.collection('sorular');

    if (sahibiId != null) {
      query = query.where('sahibiId', isEqualTo: sahibiId);
    }
    if (kategori != null) {
      query = query.where('kategori', isEqualTo: kategori);
    }

    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }
}
