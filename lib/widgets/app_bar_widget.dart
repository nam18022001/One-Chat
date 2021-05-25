import 'package:flutter/material.dart';

Widget CustomAppBar(
  String text_title,
  List<Widget> action,
) {
  return AppBar(
    title: Text(
      text_title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.bold,
        fontFamily: "Times",
      ),
    ),
    // titleSpacing: 100.0,
    actions: action,
    elevation: 10,
    // toolbarHeight: ,
  );
}
