import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

const _charsABC123 =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';

final Random _random = Random();

String generateTaskDocID() {
  return String.fromCharCodes(
    Iterable<int>.generate(
      20,
      (_) => _charsABC123.codeUnitAt(_random.nextInt(_charsABC123.length)),
    ),
  );
}

const appVersionNumber = '2.0.0 2026050901';

const loadingWidget = SpinKitCircle(
  color: CupertinoColors.white,
);
