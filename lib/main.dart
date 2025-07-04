import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screen/book_reading_screen.dart';
import 'model/coin_chapter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Reading App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Provider<User>(
        create: (context) => User(),
        child: BookReadingScreen(),
      )
    );
  }
}
