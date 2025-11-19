import 'package:flutter/material.dart';

import '../../../models/bullet_entry.dart';
import 'calendar_week_header.dart';
import '../utils/calendar_utils.dart';

class LandscapeCalendar extends StatelessWidget {
  const LandscapeCalendar({
    super.key,
    required this.currentMonthDays,
    required this.entriesByDay,
    required this.selectedDateKey,
    required this.currentMonth,
    required this.onDateSelected,
  });

  final List<DateTime> currentMonthDays;
  final Map<String, List<BulletEntry>> entriesByDay;
  final String? selectedDateKey;
  final DateTime currentMonth;
  final ValueChanged<String?> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final firstDay = currentMonthDays.first;
    final firstWeekday = firstDay.weekday; // 1(월) ~ 7(일)

    // 첫 주의 빈칸 개수 (요일 - 1)
    final leadingEmptyDays = firstWeekday - 1;

    // 전체 아이템 개수 = 빈칸 + 날짜 개수
    final totalItems = leadingEmptyDays + currentMonthDays.length;

    return Column(
      children: [
        // 요일 헤더
        const CalendarWeekHeader(),
        const Divider(height: 1),
        // 그리드 (사용 가능한 최대 높이를 차지하도록)
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 사용 가능한 너비와 높이
              final availableWidth = constraints.maxWidth - 16; // padding 제외
              final availableHeight = constraints.maxHeight - 16; // padding 제외

              // 각 아이템의 너비 계산 (7열)
              final itemWidth =
                  (availableWidth - (4 * 6)) / 7; // crossAxisSpacing * 6

              // 필요한 행 수 계산
              final rowCount = (totalItems / 7).ceil();

              // 각 아이템의 최적 높이 계산 (사용 가능한 높이를 최대한 활용)
              // 엔트리 바가 있을 수 있으므로 최소 필요 높이 고려 (28 + 4 = 32)
              final minItemHeight = 32.0;
              final calculatedItemHeight =
                  (availableHeight - (3 * (rowCount - 1))) / rowCount;

              // 계산된 높이와 최소 높이 중 큰 값 사용 (엔트리 바가 있어도 오버플로우 방지)
              final itemHeight = calculatedItemHeight > minItemHeight
                  ? calculatedItemHeight
                  : minItemHeight;

              // childAspectRatio 계산 (width / height)
              final aspectRatio = itemWidth / itemHeight;

              return Padding(
                padding: const EdgeInsets.all(8),
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: false,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: aspectRatio,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 3,
                  ),
                  itemCount: totalItems,
                  itemBuilder: (context, index) {
                    // 빈칸 처리
                    if (index < leadingEmptyDays) {
                      return const SizedBox.shrink();
                    }

                    // 실제 날짜
                    final dayIndex = index - leadingEmptyDays;
                    final day = currentMonthDays[dayIndex];
                    final key = CalendarUtils.dayKey(day);
                    final entries = entriesByDay[key] ?? [];
                    final isToday = CalendarUtils.isSameDay(day, DateTime.now());
                    final isSelected = selectedDateKey == key;

                    return GestureDetector(
                      onTap: () {
                        if (selectedDateKey == key) {
                          onDateSelected(null);
                        } else {
                          onDateSelected(key);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isSelected
                              ? Colors.teal.shade50
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? Colors.teal
                                : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Container(
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
                                      fontSize: 13,
                                      fontWeight: isToday
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isToday
                                          ? Colors.white
                                          : CalendarUtils.getDayColor(day),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (entries.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Container(
                                width: 18,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

