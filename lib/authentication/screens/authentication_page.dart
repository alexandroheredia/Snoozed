// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:smarttodo/authentication/screens/sign_in.dart';
import 'package:smarttodo/authentication/screens/sign_up.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        height: MediaQuery.of(context).size.height * 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [
              Color.fromARGB(255, 55, 57, 86),
              Color.fromARGB(255, 25, 26, 39),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Snoozed',
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 170,),

            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(35.0),
                        ),
                        border: Border.all(
                          color: CupertinoColors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.black.withValues(alpha: 0),
                            spreadRadius: 4,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          )
                        ]
                      ),
                      child: CupertinoButton(
                        child: Text('Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                            fontSize: 22
                          ),
                        ), 
                        onPressed: () {
                          Navigator.push(context, CupertinoPageRoute(builder: (context) => SignInPage()));
                        }
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(35.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.black.withValues(alpha: 0.1),
                            spreadRadius: 4,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          )
                        ]
                      ),
                      child: CupertinoButton(
                        child: Text('Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 25, 26, 39),
                            fontSize: 22
                          ),
                        ), 
                        onPressed: () {
                          Navigator.push(context, CupertinoPageRoute(builder: (context) => SignUpPage()));
                        }
                      ),
                    ),
                  ),
                ),
              ],
            ),


          ],
        ),
      ),
    );
  }
}

