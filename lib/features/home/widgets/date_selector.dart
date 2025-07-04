import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_offline_first/core/constants/utils.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) ontap;
  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.ontap,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  int weekOffset = 0;

  @override
  Widget build(BuildContext context) {
    final weekDates = generateWeekDates(weekOffset);
    String monthName = DateFormat("MMMM").format(weekDates[0]);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ).copyWith(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    weekOffset--;
                  });
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              Text(monthName, style: TextStyle(fontSize: 30)),
              IconButton(
                onPressed: () {
                  setState(() {
                    weekOffset++;
                  });
                },
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weekDates.length,
            itemBuilder: (context, index) {
              bool isSelected =
                  DateFormat('d').format(widget.selectedDate) ==
                      DateFormat('d').format(weekDates[index]) &&
                  DateFormat('M').format(widget.selectedDate) ==
                      DateFormat('M').format(weekDates[index]) &&
                  DateFormat('y').format(widget.selectedDate) ==
                      DateFormat('y').format(weekDates[index]);

              return GestureDetector(
                onTap: () => widget.ontap(weekDates[index]),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.deepOrangeAccent : Colors.white,
                    border: Border.all(
                      color:
                          isSelected
                              ? Colors.deepOrangeAccent
                              : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: 70,
                  margin: const EdgeInsets.only(right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat("d").format(weekDates[index]),
                        style: TextStyle(
                          fontSize: 20,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        DateFormat("EEE").format(weekDates[index]),
                        style: TextStyle(
                          fontSize: 20,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
