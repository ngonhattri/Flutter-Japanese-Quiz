import 'package:flutter/material.dart';
import 'package:flutter_jpn_ocr/ui/pages/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Đồ Án Tổng Hợp',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        accentColor: Colors.indigo,
        fontFamily: "Montserrat",
        buttonColor: Colors.amber,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.amber,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          textTheme: ButtonTextTheme.primary
        )
      ),
      home: HomePage(),
    );
  }
}


