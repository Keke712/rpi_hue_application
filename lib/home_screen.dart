import 'package:flutter/material.dart';
import 'color_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color _selectedColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Picker App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColorPicker(
              initialColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
            const SizedBox(height: 24.0),
            Text(
              'Selected Color: $_selectedColor',
              style: const TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}