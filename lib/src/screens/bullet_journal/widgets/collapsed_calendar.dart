import 'package:flutter/material.dart';

import '../../../models/bullet_entry.dart';
import 'calendar_week_header.dart';
import '../utils/calendar_utils.dart';

class CollapsedCalendar extends StatelessWidget {
  const CollapsedCalendar({
    super.key,
    required this.calendarDays,
    required this.entriesByDay,
    required this.selectedDateKey,
    required this.currentMonth,
    required this.onDateSelected,
  });

  final List<DateTime> calendarDays;
  final Map<String, List<BulletEntry>> entriesByDay;
  final String? selectedDateKey;
  final DateTime currentMonth;
  final ValueChanged<String?> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CalendarWeekHeader(isSmall: true),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.1,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: calendarDays.length,
            itemBuilder: (context, index) {
              final day = calendarDays[index];
              final key = CalendarUtils.dayKey(day);
              final entries = entriesByDay[key] ?? [];
              final isToday = CalendarUtils.isSameDay(day, DateTime.now());
              final isCurrentMonth = day.month == currentMonth.month;
              final isSelected = selectedDateKey == key;

              return GestureDetector(
                onTap: () {
                  if (entries.isNotEmpty || isCurrentMonth) {
                    if (selectedDateKey == key) {
                      onDateSelected(null);
                    } else {
                      onDateSelected(key);
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isSelected
                        ? Colors.teal.shade50
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.teal : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday
                              ? Colors.teal.shade700
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.w500,
                              color: !isCurrentMonth
                                  ? Colors.grey.shade300
                                  : isToday
                                      ? Colors.white
                                      : CalendarUtils.getDayColor(day),
                            ),
                          ),
                        ),
                      ),
                      if (entries.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 20,
                          height: 2,
                          color: Colors.teal,
                        ),
                      ],
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

