// ignore_for_file: public_member_api_docs, because this is an app entrypoint.

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smarttodo/app/snoozed_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SnoozedApp()));
}
