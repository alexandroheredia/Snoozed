// ignore_for_file: use_build_context_synchronously, avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smarttodo/authentication/functions/logout_prompt.dart';
import 'package:smarttodo/task_list/tasks_list.dart';
import 'package:smarttodo/shared/constants.dart';
import 'package:url_launcher/url_launcher.dart';


class HomePage extends StatefulWidget {
    const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late TextEditingController taskTitleController = TextEditingController();
  late TextEditingController taskDescriptionController = TextEditingController();
  late TextEditingController taskLinkController = TextEditingController();
  late TextEditingController editTaskTitleController = TextEditingController();
  late TextEditingController editTaskDescriptionController = TextEditingController();
  late TextEditingController editTaskLinkController = TextEditingController();
  final formKeySaveTask = GlobalKey<FormState>();
  late String taskDocID = '';
  bool isEditModeEnabled = false;


  @override
  void initState() {
    taskDocID = generateTaskDocID();
    editTaskLinkController = TextEditingController(text: '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragDown: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          border: const Border(bottom: BorderSide(color: Colors.transparent)),
          backgroundColor: const Color(0xFF28293d),
          middle: const Text('Snoozed',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold
            ),
          ),
          trailing: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: const FaIcon(FontAwesomeIcons.rightToBracket),
            onPressed: () {
              logoutConfirmationPrompt(context);
            }
          ),
        ),
        backgroundColor: const Color(0xFF28293d),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.70,
                  width: MediaQuery.of(context).size.width * 1,
                  child: Row(
                    children: [
                      Expanded(
                        child: StreamBuilder(
                          stream: myTasksDBCollection(context)
                            .where('isTaskCompleted', isEqualTo: false)
                            .orderBy('dueDate')
                            .limit(1)
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
                                  var taskDescription = user.data().toString().contains('taskDescription') ? user.get('taskDescription') : '';
                                  var taskDocID = user.data().toString().contains('taskDocID') ? user.get('taskDocID') : '';
                                  var timesSkipped = user.data().toString().contains('timesSkipped') ? user.get('timesSkipped') : 1;
                                  var taskAttachedLink = user.data().toString().contains('taskAttachedLink') ? user.get('taskAttachedLink') : '';
                                  var dueDate = user.get('dueDate');
                                  var convertedDate = DateTime.parse(dueDate.toDate().toString());
                                  DateTime updatedDueDate = convertedDate.add(Duration(days: timesSkipped));
                                  Timestamp newDueDateTimestampFormat = Timestamp.fromDate(updatedDueDate);
    
                                  deleteTask(){
                                    myTasksDBCollection(context)
                                    .doc(taskDocID)
                                    .delete();
                                  }
            
                                  markTaskAsCompleted(){
                                    myTasksDBCollection(context)
                                    .doc(taskDocID)
                                    .update({'isTaskCompleted': true});
                                  }
    
                                  skipTask(){
                                    myTasksDBCollection(context)
                                    .doc(taskDocID)
                                    .update({
                                      'timesSkipped': timesSkipped + 1,
                                      'dueDate': newDueDateTimestampFormat,
                                    });
                                  }
    
                                  editTask(){
                                    myTasksDBCollection(context)
                                    .doc(taskDocID)
                                    .update({
                                      'taskTile': editTaskTitleController.text,
                                      'taskDescription': editTaskDescriptionController.text,
                                      'taskAttachedLink': editTaskLinkController.text,
                                    });
                                  }
    
                                  return Builder(
                                    builder: (context) {
                                      if (isEditModeEnabled == true) {
                                        return Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(20.0),
                                              child: Container(
                                                height: MediaQuery.of(context).size.height * 0.5,
                                                width: MediaQuery.of(context).size.width * 0.90,
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(255, 57, 59, 85),
                                                  borderRadius: const BorderRadius.all(
                                                    Radius.circular(35.0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: CupertinoColors.black.withValues(alpha: 0),
                                                      spreadRadius: 4,
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 3),
                                                    )
                                                  ]
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    const SizedBox(height: 15,),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.85,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
                                                              child: Container(
                                                                decoration: const BoxDecoration(
                                                                  color: Color.fromARGB(255, 62, 64, 93),
                                                                  borderRadius: BorderRadius.all(
                                                                  Radius.circular(20.0),
                                                                  ),
                                                                ),
                                                                child: CupertinoTextFormFieldRow(
                                                                  textCapitalization: TextCapitalization.sentences,
                                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                  maxLength: 65,
                                                                  maxLines: 1,
                                                                  placeholder: 'Enter a title for this task',
                                                                  decoration: const BoxDecoration(
                                                                    color: Color.fromARGB(255, 62, 64, 93),
                                                                    borderRadius: BorderRadius.all(
                                                                    Radius.circular(20.0),
                                                                    ),
                                                                  ),
                                                                  controller: editTaskTitleController,
                                                                  style: const TextStyle(
                                                                    fontSize: 20,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5,),
                                                    SizedBox(
                                                      // height: MediaQuery.of(context).size.height * 0.1,
                                                      width: MediaQuery.of(context).size.width * 0.85,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
                                                              child: Container(
                                                                decoration: const BoxDecoration(
                                                                  color: Color.fromARGB(255, 62, 64, 93),
                                                                  borderRadius: BorderRadius.all(
                                                                  Radius.circular(20.0),
                                                                  ),
                                                                ),
                                                                child: CupertinoTextFormFieldRow(
                                                                  textCapitalization: TextCapitalization.sentences,
                                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                  maxLength: 1000,
                                                                  maxLines: 6,
                                                                  placeholder: 'Enter a description for this task',
                                                                  decoration: const BoxDecoration(
                                                                    color: Color.fromARGB(255, 62, 64, 93),
                                                                    borderRadius: BorderRadius.all(
                                                                    Radius.circular(20.0),
                                                                    ),
                                                                  ),
                                                                  controller: editTaskDescriptionController,
                                                                  style: const TextStyle(
                                                                    fontSize: 20,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5,),
                                                    Row(
                                                      children: [
                                                        const SizedBox(width: 17,),
                                                        const FaIcon(
                                                          FontAwesomeIcons.link,
                                                          size: 26,
                                                        ),
                                                        const SizedBox(width: 12,),
                                                        // Expanded(
                                                        //   child: Text(taskAttachedLink,
                                                        //     overflow: TextOverflow.ellipsis,
                                                        //     style: const TextStyle(
                                                        //       color: Color.fromARGB(255, 60, 153, 252),
                                                        //       fontSize: 19,
                                                        //       fontWeight: FontWeight.bold,
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width * 0.68,
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
                                                                  child: Container(
                                                                    decoration: const BoxDecoration(
                                                                      color: Color.fromARGB(255, 62, 64, 93),
                                                                      borderRadius: BorderRadius.all(
                                                                      Radius.circular(20.0),
                                                                      ),
                                                                    ),
                                                                    child: CupertinoTextFormFieldRow(
                                                                      textCapitalization: TextCapitalization.sentences,
                                                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                      maxLength: 500,
                                                                      maxLines: 1,
                                                                      placeholder: 'Paste a link for this task',
                                                                      decoration: const BoxDecoration(
                                                                        color: Color.fromARGB(255, 62, 64, 93),
                                                                        borderRadius: BorderRadius.all(
                                                                        Radius.circular(20.0),
                                                                        ),
                                                                      ),
                                                                      controller: editTaskLinkController,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 20,),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 17,),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(12.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: const Color.fromARGB(255, 18, 18, 27),
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(35.0),
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: CupertinoColors.black.withValues(alpha: 0),
                                                            spreadRadius: 4,
                                                            blurRadius: 10,
                                                            offset: const Offset(0, 3),
                                                          )
                                                        ]
                                                      ),
                                                      child: CupertinoButton(
                                                        child: const Text('Cancel',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: CupertinoColors.white,
                                                            fontSize: 22
                                                          ),
                                                        ), 
                                                        onPressed: () {
                                                          setState(() {
                                                            isEditModeEnabled = false;
                                                          });
                                                        }
                                                      ),
                                                    ),
                                                  ),
                                                ),
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
                                                            color: CupertinoColors.black.withValues(alpha: 0),
                                                            spreadRadius: 4,
                                                            blurRadius: 10,
                                                            offset: const Offset(0, 3),
                                                          )
                                                        ]
                                                      ),
                                                      child: CupertinoButton(
                                                        child: const Text('Save',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Color.fromARGB(255, 18, 18, 27),
                                                            fontSize: 22
                                                          ),
                                                        ), 
                                                        onPressed: () {
                                                          editTask();
                                                          setState(() {
                                                            isEditModeEnabled = false;
                                                          });
                                                        }
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      } else {
                                        return Column(
                                          children: [
                                            Stack(
                                              alignment: AlignmentDirectional.bottomEnd,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
                                                  child: Container(
                                                    height: MediaQuery.of(context).size.height * 0.40,
                                                    width: MediaQuery.of(context).size.width * 0.90,
                                                    decoration: BoxDecoration(
                                                      color: const Color.fromARGB(255, 57, 59, 85),
                                                      borderRadius: const BorderRadius.all(
                                                        Radius.circular(35.0),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: CupertinoColors.black.withValues(alpha: 0),
                                                          spreadRadius: 4,
                                                          blurRadius: 10,
                                                          offset: const Offset(0, 3),
                                                        )
                                                      ]
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: [
                                                        const SizedBox(height: 20,),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 8, bottom: 12, left: 15, right: 15),
                                                          child: SelectableText(taskTile,
                                                          textAlign: TextAlign.center,
                                                            style: const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(top: 5, bottom: 12, left: 12, right: 12),
                                                            child: SelectableText(taskDescription,
                                                              textAlign: TextAlign.start,
                                                              style: const TextStyle(
                                                                fontSize: 20,
                                                              ),
                                                              maxLines: 8,
                                                            ),
                                                          ),
                                                        ),
                                                        Builder(
                                                          builder: (context) {
                                                            if (taskAttachedLink == '') {
                                                              return Container();
                                                            } else {
                                                              return Row(
                                                                children: [
                                                                  const SizedBox(width: 17,),
                                                                  const FaIcon(
                                                                    FontAwesomeIcons.link,
                                                                    size: 26,
                                                                  ),
                                                                  const SizedBox(width: 12,),
                                                                  Expanded(
                                                                    child: GestureDetector(
                                                                      onTap: () async {
                                                                        await _launchInBrowser(Uri.parse(taskAttachedLink)); 
                                                                      },
                                                                      child: Text(taskAttachedLink,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: const TextStyle(
                                                                          color: Color.fromARGB(255, 60, 153, 252),
                                                                          fontSize: 19,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(width: 20,),
                                                                ],
                                                              );
                                                            }
                                                          }
                                                        ),
                                                      const SizedBox(height: 17,),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                right: -15,
                                                bottom: -20,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 0, left: 0, right: 25, bottom: 28),
                                                  child: Container(
                                                    decoration: const BoxDecoration(
                                                      color: Color.fromARGB(255, 18, 18, 27),
                                                      borderRadius: BorderRadius.all(
                                                        Radius.circular(35),
                                                      ),
                                                    ),
                                                    child: Builder(
                                                      builder: (context) {
                                                        if (isEditModeEnabled == false) {
                                                          return CupertinoButton(
                                                          padding: const EdgeInsets.all(0),
                                                          pressedOpacity: 0.8,
                                                          child: const FaIcon(
                                                            FontAwesomeIcons.pen,
                                                            size: 22,
                                                          ),
                                                          onPressed: (){
                                                            setState(() {
                                                              editTaskTitleController.text = taskTile;
                                                              editTaskLinkController.text = taskAttachedLink;
                                                              editTaskDescriptionController.text = taskDescription;
                                                              isEditModeEnabled = true;
                                                            });
                                                          }
                                                        );
                                                        } else {
                                                          return Container();
                                                        }
                                                      }
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              const SizedBox(width: 5,),
                                              Container(
                                                height: 80,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(255, 18, 18, 27),
                                                  borderRadius: const BorderRadius.all(
                                                    Radius.circular(50.0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: CupertinoColors.systemGrey.withValues(alpha: 0.05),
                                                      spreadRadius: 4,
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 3),
                                                    )
                                                  ]
                                                ),
                                                child: CupertinoButton(
                                                  child: const FaIcon(
                                                  FontAwesomeIcons.trashCan,
                                                  color: CupertinoColors.systemRed,
                                                  size: 30,
                                                ),
                                                  onPressed: () {
                                                    deleteTask();
                                                  },
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  const SizedBox(height: 40,),
                                                  Container(
                                                    height: 100,
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                      color: const Color.fromARGB(255, 18, 18, 27),
                                                      borderRadius: const BorderRadius.all(
                                                        Radius.circular(50.0),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: CupertinoColors.systemGrey.withValues(alpha: 0.05),
                                                          spreadRadius: 4,
                                                          blurRadius: 10,
                                                          offset: const Offset(0, 3),
                                                        )
                                                      ]
                                                    ),
                                                    child: CupertinoButton(
                                                      child: const FaIcon(
                                                      FontAwesomeIcons.check,
                                                      color: CupertinoColors.activeGreen,
                                                      size: 55,
                                                    ),
                                                      onPressed: (){
                                                        markTaskAsCompleted();
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                height: 80,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(255, 18, 18, 27),
                                                  borderRadius: const BorderRadius.all(
                                                    Radius.circular(50.0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: CupertinoColors.systemGrey.withValues(alpha: 0.05),
                                                      spreadRadius: 4,
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 3),
                                                    )
                                                  ]
                                                ),
                                                child: CupertinoButton(
                                                  child: const FaIcon(
                                                  FontAwesomeIcons.share,
                                                  color: Color.fromARGB(255, 255, 179, 0),
                                                  size: 30,
                                                ),
                                                  onPressed: (){
                                                    skipTask();
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 5,),
                                            ],
                                          ),
                                        ],
                                      );
                                      }
                                    }
                                  );
                                }
                              );
                            } if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                              // if the stream of data is empty
                              return Column(
                                children: [
                                  const SizedBox(height: 10,),
                                  const Image(
                                    height: 300,
                                    fit: BoxFit.fitHeight,
                                    image: AssetImage('assets/images/celebration_task_list_empty.png')
                                  ),
                                  const SizedBox(height: 30,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text('Your task list is empty, Yay!',
                                        style: TextStyle(
                                          color: CupertinoColors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 30, right: 30),
                                          child: Text('Add more tasks by tapping the "+" icon below',
                                            style: TextStyle(
                                              color: CupertinoColors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              return loadingWidget;
                            }
                          },
                        ),
                      ),
                    ]
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 18, 18, 27),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(50.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey.withValues(alpha: 0.05),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ]
                  ),
                  child: CupertinoButton(
                    child: const FaIcon(
                    FontAwesomeIcons.bars,
                    color: CupertinoColors.white,
                  ),
                    onPressed: (){
                      showTaskListPanel(context);
                    },
                  ),
                ),
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 18, 18, 27),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(50.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey.withValues(alpha: 0.05),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ]
                  ),
                  child: CupertinoButton(
                    child: const FaIcon(
                    FontAwesomeIcons.plus,
                    color: CupertinoColors.white,
                  ),
                    onPressed: (){
                      _showAddTaskPanel(context);
                    },
                  ),
                ),
              ],
            ),
            const Text('Version $appVersionNumber',
              style: TextStyle(
                color: Color.fromARGB(255, 80, 80, 113),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication,)) {
       Fluttertoast.showToast(
        timeInSecForIosWeb: 5,
        msg: 'Can\'t open this link, make sure it\'s like this: https://www.website.com/',
        fontSize:16
      );
    }
  }

  void _showAddTaskPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: const Color.fromRGBO(0, 0, 0, 0.001),
            child: DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.2,
              builder: (_, controller) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF28293d),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: const [
                          SizedBox(height: 30,),
                          Text('Add New Task',
                            style: TextStyle(
                              fontSize: 24,
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 20,),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Form(
                                key: formKeySaveTask,
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.85,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.9,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: Color.fromARGB(255, 62, 64, 93),
                                                    borderRadius: BorderRadius.all(
                                                    Radius.circular(20.0),
                                                    ),
                                                  ),
                                                  child: CupertinoTextFormFieldRow(
                                                    textCapitalization: TextCapitalization.sentences,
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    maxLength: 65,
                                                    maxLines: 1,
                                                    placeholder: 'Name this task',
                                                    decoration: const BoxDecoration(
                                                      color: Color.fromARGB(255, 62, 64, 93),
                                                      borderRadius: BorderRadius.all(
                                                      Radius.circular(20.0),
                                                      ),
                                                    ),
                                                    controller: taskTitleController,
                                                    validator: (taskTitle) {
                                                      if (taskTitle == null || taskTitle.isEmpty) {
                                                        return 'please type something first';
                                                        
                                                      } else if (taskTitle.length < 3) {
                                                        return 'must be at least 3 characters long';
                                                        
                                                      } else {
                                                        return null;
                                                      }
                                                    }
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 15,),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.9,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: Color.fromARGB(255, 62, 64, 93),
                                                    borderRadius: BorderRadius.all(
                                                    Radius.circular(20.0),
                                                    ),
                                                  ),
                                                  child: CupertinoTextFormFieldRow(
                                                    textCapitalization: TextCapitalization.sentences,
                                                    maxLength: 1000,
                                                    maxLines: 8,
                                                    placeholder: 'Describe this task',
                                                    decoration: const BoxDecoration(
                                                      color: Color.fromARGB(255, 62, 64, 93),
                                                      borderRadius: BorderRadius.all(
                                                      Radius.circular(20.0),
                                                      ),
                                                    ),
                                                    controller: taskDescriptionController,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 15,),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.9,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: Color.fromARGB(255, 62, 64, 93),
                                                    borderRadius: BorderRadius.all(
                                                    Radius.circular(20.0),
                                                    ),
                                                  ),
                                                  child: CupertinoTextFormFieldRow(
                                                    textCapitalization: TextCapitalization.sentences,
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    maxLength: 500,
                                                    maxLines: 1,
                                                    placeholder: 'Paste a link for this task',
                                                    decoration: const BoxDecoration(
                                                      color: Color.fromARGB(255, 62, 64, 93),
                                                      borderRadius: BorderRadius.all(
                                                      Radius.circular(20.0),
                                                      ),
                                                    ),
                                                    controller: taskLinkController,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 15,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 70, right: 70, top: 10),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(255, 18, 18, 27),
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
                                                  child: const Text('Add Task',
                                                    style: TextStyle(
                                                      color: CupertinoColors.white,
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                  ), 
                                                  onPressed: (){
                                                    final form = formKeySaveTask.currentState!;
                                                      if (form.validate()) {
                                                        saveTaskToFirestore();
                                                        Fluttertoast.showToast(
                                                          timeInSecForIosWeb: 3,
                                                          msg: 'Task added!',
                                                          fontSize:16
                                                        );
                                                                                    
                                                        taskTitleController.clear();
                                                        taskDescriptionController.clear();
                                                        taskLinkController.clear();
                                          
                                                        setState(() {
                                                          taskDocID = generateTaskDocID();
                                                        });
                                                      } else{
                                                                              
                                                      }
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }


  void saveTaskToFirestore(){
    myTasksDBCollection(context)
    .doc(taskDocID)
    .set({
      'taskTile': taskTitleController.text,
      'taskDescription': taskDescriptionController.text,
      'taskAttachedLink': taskLinkController.text,
      'taskDocID': taskDocID,
      'dueDate': Timestamp.now(),
      'isTaskCompleted': false,
      'timesSkipped': 1,
    });
  }

}

