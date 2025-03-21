import 'package:flutter/material.dart';
import '../Filtre/data/repositories/presta_repository.dart';
import '../Filtre/data/models/presta_type_model.dart';
import '../Filtre/PrestatairesListScreen.dart';

class PrestatairesScreen extends StatefulWidget {
  const PrestatairesScreen({Key? key}) : super(key: key);

  @override
  State<PrestatairesScreen> createState() => _PrestatairesScreenState();
}

class _PrestatairesScreenState extends State<PrestatairesScreen> {
  final PrestaRepository _repository = PrestaRepository();
  bool _isLoading = true;
  List<PrestaTypeModel> _prestaTypes = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPrestaTypes();
  }

  Future<void> _loadPrestaTypes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      final types = await _repository.getPrestaTypes();
      
      setState(() {
        _prestaTypes = types;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible de charger les types de prestataires: $e';
        _isLoading = false;
        
        // Données par défaut en cas d'erreur
        _prestaTypes = [
          PrestaTypeModel(id: 1, name: 'Lieu', description: 'Lieux pour votre mariage'),
          PrestaTypeModel(id: 2, name: 'Traiteur', description: 'Services de restauration'),
          PrestaTypeModel(id: 3, name: 'Photographe', description: 'Capture de vos souvenirs'),
          PrestaTypeModel(id: 4, name: 'Wedding Planner', description: 'Organisation de votre mariage'),
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Types de prestataires'),
        backgroundColor: const Color(0xFF524B46),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _prestaTypes.length,
                  itemBuilder: (context, index) {
                    final type = _prestaTypes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(type.name),
                        subtitle: Text(type.description),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _navigateToPrestaList(type),
                      ),
                    );
                  },
                ),
    );
  }

  void _navigateToPrestaList(PrestaTypeModel type) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => PrestatairesListScreen(
          prestaType: type,
        ),
      ),
    );
  }
}