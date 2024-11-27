import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LightApiService {
  String _baseUrl = 'http://192.168.0.11:5000';

  LightApiService() {
    _loadBaseUrl();
  }

  String get baseUrl => _baseUrl;

  Future<void> _loadBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUrl = prefs.getString('baseUrl');
    if (savedUrl != null) {
      _baseUrl = savedUrl;
    }
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('baseUrl', url);
  }

  Future<bool> connect() async {
    try {
      await http.get(Uri.parse('$_baseUrl/connect'));
      final state = await getLightState();
      return state.isConnected;
    } catch (e) {
      print('Erreur de connexion: $e');
      return false;
    }
  }

  Future<bool> turnOn() async {
    try {
      await http.get(Uri.parse('$_baseUrl/on'));
      return true;
    } catch (e) {
      print('Erreur lors de l\'allumage: $e');
      return false;
    }
  }

  Future<bool> turnOff() async {
    try {
      await http.get(Uri.parse('$_baseUrl/off'));
      return true;
    } catch (e) {
      print('Erreur lors de l\'extinction: $e');
      return false;
    }
  }

  Future<bool> setColor(Color color) async {
    try {
      final rgb = '${color.red},${color.green},${color.blue}';
      final response = await http.get(
        Uri.parse('$_baseUrl/color').replace(
          queryParameters: {'rgb': rgb},
        ),
      );
      return _isSuccessful(response);
    } catch (e) {
      print('Erreur lors du changement de couleur: $e');
      return false;
    }
  }

  Future<bool> setBrightness(int? brightness) async {
    if (brightness == null) {
      print('Brightness value is null');
      return false;
    }
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/brightness').replace(
          queryParameters: {'p': brightness.toString()},
        ),
      );
      return _isSuccessful(response);
    } catch (e) {
      print('Erreur lors du changement de luminosité: $e');
      return false;
    }
  }

  Future<LightState> getLightState() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/state'));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = json.decode(response.body);
        return LightState.fromJson(data);
      }
      throw Exception('Failed to get light state with status code: ${response.statusCode}');
    } catch (e) {
      print('Error in getLightState: $e');
      rethrow;
    }
  }

  Future<bool> setMode(String profile) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/set_mode').replace(
          queryParameters: {'profile': profile},
        ),
      );
      return _isSuccessful(response);
    } catch (e) {
      print('Error setting mode: $e');
      return false;
    }
  }

  Future<bool> createMode(Mode mode) async {
    try {
      // Convertir la couleur en chaîne hexadécimale sans le préfixe 0x
      String colorHex = mode.color.toRadixString(16).padLeft(6, '0');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/create_mode'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'profile': mode.profile,
          'light_state': mode.lightState,
          'brightness': mode.brightness.toString(),
          'color': colorHex,  // Utiliser la chaîne hexadécimale
        },
      );
      return _isSuccessful(response);
    } catch (e) {
      print('Error creating mode: $e');
      return false;
    }
  }

  Future<bool> loadMode(String name) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/set_mode').replace(
          queryParameters: {'profile': name},
        ),
      );
      if (_isSuccessful(response)) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          return true;
        }
        print('Error loading mode: ${data['message']}');
      }
      return false;
    } catch (e) {
      print('Error loading mode: $e');
      return false;
    }
  }

  Future<List<String>> getModes() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/get_modes'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['modes'] == false) {
          return [];
        }
        final modeList = ModeList.fromJson(data);
        return modeList.modes.keys.toList();
      }
      return [];
    } catch (e) {
      print('Error getting modes: $e');
      return [];
    }
  }

  bool _isSuccessful(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}

class LightState {
  final int? brightness;
  final int? color; // Changed to int to store the parsed color value
  final bool isOn;
  final bool isConnected;

  LightState({
    this.brightness,
    this.color,
    required this.isOn,
    required this.isConnected,
  });

  factory LightState.fromJson(Map<String, dynamic> json) {
    int? color;
    if (json['color'] != null) {
      final colorJson = json['color'];
      color = (colorJson['r'] << 16) + (colorJson['g'] << 8) + colorJson['b'];
    }
    return LightState(
      brightness: json['brightness'] != null ? int.tryParse(json['brightness'].toString()) : null,
      color: color,
      isOn: json['light_state'] == "01",
      isConnected: json['connected'] == true,
    );
  }
}

class Mode {
  final String profile;
  final String lightState;
  final int brightness;
  final int color;

  Mode({
    required this.profile,
    required this.lightState,
    required this.brightness,
    required this.color,
  });

  factory Mode.fromJson(Map<String, dynamic> json) {
    return Mode(
      profile: json['profile'],
      lightState: json['light_state'],
      brightness: int.parse(json['brightness'].toString()),
      color: int.parse(json['color'], radix: 16),
    );
  }

  Map<String, dynamic> toJson() => {
    'profile': profile,
    'light_state': lightState,
    'brightness': brightness.toString(),
    'color': color.toRadixString(16).padLeft(8, '0'),
  };
}

class ModeList {
  final Map<String, Mode> modes;

  ModeList({required this.modes});

  factory ModeList.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final modes = data.map((key, value) {
      // Parser la chaîne de couleur au format Python
      String colorStr = value['color'] as String;
      int color;
      if (colorStr.startsWith("{'r':")) {
        // Extraire les valeurs RGB avec RegExp
        final rgbRegex = RegExp(r"'r': (\d+).*'g': (\d+).*'b': (\d+)");
        final match = rgbRegex.firstMatch(colorStr);
        if (match != null) {
          final r = int.parse(match.group(1)!);
          final g = int.parse(match.group(2)!);
          final b = int.parse(match.group(3)!);
          color = (r << 16) + (g << 8) + b;
        } else {
          color = 0xFFFFFF; // Valeur par défaut si le parsing échoue
        }
      } else {
        // Si c'est une valeur hexadécimale
        color = int.parse(value['color'], radix: 16);
      }

      return MapEntry(
        key,
        Mode(
          profile: key,
          lightState: value['light_state'] as String,
          brightness: int.parse(value['brightness']),
          color: color,
        ),
      );
    });
    return ModeList(modes: modes);
  }
}