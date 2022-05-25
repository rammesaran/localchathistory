import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localchathistory/data/databasehelper.dart';
import 'package:localchathistory/utils/commonutlis.dart';
import 'package:localchathistory/view/chatscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    CommonUtils.sharedPreferences = prefs;

    /// instance of databasehelper
    DatabaseHelper databaseHelper = DatabaseHelper();

    /// accessing db
    await databaseHelper.db;

    runApp(
      const MyApp(),
    );
  }, (error, stack) {
    print("Exception from widgets error is $error");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChatScreen(),
    );
  }
}
