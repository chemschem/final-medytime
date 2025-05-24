import 'package:flutter/material.dart';
import 'package:meditime/api/function_date.dart';
import 'package:meditime/core/theme/colors.dart';


class ModifyDeleteDialogs {
 Future<bool?> showModifyDialog(
  BuildContext context,
  String docId,
  String currentDay,
  int currentStart,
  int currentEnd,
  int currentLimit,
) async {
  TextEditingController controllerStart = TextEditingController(text: currentStart.toString());
  TextEditingController controllerEnd = TextEditingController(text: currentEnd.toString());
  TextEditingController controllerLimit = TextEditingController(text: currentLimit.toString());

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      title: const Text(
        'Modify Day',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(controllerStart, 'New Start'),
            const SizedBox(height: 12),
            _buildTextField(controllerEnd, 'New End'),
            const SizedBox(height: 12),
            _buildTextField(controllerLimit, 'New Limit'),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[700],
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            int newStart = int.tryParse(controllerStart.text.trim()) ?? 0;
            int newEnd = int.tryParse(controllerEnd.text.trim()) ?? 0;
            int newLimit = int.tryParse(controllerLimit.text.trim()) ?? 0;

            if (newStart > 0 && newEnd > 0 && newLimit > 0) {
              bool islimitchanged = newLimit > currentLimit;

              await function_date().modifyDate(docId, {
                'day': currentDay,
                'start': newStart,
                'end': newEnd,
                'limit': newLimit,
              }, islimitchanged);

              Navigator.pop(context, true);
            } else {
              Navigator.pop(context, false);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Widget _buildTextField(TextEditingController controller, String label) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    keyboardType: TextInputType.number,
  );
}


  static Widget _buildNumberField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Future<bool?> showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Delete Appointment"),
              const SizedBox(height: 15),
              const Text("Are you sure you want to delete this appointment?"),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel", style: TextStyle(color: Colors.black),),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text("Delete", style: TextStyle(color: Colors.white),),
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
