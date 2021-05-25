import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:one_chat_rebuild/call_method/call.dart';
import 'package:one_chat_rebuild/call_method/call_method.dart';
import 'package:one_chat_rebuild/views/call/pickup/pickup_screen.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  PickupLayout({@required this.scaffold});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          callMethods.callStream(uid: FirebaseAuth.instance.currentUser.uid),
      builder: (context, snappp) {
        if (snappp.hasData && snappp.data.data() != null) {
          Call call = Call.fromMap(snappp.data.data());
          if (call.hasDialled == false) {
            return PickUpScreen(call: call);
          }
          // print(snappp.data.data());
        }
        return scaffold;
      },
    );
  }
}
