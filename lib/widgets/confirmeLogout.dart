import 'package:flutter/material.dart';
import 'package:meditime/core/theme/colors.dart';


class ConfirmLogout extends StatelessWidget {
  final String date;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmLogout({
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
                "Are you sure you want to logout?",
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
                    ),
                    child: Text("Logout",
                      // ignore: deprecated_member_use
                      style: TextStyle(color: Colors.red ,fontSize: 18, fontWeight: FontWeight.bold),
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
