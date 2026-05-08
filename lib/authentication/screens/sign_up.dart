// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarttodo/authentication/services/authentication_service.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  late TextEditingController emailController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.transparent)),
        middle: Text(''),
      ),
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
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Text('Sign Up',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito'
              ),
            ),
            SizedBox(height: 15,),
            SizedBox(
              width: MediaQuery.of(context).size.height * 1,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 62, 64, 93),
                          borderRadius: const BorderRadius.all(
                          Radius.circular(20.0),
                          ),
                        ),
                        child: CupertinoTextFormFieldRow(
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: 500,
                          maxLines: 1,
                          placeholder: 'Email address',
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 62, 64, 93),
                            borderRadius: const BorderRadius.all(
                            Radius.circular(20.0),
                            ),
                          ),
                          controller: emailController,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15,),
            SizedBox(
              width: MediaQuery.of(context).size.height * 1,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 62, 64, 93),
                          borderRadius: const BorderRadius.all(
                          Radius.circular(20.0),
                          ),
                        ),
                        child: CupertinoTextFormFieldRow(
                          obscureText: true,
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: 50,
                          placeholder: 'password',
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 62, 64, 93),
                            borderRadius: const BorderRadius.all(
                            Radius.circular(20.0),
                            ),
                          ),
                          controller: passwordController,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30,),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 0),
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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 25, 26, 39),
                          ),
                        ), 
                        onPressed: () async {
                          try {
                            context.read<AuthenticationService>().signUp(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim()
                            );
                          Navigator.of(context, rootNavigator: true).pop();
                            
                          } catch (e) {
                            print(e);
                            
                          }
                          
                          // Navigator.of(context, rootNavigator: true).pop();
                        }
                      ),
                    ),
                  ),
                )

              ],
            ),
            

          ],
        ),
      ),
    );
  }
}


// context.read<AuthenticationService>().signUp(
//             email: emailController.text.trim(),
//             password: passwordController.text.trim());