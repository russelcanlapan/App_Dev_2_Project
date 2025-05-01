import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import '../calendar.dart';
import '../assignments.dart';
import '../settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../services/location_services.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _username = 'No User Found';
  String _email = 'No Email Found';
  bool _isLoading = true;
  var lat;
  var long;

  final WeatherFactory _weatherFactory =
      WeatherFactory("8b50ab72d9bf8e21c4b502fe7cce56a4");

  Weather? _weather;

  @override
  void initState() {
    super.initState();
    getUserDoc();
    getLocation();
  }

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
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching user data: $e');
    }
  }

  Future<void> getLocation() async {
    try {
      Position position = await LocationServices.getCurrentLocation();
      setState(() {
        lat = position.latitude;
        long = position.longitude;
      });

      if (lat != null && long != null) {
        _weatherFactory
            .currentWeatherByLocation(lat, long)
            .then((w) => setState(() {
          _weather = w;
        }));
      } else {
        _weatherFactory
            .currentWeatherByCityName("Philadelphia")
            .then((w) => setState(() {
          _weather = w;
        }));
      }

      print(lat);
      print(long);
    } catch (e) {
      print('Error getting location: $e');
      // Fallback to using a city name if there's an error
      _weatherFactory
          .currentWeatherByCityName("Philadelphia")
          .then((w) => setState(() {
        _weather = w;
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              // not here
              color: colorScheme.primary,
            ),
            margin: EdgeInsets.all(0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // not here
              children: [
                // not here
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child:
                      Icon(Icons.person, color: colorScheme.primary, size: 40),
                ),
                SizedBox(height: 10),
                Text(
                  _username,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _email,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              ListTile(
                leading: Icon(Icons.calendar_today, color: colorScheme.primary),
                title: Text('Calendar',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CalendarPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.assignment, color: colorScheme.primary),
                title: Text('Assignments',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AssignmentsPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: colorScheme.primary),
                title: Text('Settings',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
            ],
          ),
          Column(
            children: [_buildWeatherUI()],
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => WelcomePage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
