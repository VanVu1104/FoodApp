import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar customAppBar(BuildContext context, String title) {
  return AppBar(
    scrolledUnderElevation: 0,
    backgroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      icon: Icon(CupertinoIcons.back, size: 32 , color: Colors.black),
      onPressed: () => Navigator.pop(context),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
    centerTitle: true,
  );
}