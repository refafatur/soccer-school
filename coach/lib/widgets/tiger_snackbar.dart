import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

void showTigerSnackbar(
  BuildContext context, {
  required String message,
  bool isError = false,
}) {
  final snackBar = SnackBar(
    content: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red : AppTheme.goldAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
    backgroundColor: isError 
        ? Colors.red.withOpacity(0.9)
        : AppTheme.tigerOrange.withOpacity(0.9),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.all(16),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
} 