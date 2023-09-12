import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Voice Text Editor App')),
        body: const TextEditor(),
      ),
    );
  }
}

class TextEditor extends StatefulWidget {
  const TextEditor({Key? key}) : super(key: key);

  @override
  _TextEditorState createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _texts = [];
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<void> _initializeVoice() async {
  bool available = await _speech.initialize(
    onStatus: (val) => print('onStatus: $val'), 
    onError: (val) => print('onError: $val'), 
  );
  if (available) {
    _speech.listen(
      onResult: (val) => setState(() {
        _controller.text = val.recognizedWords;
      }),
      localeId: 'ja_JP',  // 日本語のロケールを指定
    );
  }
}

  void _stopListening() {
    _speech.stop();
  }

  void _showDialog(int index, BuildContext context) {
    _controller.text = _texts[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit or Delete'),
          content: TextField(
            controller: _controller,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _texts.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _texts[index] = _controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Enter text or use voice',
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _texts.add(_controller.text);
                      _controller.clear();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () async {
                    await _initializeVoice();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () {
                    _stopListening();
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _texts.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_texts[index]),
                onTap: () => _showDialog(index, context),
              );
            },
          ),
        ),
      ],
    );
  }
}
