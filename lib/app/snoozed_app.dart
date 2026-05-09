// ignore_for_file: public_member_api_docs, because this is app-internal.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttodo/core/constants.dart';
import 'package:smarttodo/features/tasks/tasks.dart';

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
      home: _AppBootstrap(),
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
    );
  }
}

class _AppBootstrap extends ConsumerWidget {
  const _AppBootstrap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialization = ref.watch(tasksInitializationProvider);

    return initialization.when(
      loading: () => const CupertinoPageScaffold(
        backgroundColor: Color(0xFF28293d),
        child: Center(child: loadingWidget),
      ),
      error: (error, stackTrace) => CupertinoPageScaffold(
        backgroundColor: const Color(0xFF28293d),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Could not initialize Snoozed.\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CupertinoColors.systemGrey2,
              ),
            ),
          ),
        ),
      ),
      data: (_) => const HomePage(),
    );
  }
}
