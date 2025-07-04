import 'package:flutter/foundation.dart';

class Chapter {
  final String title;
  final String content;
  bool isUnlocked;

  Chapter({
    required this.title,
    required this.content,
    this.isUnlocked = false,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      title: json['title'],
      content: json['content'],
    );
  }
}

class User with ChangeNotifier {
  int coins = 100;

  void spendCoins(int amount) {
    if (coins >= amount) {
      coins -= amount;
      notifyListeners();
    }
  }

  void addCoins(int amount) {
    coins += amount;
    notifyListeners();
  }
}
