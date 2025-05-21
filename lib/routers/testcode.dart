import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meditime/core/theme/colors.dart';
import 'package:meditime/widgets/confirme_dailog.dart';
import 'package:meditime/widgets/confirmed_dailog.dart';
class testcode extends StatefulWidget {
  const testcode({super.key});

  @override
  testcodeScreenState createState() => testcodeScreenState();
}

class testcodeScreenState extends State<testcode> {
  DateTime _currentDate = DateTime.now();
  DateTime? _selectedDate;
  final List<String> _weekDays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  List<DateTime> _getDaysInMonth() {
    var firstDay = DateTime(_currentDate.year, _currentDate.month, 1);
    var lastDay = DateTime(_currentDate.year, _currentDate.month + 1, 0);

    List<DateTime> days = [];
    int weekdayOffset = (firstDay.weekday % 7);
    for (var i = 0; i < weekdayOffset; i++) {
      days.add(DateTime(0)); // empty days
    }

    for (var i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(_currentDate.year, _currentDate.month, i));
    }

    return days;
  }

  void _goToNextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      _selectedDate = null;
    });
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      _selectedDate = null;
    });
  }

  Future<void> _selectMonthAndYear() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (selected != null) {
      setState(() {
        _currentDate = DateTime(selected.year, selected.month);
      });
    }
  }
// SHOW DAILOG فيه CARD تع Confirm

  @override
  Widget build(BuildContext context) {
    var daysInMonth = _getDaysInMonth();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primaryColor,
      ),
     // bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'SELECT TIME',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _goToPreviousMonth,
                ),
                InkWell(
                  onTap: _selectMonthAndYear,
                  child: Text(
                    DateFormat('MMMM y').format(_currentDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _goToNextMonth,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: _weekDays
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),



















                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 352,
              height: 330,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                ),
                itemCount: daysInMonth.length,
                itemBuilder: (context, index) {
                  var day = daysInMonth[index];
                  bool isToday = day.day == DateTime.now().day &&
                      day.month == DateTime.now().month &&
                      day.year == DateTime.now().year;
                  bool isSelected = _selectedDate != null &&
                      day.day == _selectedDate!.day &&
                      day.month == _selectedDate!.month &&
                      day.year == _selectedDate!.year;

                  return GestureDetector(
                    onTap: day.year == 0
                        ? null
                        : () {
                          },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: day.year == 0
                            ? Colors.transparent
                            : isSelected
                                ? AppColors.primaryColor
                                : null,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          day.year == 0 ? '' : day.day.toString(),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : day.weekday == DateTime.friday
                                    ? Colors.red
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                    },
                                   
                child: const Text(
                  'BOOK NOW',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}