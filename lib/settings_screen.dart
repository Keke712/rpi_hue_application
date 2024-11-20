import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appearance',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Text Size',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Slider(
              value: _fontSize,
              min: 12.0,
              max: 24.0,
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            Text(
              'Current Text Size: $_fontSize',
              style: TextStyle(fontSize: _fontSize),
            ),
          ],
        ),
      ),
    );
  }
}