import 'dart:collection';
import 'package:flutter/material.dart';

class PromptAns {
  PromptAns({required this.prompt, required this.gptResponse});
  String prompt;
  String gptResponse;
}

class HistoryModel extends ChangeNotifier {
  /// this model is used to keeptrack of the history of conversation.
  final List<PromptAns> _list = [];

  UnmodifiableListView<PromptAns> get hist => UnmodifiableListView(_list);

  int get totalConvo => _list.length;

  void addToHist(PromptAns pa) {
    _list.add(pa);
    notifyListeners();
  }

  void clearHistory() {
    _list.clear();
    notifyListeners();
  }
}
