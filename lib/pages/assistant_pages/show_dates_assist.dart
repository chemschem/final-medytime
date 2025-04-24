import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meditime/api/function_appoint.dart';
import 'package:meditime/api/function_date.dart';
import 'package:meditime/api/function_session.dart';
import 'package:meditime/api/globals.dart' as globals;
import 'package:meditime/core/theme/colors.dart';

class show_dates_assist extends StatefulWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
   show_dates_assist({super.key});

  @override
  State<show_dates_assist> createState() => _show_dates_assistState();
}

class _show_dates_assistState extends State<show_dates_assist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Manage Appointments',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              function_session().logout(context);
            },
            icon: const Icon(Icons.logout, color: AppColors.whiteColor),
            tooltip: 'Logout',
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'User ID: ${globals.currentUserId}',
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: function_date().getdate(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No Appointments Found'));
                }

                var dates = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    var data = dates[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                        title: Text(
                          "Day: ${data['day']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textColor,
                          ),
                        ),
                        subtitle: Text(
                          "Start: ${data['start']} - End: ${data['end']}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: Wrap(
                         spacing: 8,
                         runSpacing: 8,
                         children: [
                           ElevatedButton(
                             onPressed: () {
                               function_date().showModifyDialog(
                                 context,
                                 data['id_date'],
                                 data['day'],
                                 data['start'],
                                 data['end'],
                                 data['limit'],
                               );
                             },
                             style: ElevatedButton.styleFrom(
                               backgroundColor: AppColors.primary,
                               padding: const EdgeInsets.symmetric(horizontal: 12),
                               minimumSize: const Size(70, 36),
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(8),
                               ),
                             ),
                             child: const Text('Modify', style: TextStyle(fontSize: 12)),
                           ),
                           ElevatedButton(
                             onPressed: () {
                               function_date().deleteDate(data['id_date']);
                               function_appoint().deleteAppoointAssaigndwithDay(data['id_date']);
                             },
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.red.shade400,
                               padding: const EdgeInsets.symmetric(horizontal: 12),
                               minimumSize: const Size(70, 36),
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(8),
                               ),
                             ),
                             child: const Text('Delete', style: TextStyle(fontSize: 12)),
                           ),
                         ],
                       ),

                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    function_date().deleteAllDates();
                    function_appoint().deleteAllAppointments();
                  },
                  icon: const Icon(Icons.delete_forever),
                  label: const Text("Delete All Days"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
