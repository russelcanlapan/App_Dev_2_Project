import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'widgets/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  Map<DateTime, List<String>> eventDetails = {}; // Store event details
  List<DateTime> highlightedDates = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    FirebaseFirestore.instance
        .collection("assignments")
        .where('creator', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('date', descending: false)
        .get()
        .then((querySnapshot) {
      setState(() {
        eventDetails.clear();
        highlightedDates.clear();

        for (var doc in querySnapshot.docs) {
          Timestamp timestamp = doc['date'];
          DateTime eventDate = timestamp.toDate();

          // Normalize eventDate to ignore time by setting it to midnight UTC
          eventDate = DateTime(
              eventDate.year, eventDate.month, eventDate.day, 0, 0, 0, 0, 0);

          String title = doc['title'];
          String description = doc['description'];
          String course = doc['course'];


          if (eventDetails[eventDate] == null) {
            eventDetails[eventDate] = [];
          }

          eventDetails[eventDate]?.add(title);
          eventDetails[eventDate]?.add(course);
          eventDetails[eventDate]?.add(description);
          highlightedDates.add(eventDate);
        }
      });
    });
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Calendar View',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              // Normalize the day being compared to ignore time by setting it to midnight UTC
              day = DateTime(day.year, day.month, day.day, 0, 0, 0, 0, 0);

              // Highlight the days in highlightedDates list
              return highlightedDates.any((highlightedDate) =>
                  highlightedDate.year == day.year &&
                  highlightedDate.month == day.month &&
                  highlightedDate.day == day.day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                // Normalize selected day to ignore time by setting it to midnight UTC
                _selectedDay = DateTime(selectedDay.year, selectedDay.month,
                    selectedDay.day, 0, 0, 0, 0, 0);
                _focusedDay = focusedDay;

                // Debugging print
                print('Selected Day: $_selectedDay');
                print('Highlighted Dates: $highlightedDates');
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
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent.shade700,
              ),
              weekendTextStyle: TextStyle(color: Colors.black),
              outsideDaysVisible: true,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
              weekendStyle:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: eventDetails[_selectedDay!] != null
                ? Container(
              margin: EdgeInsets.all(16), // Margin around the container
              padding: EdgeInsets.all(20), // Padding inside the container
              decoration: BoxDecoration(
                color: Colors.blueAccent, // Background color
                borderRadius: BorderRadius.circular(10), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Shadow color
                    blurRadius: 5, // Shadow blur radius
                    offset: Offset(0, 4), // Shadow offset
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Date: ${_selectedDay != null ? DateFormat('yyyy-MM-dd').format(_selectedDay!) : 'No date selected'}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 40), // Space between the text
                  Text(
                    'Event Title: ${eventDetails[_selectedDay!]?[0] ?? 'No title'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Course: ${eventDetails[_selectedDay!]?[1] ?? 'No course'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Description: ${eventDetails[_selectedDay!]?[2] ?? 'No description'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
                : Text(
              'No events for this date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
