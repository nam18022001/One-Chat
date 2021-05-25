import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:one_chat_rebuild/services/auth.dart';
import 'package:one_chat_rebuild/services/database_users.dart';
import 'package:one_chat_rebuild/sign_in/sign_in_page.dart';
import 'package:one_chat_rebuild/views/home_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key key, @required this.auth}) : super(key: key);

  final AuthBase auth;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User user = snapshot.data;
          if (user != null) {
            UserMethod().addUser();
            return HomeScreen(
              auth: auth,
            );
          } else {
            return SignIn(
              auth: auth,
            );
          }
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
