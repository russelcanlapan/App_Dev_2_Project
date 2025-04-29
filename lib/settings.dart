import 'package:flutter/material.dart';
import 'widgets/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var _usernameController = TextEditingController();
  int _selectedValue = 1;
  int _selectedValue2 = 1;


  @override
  void initState() {
    super.initState();
    getUsername();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> getUsername() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          _usernameController.text = data['username'] ?? 'No Username Found';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _showUsernameDialog() async {
    // CHANGE USERNAME dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Change Username',
                  style: TextStyle(color: Colors.blueAccent.shade700)),
              backgroundColor: Colors.white,
              iconColor: Colors.blue,
              shadowColor: Colors.blue,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
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
                    if (_usernameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Please fill in the username field')),
                      );
                      return;
                    } else {
                      try {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({"username": _usernameController.text.trim()});
                      } catch (e) {
                        print(e);
                      }
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50),
                  child: Text('Change', style: TextStyle(color: Colors.blue)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showUserColour() async {
    // CHANGE COLOUR dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Change Colour',
                  style: TextStyle(color: Colors.blueAccent.shade700)),
              backgroundColor: Colors.white,
              iconColor: Colors.blue,
              shadowColor: Colors.blue,
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Radio<int>(
                            value: 1, // Value when this radio button is selected
                            groupValue: _selectedValue2, // Value of the selected radio button
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue2 = value!;
                              });
                            },
                          ),
                          Text('Red', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Radio<int>(
                            value: 2,
                            groupValue: _selectedValue2,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue2 = value!;
                              });
                            },
                          ),
                          Text('Orange', style: TextStyle(color: Colors.orange)),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Radio<int>(
                            value: 3,
                            groupValue: _selectedValue2,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue2 = value!;
                              });
                            },
                          ),
                          Text('Yellow', style: TextStyle(color: Colors.yellow)),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Radio<int>(
                            value: 4,
                            groupValue: _selectedValue2,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue2 = value!;
                              });
                            },
                          ),
                          Text('Green', style: TextStyle(color: Colors.greenAccent)),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Radio<int>(
                            value: 5,
                            groupValue: _selectedValue2,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue2 = value!;
                              });
                            },
                          ),
                          Text('Blue', style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Radio<int>(
                            value: 6,
                            groupValue: _selectedValue2,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue2 = value!;
                              });
                            },
                          ),
                          Text('Purple', style: TextStyle(color: Colors.purple)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.blue)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String _colour = 'blue';
                    switch (_selectedValue2) {
                      case 1:
                        _colour = 'red';
                        break;
                      case 2:
                        _colour = 'orange';
                        break;
                      case 3:
                        _colour = 'yellow';
                        break;
                      case 4:
                        _colour = 'green';
                        break;
                      case 5:
                        break;
                      case 6:
                        _colour = 'purple';
                        break;
                      default:
                        break;
                    }
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({'preferredColour': _colour});
                    } catch (e) {
                      print(e);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50),
                  child: Text('Change', style: TextStyle(color: Colors.blue)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showUserLightMode() async {
    // CHANGE LIGHT MODE dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select a Light Mode',
                  style: TextStyle(color: Colors.blueAccent.shade700)),
              backgroundColor: Colors.white,
              iconColor: Colors.blue,
              shadowColor: Colors.blue,
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Radio<int>(
                            value: 1, // Value when this radio button is selected
                            groupValue: _selectedValue, // Value of the selected radio button
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue = value!;
                              });
                            },
                          ),
                          Text('Light Mode'),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Radio<int>(
                            value: 2,
                            groupValue: _selectedValue,
                            onChanged: (int? value) {
                              setState(() {
                                _selectedValue = value!;
                              });
                            },
                          ),
                          Text('Dark Mode'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.blue)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String _lightMode = 'Light Mode';
                    switch (_selectedValue) {
                      case 1:
                        break;
                      case 2:
                        _lightMode = 'Dark Mode';
                        break;
                      default:
                        break;
                    }
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({'preferredLightMode': _lightMode});
                      } catch (e) {
                        print(e);
                      }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50),
                  child: Text('Change', style: TextStyle(color: Colors.blue)),
                ),
              ],
            );
          },
        );
      },
    );
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _showUserLightMode();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                    minimumSize: Size(double.infinity, 0),
                  ),
                  child: Text(
                    'Change to Dark Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _showUserColour();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                    minimumSize: Size(double.infinity, 0),
                  ),
                  child: Text(
                    'Set Colours',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _showUsernameDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                    minimumSize: Size(double.infinity, 0),
                  ),
                  child: Text(
                    'Change Username',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
