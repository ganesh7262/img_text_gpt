import 'package:flutter/material.dart';
import 'package:img_text_gpt/assets/history_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../assets/convo_block.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Widget defaultScreen() {
    return const Center(
      child: Text("No History Found"),
    );
  }

  Padding ifHistory(HistoryModel history) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: history.totalConvo,
        itemBuilder: (context, index) {
          return ConvoBlock(
              prompt: history.hist[index].prompt,
              gptResponse: history.hist[index].gptResponse);
        },
      ),
    );
  }

  Widget displayMainContent(HistoryModel history) {
    if (history.hist.isEmpty) return defaultScreen();
    return ifHistory(history);
  }

  String getCurrentDate() {
    final formatter = DateFormat.yMd();
    return formatter.format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryModel>(
      builder: (context, history, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Conversation History'),
            actions: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(getCurrentDate()),
              )
            ],
          ),
          body: displayMainContent(history),
        );
      },
    );
  }
}
