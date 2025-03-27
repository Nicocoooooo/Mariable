import 'package:flutter/material.dart';
import '../services/region_service.dart';

class LieuSelectorDialog extends StatefulWidget {
  final String? initialLieu;

  const LieuSelectorDialog({
    super.key,
    this.initialLieu,
  });

  @override
  State<LieuSelectorDialog> createState() => _LieuSelectorDialogState();
}

class _LieuSelectorDialogState extends State<LieuSelectorDialog> {
  final RegionService _regionService = RegionService();
  List<String> _regions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }
  
  Future<void> _loadRegions() async {
    try {
      final regions = await _regionService.getAllRegions();
      
      setState(() {
        _regions = regions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _regions = ['Paris', 'Lyon', 'Marseille', 'Bordeaux', 'Strasbourg'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: const Color(0xFFFFF3E4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sélectionnez un lieu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
              ? CircularProgressIndicator()
              : Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _regions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          _regions[index],
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        onTap: () => Navigator.pop(context, _regions[index]),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}