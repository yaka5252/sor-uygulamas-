import 'package:flutter/material.dart';
import 'package:flutter_soru_cozum/provider/user_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    UserProvider _userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.grey),
            ),
            elevation: 3,
          ),
          icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
          label: const Text(
            "Google ile giriş yap",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          onPressed: () async {
            await _userProvider.signInWithGoogle();
            // Buraya Google SignIn fonksiyonunu ekleyeceğiz
          },
        ),
      ),
    );
  }
}
