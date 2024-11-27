import 'package:flutter/material.dart';
import 'LightApiService.dart';

class ModesScreen extends StatefulWidget {
  const ModesScreen({Key? key}) : super(key: key);

  @override
  _ModesScreenState createState() => _ModesScreenState();
}

class _ModesScreenState extends State<ModesScreen> {
  final LightApiService _lightService = LightApiService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<String> _modes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModes();
  }

  Future<void> _loadModes() async {
    setState(() => _isLoading = true);
    final modes = await _lightService.getModes();
    setState(() {
      _modes = modes;
      _isLoading = false;
    });
  }

  Future<void> _createMode() async {
    if (_formKey.currentState?.validate() ?? false) {
      final state = await _lightService.getLightState();
      final newMode = Mode(
        profile: _nameController.text,
        lightState: state.isOn ? "01" : "00",
        brightness: state.brightness ?? 100,
        color: state.color ?? 0xFFFFFF,
      );

      try {
        final success = await _lightService.createMode(newMode);
        if (success) {
          _nameController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mode créé avec succès')),
          );
          _loadModes();  // Recharger la liste des modes
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du mode',
                      hintText: 'Ex: MODE1',
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _createMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _modes.isEmpty
                    ? const Center(child: Text('Aucun mode enregistré'))
                    : ListView.builder(
                        itemCount: _modes.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.light_mode),
                            title: Text(_modes[index]),
                            onTap: () async {
                              final success = await _lightService.loadMode(_modes[index]);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success 
                                        ? 'Mode ${_modes[index]} chargé' 
                                        : 'Erreur lors du chargement du mode'
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}