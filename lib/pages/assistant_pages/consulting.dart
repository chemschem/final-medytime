import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meditime/api/function_appoint.dart';

class consulting extends StatefulWidget {
  const consulting({Key? key}) : super(key: key);

  @override
  consultingState createState() => consultingState();
}

class consultingState extends State<consulting> {
  List<Map<String, dynamic>> todayUsersAppoint = [];
  bool isLoading = true;
  String usersHaveBooked = ''; // Variable to hold usersHaveBooked data
  int usersWaiting = 0;
  Set<String> markedUsers = {}; // to track which users were clicked


  @override
  void initState() {
    super.initState();
    fetchTodayUsers();
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

    final TodayAppointSnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('id_date', isEqualTo: todayId)
        .get();

    if (TodayAppointSnapshot.docs.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    final appointFunction = function_appoint();
    String bookedUsers = await appointFunction.fetchUsersHaveBooked(todayId);
    String waitingUsers = await appointFunction.fetchUsersWaiting(todayId);
    int waiting = int.tryParse(waitingUsers) ?? 0;

    List<Map<String, dynamic>> todayUsersList = [];

    for (final doc in TodayAppointSnapshot.docs) {
      final userId = doc['id_user'];
      final order = doc['order'];
      final userDoc = await FirebaseFirestore.instance.collection('user').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        todayUsersList.add({
          'name': '${userData?['name']}',
          'time': todayDoc['fullDate'].toDate(),
          'order': order,
          'id_date': todayId,
          'appoint_id': doc.id,
          'consultinDdone': doc['consultinDdone'] ?? false,
        });
      }
    }
         todayUsersList.sort((a, b) => a['order'].compareTo(b['order']));
     
         await FirebaseFirestore.instance.collection('dates').doc(todayId).update({
           'usersWaiting': waiting,
         });
     
         setState(() {
           usersHaveBooked = bookedUsers;
           usersWaiting = waiting;
           todayUsersAppoint = todayUsersList;
           isLoading = false;
         });
       } catch (e) {
         print('🔥 Error in fetchTodayUsers: $e');
         setState(() => isLoading = false);
       }
     }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Appointments")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display today's date and current time
                      Text(
                        '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}',
                      ),
                      // Display number of users who have booked
                      Text(
                        'Users Who Have Booked: $usersHaveBooked\nUsers Waiting: $usersWaiting',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                todayUsersAppoint.isEmpty
                    ? const Center(child: Text('No appointments today'))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: todayUsersAppoint.length,
                          itemBuilder: (context, index) {
                            final user = todayUsersAppoint[index];
                            // Format time
                            TimeOfDay.fromDateTime(user['time']).format(context);
                            return ListTile(
                            tileColor: markedUsers.contains(user['name']) ? Colors.grey[300] : null,
                            leading: const Icon(Icons.people, color: Colors.blue),
                            title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Order: ${user['order']}'),
                            trailing: ElevatedButton(
                            onPressed: user['consultinDdone'] ? null : () async {
                              setState(() {
                                user['consultinDdone'] = true;
                                usersWaiting = (usersWaiting - 1).clamp(0, usersWaiting);
                              });                          
                              await FirebaseFirestore.instance
                                  .collection('appointments')
                                  .doc(user['appoint_id'])
                                  .update({'consultinDdone': true});                          
                              await FirebaseFirestore.instance
                                  .collection('dates')
                                  .doc(user['id_date'])
                                  .update({'usersWaiting': usersWaiting});
                            },
                            child: const Text(
                              'Mark Done',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          );
                          },
                        ),
                      ),
              ],
            ),
    );
  }
}
