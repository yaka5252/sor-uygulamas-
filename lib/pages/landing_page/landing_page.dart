import 'package:flutter/material.dart';
import 'package:flutter_soru_cozum/pages/home_page/home_page.dart';
import 'package:flutter_soru_cozum/pages/loading_overlay.dart';
import 'package:flutter_soru_cozum/pages/sign_in_page/sign_in_page.dart';
import 'package:flutter_soru_cozum/provider/user_provider.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late UserProvider _userProvider;

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserProvider>(context);
    if (_userProvider.signInDeger == ViewState.Idle) {
      if (_userProvider.userModel == null) {
        return SignInPage();
      } else {
        return HomePage();
      }
    } else {
      return Scaffold(
        body: Center(child: LoadingOverlay(message: "Giriş Yapılıyor")),
      );
    }
  }
}
