import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import '../calendar.dart';
import '../assignments.dart';
import '../settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _username = 'No User Found';
  String _email = 'No Email Found';
  bool _isLoading = true;

  final WeatherFactory _weatherFactory =
      WeatherFactory("5a4f62caa9dd98bf4b6b4902519ace0a");

  Weather? _weather;

  @override
  void initState() {
    super.initState();
    getUserDoc();
    _weatherFactory
        .currentWeatherByCityName("Montreal")
        .then((w) => setState(() {
              _weather = w;
            }));
  }

  // Function to fetch user document
  Future<void> getUserDoc() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          _username = data['username'] ?? 'No User Found';
          _email = FirebaseAuth.instance.currentUser!.email ?? 'No Email Found';
          _isLoading = false; // Set loading to false once data is fetched
        });
      } else {
        setState(() {
          _isLoading = false; // Set loading to false if document doesn't exist
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Set loading to false in case of error
      });
      print('Error fetching user data: $e');
    }
  }

  Future<bool> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue,
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 12),
                // Show loading indicator while fetching user data
                _isLoading
                    ? CircularProgressIndicator()
                    : Column(
                        children: [
                          Text(
                            _username,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _email,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Calendar'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CalendarPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Assignments'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AssignmentsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          SizedBox(height: 75),
          _buildWeatherUI(),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (await logout() == true) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
                minimumSize: Size(double.infinity, 0),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherUI() {
    if (_weather == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Container(
        height: 250,
        margin: EdgeInsets.all(15),
        color: Colors.greenAccent.shade400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_weather?.areaName ?? "No Area Found",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            _dateTimeInfo(),
            _weatherIcon(),
            Text(_weather?.weatherDescription ?? "No Weather Description Found",
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 20)),
            Text(
                "${_weather?.temperature?.celsius?.toStringAsFixed(0)}°C" ??
                    "No Temperature found",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28)),
          ],
        ),
      );
    }
  }

  Widget _dateTimeInfo() {
    DateTime? now = _weather!.date;
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now!),
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _weatherIcon() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(
                  "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"))),
    );
  }
}
