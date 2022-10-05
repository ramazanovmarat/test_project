import 'package:flutter/material.dart';

import 'news_model.dart';

class NewsDetail extends StatelessWidget {
  final SportsNews sportsNews;
  const NewsDetail({Key? key, required this.sportsNews}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports news'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(sportsNews.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
              const SizedBox(height: 20),
              Image.network(sportsNews.image),
              const SizedBox(height: 20),
              Text(sportsNews.description, style: const TextStyle(fontSize: 18),),
            ],
          ),
        ),
      ),
    );
  }
}
