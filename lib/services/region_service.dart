import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class RegionService {
  static final RegionService _instance = RegionService._internal();
  
  factory RegionService() {
    return _instance;
  }
  
  RegionService._internal();
  
  List<String>? _cachedRegions;
  
  Future<List<String>> getAllRegions() async {
    if (_cachedRegions != null) {
      return _cachedRegions!;
    }
    
    try {
      AppLogger.info('Chargement des régions depuis Supabase');
      
      final response = await Supabase.instance.client
          .from('presta')
          .select('region')
          .eq('actif', true)
          .order('region');
      
      final regions = <String>{};
      for (var item in response) {
        if (item['region'] != null && item['region'].toString().isNotEmpty) {
          regions.add(item['region']);
        }
      }
      
      final sortedRegions = regions.toList()..sort();
      _cachedRegions = sortedRegions;
      
      return sortedRegions;
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération des régions', e);
      return [
        'Paris', 'Lyon', 'Marseille', 'Bordeaux', 'Strasbourg', 
        'Lille', 'Nice', 'Toulouse', 'Nantes', 'Montpellier'
      ];
    }
  }
  
  void clearCache() {
    _cachedRegions = null;
  }
}