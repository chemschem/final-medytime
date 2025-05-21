import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meditime/api/function_appoint.dart';
import 'package:meditime/core/theme/colors.dart';
import 'package:intl/intl.dart'; // للاستفادة من DateFormat

class consulting extends StatefulWidget {
  const consulting({super.key});

  @override
  State<consulting> createState() => _consultingState();
}

class _consultingState extends State<consulting> {
  List<Map<String, dynamic>> todayUsersAppoint = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;
  int usersHaveBooked = 0;
  int usersWaiting = 0;
  Set<String> markedUsers = {};
  String dateInfo = ''; // لتخزين تاريخ اليوم
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setTodayDate(); // تعيين تاريخ اليوم
    fetchTodayUsers();
    _searchController.addListener(_filterUsers);
  }

  // دالة لتعيين تاريخ اليوم
  void _setTodayDate() {
    final DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMMM d, y').format(now);  // تنسيق التاريخ
    setState(() {
      dateInfo = 'Today: $formattedDate';  // تعيين تاريخ اليوم
    });
  }

  Future<void> fetchTodayUsers() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final dateSnapshot = await FirebaseFirestore.instance
          .collection('dates')
          .where('fullDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('fullDate', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      if (dateSnapshot.docs.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      final todayDoc = dateSnapshot.docs.first;
      final todayId = todayDoc.id;
      final fullDate = todayDoc['fullDate'].toDate();
      // ignore: non_constant_identifier_names
      final TodayAppointSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('id_date', isEqualTo: todayId)
          .get();

      if (TodayAppointSnapshot.docs.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      final appointFunction =function_appoint();
      int bookedUsers = await appointFunction.fetchUsersHaveBooked(todayId);
      int waitingUsers = await appointFunction.fetchUsersWaiting(todayId);

      int waiting = waitingUsers;
      List<Map<String, dynamic>> todayUsersList = [];

      for (final doc in TodayAppointSnapshot.docs) {
        final userId = doc['id_user'];
        final order = doc['order'];
        final userDoc = await FirebaseFirestore.instance.collection('user').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          todayUsersList.add({
            'name': '${userData?['name']}',
            'email': '${userData?['email']}',
            'phone': '${userData?['phone']}',
            'age': '${userData?['age']}',
            'time': fullDate,
            'order': order,
            'id_date': todayId,
            'appoint_id': doc.id,
            'consultinDone': doc['consultinDone'] ?? false,
          });
        }
      }

      todayUsersList.sort((a, b) => a['order'].compareTo(b['order']));

      await FirebaseFirestore.instance.collection('dates').doc(todayId).update({
        'usersWaiting': waiting,
        'usersHaveBooked': bookedUsers,
      });

      setState(() {
        usersHaveBooked = bookedUsers;
        usersWaiting = waiting;
        todayUsersAppoint = todayUsersList;
        filteredUsers = todayUsersList;
        isLoading = false;
      });
    } catch (e) {
      print('🔥 Error in fetchTodayUsers: $e');
      setState(() => isLoading = false);
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers = todayUsersAppoint.where((user) {
        return user['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  InputDecoration _searchDecoration() {
    return InputDecoration(
      hintText: 'search patient..',
      hintStyle: const TextStyle(color: AppColors.textColor),
      prefixIcon: const Icon(Icons.search, color: AppColors.secondaryColor),
      filled: true,
      fillColor: AppColors.backgroundColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text("Consulting", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false, // This removes the back arrow
        centerTitle: true,

      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateInfo, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Users Who Have Booked: $usersHaveBooked\nUsers Waiting: $usersWaiting',
                      style: const TextStyle(color: AppColors.textColor)),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: _searchDecoration(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: filteredUsers.isEmpty
                        ? const Center(child: Text('no appointments', style: TextStyle(color: AppColors.textColor)))
                        : ListView.builder(
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: CircleAvatar(
                                    backgroundImage: const AssetImage('assets/images/doctor.png'),
                                    radius: 25,
                                    backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                                  ),
                                  title: Text(
                                    user['name'],
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textColor),
                                  ),
                              subtitle: Text(
                                'order: ${user['order']}\n'
                                'status: ${user['consultinDone'] == true ? 'done' : 'waiting'}\n'
                                'email: ${user['email']}\n'
                                'age: ${user['age']}\n'
                                'phone: ${user['phone']}',
                                style: const TextStyle(fontSize: 13, color: AppColors.textColor),
                              ),
                                  trailing: user['consultinDone']
    ? const Icon(Icons.check_circle, color: Colors.green)
    : ElevatedButton(
       onPressed: () async {
  if (user['consultinDone'] == true) return;

  final newUsersWaiting = (usersWaiting - 1).clamp(0, usersWaiting);

  try {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(user['appoint_id'])
        .update({'consultinDone': true});

    await FirebaseFirestore.instance
        .collection('dates')
        .doc(user['id_date'])
        .update({'usersWaiting': newUsersWaiting});

    if (!mounted) return;

    setState(() {
      user['consultinDone'] = true;
      usersWaiting = newUsersWaiting;
    });
  } catch (e) {
    print('🔥 Error updating appointment: $e');
  }
},


        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Mark Done',
          style: TextStyle(color: Colors.white),
        ),
      ),

                                  ), 
                                );
                            },
                          ),
                  ),
                ],
              ),
            ),   



            // Bottom Navigation Bar

   bottomNavigationBar: BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check),
          label: 'Consulting',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
currentIndex: 1, // Set the current index to highlight the active tab
  selectedItemColor: Colors.blue, // Color for the selected item
  unselectedItemColor: Colors.grey, // Color for unselected items
       onTap: (index) {
        // Handle navigation based on the selected index
        if (index == 0) {
          Navigator.pushNamed(context, '/home_assistant');
        } else if (index == 1) {
          // Stay on the current page 
        } else if (index == 2) {
          Navigator.pushNamed(context, '/setting_assistant');
        }
      },
    ),

    );
  }
}


                                    
                                 