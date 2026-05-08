import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smarttodo/task_list/functions/delete_completed_tasks.dart';
import 'package:smarttodo/shared/constants.dart';



void showTaskListPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: const Color.fromRGBO(0, 0, 0, 0.001),
            child: GestureDetector(
              onTap: () {},
              child: DraggableScrollableSheet(
                initialChildSize: 0.72,
                minChildSize: 0.2,
                builder: (_, controller) {
                  return Container(
                    height: 600,
                    decoration: const BoxDecoration(
                      color: Color(0xFF28293d),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 15,),
                        const Text('My Tasks',
                          style: TextStyle(
                            fontSize: 24,
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.55,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: StreamBuilder(
                                        stream: myTasksDBCollection(context)
                                          .orderBy('isTaskCompleted')
                                          .snapshots(),
                                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                            return ListView.builder(
                                              physics: const BouncingScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              itemCount: snapshot.data?.docs.length,
                                              itemBuilder: (BuildContext context, int index) {
                                                QueryDocumentSnapshot<Object?>? user = snapshot.data?.docs[index];
                          
                                                var taskTile = user!.data().toString().contains('taskTile') ? user.get('taskTile') : '';
                                                var taskDocID = user.data().toString().contains('taskDocID') ? user.get('taskDocID') : '';
                                                var isTaskCompleted = user.data().toString().contains('isTaskCompleted') ? user.get('isTaskCompleted') : false;
                  
                                                return Column(
                                                  children: [
                                                    Slidable(
                                                      key: const ValueKey(0),
                                                      endActionPane:  ActionPane(
                                                      motion: const StretchMotion(),
                                                      children: [
                                                        SlidableAction(
                                                          autoClose: true,
                                                          onPressed: (BuildContext context) async {
                                                            myTasksDBCollection(context)
                                                            .doc(taskDocID)
                                                            .delete();
                                                          },
                                                          backgroundColor: CupertinoColors.systemRed,
                                                          foregroundColor: Colors.white,
                                                          icon: Icons.delete_outline,
                                                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                        ),
                                                      ],
                                                    ),
                                                      child: Builder(
                                                        builder: (context) {
                                                          if (isTaskCompleted == false) {
                                                            return Row(
                                                            children: [
                                                              Expanded(
                                                                child: GestureDetector(
                                                              onTap: () {
                                                                myTasksDBCollection(context)
                                                                .doc(taskDocID)
                                                                .update({'isTaskCompleted': true});
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(5),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 5),
                                                                      child: Column(
                                                                        children: [
                                                                          SizedBox(
                                                                            width: 30,
                                                                            height: 30,
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: const [
                                                                                FaIcon(
                                                                                  FontAwesomeIcons.circle,
                                                                                  size: 26,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: GestureDetector(
                                                                        onTap: () {
                                                                          myTasksDBCollection(context)
                                                                          .doc(taskDocID)
                                                                          .update({'isTaskCompleted': true});
                                                                        },
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(taskTile,
                                                                              style: const TextStyle(
                                                                                color: CupertinoColors.white,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                            
                                                          } else {
                                                            return Row(
                                                              children: [
                                                                Expanded(
                                                                  child: GestureDetector(
                                                                onTap: () {
                                                                  myTasksDBCollection(context)
                                                                  .doc(taskDocID)
                                                                  .update({'isTaskCompleted': false});
                                                                },
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(5),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 5),
                                                                        child: Column(
                                                                          children: [
                                                                            SizedBox(
                                                                              width: 30,
                                                                              height: 30,
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: const [
                                                                                  FaIcon(
                                                                                    FontAwesomeIcons.solidCircleCheck,
                                                                                    color: CupertinoColors.activeGreen,
                                                                                    size: 26,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child: GestureDetector(
                                                                          onTap: () {
                                                                            // do something when clicking on it
                                                                    
                                                                          },
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(taskTile,
                                                                                style: const TextStyle(
                                                                                  decoration: TextDecoration.lineThrough,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  color: CupertinoColors.white,
                                                                                ),
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                        }
                                                      ),
                                                    ),
                                                    const Divider()
                                                  ],
                                                );
                                              }
                                            );
                                          } if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                                            // if the stream of data is empty
                                            return const Center(
                                              child: Text('no tasks to show'),
                                            );
                                          } else {
                                            // Still loading
                                            return loadingWidget;
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ]
                              ),
                            ),
                          ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.activeGreen,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(35.0),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: CupertinoColors.black.withValues(alpha: 0.1),
                                        spreadRadius: 4,
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      )
                                    ]
                                  ),
                                  child: CupertinoButton(
                                    // padding: EdgeInsets.all(8),
                                    child: const Text('Remove Completed',
                                      style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ), 
                                    onPressed: () {
                                      deleteCompletedTasks(context);
                                    }
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }