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
  final TextEditingController _nameController = TextEditingController();
  bool _isAddingNote = false;

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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Nota'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome da Nota'),
              ),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: 'Texto da Nota'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _noteController.text.isNotEmpty) {
                  final newNote = {
                    'name': _nameController.text,
                    'text': _noteController.text,
                    'timestamp': DateTime.now().toString(),
                  };
                  setState(() {
                    notes.add(newNote);
                    _nameController.clear();
                    _noteController.clear();
                  });
                  _saveNotes();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Salvar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoteList() {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final noteName = note['name'] ?? 'Nome não definido';
        return ListTile(
          title: Text(noteName),
          subtitle: Text(note['timestamp']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteDetailScreen(note: note),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bloco de Notas'),
      ),
      body: _isAddingNote ? _buildNoteDetailScreen() : _buildNoteList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isAddingNote = true;
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteDetailScreen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Nome da Nota'),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _noteController,
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'Texto da Nota',
                alignLabelWithHint: true,
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _noteController.text.isNotEmpty) {
              final newNote = {
                'name': _nameController.text,
                'text': _noteController.text,
                'timestamp': DateTime.now().toString(),
              };
              setState(() {
                notes.add(newNote);
                _nameController.clear();
                _noteController.clear();
                _isAddingNote = false;
              });
              _saveNotes();
            }
          },
          child: Text('Salvar Nota'),
        ),
      ],
    );
  }
}

class NoteDetailScreen extends StatelessWidget {
  final Map<String, dynamic> note;

  NoteDetailScreen({required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note['name'] ?? 'Nome não definido'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data de Criação: ${note['timestamp']}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              note['text'],
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
