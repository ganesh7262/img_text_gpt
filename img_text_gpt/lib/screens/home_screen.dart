import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _promptController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ImgTextGPT")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          const Expanded(
            child: Text("welcome"),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  minLines: 1,
                  maxLines: null,
                  autocorrect: true,
                  enableSuggestions: true,
                  controller: _promptController,
                  decoration:
                      const InputDecoration(label: Text("Enter a Prompt")),
                ),
              ),
              IconButton(
                  onPressed: () {
                    print("test");
                  },
                  icon: const Icon(Icons.send)),
            ],
          )
        ]),
      ),
    );
  }
}
