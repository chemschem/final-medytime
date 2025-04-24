import 'package:flutter/material.dart';
import 'package:meditime/core/theme/colors.dart';

class ConfirmedDialog extends StatelessWidget {
  final int turnNumber; // المتغير الخاص برقم الدور

   ConfirmedDialog({super.key, required this.turnNumber});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                "Your appointment is confirmed",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Your turn number is: $turnNumber",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
