import 'package:flutter/material.dart';
import 'package:invent_track_mobile/auth/login.dart';
import 'package:invent_track_mobile/pages/dashboard.dart';
import 'package:invent_track_mobile/backend/dbconn.dart';
import 'auth/register.dart';
import 'pages/addItems.dart';
import 'pages/updateItems.dart';
import 'pages/viewItems.dart'; // Your dashboard page

void main() async{
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => DashboardPage(),
        '/add': (context) => AddItemPage(),
        '/update': (context) => UpdateItemPage(),
        '/register': (context) => RegisterPage(),
        '/view': (context) => ItemListPage(),

      },
    );
  }
}
