import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:smarttodo/shared/constants.dart';



Future<void> deleteCompletedTasks(BuildContext context) async {
  QuerySnapshot eventsQuery = 
    await myTasksDBCollection(context)
    .where('isTaskCompleted', isEqualTo: true)
    .get();

  for (var value in eventsQuery.docs) {
    value.reference.delete();
  }
}