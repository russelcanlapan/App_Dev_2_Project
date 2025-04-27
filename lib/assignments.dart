import 'package:flutter/material.dart';
import 'widgets/app_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Assignment {
  final String title;
  final String description;
  final DateTime dueDate;
  final String course;
  bool isCompleted;

  Assignment({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.course,
    this.isCompleted = false,
  });
}

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {

  Future<void> _showAssignmentDialog() async { // the ADD dialog
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final courseController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Assignment', style: TextStyle(color: Colors.blueAccent.shade700)),
              backgroundColor: Colors.white,
              iconColor: Colors.blue,
              shadowColor: Colors.blue,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: courseController,
                      decoration: InputDecoration(
                        labelText: 'Course',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                            'Due Date: ${selectedDate.toString().split(' ')[0]}'),
                        Spacer(),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 1,
                                  DateTime.now().month, DateTime.now().day),
                            );
                            if (picked != null && picked != selectedDate) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Text('Select Date', style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.blue)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty ||
                        courseController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Please fill in all required fields')),
                      );
                      return;
                    } else {
                      try {
                        await FirebaseFirestore.instance
                            .collection("assignments")
                            .add({
                          "title": titleController.text.trim(),
                          "description": descriptionController.text.trim(),
                          "course": courseController.text.trim(),
                          "date": selectedDate,
                          "postedDate": FieldValue.serverTimestamp(),
                          "creator": FirebaseAuth.instance.currentUser!.uid
                        });
                      } catch (e) {
                        print(e);
                      }
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade50),
                  child: Text('Add', style: TextStyle(color: Colors.blue)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showUpdateAssignmentDialog( // the EDIT dialog
      String docId, Assignment? existingAssignment) async {
    final titleController =
        TextEditingController(text: existingAssignment?.title ?? '');
    final descriptionController =
        TextEditingController(text: existingAssignment?.description ?? '');
    final courseController =
        TextEditingController(text: existingAssignment?.course ?? '');
    DateTime selectedDate = existingAssignment?.dueDate ?? DateTime.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Assignment', style: TextStyle(color: Colors.blueAccent.shade700)),
              backgroundColor: Colors.white,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: courseController,
                      decoration: InputDecoration(
                        labelText: 'Course',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                            'Due Date: ${selectedDate.toString().split(' ')[0]}'),
                        Spacer(),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 1,
                                  DateTime.now().month, DateTime.now().day),
                            );
                            if (picked != null && picked != selectedDate) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Text('Select Date', style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.blue)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        courseController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Please fill in all required fields')),
                      );
                      return;
                    }

                    final updatedAssignment = Assignment(
                      title: titleController.text,
                      description: descriptionController.text,
                      dueDate: selectedDate,
                      course: courseController.text,
                      isCompleted: existingAssignment?.isCompleted ?? false,
                    );

                    FirebaseFirestore.instance
                        .collection("assignments")
                        .doc(docId)
                        .update({
                      "title": updatedAssignment.title,
                      "description": updatedAssignment.description,
                      "course": updatedAssignment.course,
                      "date": updatedAssignment.dueDate,
                    });

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade50),
                  child: Text('Save', style: TextStyle(color: Colors.blue))
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAssignment(String docId) async {
    await FirebaseFirestore.instance
        .collection("assignments")
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ORGANICE',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      endDrawer: AppDrawer(),
      body: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assignment Manager',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("assignments").where('creator', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No Assignments Yet...'));
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final assignment = Assignment(
                          title: data['title'],
                          description: data['description'],
                          dueDate: (data['date'] as Timestamp).toDate(),
                          course: data['course'],
                        );

                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                          shadowColor: Colors.blue,
                          child: ExpansionTile(
                            title: Text(assignment.title,
                                style: TextStyle(
                                    color: Colors.blueAccent.shade700,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500)),
                            iconColor: Colors.blue,
                            collapsedBackgroundColor: Colors.white,
                            backgroundColor: Colors.white,
                            children: [
                              ListTile(
                                title: Text('Course'),
                                subtitle: Text(assignment.course),
                              ),
                              ListTile(
                                title: Text('Description'),
                                subtitle: Text(assignment.description),
                              ),
                              ListTile(
                                title: Text('Due Date'),
                                subtitle: Text(assignment.dueDate
                                    .toString()
                                    .split(' ')[0]),
                              ),
                              ButtonBar(
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        _showUpdateAssignmentDialog(
                                            doc.id, assignment),
                                    child: Text(
                                      'Update',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _deleteAssignment(doc.id),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          )),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _showAssignmentDialog(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 0,
          ),
          child: Text(
            'Add Assignment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
