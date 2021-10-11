import 'package:flutter/material.dart';
import 'package:todo/screens/home_screen.dart';
import 'package:todo/todo_theme.dart';

void main() => runApp(const Todo());

class Todo extends StatelessWidget {
  const Todo({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = TodoTheme.light();
    // final theme = TodoTheme.dark();

    return MaterialApp(
      title: 'Todo List',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const HomeScreen(),
    );
  }
}
