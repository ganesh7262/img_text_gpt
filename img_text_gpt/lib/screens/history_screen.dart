import 'package:flutter/material.dart';
import 'package:img_text_gpt/history_model.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Widget defaultScreen() {
    return const Center(
      child: Text("No History Found"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryModel>(
      builder: (context, hist, child) {
        if (hist.totalConvo == 0) {
          return defaultScreen();
        } else {
          return const Scaffold(
            body: Text("has convo"),
          );
        }
      },
    );
  }
}
