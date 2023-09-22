import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:img_text_gpt/history_model.dart';
import 'package:provider/provider.dart';

class ConvoBlock extends StatelessWidget {
  const ConvoBlock(
      {super.key, required this.prompt, required this.gptResponse});
  final String prompt;
  final String gptResponse;

  void clipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: gptResponse));
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("copied to clickboard"),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 100),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => clipboard(context),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prompt,
              ),
              const SizedBox(
                height: 5,
              ),
              const Divider(),
              Text(
                gptResponse,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: history.totalConvo,
              itemBuilder: (context, index) {
                return ConvoBlock(
                    prompt: history.hist[index].prompt,
                    gptResponse: history.hist[index].gptResponse);
              },
            ),
          ),
        );
      },
    );
  }
}
