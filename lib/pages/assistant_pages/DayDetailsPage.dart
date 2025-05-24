import 'package:flutter/material.dart';
import 'package:meditime/api/function_appoint.dart';
import 'package:meditime/api/function_date.dart';
import 'package:meditime/core/theme/colors.dart';
import 'package:meditime/widgets/ModifyDeleteDialogs.dart';
import 'package:meditime/widgets/showMessage.dart';

class DayDetailsPage extends StatefulWidget {
  final String dateInfo;
  final Map<String, dynamic> dateData;
  final List appointments;
  final List appointmentsAndUsers;

  const DayDetailsPage({
    super.key,
    required this.dateInfo,
    required this.dateData,
    required this.appointments,
    this.appointmentsAndUsers = const [],
  });

  @override
  State<DayDetailsPage> createState() => _DayDetailsPageState();
}

class _DayDetailsPageState extends State<DayDetailsPage> {
  final TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> _filteredAppointments;
  late Stream<List<Map<String, dynamic>>> _appointmentsStream;
  String _dateInfo = ''; // هنا سيتم عرض التاريخ المحدث

  @override
  void initState() {
    super.initState();
    _fetchAndSetDateInfo();

    _filteredAppointments = List.generate(widget.appointments.length, (index) {
      return {
        'appointments': widget.appointments[index],
        'user': widget.appointmentsAndUsers[index],
      };
    });
    _searchController.addListener(_filterAppointments);
    _filterAppointments();
  }

  Future<void> _fetchAndSetDateInfo() async {
    String result = await function_date().fetchDate(widget.dateData['id_date']);
    setState(() {
      _dateInfo = result;
    });
  }

  void _filterAppointments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAppointments = List.generate(widget.appointments.length, (index) {
        final user = widget.appointmentsAndUsers[index];
        return {
          'appointment': widget.appointments[index],
          'user': user,
        };
      }).where((item) {
        return item['user']['name']?.toLowerCase().contains(query) ?? false;
      }).toList();
    });
  }

  InputDecoration _searchDecoration() {
    return InputDecoration(
      hintText: 'search patient..',
      hintStyle: const TextStyle(color: AppColors.textColor),
      prefixIcon: const Icon(Icons.search, color: AppColors.backgroundColor),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,      
      appBar: AppBar(
       backgroundColor: AppColors.primaryColor,
       centerTitle: true,
       iconTheme: const IconThemeData(
          color: Colors.white,
        ),
         title: const Text("Appointments details ", 
        style: TextStyle(color: Colors.white,
        fontWeight: FontWeight.bold),      
      ),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _dateInfo.isNotEmpty ? _dateInfo : '... loading',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize:12),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'update appointment',
                      onPressed: () async {
                       final id = widget.dateData['id_date'];
final day = widget.dateData['day'];
final start = int.tryParse(widget.dateData['start'].toString()) ?? 9;
final end = int.tryParse(widget.dateData['end'].toString()) ?? 17;
final limit = int.tryParse(widget.dateData['limit'].toString()) ?? 10;


                        if (id == null || day == null || start == null || end == null || limit == null) {
  print("id: $id, day: $day, start: $start, end: $end, limit: $limit");
  ShowMessage.showError(context, "error: missing date data.");
  return;
}

                       bool? updated = await function_date().showModifyDialog(
                        context,
                        id,
                        day,
                        start,
                        end,
                        limit,
                      );
                      

                        if (updated == true) {
                          await _fetchAndSetDateInfo(); 
                          ShowMessage.showValid(context, "appointment updated successfully.");                         
                        }
                      },
                    ),
                    IconButton(
  icon: const Icon(Icons.delete, color: Colors.red),
  tooltip: 'delete appointment',
 onPressed: () async {
  final confirmed = await ModifyDeleteDialogs.showDeleteConfirmationDialog(context);

  if (confirmed == true) {
    await function_date().deleteDate(widget.dateData['id_date']);
    await function_appoint().deleteAppoointAssaigndwithDay(widget.dateData['id_date']);
    
    if (context.mounted) {
      ShowMessage.showValid(context, "Appointment deleted successfully.");
      Navigator.pop(context);
    }
  }
},

),

                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('appointments: ${widget.appointments.length}',
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
  child: _filteredAppointments.isEmpty
      ? const Center(
          child: Text('no appointments found',
              style: TextStyle(color: AppColors.textColor)),
        )
      : ListView.builder(
          itemCount: _filteredAppointments.length,
          itemBuilder: (context, index) {
            final appt = _filteredAppointments[index]['appointment'];
            final user = _filteredAppointments[index]['user'];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundImage: const AssetImage('assets/doctor.png'),
                  radius: 25,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                ),
                title: Text(
                  user['name'] ?? 'no name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        const Icon(Icons.format_list_numbered, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 6),
        Text('order: ${appt['order'] ?? 'not found'}'),
      ],
    ),
    Row(
      children: [
        Icon(
          appt['consultinDone'] == true ? Icons.check_circle : Icons.hourglass_empty,
          size: 16,
          color: appt['consultinDone'] == true ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 6),
        Text(appt['consultinDone'] == true ? 'done' : 'waiting'),
      ],
    ),
    
    Row(
      children: [
        const Icon(Icons.cake, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 6),
        Text('birth: ${user['age'] ?? 'not found'}'),
      ],
    ),
    Row(
      children: [
        const Icon(Icons.phone, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 6),
        Text('phone: ${user['phone'] ?? 'not found'}'),
      ],
    ),
    Row(
      children: [
        const Icon(Icons.email, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 6),
        Text('email: ${user['email'] ?? 'not found'}'),
      ],
    ),
  ],
),
              ),
            );
          },
        ),
),
            
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
