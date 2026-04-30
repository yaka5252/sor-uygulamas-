import 'package:flutter_soru_cozum/provider/soru_provider.dart';
import 'package:flutter_soru_cozum/provider/user_provider.dart';
import 'package:flutter_soru_cozum/services/firebase_auth_services.dart';
import 'package:flutter_soru_cozum/services/firestore_soru_services.dart';
import 'package:get_it/get_it.dart';

import 'package:flutter_soru_cozum/services/firestore_user_services.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<FirestoreUserServices>(
    () => FirestoreUserServices(),
  );
  locator.registerLazySingleton<FirebaseAuthServices>(
    () => FirebaseAuthServices(),
  );
  locator.registerLazySingleton<UserProvider>(() => UserProvider());
  locator.registerLazySingleton<FirestoreSoruServices>(
    () => FirestoreSoruServices(),
  );
  locator.registerLazySingleton<SoruProvider>(() => SoruProvider());
}
