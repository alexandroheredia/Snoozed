import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

const _charsABC123 =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';

final Random _random = Random();

/// Generates a random local identifier for a task.
String generateTaskDocID() {
  return String.fromCharCodes(
    Iterable<int>.generate(
      20,
      (_) => _charsABC123.codeUnitAt(_random.nextInt(_charsABC123.length)),
    ),
  );
}

/// The user-visible app version shown in the UI.
const appVersionNumber = '2.0.0 2026050901';

/// Shared loading indicator used across the app.
const loadingWidget = SpinKitCircle(
  color: CupertinoColors.white,
);
