import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meditime/core/theme/colors.dart';
import 'package:meditime/models/clinic_model.dart';

class clinicInfo extends StatefulWidget {
  const clinicInfo({super.key});

  @override
  clinicInfoState createState() => clinicInfoState();
}

class clinicInfoState extends State<clinicInfo> {
  late Future<clinic_model> _clinicFuture;

  @override
  void initState() {
    super.initState();
    _clinicFuture = fetchClinicData();
  }

  Future<clinic_model> fetchClinicData() async {
    final snapshot = await FirebaseFirestore.instance.collection("clinic").limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return clinic_model.fromJson(doc.data());
    } else {
      throw Exception("No clinic data found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        elevation: 0,
        title: const Text(
          "About clinic",
          style: TextStyle(fontWeight: FontWeight.bold, 
          color: Colors.white),

        ),
      ),
      //bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: FutureBuilder<clinic_model>(
        future: _clinicFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No clinic info available."));
          }

          final clinic = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage("assets/images/doctor.png"),
                ),
                const SizedBox(height: 20),

                Text(
                  clinic.doctor_name ?? "Unknown Doctor",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 5),

                const Text(
                  "General Practitioner", // يمكنك جلبها من Firestore لاحقًا
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),

                _buildInfoTile("Clinic", clinic.name_clinic ?? "N/A"),
                _buildInfoTile("Clinic Address", clinic.addresse_clinic ?? "N/A"),                
                _buildInfoTile("Phone", clinic.clinic_phone != null ? "+213 ${clinic.clinic_phone}" : "N/A"),
                _buildInfoTile("Doctor", clinic.doctor_name ?? "N/A"),
                _buildInfoTile("About Doctor", clinic.doctor_des ?? "N/A"),


                const SizedBox(height: 30),

              ],
            ),
          );
        },
      ),

//               // Bottom Navigation Bar

//    bottomNavigationBar: BottomNavigationBar(
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.calendar_today),
//           label: 'Book',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.info),
//           label: 'About',
//         ),
//       ],
// currentIndex: 2, // Set the current index to highlight the active tab
//   selectedItemColor: Colors.blue, // Color for the selected item
//   unselectedItemColor: Colors.grey, // Color for unselected items
//        onTap: (index) {
//         // Handle navigation based on the selected index
//         if (index == 0) {
//           Navigator.pushNamed(context, '/home_patient');
//         } else if (index == 1) {
//           Navigator.pushNamed(context, '/book_appoint');
//         } else if (index == 2) {
//           Navigator.pushNamed(context, '/clinicInfo');
//         }
        

//       },
//     ),
    

    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
