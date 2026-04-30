import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_soru_cozum/model/user_model.dart';

class FirestoreUserServices {
  final FirebaseFirestore _firebaseStore = FirebaseFirestore.instance;

  // Save user data to Firestore
  Future<bool> saveUser(UserModel user) async {
    try {
      // Check if user already exists
      DocumentSnapshot existingUser = await _firebaseStore
          .collection("users")
          .doc(user.id)
          .get();

      if (existingUser.exists) {
        // Update existing user
        await _firebaseStore
            .collection("users")
            .doc(user.id)
            .update(user.toMap());
      } else {
        // Create new user
        await _firebaseStore
            .collection("users")
            .doc(user.id)
            .set(user.toMap(), SetOptions(merge: true));
      }
      return true;
    } catch (e) {
      print("Error saving user: $e");
      return false;
    }
  }

  // Read user data from Firestore
  Future<UserModel?> readUser(String id) async {
    try {
      DocumentSnapshot _okunanUser = await _firebaseStore
          .doc("users/$id")
          .get();

      if (_okunanUser.data() != null) {
        Map<String, dynamic> okunanUserBilgileriMap =
            _okunanUser.data() as Map<String, dynamic>;

        UserModel _okunanUserBilgileriNesnesi = UserModel.fromMap(
          okunanUserBilgileriMap,
        );

        return _okunanUserBilgileriNesnesi;
      }
      return null;
    } catch (e) {
      print("Error reading user: $e");
      return null;
    }
  }

  // Update user data in Firestore
  Future<bool> updateUser(UserModel user) async {
    try {
      await _firebaseStore
          .collection("users")
          .doc(user.id)
          .update(user.toMap());
      return true;
    } catch (e) {
      print("Error updating user: $e");
      return false;
    }
  }
}
