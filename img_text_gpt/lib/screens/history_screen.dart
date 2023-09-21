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
      builder: (context, history, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Conversation History'),
          ),
          body: ListView.builder(
            itemCount: history.totalConvo,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(history.hist[index].gptResponse),
              );
            },
          ),
        );
      },
    );
  }
}
