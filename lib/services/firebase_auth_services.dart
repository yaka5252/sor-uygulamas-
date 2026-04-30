import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_soru_cozum/model/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthServices {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserModel? _userFromFirebase(User? user) {
    // ignore: unnecessary_null_comparison
    if (user == null) return null;

    return UserModel(name: null, mail: user.email!, id: user.uid);
  }

  Future<UserModel?> getUserData() async {
    try {
      User? _user = await _firebaseAuth.currentUser;

      return _userFromFirebase(_user);
    } catch (e) {
      throw Exception("currentUser hata : $e");
    }
  }

  Future<bool> signOut() async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.signOut();
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      // 0. ÖNCE YAPILANDIRMA (İŞTE EKSİK OLAN KISIM BURASI)
      await GoogleSignIn.instance.initialize(
        // Buraya kendi Firebase Web Client ID'ni yazmayı unutma!
        serverClientId:
            "677987214244-omj0a63b5lgltdm7gilq50jcmvq69rmk.apps.googleusercontent.com",
      );

      // 1. Kullanıcıyı doğrula (Kimlik Doğrulaması)
      final googleUser = await GoogleSignIn.instance.authenticate();

      // Kullanıcı pencereyi kapatıp vazgeçerse işlemi iptal et ve null dön

      // idToken'ı alıyoruz
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      // 2. Yetkilendirmeleri al (accessToken buradan gelecek)
      final authClient = googleUser.authorizationClient;

      // Gerekli yetkiler (scope) daha önce verilmiş mi diye sessizce kontrol et
      var authorization = await authClient.authorizationForScopes([
        'email',
        'profile',
      ]);

      // Eğer daha önce yetki verilmemişse veya accessToken boşsa, onay ekranı çıkart
      authorization ??= await authClient.authorizeScopes(['email', 'profile']);

      final accessToken = authorization.accessToken;

      // 3. Hem idToken hem de accessToken ile Firebase Credential oluştur
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      // 4. Firebase'e giriş yap
      await FirebaseAuth.instance.signInWithCredential(credential);

      print("Giriş Başarılı!");
      final user = FirebaseAuth.instance.currentUser;
      return _userFromFirebase(user);
    } catch (e) {
      print("Google Giriş Hatası: $e");
      return null;
    }
  }
}
