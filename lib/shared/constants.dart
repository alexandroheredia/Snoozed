import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';


// Generate strings with random characters and numbers
const _charsABC123 = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
const _chars123 = '1234567890';

final Random _rnd = Random();

String getRandomStringABC123(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _charsABC123.codeUnitAt(_rnd.nextInt(_charsABC123.length))));

String getRandomString123(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars123.codeUnitAt(_rnd.nextInt(_chars123.length))));


// Generates a random string of 20 characters used for the documents name on Firestore for each task.
String generateTaskDocID() {
  String questionID = getRandomStringABC123(20);
  return questionID;
}


// returns the UID for the current logged in user
String myUID(BuildContext context){
  var user = Provider.of<User>(context, listen: false);
  var myUID = user.uid;

  return myUID;
}


// Constants variables
const appVersionNumber = '1.1.3';

const loadingWidget = SpinKitCircle(
  color: CupertinoColors.white,
);


CollectionReference<Map<String, dynamic>> myTasksDBCollection(BuildContext context){
  var dbReference = 
    FirebaseFirestore.instance
    .collection('users')
    .doc(myUID(context))
    .collection('myTasks');

  return dbReference;
}