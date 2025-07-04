// 📄 lib/screens/book_reading_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../model/coin_chapter.dart';
import '../widget/coin_animation.dart';

class BookReadingScreen extends StatefulWidget {
  const BookReadingScreen({super.key});

  @override
  State<BookReadingScreen> createState() => _BookReadingScreenState();
}

class _BookReadingScreenState extends State<BookReadingScreen>
    with TickerProviderStateMixin {
  final User user = User();
  List<Chapter> chapters = [];
  bool isSlidingMode = true;

  final GlobalKey coinBalanceKey = GlobalKey();
  final Map<int, GlobalKey> unlockButtonKeys = {};

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    loadChaptersFromJson();
  }

  Future<void> loadChaptersFromJson() async {
    final String jsonString = await rootBundle.loadString(
      'lib/assets/chapter.json',
    );
    final List<dynamic> jsonData = json.decode(jsonString);
    final loadedChapters = jsonData.map((e) => Chapter.fromJson(e)).toList();

    if (loadedChapters.isNotEmpty) {
      loadedChapters[0].isUnlocked = true;
    }

    setState(() {
      chapters = loadedChapters;
    });
  }

  void unlockChapter(int index) {
    if (!chapters[index].isUnlocked && user.coins >= 10) {
      CoinFlyAnimation.fly(
        context: context,
        fromKey: coinBalanceKey,
        toKey: unlockButtonKeys[index]!,
      );

      setState(() {
        user.spendCoins(10);
        chapters[index].isUnlocked = true;
      });
    } else if (chapters[index].isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chapter is already unlocked')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not enough coins')));
    }
  }

  Widget buildChapterReader() {
    if (isSlidingMode) {
      return PageView.builder(
        controller: _pageController,
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: chapter.isUnlocked
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          chapter.content,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('This chapter is locked'),
                    ],
                  ),
          );
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chapter.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              chapter.isUnlocked
                  ? Text(chapter.content, style: const TextStyle(fontSize: 16))
                  : const Text('This chapter is locked'),
              const SizedBox(height: 24),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Reader'),
        actions: [
          IconButton(
            icon: Icon(isSlidingMode ? Icons.menu_book : Icons.view_agenda),
            onPressed: () {
              setState(() {
                isSlidingMode = !isSlidingMode;
              });
            },
          ),
        ],
      ),
      body: chapters.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    key: coinBalanceKey,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        "Coins: ${user.coins}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = chapters[index];
                      return Card(
                        margin: const EdgeInsets.only(right: 12),
                        child: Container(
                          width: 160,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chapter.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  chapter.isUnlocked
                                      ? "Unlocked"
                                      : "Locked - 10 coins",
                                  style: TextStyle(
                                    color: chapter.isUnlocked
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                key: unlockButtonKeys.putIfAbsent(
                                  index,
                                  () => GlobalKey(),
                                ),
                                onPressed: () => unlockChapter(index),
                                child: const Text("Unlock"),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(child: Stack(children: [buildChapterReader()])),
              ],
            ),
    );
  }
}
