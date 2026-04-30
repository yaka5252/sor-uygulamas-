import 'package:flutter/material.dart';
import 'package:flutter_soru_cozum/locator/locator.dart';
import 'package:flutter_soru_cozum/model/user_model.dart';
import 'package:flutter_soru_cozum/services/firebase_auth_services.dart';
import 'package:flutter_soru_cozum/services/firestore_user_services.dart';

enum ViewState { Idle, Busy }

class UserProvider extends ChangeNotifier {
  final FirebaseAuthServices _firebaseAuthServices =
      locator<FirebaseAuthServices>();
  final FirestoreUserServices _firestoreUserServices =
      locator<FirestoreUserServices>();

  ViewState signInDeger = ViewState.Idle;
  UserModel? userModel;

  set state(ViewState value) {
    signInDeger = value;
    notifyListeners();
  }

  UserProvider() {
    currentUser();
    //  getAllMusteri();
  }

  Future<UserModel?> currentUser() async {
    try {
      state = ViewState.Busy;
      UserModel? _user = await _firebaseAuthServices.getUserData();
      UserModel? okunanUser;
      if (_user != null) {
        okunanUser = await _firestoreUserServices.readUser(_user.id);
      }
      userModel = okunanUser;
      state = ViewState.Idle;
      return okunanUser;
    } catch (e) {
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      state = ViewState.Busy;
      UserModel? _user = await _firebaseAuthServices.signInWithGoogle();
      if (_user != null) {
        await _firestoreUserServices.saveUser(_user);

        userModel = await _firestoreUserServices.readUser(_user.id);

        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception(e.toString() + "777");
    } finally {
      state = ViewState.Idle;
    }
  }

  Future<bool> signOut() async {
    state = ViewState.Busy;
    bool foo = await _firebaseAuthServices.signOut();

    userModel = null;
    state = ViewState.Idle;
    return foo;
  }

  updateUser(UserModel user) async {
    await _firestoreUserServices.updateUser(user);
  }
}
