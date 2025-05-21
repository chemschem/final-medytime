
import 'package:flutter/material.dart';
import 'package:meditime/api/globals.dart' as globals;
import 'package:meditime/core/theme/colors.dart';

class edit_defult_times extends StatefulWidget {
  const edit_defult_times({super.key});

  @override
  State<edit_defult_times> createState() => _edit_defult_timesState();
}

class _edit_defult_timesState extends State<edit_defult_times> {
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTimeController.text = globals.defaultStartTime;
    _endTimeController.text = globals.defaultEndTime;
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
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
         title: const Text("Default times ", 
        style: TextStyle(color: Colors.white,
        fontWeight: FontWeight.bold),      
      ),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInputField(
              controller: _startTimeController,
              label: 'Default Start Time',
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _endTimeController,
              label: 'Default End Time',
            ),
            const SizedBox(height: 20),
SizedBox(
  width: double.infinity,
  child: _buildElevatedButton(
    label: 'Save',
    onPressed: () {
      setState(() {
        globals.defaultStartTime = _startTimeController.text;
        globals.defaultEndTime = _endTimeController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default times updated!')),
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