import 'package:flutter/material.dart';
import 'side_menu.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'address_url.dart';

class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});
}

class EditView extends StatefulWidget {
  @override
  _EditViewState createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  final _titleController = TextEditingController();
  final _taskController = TextEditingController();
  final _idController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Task> _tasks = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Map<String, dynamic>? routeArgs =
    ModalRoute
        .of(context)
        ?.settings
        .arguments as Map<String, dynamic>?;

    if (routeArgs != null) {
      final int id = routeArgs['id'];
      final String title = routeArgs['title'];
      final List<dynamic> tasks = routeArgs['tasks'];

      _idController.text = id.toString();
      _titleController.text = title;

      for (final task in tasks) {
        _tasks.add(Task(title: task['description'], isDone: task['is_done'] ?? false));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: _taskController.text));
        _taskController.clear();
      });
    }
  }

  void _toggleDone(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
  }

  void _editTask(int index) async {
    final editedTaskTitle = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String editedTitle = _tasks[index].title;

        return AlertDialog(
          title: Text('Edytuj zadanie'),
          content: TextField(
            onChanged: (value) {
              editedTitle = value;
            },
            controller: TextEditingController(text: _tasks[index].title),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                    context); // Zamknięcie dialogu bez zapisywania zmian
              },
              child: Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context,
                    editedTitle); // Zapisanie zmienionego tytułu zadania
              },
              child: Text('Zapisz'),
            ),
          ],
        );
      },
    );

    if (editedTaskTitle != null) {
      setState(() {
        _tasks[index].title = editedTaskTitle;
      });
    }
  }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Usuń zadanie'),
          content: Text('Czy na pewno chcesz usunąć to zadanie?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Zamknięcie dialogu bez usuwania zadania
              },
              child: Text('Anuluj'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _tasks.removeAt(index); // Usunięcie zadania
                });
                Navigator.of(context)
                    .pop(); // Zamknięcie dialogu po usunięciu zadania
              },
              child: Text('Usuń'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveTaskList() async {
    // Sprawdź, czy tytuł został wprowadzony
    if (_titleController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Błąd'),
            content: Text('Wprowadź tytuł listy zadań.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Sprawdź, czy przynajmniej jedno zadanie zostało dodane
    if (_tasks.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Błąd'),
            content: Text('Dodaj przynajmniej jedno zadanie do listy.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Zapisz listę zadań
    // Tutaj możesz dodać logikę zapisu listy zadań przy użyciu usługi Django
    //final url_get = 'http://172.16.161.207:8080/app/get_all_tasks'; // Adres URL twojego API
    //final url = 'http://172.16.161.207:8080/app/update_task'; // Adres URL twojego API
    //final url = 'http://172.16.161.207:8080/app/create_task'; // Adres URL twojego API
    String url = Address_Url.apiUrlUpdate;

    final taskListData = {
      'id': int.parse(_idController.text),
      'title': _titleController.text,
      'tasks': _tasks.map((task) =>
      {
        'description': task.title,
        'is_done': task.isDone,
      }).toList(),
    };

    print(taskListData);

    final response = await http.post(
      Uri.parse(url),
      body: json.encode(taskListData),
      headers: <String, String> {'Content-Type': 'application/json; charset=UTF-8'},
    );

    // final response = await http.get(
    //   Uri.parse(url_get),
    //   //body: json.encode(taskListData),
    //   headers: <String, String> {'Content-Type': 'application/json; charset=UTF-8'},
    // );


    print(response.body);

    // Wyświetl potwierdzenie zapisu
    if (response.statusCode == 200) {
      // Lista zadań została zapisana poprawnie
      // Możesz wykonać odpowiednie akcje po zapisaniu, np. wyświetlić komunikat sukcesu

      _showSnackBar('Lista zadań została zapisana.');
      // Nawigacja do strony home_view
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/');
      });
    } else {
      // Wystąpił błąd podczas zapisywania listy zadań
      // Możesz wykonać odpowiednie akcje w przypadku błędu, np. wyświetlić komunikat o błędzie
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Edytuj listę zadań:'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTaskList,
          ),
        ],
      ),
      drawer: SideMenu(
          selectedMenuItem: '', onMenuItemSelected: (String item) {}),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Wpisz tytuł',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: Checkbox(
                    value: _tasks[index].isDone,
                    onChanged: (bool? value) {
                      if (value != null) {
                        _toggleDone(index);
                      }
                    },
                  ),
                  title: Text(
                    _tasks[index].title,
                    style: TextStyle(
                      decoration: _tasks[index].isDone ? TextDecoration
                          .lineThrough : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editTask(index);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteTask(index);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _toggleDone(index);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: 'Wpisz zadanie',
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _addTask,
                  child: Text('Dodaj'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}