import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/database/database.dart';
import 'package:todo/models/note_model.dart';
import 'package:todo/screens/add_note_screen.dart';
import 'package:todo/todo_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Note>> _noteList;

  final DateFormat _dateFormatter = DateFormat("MMM dd, yyyy");

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _updateNoteList();
  }

  _updateNoteList() {
    setState(() {
      _noteList = _databaseHelper.getNoteList();
    });
  }

  Widget _buildNote(Note note) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              note.title!,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.deepPurple,
                decoration: note.status == 1 ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            subtitle: Text(
              '${_dateFormatter.format(note.date!)} - ${note.priority}',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.deepPurple,
                decoration: note.status == 1 ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            trailing: Checkbox(
              value: (note.status == 1) ? true : false,
              onChanged: (value) async {
                note.status = (value! ? 1 : 0);
                _databaseHelper.updateNote(note);
                _updateNoteList();
              },
            ),
            onLongPress: () {
              _databaseHelper.deleteNote(note.id!);
              _updateNoteList();
            },
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) {
                  return AddNoteScreen(
                    updateNoteList: _updateNoteList,
                    note: note,
                  );
                },
              ),
            ),
          ),
          const Divider(height: 5.0),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo'), elevation: 0),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => AddNoteScreen(
                updateNoteList: _updateNoteList,
              ),
            ),
          );
        },
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _noteList,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final int completedNoteCount = snapshot.data!.where((Note note) => note.status == 1).toList().length;
            if (snapshot.data.length == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _headerBuilder(completedNoteCount, snapshot.data.length),
                  const Expanded(flex: 6, child: Center(child: Text('No Data'))),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _headerBuilder(completedNoteCount, snapshot.data.length),
                Expanded(
                  flex: 6,
                  child: ListView.builder(
                    itemCount: int.parse(snapshot.data!.length.toString()),
                    itemBuilder: (BuildContext context, int index) => _buildNote(snapshot.data![index]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _headerBuilder(int completedNoteCount, int noteCount) {
    return Expanded(
      flex: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.deepPurple.shade400],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              Text(
                "$completedNoteCount of $noteCount Notes",
                style: TodoTheme.headTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
