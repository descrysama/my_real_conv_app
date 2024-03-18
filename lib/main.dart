import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'firebase_options.dart';
//Components
import 'package:my_real_conv_app/pages/HomePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = [EmailAuthProvider()];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ok',
      initialRoute:
          fba.FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/',
      routes: {
        '/': (context) => fba.FirebaseAuth.instance.currentUser == null
            ? SignInScreen(
                providers: providers,
                actions: [
                  AuthStateChangeAction<SignedIn>((context, state) {
                    Navigator.pushReplacementNamed(context, '/');
                  }),
                ],
              )
            : const MyHomePage(title: 'Conversations'),
        '/sign-in': (context) {
          return SignInScreen(
            providers: providers,
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacementNamed(context, '/');
              }),
            ],
          );
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
    );
  }
}
