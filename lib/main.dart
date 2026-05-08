import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarttodo/authentication/services/authentication_service.dart';
import 'package:smarttodo/authentication/services/wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<Object?> _firebaseInitialization = _initializeFirebase();

  Future<Object?> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      return null;
    } catch (error, stackTrace) {
      debugPrint('Firebase initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object?>(
      future: _firebaseInitialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _BaseApp(
            home: _LoadingPage(),
          );
        }

        final initializationError = snapshot.data;
        if (initializationError != null) {
          return _BaseApp(
            home: _FirebaseSetupRequiredPage(
              error: initializationError,
            ),
          );
        }

        return MultiProvider(
          providers: [
            Provider<AuthenticationService>(
              create: (_) => AuthenticationService(FirebaseAuth.instance),
            ),
            StreamProvider<User?>(
              create: (context) =>
                  context.read<AuthenticationService>().authStateChanges,
              initialData: null,
            ),
          ],
          child: const _BaseApp(
            home: AuthenticationWrapper(),
          ),
        );
      },
    );
  }
}

class _BaseApp extends StatelessWidget {
  const _BaseApp({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(
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
      home: home,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      backgroundColor: Color(0xFF28293d),
      child: Center(
        child: CupertinoActivityIndicator(radius: 16),
      ),
    );
  }
}

class _FirebaseSetupRequiredPage extends StatelessWidget {
  const _FirebaseSetupRequiredPage({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF28293d),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: CupertinoColors.systemYellow,
                  size: 56,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Firebase setup required',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'The app now builds on current Flutter, but Firebase is not '
                  'configured for this checkout yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CupertinoColors.systemGrey2,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add these files from your Firebase project:\n\n'
                  '• android/app/google-services.json\n'
                  '• ios/Runner/GoogleService-Info.plist',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
