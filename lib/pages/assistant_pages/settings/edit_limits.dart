import 'package:flutter/material.dart';
import 'package:meditime/api/globals.dart' as globals;
import 'package:meditime/api/globals.dart' as global;
import 'package:meditime/core/theme/colors.dart';

class edit_limits extends StatefulWidget {
  const edit_limits({super.key});

  @override
  State<edit_limits> createState() => _edit_limitsState();
}

class _edit_limitsState extends State<edit_limits> {
  final TextEditingController _limitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _limitController.text = globals.defaultLimit;
  }
Widget _buildElevatedButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        
        backgroundColor: AppColors.primaryColor, // Replace with AppColors.primaryColor if you have it
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor: AppColors.primaryColor,
       centerTitle: true,
       iconTheme: const IconThemeData(
          color: Colors.white,
        ),
         title: const Text("Default limit ", 
        style: TextStyle(color: Colors.white,
        fontWeight: FontWeight.bold),      
      ),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _limitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Default Limit',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
  width: double.infinity,
  child: _buildElevatedButton(
    label: 'Save',
    onPressed: () {
      setState(() {
       global.defaultLimit = _limitController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default limit updated!')),
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