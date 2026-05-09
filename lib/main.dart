// ignore_for_file: public_member_api_docs, because this is an app entrypoint.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smarttodo/data/tasks_repository.dart';
import 'package:smarttodo/homepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TasksRepository.instance.initialize();
  runApp(const SnoozedApp());
}

class SnoozedApp extends StatelessWidget {
  const SnoozedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(
        barBackgroundColor: CupertinoColors.white,
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.white,
        textTheme: CupertinoTextThemeData(
          primaryColor: CupertinoColors.white,
          textStyle: TextStyle(
            color: CupertinoColors.white,
            fontSize: 17,
          ),
        ),
      ),
      home: HomePage(),
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
    );
  }
}
