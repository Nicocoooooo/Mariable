import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AvailabilitySelector extends StatefulWidget {
  final String prestataireName;
  final VoidCallback? onClose;
  final Function(DateTime, String)? onTimeSelected;

  const AvailabilitySelector({
    super.key,
    required this.prestataireName,
    this.onClose,
    this.onTimeSelected,
  });

  @override
  State<AvailabilitySelector> createState() => _AvailabilitySelectorState();
}

class _AvailabilitySelectorState extends State<AvailabilitySelector> {
  // État pour suivre les sélections de l'utilisateur
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 2));
  String? _selectedTimeSlot;
  int _currentMonthPage = 0;
  
  // Contrôleur de page pour le calendrier mensuel
  final PageController _pageController = PageController(initialPage: 0);
  
  // Formatter pour les dates
  final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'fr_FR');
  final DateFormat _dayFormat = DateFormat('EEE d', 'fr_FR');
  final DateFormat _dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
  
  // Créer des créneaux horaires fictifs
  List<String> _getAvailableTimeSlots(DateTime date) {
    // Logique fictive pour simuler des disponibilités
    // En situation réelle, ces données viendraient de l'API
    
    // Weekend (samedi/dimanche) - moins de disponibilités
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return ['10:00', '11:00', '14:00', '15:00'];
    }
    
    // Jour de semaine - plus de disponibilités
    return ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00', '17:00'];
  }
  
  // Générer des jours pour le mois sélectionné
  List<DateTime> _getDaysInMonth(int monthOffset) {
    final DateTime now = DateTime.now();
    final DateTime firstDay = DateTime(now.year, now.month + monthOffset, 1);
    final DateTime lastDay = DateTime(now.year, now.month + monthOffset + 1, 0);
    
    return List.generate(
      lastDay.day,
      (index) => DateTime(firstDay.year, firstDay.month, index + 1),
    ).where((date) => date.isAfter(now) || date.day == now.day).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec titre et bouton fermer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Prendre rendez-vous',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'avec ${widget.prestataireName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
              
              // Corps du sélecteur
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sélecteur de mois
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, size: 16),
                              onPressed: _currentMonthPage > 0
                                  ? () {
                                      setState(() {
                                        _currentMonthPage--;
                                        _pageController.previousPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      });
                                    }
                                  : null,
                            ),
                            Text(
                              _monthYearFormat.format(
                                DateTime.now().add(Duration(days: 30 * _currentMonthPage)),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, size: 16),
                              onPressed: _currentMonthPage < 3
                                  ? () {
                                      setState(() {
                                        _currentMonthPage++;
                                        _pageController.nextPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      
                      // Calendrier mensuel
                      SizedBox(
                        height: 100,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (page) {
                            setState(() {
                              _currentMonthPage = page;
                            });
                          },
                          itemCount: 4, // Limite à 4 mois
                          itemBuilder: (context, monthIndex) {
                            final days = _getDaysInMonth(monthIndex);
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: days.length,
                              itemBuilder: (context, index) {
                                final day = days[index];
                                final isSelected = day.year == _selectedDate.year &&
                                    day.month == _selectedDate.month &&
                                    day.day == _selectedDate.day;
                                
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDate = day;
                                      _selectedTimeSlot = null;
                                    });
                                  },
                                  child: Container(
                                    width: 60,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF524B46)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF524B46)
                                            : Colors.grey.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _dayFormat.format(day).split(' ')[0],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _dayFormat.format(day).split(' ')[1],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      
                      // Date sélectionnée
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        child: Text(
                          'Disponibilités le ${_dateFormat.format(_selectedDate)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      // Créneaux horaires
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          children: _getAvailableTimeSlots(_selectedDate).map((time) {
                            final isSelected = _selectedTimeSlot == time;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTimeSlot = time;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF524B46)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF524B46)
                                        : Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  time,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF2B2B2B),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      
                      // Explication
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info_outline, 
                                    color: Color(0xFF524B46),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'À propos de ce rendez-vous',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ce rendez-vous vous permettra de discuter de votre projet avec le prestataire et de poser toutes vos questions.',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Le rendez-vous peut se faire par visioconférence ou par téléphone selon vos préférences.',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bouton Confirmer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _selectedTimeSlot != null
                      ? () {
                          if (widget.onTimeSelected != null) {
                            widget.onTimeSelected!(_selectedDate, _selectedTimeSlot!);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF524B46),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                    disabledForegroundColor: Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Confirmer le rendez-vous',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}