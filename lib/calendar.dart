import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'widgets/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'assignments.dart';  // Import to use the Subtask class

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> eventDetails = {};
  List<DateTime> highlightedDates = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("assignments")
          .where('creator', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('date', descending: false)
          .get();

      setState(() {
        eventDetails.clear();
        highlightedDates.clear();

        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          Timestamp timestamp = data['date'];
          DateTime eventDate = timestamp.toDate();
          eventDate = DateTime(
              eventDate.year, eventDate.month, eventDate.day, 0, 0, 0, 0, 0);

          Map<String, dynamic> assignment = {
            'title': data['title'] ?? '',
            'course': data['course'] ?? '',
            'description': data['description'] ?? '',
            'subtasks': data['subtasks'] ?? [],
            'progress': data['progress'] ?? 0.0,
          };

          if (eventDetails[eventDate] == null) {
            eventDetails[eventDate] = [];
          }

          eventDetails[eventDate]!.add(assignment);
          if (!highlightedDates.contains(eventDate)) {
            highlightedDates.add(eventDate);
          }
        }
      });
      
      print('Fetched ${querySnapshot.docs.length} assignments');
      print('Dates with events: ${highlightedDates.length}');
      eventDetails.forEach((date, assignments) {
        print('Date: $date, Assignments: ${assignments.length}');
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
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
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: isDarkMode ? Colors.white : Colors.black),
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
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              formatButtonShowsNext: false,
              formatButtonTextStyle: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              formatButtonDecoration: BoxDecoration(
                border: Border.all(color: colorScheme.primary),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              final normalizedDay = DateTime(day.year, day.month, day.day, 0, 0, 0, 0, 0);
              final assignments = eventDetails[normalizedDay] ?? [];
              return assignments.isNotEmpty ? List.generate(assignments.length, (_) => normalizedDay) : [];
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerSize: 8,
              markersMaxCount: 4,
              markerDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerMargin: EdgeInsets.symmetric(horizontal: 0.3),
            ),
          ),
          Expanded(
            child: _selectedDay == null
                ? Center(
                    child: Text('Please select a day'),
                  )
                : Builder(
                    builder: (context) {
                      final normalizedSelectedDay = DateTime(
                        _selectedDay!.year,
                        _selectedDay!.month,
                        _selectedDay!.day,
                        0,
                        0,
                        0,
                        0,
                        0
                      );
                      
                      final assignments = eventDetails[normalizedSelectedDay] ?? [];
                      
                      if (assignments.isEmpty) {
                        return Center(
                          child: Text('No assignments for selected day'),
                        );
                      }

                      return SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: assignments.map((assignment) => Container(
                            margin: EdgeInsets.only(bottom: 16),
                            padding: EdgeInsets.all(20),
                            constraints: BoxConstraints(
                              minHeight: 150,
                              minWidth: double.infinity,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.black : colorScheme.surface,
                              border: Border.all(
                                color: colorScheme.primary,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  assignment['title'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Course',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  assignment['course'],
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  assignment['description'],
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                                if ((assignment['subtasks'] as List?)?.isNotEmpty ?? false) ...[
                                  SizedBox(height: 16),
                                  Text(
                                    'Subtasks',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  ...(assignment['subtasks'] as List).map((subtaskData) {
                                    final subtask = Subtask.fromMap(subtaskData as Map<String, dynamic>);
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            subtask.isCompleted 
                                              ? Icons.check_box 
                                              : Icons.check_box_outline_blank,
                                            color: colorScheme.primary,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            subtask.title,
                                            style: TextStyle(
                                              color: isDarkMode ? Colors.white : Colors.black,
                                              decoration: subtask.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  SizedBox(height: 16),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: assignment['progress'] ?? 0.0,
                                      backgroundColor: colorScheme.primary.withOpacity(0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.primary,
                                      ),
                                      minHeight: 10,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '${((assignment['progress'] ?? 0.0) * 100).toInt()}% Complete',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )).toList(),
                        ),
                      );
                    }
                  ),
          ),
        ],
      ),
    );
  }
}
