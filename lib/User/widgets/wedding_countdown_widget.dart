import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

/// Widget pour afficher un compte à rebours jusqu'à la date du mariage
class WeddingCountdownWidget extends StatefulWidget {
  final DateTime weddingDate;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? accentColor;
  final TextStyle? titleStyle;
  final TextStyle? timeStyle;
  final TextStyle? labelStyle;
  final bool showDaysOnly;

  const WeddingCountdownWidget({
    super.key,
    required this.weddingDate,
    this.backgroundColor,
    this.textColor,
    this.accentColor,
    this.titleStyle,
    this.timeStyle,
    this.labelStyle,
    this.showDaysOnly = false,
  });

  @override
  State<WeddingCountdownWidget> createState() => _WeddingCountdownWidgetState();
}

class _WeddingCountdownWidgetState extends State<WeddingCountdownWidget> {
  late Timer _timer;
  late Duration _timeLeft;
  late bool _isToday;
  late bool _isPast;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    final difference = widget.weddingDate.difference(now);
    
    setState(() {
      _timeLeft = difference;
      _isToday = difference.inDays == 0 && difference.inHours >= 0;
      _isPast = difference.isNegative;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Couleurs par défaut
    final Color backgroundColor = widget.backgroundColor ?? Colors.white;
    final Color textColor = widget.textColor ?? const Color(0xFF2B2B2B);
    final Color accentColor = widget.accentColor ?? const Color(0xFF524B46);
    
    // Déterminer la couleur du compteur
    Color countdownColor = accentColor;
    if (_isPast) {
      countdownColor = Colors.grey;
    } else if (_isToday) {
      countdownColor = Colors.red;
    } else if (_timeLeft.inDays < 30) {
      countdownColor = Colors.red;
    } else if (_timeLeft.inDays < 90) {
      countdownColor = Colors.orange;
    }
    
    // Formater la date de mariage pour l'affichage
    final dateFormatter = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final formattedDate = dateFormatter.format(widget.weddingDate);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Titre avec la date de mariage
          Text(
            'Votre mariage',
            style: widget.titleStyle ?? TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Date du mariage
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Compte à rebours
          _isPast
              ? _buildPastWedding()
              : widget.showDaysOnly
                  ? _buildDaysCounter(countdownColor)
                  : _buildFullCounter(countdownColor),
        ],
      ),
    );
  }

  // Widget pour le compteur en jours seulement
  Widget _buildDaysCounter(Color countdownColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: countdownColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isToday ? Icons.celebration : Icons.hourglass_top,
            color: countdownColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            _isToday
                ? 'C\'est aujourd\'hui !'
                : 'J-${_timeLeft.inDays}',
            style: widget.timeStyle ?? TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: countdownColor,
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour le compteur complet (jours, heures, minutes, secondes)
  Widget _buildFullCounter(Color countdownColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: countdownColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _isToday
          ? Column(
              children: [
                Icon(
                  Icons.celebration,
                  color: countdownColor,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'C\'est aujourd\'hui !',
                  style: widget.timeStyle ?? TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: countdownColor,
                  ),
                ),
                Text(
                  'Plus que ${_timeLeft.inHours} heures et ${_timeLeft.inMinutes.remainder(60)} minutes',
                  style: widget.labelStyle ?? TextStyle(
                    fontSize: 14,
                    color: countdownColor,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeUnit(_timeLeft.inDays, 'JOURS'),
                _buildDivider(),
                _buildTimeUnit(_timeLeft.inHours.remainder(24), 'HEURES'),
                _buildDivider(),
                _buildTimeUnit(_timeLeft.inMinutes.remainder(60), 'MIN'),
                _buildDivider(),
                _buildTimeUnit(_timeLeft.inSeconds.remainder(60), 'SEC'),
              ],
            ),
    );
  }

  // Widget pour les mariages passés
  Widget _buildPastWedding() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite,
            color: Colors.pink,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Mariage passé',
            style: widget.timeStyle ?? const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour une unité de temps (jours, heures, etc.)
  Widget _buildTimeUnit(int value, String label) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: widget.timeStyle ?? TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: widget.accentColor ?? const Color(0xFF524B46),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: widget.labelStyle ?? TextStyle(
            fontSize: 12,
            color: widget.textColor ?? const Color(0xFF2B2B2B),
          ),
        ),
      ],
    );
  }

  // Séparateur entre les unités de temps
  Widget _buildDivider() {
    return Text(
      ':',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: widget.accentColor ?? const Color(0xFF524B46),
      ),
    );
  }
}