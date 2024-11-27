import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'lights_screen.dart';
import 'LightApiService.dart';
import 'modes_screen.dart';
import 'color_wheel.dart';

class TabsScreen extends StatefulWidget {
  final LightState initialState;

  const TabsScreen({Key? key, required this.initialState}) : super(key: key);

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> with SingleTickerProviderStateMixin {
  final LightApiService _lightService = LightApiService();
  late Color _selectedColor;
  late double _brightness;
  late bool _isLightOn;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedColor = Color(0xFF000000 | (widget.initialState.color ?? 0xFFFFFF));
    _brightness = widget.initialState.brightness?.toDouble() ?? 100.0;
    _isLightOn = widget.initialState.isOn;
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<void> _setBrightness(double value) async {
    setState(() {
      _brightness = value;
    });
    await _lightService.setBrightness(value.round());
  }

  Future<void> _setColor(Color color) async {
    setState(() {
      _selectedColor = color;
    });
    await _lightService.setColor(color);
  }

  Widget _buildBrightnessSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.brightness_low),
              Expanded(
                child: Slider(
                  value: _brightness,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: _brightness.round().toString(),
                  onChanged: (value) {
                    setState(() => _brightness = value);
                  },
                  onChangeEnd: _setBrightness,
                ),
              ),
              const Icon(Icons.brightness_high),
            ],
          ),
          Text('${_brightness.round()}%'),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return ColorWheel(
      initialColor: _selectedColor,
      onColorChanged: _setColor,
    );
  }

  Widget _buildColorTab() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            backgroundColor: _selectedColor,
            radius: 30,
          ),
          const SizedBox(height: 20),
          _buildBrightnessSlider(),
          const SizedBox(height: 20),
          _buildColorPicker(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('RPI Hue Application'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.lightbulb), text: 'Lumières'),
              Tab(icon: Icon(Icons.palette), text: 'Couleurs'),
              Tab(icon: Icon(Icons.auto_fix_high), text: 'Modes'),
              Tab(icon: Icon(Icons.settings), text: 'Paramètres'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            LightsScreen(
              isLightOn: _isLightOn,
              brightness: _brightness,
              color: _selectedColor,
              onToggle: (isOn) async {
                setState(() {
                  _isLightOn = isOn;
                });
                if (isOn) {
                  await _lightService.turnOn();
                } else {
                  await _lightService.turnOff();
                }
              },
            ),
            _buildColorTab(),
            const ModesScreen(),
            const SettingsScreen(),
          ],
        ),
      ),
    );
  }
}