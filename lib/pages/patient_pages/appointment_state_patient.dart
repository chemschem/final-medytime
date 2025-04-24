import 'package:flutter/material.dart';
import 'package:meditime/api/function_appoint.dart';
import 'package:meditime/api/function_date.dart';
import 'package:meditime/core/theme/colors.dart';

class appointment_state_patient extends StatefulWidget {
  const appointment_state_patient({Key? key});
  @override
  _appointment_state_patientState createState() => _appointment_state_patientState();
}

class _appointment_state_patientState extends State<appointment_state_patient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Appointments',
          style: TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: function_appoint().fetchMyAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading state
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Error state
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No appointments found')); // No data state
          } else {
            final appointments = snapshot.data!; // Data loaded successfully
            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index]; // Display each appointment
                return Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    splashColor: AppColors.primary.withOpacity(0.2),
                    highlightColor: AppColors.primary.withOpacity(0.1),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order with a CircleAvatar
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  appointment['order'].toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Appointment Order: ${appointment['order']}',
                                style: TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Fetch and display date of appointment
                          FutureBuilder<String>(
                            future: function_date().fetchDate(appointment['id_date']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text('Loading Date...');
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Text('Date: ${snapshot.data}',
                                    style: TextStyle(
                                        color: AppColors.textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500));
                              }
                            },
                          ),
                          const SizedBox(height: 8),

                          // Displaying usersHaveBooked
                          FutureBuilder<String>(
                            future: function_appoint().fetchUsersHaveBooked(appointment['id_date']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text('Loading users...');
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Text('No users have booked');
                              } else {
                                return Text('Users Have Booked: ${snapshot.data}');
                              }
                            },
                          ),
                          const SizedBox(height: 8),

                          // Displaying usersWaiting
                          FutureBuilder<String>(
                            future: function_appoint().fetchUsersWaiting(appointment['id_date']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text('Loading users...');
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Text('No users are waiting');
                              } else {
                                return Text('Users Waiting: ${snapshot.data}');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
