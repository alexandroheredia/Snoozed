
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:smarttodo/authentication/services/authentication_service.dart';


Future<void> logoutConfirmationPrompt(BuildContext context) {
  return showCupertinoDialog(
    context: context,
    builder: (_) {
      return CupertinoAlertDialog(
        title: const Text('Are you sure you want to logout?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Yes, logout',
              style: TextStyle(
                color: CupertinoColors.systemRed,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito'
              ),
            ),
            onPressed: () async {
              await context.read<AuthenticationService>().signOut();
              if (!context.mounted) {
                return;
              }
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text('Cancel',
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito'
              ),
            ),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ]
      );
    },
    barrierDismissible: true,
  );
}