import 'package:flutter/material.dart';
import 'side_menu.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'address_url.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<dynamic> _taskLists = [];


  @override
  void initState() {
    super.initState();
    _fetchTaskLists().then((taskLists) {
      setState(() {
        print(taskLists);
        _taskLists = taskLists;
      });
    }).catchError((error) {
      print('Error: $error');
    });
  }

  String url = Address_Url.apiUrlGet;

  Future<List<dynamic>> _fetchTaskLists() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      final data = json.decode(responseBody);
      print(data);
      print(data.runtimeType);
      return data;
    } else {
      throw Exception('Failed to fetch task lists');
    }
  }


  // @override
  // void initState() {
  //   super.initState();
  //   _initializeTaskLists();
  // }
  //
  // void _initializeTaskLists() {
  //   // Dodajemy przykładowe listy zadań
  //   setState(() {
  //     _taskLists = [
  //       {
  //         'id': 1,
  //         'title': 'Lista zakupów',
  //         'tasks': [
  //           {'description': 'Mleko', 'is_done': false},
  //           {'description': 'Chleb', 'is_done': true},
  //           {'description': 'Jabłka', 'is_done': false},
  //           {'description': 'Masło', 'is_done': false},
  //           {'description': 'Jogurt', 'is_done': false},
  //           {'description': 'Ser', 'is_done': false},
  //           {'description': 'Szynka', 'is_done': false},
  //         ],
  //       },
  //       {
  //         'id': 2,
  //         'title': 'Projekt Flutter',
  //         'tasks': [
  //           {'description': 'Zaprojektować interfejs', 'is_done': true},
  //           {'description': 'Zaimplementować logikę', 'is_done': false},
  //           {'description': 'Przetestować aplikację', 'is_done': false},
  //           {'description': 'Napisać dokumentację', 'is_done': false},
  //           {'description': 'Publikować na GitHub', 'is_done': false},
  //         ],
  //       },
  //     ];
  //   });
  // }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _deleteTaskList(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Usuń listę zadań'),
          content: Text('Czy na pewno chcesz usunąć tę listę zadań?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Anuluj'),
            ),
            TextButton(
              onPressed: () async {
                // Wywołaj API usuwające listę zadań
                final url = Address_Url.apiUrlDelete + '/$id'; // Adres URL usuwania listy zadań
                final response = await http.get(Uri.parse(url));

                if (response.statusCode == 200) {
                  // Lista zadań została usunięta poprawnie
                  setState(() {
                    _taskLists.removeWhere((taskList) => taskList['id'] == id);
                  });
                  _showSnackBar('Lista zadań została usunięta.');
                  Navigator.pushReplacementNamed(context, '/');
                } else {
                  // Wystąpił błąd podczas usuwania listy zadań
                  // Możesz wykonać odpowiednie akcje w przypadku błędu, np. wyświetlić komunikat o błędzie
                  _showSnackBar('Błąd podczas usuwania listy zadań.');
                }
              },
              child: Text('Usuń'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Moje zadania'),
      ),
      drawer: SideMenu(
        selectedMenuItem: '',
        onMenuItemSelected: (String item) {},
      ),
      body: ListView.builder(
        itemCount: _taskLists.length,
        itemBuilder: (BuildContext context, int index) {
          final taskList = _taskLists[index];
          final tasks = taskList['tasks'];
          final visibleTasks = tasks.take(3).toList();
          final remainingTasks = tasks.length - visibleTasks.length;

          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                taskList['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var task in visibleTasks)
                    ListTile(
                      leading: Checkbox(
                        value: task['is_done'],
                        onChanged: (value) {
                          setState(() {
                            task['is_done'] = value;
                          });
                        },
                      ),
                      title: Text(
                        task['description'],
                        style: TextStyle(
                          decoration: task['is_done']
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          task['is_done'] = !task['is_done'];
                        });
                      },
                    ),
                  if (remainingTasks > 0)
                    Padding(
                      padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                      child: Text(
                        '+$remainingTasks więcej',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/edit_view',
                  arguments: {
                    'id': taskList['id'],
                    'title': taskList['title'],
                    'tasks': tasks,
                  },
                );
              },
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteTaskList(taskList['id']);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_view');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
