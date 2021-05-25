import 'package:flutter/material.dart';
import 'package:one_chat_rebuild/services/auth.dart';
import 'package:one_chat_rebuild/widgets/app_bar_widget.dart';

class SignIn extends StatelessWidget {
  //
  const SignIn({
    Key key,
    @required this.auth,
  }) : super(key: key);
  //
  final AuthBase auth;

  Future<void> _signInWithGoogle() async {
    try {
      await auth.signInWithGoogle();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar("Sign In", []),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "Continue to One Chat",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontFamily: "Verdana",
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          RaisedButton(
            onPressed: _signInWithGoogle,
            color: Colors.white,
            padding: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset("assets/images/google-logo.png"),
                Text(
                  "Sign In with Google",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Times",
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Opacity(
                  opacity: 0.0,
                  child: Image.asset("assets/images/google-logo.png"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
