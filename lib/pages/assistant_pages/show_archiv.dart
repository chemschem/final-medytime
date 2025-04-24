import 'package:flutter/material.dart';
import 'package:meditime/api/function_archiv.dart';

class show_archiv extends StatefulWidget {
  const show_archiv({Key? key}) : super(key: key);

  @override
  _show_archivState createState() => _show_archivState();
}
class _show_archivState extends State<show_archiv> {
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Archive Data')),
    body: Column(
      children: [
        Text('this data is saved even though you delete the appointments'),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
        future: function_archiv().fetchArchivData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            List<Map<String, dynamic>> archivData = snapshot.data!;
            return ListView.builder(
              itemCount: archivData.length,
              itemBuilder: (context, index) {
                var dateData = archivData[index];//dateData is a Map<String, dynamic> that contains information about a specific archived date
                return ExpansionTile(//ExpansionTile is a material design expansion panel list that expands/collapses to show/hide children
                  title: Text('Date: ${dateData['day']}'),
                  subtitle: Text(
                      'Start: ${dateData['start']} - End: ${dateData['end']} (Limit: ${dateData['limit']})'),
                  children: dateData['users'].map<Widget>((user) {
                    //'users' is a key inside dateData that holds a list of users. Each user is a Map<String, dynamic>.
                    //The map() method is used to create a new list of ExpansionTile widgets, each representing a user and their appointments.
                    return ExpansionTile(
                      title: Text('User: ${user['name']}'),
                      subtitle: Text('phone: ${user['phone']}'),
                      children: user['appointments'].map<Widget>((appointment) {//'appointments' is a key inside user that holds a list of appointments. Each appointment is a Map<String, dynamic>
                        return ListTile(
                          title: Text('order: ${appointment['order']}'),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              },
            );
          }
          }
          ),
        ),
      ],
    ),
  );
}
}
