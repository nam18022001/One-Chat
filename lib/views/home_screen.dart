import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:one_chat_rebuild/services/auth.dart';
import 'package:one_chat_rebuild/services/database_users.dart';
import 'package:one_chat_rebuild/views/add_screen.dart';
import 'package:one_chat_rebuild/views/call/pickup/pickup_layout.dart';
import 'package:one_chat_rebuild/widgets/category_selector.dart';
import 'package:one_chat_rebuild/widgets/recent_chats.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key, @required this.auth}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();

  final AuthBase auth;
}

class _HomeScreenState extends State<HomeScreen> {
  //
  String myUid = FirebaseAuth.instance.currentUser.uid;
  UserMethod userMethod = new UserMethod();

  @override
  void initState() {
    Timer(Duration(seconds: 3), () {
      _getFCMToken();
    });
    super.initState();
  }

  Future<void> _getFCMToken() async {
    const yourVapidKey =
        "BD4VpW1bTMfGrYwNUWfidI86-9V7gTzo2ocUkIZweCc45MEwHFsNuL14XP8QD6e5IB0Ol7KwliRY9knihX6hLfk";

    String token =
        await FirebaseMessaging.instance.getToken(vapidKey: yourVapidKey);
    await userMethod.updateFcmToken(myUid, token);
  }

  Future<void> signOut() async {
    UserMethod().deleteFcmToken(myUid);
    try {
      await widget.auth.singOut();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(
              FirebaseAuth.instance.currentUser.photoURL,
            ),
          ),
          title: Text(
            "Chats",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              fontFamily: "Times",
            ),
          ),
          actions: [
            GestureDetector(
              onTap: signOut,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Icon(
                  Icons.exit_to_app_rounded,
                ),
              ),
            ),
            IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => super.widget,
                    ),
                  );
                })
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async => await Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddScreen())),
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Container(
          child: Column(
            children: [
              CategorySelector(),
              Expanded(
                child: Container(
                  height: 500,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListChatUser(
                        context: context,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
