
import 'package:flutter/material.dart';
import 'package:meditime/api/function_appoint.dart';
import 'package:meditime/api/function_date.dart';
import 'package:meditime/core/theme/colors.dart';
import 'package:meditime/core/theme/styles.dart';

class appointment_state_patient extends StatefulWidget {
  const appointment_state_patient({super.key});

  @override
  State<appointment_state_patient> createState() => _appointment_state_patientState();
}

class _appointment_state_patientState extends State<appointment_state_patient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Text(
              'My Appointments',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            
                  IconButton(
                    icon: const Icon(Icons.notifications, color: AppColors.primaryColor, size: 40),
                    onPressed: () {
                      Navigator.pushNamed(context, "/notifications_patient");
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

           

            //  محتوى المواعيد
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: function_appoint().fetchMyAppointments(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No appointments found'));
                    } else {
                      final appointments = snapshot.data!;
                      return ListView.builder(
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(


                              color: appointment['consultinDone'] 
                                 ? AppColors.donestate
                                 : AppColors.backgroundSecondary,
  
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<String>(
                                  future: function_date().fetchDate(appointment['id_date']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Text('Loading Date...');
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      return Text(
                                        'Date: ${snapshot.data}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textColor,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                               Row(
                               children: [
                                 const SizedBox(width: 8),
                                 Text(
                                  'order: ${appointment['order'].toString()}',
                                   style: const TextStyle(
                                     fontSize: 24,
                                     fontWeight: FontWeight.bold,
                                     color: AppColors.secondColor,
                                   ),
                                 ),
                               ],
                             ),

                                const SizedBox(height: 10),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder<String>(
                                      future: function_appoint().fetchUsersWaiting(appointment['id_date']).then((value) => value.toString()),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Loading waiting users...');
                                        } else if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        } else {
                                          return Row(
                                            children: [
                                              const Icon(Icons.people, color: AppColors.textColor),
                                              const SizedBox(width: 5),
                                              Text(
                                                "${snapshot.data} waiting",
                                                style: const TextStyle(fontSize: 14, color: AppColors.textColor),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 10),

                                    FutureBuilder<bool>(
                                      future: function_appoint().fetchConsultinDone(appointment['id_date']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Loading registered users...');
                                        } else if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        } else {
                                          return Row(
                                            children: [
  (snapshot.data ?? false) // Provide a default value if snapshot.data is null
      ? const Icon(Icons.check_circle, color: AppColors.textColor)
      : const Icon(Icons.airline_seat_recline_normal, color: AppColors.textColor),
  const SizedBox(width: 5),
  Text(
    (snapshot.data ?? false) ? "State: Done" : "State: Outstanding", // Use the same null-aware operator here
    style: const TextStyle(fontSize: 14, color: AppColors.textColor),
  ),
],
                                          );
                                        }
                                      },
                                    ),

                                  ],
                                ),
                                const SizedBox(height: 10),

                                TextButton(
                                 onPressed: () {
                                   Navigator.pushNamed(context, '/clinicInfo');
                                 },
                                 child: const Text(
                                   "About clinic",
                                   style: TextStyle(
                                     color: AppColors.primaryColor,
                                     fontSize: 16,
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                               ),

                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/book_appoint");
                  },
                  style: AppStyles.OtherbuttonStyle(AppColors.primaryColor),
                  child: const Text(
                    "NEW APPOINTMENT",
                    style: TextStyle(
                      color: AppColors.backgroundPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'My appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings',
          ),
        ],
        currentIndex: 1, // Set the current index to highlight the active tab
        selectedItemColor: Colors.blue, // Color for the selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        onTap: (index) {
          // Handle navigation based on the selected index
          if (index == 0) {
            Navigator.pushNamed(context, '/home_patient');
          } else if (index == 1) {
            //
          } else if (index == 2) {
            Navigator.pushNamed(context, '/patient_settings');
          }
        },
      ),

    );
  }
}
