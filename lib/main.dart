import 'package:flutter/material.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const NotesScreen(),
    );
  }
}

class Note {
  String text;
  Note(this.text);
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Note> _notes = [];
  int? _editingIndex;

  void _saveNote() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      if (_editingIndex != null) {
        _notes[_editingIndex!].text = text;
        _editingIndex = null;
      } else {
        _notes.add(Note(text));
      }
      _controller.clear();
    });
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
      if (_editingIndex == index) {
        _editingIndex = null;
        _controller.clear();
      } else if (_editingIndex != null && _editingIndex! > index) {
        _editingIndex = _editingIndex! - 1;
      }
    });
  }

  void _editNote(int index) {
    setState(() {
      _editingIndex = index;
      _controller.text = _notes[index].text;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingIndex = null;
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingIndex != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заметки'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Введите текст заметки...',
                border: const OutlineInputBorder(),
                filled: true,
                suffixIcon: isEditing
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _cancelEdit,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _saveNote,
                    icon: Icon(isEditing ? Icons.check : Icons.save),
                    label: Text(isEditing ? 'Сохранить' : 'Добавить'),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _cancelEdit,
                    child: const Text('Отмена'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Expanded(
              child: _notes.isEmpty
                  ? const Center(
                      child: Text(
                        'Заметок пока нет',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _notes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final isBeingEdited = _editingIndex == index;
                        return Card(
                          color: isBeingEdited
                              ? Colors.indigo.withOpacity(0.08)
                              : null,
                          child: ListTile(
                            title: Text(_notes[index].text),
                            leading: CircleAvatar(
                              radius: 16,
                              child: Text('${index + 1}'),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editNote(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _deleteNote(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}