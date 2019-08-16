import 'package:flutter/material.dart';
import 'package:reader/preview_screen.dart';
import 'package:reader/reader_screen.dart';
import "settings_screen.dart";

import "./library_screen.dart";
import "package:reader/providers/library.dart";
import "package:provider/provider.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Library()),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: LibraryScreen(),
          onGenerateRoute: (RouteSettings settings) {
            var routes = {
              ReaderScreen.routeName: (ctx) => ReaderScreen(settings.arguments),
              PreviewScreen.routeName: (ctx) => PreviewScreen(),
              SettingsScreen.routeName: (ctx) => SettingsScreen()
            };
            WidgetBuilder builder = routes[settings.name];
            return MaterialPageRoute(
                builder: (ctx) => builder(ctx), settings: settings);
          },
        ));
  }
}
