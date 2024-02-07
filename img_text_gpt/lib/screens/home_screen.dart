import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:img_text_gpt/assets/history_model.dart';
import 'package:img_text_gpt/screens/history_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? pickedImage;
  final _cameraObj = ImagePicker();
  late InputImage inpImg_ml;
  String recognisedText = "";
  final _modelBottomSheetTextController = TextEditingController();
  final _promptController = TextEditingController();

  /// this is the default response which will be shown.
  String _gptresponse = '''print("Hello world")''';

  final txtRecognizer = TextRecognizer();
  bool _isgettingresponse = false;

  /// this shows the modal bottom sheet which displays the picked image and a preview of extracted text from image
  void _modalBottomDisplayer() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
        isScrollControlled: true,
        useSafeArea: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(child: Image.file(pickedImage!)),
                ),
                const SizedBox(height: 10),
                Card(
                  color: Theme.of(context).colorScheme.background,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      autocorrect: true,
                      controller: _modelBottomSheetTextController,
                      enableSuggestions: true,
                      minLines: 1,
                      maxLines: null,
                      autofocus: false,
                      decoration: const InputDecoration(labelText: "Prompt"),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Send to prompt")),
                )
              ],
            ),
          );
        });
  }

  ///reconginzed the text
  Future _recognizeText() async {
    final txt = await txtRecognizer.processImage(inpImg_ml);
    var prompt = txt.text.split("\n").join(" ");
    recognisedText = prompt;
  }

  /// get image from gallery and reconginze the text
  void _fromGallery() async {
    final galleryImage =
        await _cameraObj.pickImage(source: ImageSource.gallery);
    if (galleryImage == null) return;
    pickedImage = File(galleryImage.path);
    inpImg_ml = InputImage.fromFile(pickedImage!);
    await _recognizeText();
    _modelBottomSheetTextController.text = recognisedText;
    _promptController.text = recognisedText;
    setState(() {});
    _modalBottomDisplayer();
  }

  ///get image from camera and reconginze the text
  void _fromCamera() async {
    final img = await _cameraObj.pickImage(source: ImageSource.camera);
    if (img != null) {
      pickedImage = File(img.path);
    }
    inpImg_ml = InputImage.fromFile(pickedImage!);
    await _recognizeText();
    _modelBottomSheetTextController.text = recognisedText;
    _promptController.text = recognisedText;
    _modalBottomDisplayer();
  }

  Future generateTextUsingGPT3(String prompt) async {
    final apiKey = dotenv.env['token'];

    if (apiKey == null) {
      throw Exception("OpenAI API key not found in .env file");
    }

    const apiUrl = 'https://api.openai.com/v1/completions';

    // Define the request headers and body
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      "model": "gpt-3.5-turbo-instruct",
      "prompt": prompt,
      "max_tokens": 250,
      "temperature": 0,
      "top_p": 1,
    });

    try {
      final response = await post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final generatedText = jsonResponse['choices'][0]['text'];
        _gptresponse = generatedText.toString().trim();

        await Clipboard.setData(ClipboardData(text: _gptresponse));
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("copied to clickboard"),
            behavior: SnackBarBehavior.floating,
            duration: Duration(milliseconds: 100),
          ));
        }
      } else {
        throw Exception(
            "Failed to generate text. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error generating text: $e");
    }
  }

  Widget chatscreen() {
    if (_isgettingresponse) return const CircularProgressIndicator();
    return Text(
      (_gptresponse),
      textAlign: TextAlign.center,
    );
  }

  void showHistory() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HistoryScreen(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("ImgTextGPT"),
        actions: [
          IconButton(onPressed: _fromCamera, icon: const Icon(Icons.camera)),
          IconButton(
            onPressed: _fromGallery,
            icon: const Icon(Icons.collections),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
                onPressed: showHistory, icon: const Icon(Icons.history)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Expanded(
            child: Card(
              child: Center(
                child: chatscreen(),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 15),
              child: Row(
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          child: TextField(
                            minLines: 1,
                            maxLines: null,
                            autocorrect: true,
                            enableSuggestions: true,
                            controller: _promptController,
                            decoration: const InputDecoration(
                                label: Text("Enter a Prompt")),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        if (_promptController.text.trim().isEmpty) return;
                        setState(() {
                          _isgettingresponse = true;
                        });
                        await generateTextUsingGPT3(_promptController.text);
                        if (context.mounted) {
                          PromptAns pa = PromptAns(
                              prompt: _promptController.text,
                              gptResponse: _gptresponse);
                          Provider.of<HistoryModel>(context, listen: false)
                              .addToHist(pa);
                        }
                        _promptController.clear();
                        if (context.mounted) FocusScope.of(context).unfocus();

                        setState(() {
                          _isgettingresponse = false;
                        });
                      },
                      icon: const Icon(Icons.send)),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
