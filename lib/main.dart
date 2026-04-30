import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soru_cozum/firebase_options.dart';
import 'package:flutter_soru_cozum/locator/locator.dart';
import 'package:flutter_soru_cozum/pages/landing_page/landing_page.dart';
import 'package:flutter_soru_cozum/provider/soru_provider.dart';
import 'package:flutter_soru_cozum/provider/user_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<UserProvider>()),
        ChangeNotifierProvider(create: (_) => locator<SoruProvider>()),
      ],
      child: MaterialApp(
        title: 'Soru Çözüm',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: LandingPage(),
      ),
    );
  }
}
