// ignore_for_file: unused_element, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/database/database.dart';
import 'package:todo/models/note_model.dart';
import 'package:todo/screens/home_screen.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? note;
  final Function? updateNoteList;

  const AddNoteScreen({Key? key, this.note, this.updateNoteList}) : super(key: key);

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _priority = 'Low';
  DateTime _date = DateTime.now();
  late String btnText;
  String titleText = "New Note";

  final TextEditingController _dateController = TextEditingController();

  final DateFormat _dateFormatter = DateFormat("MMM dd, yyyy");
  final List<String> _priorities = ['Low', 'Medium', 'HIGH'];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _title = widget.note!.title!;
      _date = widget.note!.date!;
      _priority = widget.note!.priority!;

      btnText = "SAVE";
      titleText = "Update Note";
    } else {
      btnText = "ADD";
      titleText = "New Note";
    }
    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  _handleDatePicker() async {
    final DateTime? dateTime = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dateTime != null && dateTime != _date) {
      setState(() => _date = dateTime);
      _dateController.text = _dateFormatter.format(_date);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('$_title, $_date, $_priority');

      Note note = Note(title: _title, date: _date, priority: _priority);

      if (widget.note == null) {
        note.status = 0;
        DatabaseHelper.instance.insertNote(note);
        Navigator.pop(context, CupertinoPageRoute(builder: (_) => const HomeScreen()));
      } else {
        note.id = widget.note!.id;
        note.status = widget.note!.status;
        DatabaseHelper.instance.updateNote(note);
        Navigator.pop(context, CupertinoPageRoute(builder: (_) => const HomeScreen()));
      }

      widget.updateNoteList!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, CupertinoPageRoute(builder: (_) => const HomeScreen())),
                  child: const Icon(Icons.arrow_back, size: 30.0, color: Colors.deepPurple),
                ),
                const SizedBox(height: 20.0),
                Text(titleText, style: const TextStyle(color: Colors.deepPurple, fontSize: 40.0, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 30.0),
                      TextFormField(
                        style: _style(context),
                        decoration: _inputDecoration(labelText: 'Title'),
                        validator: (input) => input!.trim().isEmpty ? "Please enter a note title" : null,
                        onSaved: (input) => _title = input!,
                        initialValue: _title,
                      ),
                      const SizedBox(height: 15.0),
                      TextFormField(
                        style: _style(context),
                        decoration: _inputDecoration(labelText: 'Date'),
                        readOnly: true,
                        onTap: _handleDatePicker,
                        controller: _dateController,
                      ),
                      const SizedBox(height: 15.0),
                      DropdownButtonFormField(
                        style: _style(context),
                        decoration: _inputDecoration(labelText: 'Priority'),
                        isDense: true,
                        icon: const Icon(Icons.arrow_drop_down_circle),
                        iconSize: 22.0,
                        iconEnabledColor: Theme.of(context).primaryColor.withOpacity(0.5),
                        items: _priorities.map((String priority) {
                          return DropdownMenuItem(value: priority, child: Text(priority, style: _style(context)));
                        }).toList(),
                        onChanged: (value) => setState(() => _priority = value.toString()),
                        value: _priority,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 60.0),
                        height: 60.0,
                        width: double.infinity,
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(30.0)),
                        child: ElevatedButton(
                          child: Text(btnText, style: const TextStyle(color: Colors.white, fontSize: 20.0)),
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _style(BuildContext context, {double opacity = 1.0}) {
    return TextStyle(fontSize: 18.0, color: Theme.of(context).primaryColor.withOpacity(opacity));
  }

  InputDecoration _inputDecoration({String? labelText}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: _style(context, opacity: 0.5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }
}
