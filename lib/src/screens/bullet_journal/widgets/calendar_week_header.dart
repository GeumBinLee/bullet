import 'package:flutter/material.dart';

class CalendarWeekHeader extends StatelessWidget {
  const CalendarWeekHeader({super.key, this.isSmall = false});

  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: ['월', '화', '수', '목', '금', '토', '일']
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: isSmall ? 12 : 14,
                        fontWeight: FontWeight.bold,
                        color: day == '일'
                            ? Colors.red.shade700
                            : day == '토'
                                ? Colors.blue.shade700
                                : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

