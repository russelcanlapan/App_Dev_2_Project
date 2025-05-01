import 'package:flutter/material.dart';
import 'widgets/app_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Subtask {
  final String title;
  bool isCompleted;

  Subtask({
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class Assignment {
  final String title;
  final String description;
  final DateTime dueDate;
  final String course;
  bool isCompleted;
  bool isExpanded;
  List<Subtask> subtasks;
  double progress;

  Assignment({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.course,
    this.isCompleted = false,
    this.isExpanded = false,
    this.subtasks = const [],
    this.progress = 0.0,
  });

  void updateProgress() {
    if (subtasks.isEmpty) {
      progress = 0.0;
      return;
    }
    int completedTasks = subtasks.where((task) => task.isCompleted).length;
    progress = completedTasks / subtasks.length;
  }
}

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  String? expandedId;

  Future<void> _showAssignmentDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final courseController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    List<TextEditingController> subtaskControllers = [TextEditingController()];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Add Assignment',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Title'),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Course'),
                    TextField(
                      controller: courseController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Description'),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Due Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 1),
                            );
                            if (picked != null && picked != selectedDate) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Text(
                            'Select Date',
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtasks',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: colorScheme.primary),
                          onPressed: () {
                            setState(() {
                              subtaskControllers.add(TextEditingController());
                            });
                          },
                        ),
                      ],
                    ),
                    ...subtaskControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      TextEditingController controller = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  hintText: 'Enter subtask',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                            ),
                            if (subtaskControllers.length > 1)
                              IconButton(
                                icon: Icon(Icons.remove, color: colorScheme.primary),
                                onPressed: () {
                                  setState(() {
                                    subtaskControllers.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty ||
                        courseController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill in all required fields'),
                        ),
                      );
                      return;
                    }

                    List<Map<String, dynamic>> subtasks = subtaskControllers
                        .where((controller) => controller.text.isNotEmpty)
                        .map((controller) => {
                              'title': controller.text.trim(),
                              'isCompleted': false,
                            })
                        .toList();

                    try {
                      await FirebaseFirestore.instance
                          .collection("assignments")
                          .add({
                        "title": titleController.text.trim(),
                        "description": descriptionController.text.trim(),
                        "course": courseController.text.trim(),
                        "date": selectedDate,
                        "postedDate": FieldValue.serverTimestamp(),
                        "creator": FirebaseAuth.instance.currentUser!.uid,
                        "subtasks": subtasks,
                        "progress": 0.0,
                      });

                    } catch (e) {
                      print(e);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showUpdateAssignmentDialog(
      String docId,
      Assignment? existingAssignment) async {
    final titleController =
        TextEditingController(text: existingAssignment?.title ?? '');
    final descriptionController =
        TextEditingController(text: existingAssignment?.description ?? '');
    final courseController =
        TextEditingController(text: existingAssignment?.course ?? '');
    DateTime selectedDate = existingAssignment?.dueDate ?? DateTime.now();
    
    List<TextEditingController> subtaskControllers = existingAssignment?.subtasks.map(
      (subtask) => TextEditingController(text: subtask.title)
    ).toList() ?? [];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Edit Assignment',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Title'),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Course'),
                    TextField(
                      controller: courseController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Description'),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Due Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 1),
                            );
                            if (picked != null && picked != selectedDate) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Text(
                            'Select Date',
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtasks',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: colorScheme.primary),
                          onPressed: () {
                            setState(() {
                              subtaskControllers.add(TextEditingController());
                            });
                          },
                        ),
                      ],
                    ),
                    ...subtaskControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      TextEditingController controller = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  hintText: 'Enter subtask',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                            ),
                            if (subtaskControllers.length > 1)
                              IconButton(
                                icon: Icon(Icons.remove, color: colorScheme.primary),
                                onPressed: () {
                                  setState(() {
                                    subtaskControllers.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        courseController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill in all required fields'),
                        ),
                      );
                      return;
                    }

                    List<Map<String, dynamic>> subtasks = subtaskControllers
                        .where((controller) => controller.text.isNotEmpty)
                        .map((controller) => {
                              'title': controller.text.trim(),
                              'isCompleted': false,
                            })
                        .toList();

                    FirebaseFirestore.instance
                        .collection("assignments")
                        .doc(docId)
                        .update({
                      "title": titleController.text.trim(),
                      "description": descriptionController.text.trim(),
                      "course": courseController.text.trim(),
                      "date": selectedDate,
                      "subtasks": subtasks,
                      "progress": 0.0,
                    });

                    Navigator.pop(context);
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(color: colorScheme.primary),
                  ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.primary),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'ORGANICE',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Assignment Manager',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('assignments')
                  .where('creator', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .orderBy('date', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No assignments yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.onBackground,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final assignment = Assignment(
                      title: data['title'],
                      description: data['description'],
                      dueDate: (data['date'] as Timestamp).toDate(),
                      course: data['course'],
                      isCompleted: data['isCompleted'] ?? false,
                      isExpanded: data['isExpanded'] ?? false,
                      subtasks: (data['subtasks'] as List<dynamic>?)
                          ?.map((e) => Subtask.fromMap(e as Map<String, dynamic>))
                          .toList() ?? [],
                      progress: data['progress'] ?? 0.0,
                    );

                    bool isExpanded = doc.id == expandedId;

                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              expandedId = isExpanded ? null : doc.id;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            assignment.title,
                                            style: TextStyle(
                                              color: colorScheme.primary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          isExpanded ? Icons.expand_less : Icons.expand_more,
                                          color: colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isExpanded) ...[
                                Divider(color: colorScheme.primary),
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Course',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        assignment.course,
                                        style: TextStyle(color: colorScheme.onBackground),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Due Date',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        DateFormat('yyyy-MM-dd').format(assignment.dueDate),
                                        style: TextStyle(color: colorScheme.onBackground),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Description',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        assignment.description,
                                        style: TextStyle(color: colorScheme.onBackground),
                                      ),
                                      if (assignment.subtasks.isNotEmpty) ...[
                                        SizedBox(height: 16),
                                        Text(
                                          'Subtasks',
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Column(
                                          children: assignment.subtasks.asMap().entries.map((entry) {
                                            int index = entry.key;
                                            Subtask subtask = entry.value;
                                            return Padding(
                                              padding: EdgeInsets.only(bottom: 8),
                                              child: Row(
                                                children: [
                                                  Checkbox(
                                                    value: subtask.isCompleted,
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        subtask.isCompleted = value ?? false;
                                                        assignment.updateProgress();
                                                        // Update in Firestore
                                                        FirebaseFirestore.instance
                                                            .collection("assignments")
                                                            .doc(doc.id)
                                                            .update({
                                                          "subtasks": assignment.subtasks
                                                              .map((s) => s.toMap())
                                                              .toList(),
                                                          "progress": assignment.progress,
                                                        });
                                                      });
                                                    },
                                                    activeColor: colorScheme.primary,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      subtask.title,
                                                      style: TextStyle(
                                                        color: colorScheme.onBackground,
                                                        decoration: subtask.isCompleted
                                                            ? TextDecoration.lineThrough
                                                            : null,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        SizedBox(height: 16),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: LinearProgressIndicator(
                                            value: assignment.progress,
                                            backgroundColor: colorScheme.primary.withOpacity(0.2),
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              colorScheme.primary,
                                            ),
                                            minHeight: 10,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '${(assignment.progress * 100).toInt()}% Complete',
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () => _showUpdateAssignmentDialog(doc.id, assignment),
                                            child: Text(
                                              'Update',
                                              style: TextStyle(color: Colors.blue),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          TextButton(
                                            onPressed: () => _deleteAssignment(doc.id),
                                            child: Text(
                                              'Delete',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _showAssignmentDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Add Assignment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
