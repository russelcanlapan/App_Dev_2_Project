import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
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

  void _initializeSelectedColor() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currentColor = themeProvider.primaryColor;
    
    if (currentColor == Colors.red) {
      _selectedValue2 = 1;
    } else if (currentColor == Colors.orange) {
      _selectedValue2 = 2;
    } else if (currentColor == Colors.yellow) {
      _selectedValue2 = 3;
    } else if (currentColor == Colors.green) {
      _selectedValue2 = 4;
    } else if (currentColor == Colors.blue) {
      _selectedValue2 = 5;
    } else if (currentColor == Colors.purple) {
      _selectedValue2 = 6;
    }
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor: isDarkMode ? Colors.black : Colors.white,
              title: Text(
                'Change Username',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _usernameController,
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(color: colorScheme.primary),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                      ),
                    ),
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
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({'username': _usernameController.text});
                    } catch (e) {
                      print(e);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Change',
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

  Future<void> _showUserColour() async {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    // Store the initial color and value
    final initialColor = themeProvider.primaryColor;
    final initialValue = _selectedValue2;
    
    // Set the initial selected value based on current color
    final currentColor = themeProvider.primaryColor;
    if (currentColor == Colors.red) {
      _selectedValue2 = 1;
    } else if (currentColor == Colors.orange) {
      _selectedValue2 = 2;
    } else if (currentColor == Colors.yellow) {
      _selectedValue2 = 3;
    } else if (currentColor == Colors.green) {
      _selectedValue2 = 4;
    } else if (currentColor == Colors.blue) {
      _selectedValue2 = 5;
    } else if (currentColor == Colors.purple) {
      _selectedValue2 = 6;
    }

    Color getSelectedColor() {
      switch (_selectedValue2) {
        case 1:
          return Colors.red;
        case 2:
          return Colors.orange;
        case 3:
          return Colors.yellow;
        case 4:
          return Colors.green;
        case 5:
          return Colors.blue;
        case 6:
          return Colors.purple;
        default:
          return Colors.blue;
      }
    }

    String getColorName(int value) {
      switch (value) {
        case 1:
          return 'red';
        case 2:
          return 'orange';
        case 3:
          return 'yellow';
        case 4:
          return 'green';
        case 5:
          return 'blue';
        case 6:
          return 'purple';
        default:
          return 'blue';
      }
    }
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final selectedColor = getSelectedColor();
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor: isDarkMode ? Colors.black : Colors.white,
              title: Text(
                'Change Colour',
                style: TextStyle(
                  color: selectedColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text('Red', style: TextStyle(color: Colors.red)),
                      leading: Radio<int>(
                        value: 1,
                        groupValue: _selectedValue2,
                        fillColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.red;
                            }
                            return isDarkMode ? Colors.white : Colors.black;
                          },
                        ),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedValue2 = value!;
                            Provider.of<ThemeProvider>(context, listen: false)
                                .setPrimaryColor('red');
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Orange', style: TextStyle(color: Colors.orange)),
                      leading: Radio<int>(
                        value: 2,
                        groupValue: _selectedValue2,
                        fillColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.orange;
                            }
                            return isDarkMode ? Colors.white : Colors.black;
                          },
                        ),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedValue2 = value!;
                            Provider.of<ThemeProvider>(context, listen: false)
                                .setPrimaryColor('orange');
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Yellow', style: TextStyle(color: Colors.yellow)),
                      leading: Radio<int>(
                        value: 3,
                        groupValue: _selectedValue2,
                        fillColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.yellow;
                            }
                            return isDarkMode ? Colors.white : Colors.black;
                          },
                        ),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedValue2 = value!;
                            Provider.of<ThemeProvider>(context, listen: false)
                                .setPrimaryColor('yellow');
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Green', style: TextStyle(color: Colors.green)),
                      leading: Radio<int>(
                        value: 4,
                        groupValue: _selectedValue2,
                        fillColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.green;
                            }
                            return isDarkMode ? Colors.white : Colors.black;
                          },
                        ),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedValue2 = value!;
                            Provider.of<ThemeProvider>(context, listen: false)
                                .setPrimaryColor('green');
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Blue', style: TextStyle(color: Colors.blue)),
                      leading: Radio<int>(
                        value: 5,
                        groupValue: _selectedValue2,
                        fillColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.blue;
                            }
                            return isDarkMode ? Colors.white : Colors.black;
                          },
                        ),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedValue2 = value!;
                            Provider.of<ThemeProvider>(context, listen: false)
                                .setPrimaryColor('blue');
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Purple', style: TextStyle(color: Colors.purple)),
                      leading: Radio<int>(
                        value: 6,
                        groupValue: _selectedValue2,
                        fillColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.purple;
                            }
                            return isDarkMode ? Colors.white : Colors.black;
                          },
                        ),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedValue2 = value!;
                            Provider.of<ThemeProvider>(context, listen: false)
                                .setPrimaryColor('purple');
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Restore the original color and value when canceling
                    _selectedValue2 = initialValue;
                    Provider.of<ThemeProvider>(context, listen: false)
                        .setPrimaryColor(getColorName(initialValue));
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: selectedColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({'preferredColour': getColorName(_selectedValue2)});
                    } catch (e) {
                      print(e);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Change',
                    style: TextStyle(color: selectedColor),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showUserLightMode() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;
    
    // Store the initial dark mode state
    final initialIsDarkMode = themeProvider.isDarkMode;
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor: isDarkMode ? Colors.black : Colors.white,
              title: Text(
                'Select a Light Mode',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      'Light Mode',
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    leading: Radio<bool>(
                      value: false,
                      groupValue: isDarkMode,
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return colorScheme.primary;
                          }
                          return isDarkMode ? Colors.white : Colors.black;
                        },
                      ),
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            // If currently in dark mode and we want light mode, toggle
                            if (isDarkMode) {
                              themeProvider.toggleTheme();
                            }
                          });
                        }
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    leading: Radio<bool>(
                      value: true,
                      groupValue: isDarkMode,
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return colorScheme.primary;
                          }
                          return isDarkMode ? Colors.white : Colors.black;
                        },
                      ),
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            // If currently in light mode and we want dark mode, toggle
                            if (!isDarkMode) {
                              themeProvider.toggleTheme();
                            }
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // If current state doesn't match initial state, toggle back
                    if (themeProvider.isDarkMode != initialIsDarkMode) {
                      themeProvider.toggleTheme();
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'preferredLightMode': themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode'
                      });
                    } catch (e) {
                      print(e);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Change',
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
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
                    backgroundColor: colorScheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                    minimumSize: Size(double.infinity, 0),
                  ),
                  child: Text(
                    'Change Light Mode',
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
                    backgroundColor: colorScheme.primary,
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
                    backgroundColor: colorScheme.primary,
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
