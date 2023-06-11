import 'package:flutter/material.dart';
import 'add_view.dart';
import 'home_view.dart';
import 'side_menu.dart';
import 'edit_view.dart';
import 'exchange_view.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (BuildContext context) => HomeView(),
  '/add_view': (BuildContext context) => AddView(),
  '/edit_view': (BuildContext context) => EditView(),
  '/menu': (BuildContext context) => SideMenu(
    selectedMenuItem: '',
    onMenuItemSelected: (String item) {},
  ),
  '/exchange':(BuildContext context) => CurrencyConverterView()
};