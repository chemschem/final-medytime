import 'package:flutter/material.dart';
import 'package:meditime/core/theme/colors.dart';


class ConfirmDialog extends StatelessWidget {
  final String date;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmDialog({
    super.key,
    required this.date,
    required this.onConfirm,
    required this.onCancel,
  });

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
              const SizedBox(height: 50),
              const Text(
                "Are you sure you want to book in this date?",
                textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textColor,fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onCancel,
                    child: const Text("CANCEL",
                    style: TextStyle(color: AppColors.textColor,fontSize: 18, fontWeight: FontWeight.bold),),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: const Text("confirm",
                      style: TextStyle(color: AppColors.backgroundPrimary,fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
