import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SideMenu extends StatelessWidget {
  final String selectedMenuItem;
  final Function(String) onMenuItemSelected;

  const SideMenu({
    Key? key,
    required this.selectedMenuItem,
    required this.onMenuItemSelected,
  }) : super(key: key);

  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Potwierdzenie'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Czy na pewno chcesz zamknąć aplikację?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Anuluj'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Zamknij'),
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop(); // Dodaj to wywołanie
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.fact_check),
            title: Text('Listy zadań'),
            selected: selectedMenuItem == 'Listy zadań',
            onTap: () {
              onMenuItemSelected('Listy zadań');
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: Icon(Icons.dashboard_customize),
            title: Text('Dodaj zadanie'),
            selected: selectedMenuItem == 'Dodaj zadanie',
            onTap: () {
              onMenuItemSelected('Dodaj zadanie');
              Navigator.pushReplacementNamed(context, '/add_view');
            },
          ),
          ListTile(
            leading: Icon(Icons.paid),
            title: Text('Kalkulator walut'),
            selected: selectedMenuItem == 'Kalkulator walut',
            onTap: () {
              onMenuItemSelected('Kalkulator walut');
              Navigator.pushReplacementNamed(context, '/exchange');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Zamknij'),
            selected: selectedMenuItem == 'Zamknij',
            onTap: () {
              onMenuItemSelected('Zamknij');
              _showExitConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
