import 'package:flutter/material.dart';
import 'package:meditime/api/api_functions.dart';
import 'package:meditime/core/theme/colors.dart';

class show_appoint extends StatefulWidget {
  const show_appoint({Key? key}) : super(key: key);

  @override
  _show_appointState createState() => _show_appointState();
}

class _show_appointState extends State<show_appoint> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Booked Appointments',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: api_functions().getAppointByDateOrder(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final groupedData = snapshot.data!;
            if (groupedData.isEmpty) {
              return const Center(child: Text('No Appointments Found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedData.length,
              itemBuilder: (context, index) {
                String date = groupedData.keys.elementAt(index);
                List<Map<String, dynamic>> appointments = groupedData[date]!;

                return Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    title: Text(
                      'Date: $date',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    children: appointments.map((item) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            '${item['order']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          '${item['id_user']}',
                          style: const TextStyle(color: AppColors.textColor),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No Appointments Found'));
          }
        },
      ),
    );
  }
}
