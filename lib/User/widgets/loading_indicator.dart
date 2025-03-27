import 'package:flutter/material.dart';

/// Widget pour afficher un indicateur de chargement
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color color;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 40.0,
    this.color = const Color(0xFF524B46),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: color,
            ),
          ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                message!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2B2B2B),
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}