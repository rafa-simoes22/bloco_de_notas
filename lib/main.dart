import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloco de Notas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NotesScreen(),
    );
  }
}

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> notes = [];
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/notes.json');
    if (await file.exists()) {
      final contents = await file.readAsString();
      setState(() {
        notes = List<Map<String, dynamic>>.from(jsonDecode(contents));
      });
    }
  }

  Future<void> _saveNotes() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/notes.json');
    final jsonNotes = jsonEncode(notes);
    await file.writeAsString(jsonNotes);
  }

  void _addNote() {
    if (_noteController.text.isNotEmpty) {
      final newNote = {
        'text': _noteController.text,
        'timestamp': DateTime.now().toString(),
      };
      setState(() {
        notes.add(newNote);
        _noteController.clear();
      });
      _saveNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bloco de Notas'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return ListTile(
                  title: Text(note['text']),
                  subtitle: Text(note['timestamp']),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua nota...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addNote,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
