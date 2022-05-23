import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localchathistory/data/databasehelper.dart';
import 'package:localchathistory/view/chatscreen.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    /// instance of databasehelper
    DatabaseHelper databaseHelper = DatabaseHelper();

    /// accessing db
    databaseHelper.db;

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
