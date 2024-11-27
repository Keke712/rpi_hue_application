import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../LightApiService.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LightApiService _lightService = LightApiService();
  String? _connectedLamp;
  TextEditingController _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _connectedLamp = 'Hue color lamp'; // Set identifier locally
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _ipController.text = prefs.getString('baseUrl') ?? _lightService.baseUrl;
  }

  Future<void> _saveIpAddress() async {
    final newUrl = _ipController.text;
    if (newUrl.isNotEmpty) {
      await _lightService.setBaseUrl(newUrl);
      setState(() {
        _connectedLamp = null; // Reset until fetched again
      });
      _loadSettings(); // Reload settings after changing base URL
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lightbulb),
            title: const Text('Lampe connectée'),
            subtitle: Text(_connectedLamp ?? 'Chargement...'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_ethernet),
            title: const Text('Adresse IP du serveur'),
            subtitle: TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                hintText: 'http://192.168.x.x:5000',
              ),
              keyboardType: TextInputType.url,
              onSubmitted: (_) => _saveIpAddress(),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveIpAddress,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Thème'),
            subtitle: Text(
              Theme.of(context).brightness == Brightness.dark 
                ? 'Sombre' 
                : 'Clair'
            ),
          ),
          // Ajoutez d'autres paramètres ici selon vos besoins
        ],
      ),
    );
  }
}