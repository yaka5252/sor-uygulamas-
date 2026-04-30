import 'package:flutter/foundation.dart';
import 'package:flutter_soru_cozum/locator/locator.dart';
import 'package:flutter_soru_cozum/services/firebase_auth_services.dart';
import 'package:flutter_soru_cozum/model/user_model.dart';
import 'package:flutter_soru_cozum/services/firestore_user_services.dart';

enum ViewState { Idle, Busy }

class SignInPageProvider extends ChangeNotifier {
  ViewState deger = ViewState.Idle;
  final FirebaseAuthServices _firebaseAuthService =
      locator<FirebaseAuthServices>();
  final FirestoreUserServices _firestoreUserServices =
      locator<FirestoreUserServices>();
  set state(ViewState value) {
    deger = value;
    notifyListeners();
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      UserModel? _user = await _firebaseAuthService.signInWithGoogle();
      if (_user != null) {
        await _firestoreUserServices.saveUser(_user);

        return await _firestoreUserServices.readUser(_user.id);
      }
      return null;
    } catch (e) {
      throw Exception(e.toString() + "777");
    }
  }
}
