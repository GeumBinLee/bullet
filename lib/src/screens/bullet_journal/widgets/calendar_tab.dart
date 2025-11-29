import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/bullet_entry.dart';
import '../../../utils/device_type.dart';
import 'calendar_header.dart';
import 'expanded_calendar.dart';
import 'collapsed_calendar.dart';
import 'landscape_calendar.dart';
import 'calendar_entry_list.dart';
import '../utils/calendar_utils.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  DateTime _currentMonth = DateTime.now();
  String? _selectedDateKey;
  double _dragStartY = 0.0;

  // 헤더(년/월) 높이
  final double _headerHeight = 60.0;
  // 접기/펼치기 버튼 높이
  final double _toggleButtonHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulletJournalBloc, BulletJournalState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // 데이터 처리 로직
        final allEntries = <BulletEntry>[...state.entries];
        for (final diary in state.diaries) {
          // 다이어리의 모든 페이지에서 엔트리 수집
          for (final page in diary.pages) {
            allEntries.addAll(page.entries);
          }
        }

        final entriesByDay = <String, List<BulletEntry>>{};
        for (final entry in allEntries) {
          final key = CalendarUtils.dayKey(entry.date);
          entriesByDay.putIfAbsent(key, () => []).add(entry);
        }

        final firstDayOfMonth =
            DateTime(_currentMonth.year, _currentMonth.month, 1);
        int firstWeekday = firstDayOfMonth.weekday;
        final startDate =
            firstDayOfMonth.subtract(Duration(days: firstWeekday - 1));

        // 현재 달의 마지막 날
        final lastDayOfMonth = DateTime(
          _currentMonth.year,
          _currentMonth.month + 1,
          0,
        );

        // 가로 화면용: 현재 달의 날짜만 (1일부터 마지막 날까지)
        final currentMonthDays = <DateTime>[];
        for (int day = 1; day <= lastDayOfMonth.day; day++) {
          currentMonthDays.add(
            DateTime(_currentMonth.year, _currentMonth.month, day),
          );
        }

        // 세로 화면용: 6주치 날짜 (42개)
        final calendarDays = List<DateTime>.generate(42, (index) {
          return startDate.add(Duration(days: index));
        });

        return LayoutBuilder(
          builder: (context, constraints) {
            final orientation =
                DeviceTypeDetector.getDeviceOrientation(context);
            final isLandscape = orientation == DeviceOrientation.landscape;

            // 가로 화면일 때는 레이아웃을 다르게 처리
            if (isLandscape) {
              return Column(
                children: [
                  // 1. 월 네비게이션 헤더
                  CalendarHeader(
                    currentMonth: _currentMonth,
                    headerHeight: _headerHeight,
                    onPreviousMonth: () {
                      setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month - 1,
                        );
                      });
                    },
                    onNextMonth: () {
                      setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month + 1,
                        );
                      });
                    },
                  ),

                  // 2. 가로 화면: 왼쪽에 날짜만 보이는 캘린더, 오른쪽에 일정 확인란
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 왼쪽: 현재 달의 날짜만 표시하는 캘린더
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: LandscapeCalendar(
                              currentMonthDays: currentMonthDays,
                              entriesByDay: entriesByDay,
                              selectedDateKey: _selectedDateKey,
                              currentMonth: _currentMonth,
                              onDateSelected: (key) {
                                setState(() {
                                  if (_selectedDateKey == key) {
                                    _selectedDateKey = null;
                                  } else {
                                    _selectedDateKey = key;
                                  }
                                });
                              },
                            ),
                          ),
                        ),

                        // 오른쪽: 엔트리 리스트 (일정 확인란)
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: CalendarEntryList(
                              entriesByDay: entriesByDay,
                              selectedDateKey: _selectedDateKey,
                              state: state,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            // 세로 화면: 기존 레이아웃 유지
            // 사용 가능한 높이 (전체 높이 - 헤더 - 버튼)
            final double availableHeight =
                constraints.maxHeight - _headerHeight - _toggleButtonHeight;

            // 펼쳐졌을 때 차지할 최대 높이
            final double expandedHeight = availableHeight;

            // 접혔을 때 캘린더가 차지할 높이 (화면의 2/3)
            final double collapsedHeight = availableHeight * 2 / 3;

            // 접혔을 때 일정 확인란이 차지할 높이 (화면의 1/3)
            final double entryListHeight = availableHeight * 1 / 3;

            return Column(
              children: [
                // 1. 월 네비게이션 헤더
                CalendarHeader(
                  currentMonth: _currentMonth,
                  headerHeight: _headerHeight,
                  onPreviousMonth: () {
                    setState(() {
                      _currentMonth = DateTime(
                        _currentMonth.year,
                        _currentMonth.month - 1,
                      );
                    });
                  },
                  onNextMonth: () {
                    setState(() {
                      _currentMonth = DateTime(
                        _currentMonth.year,
                        _currentMonth.month + 1,
                      );
                    });
                  },
                ),

                // 2. 캘린더 영역 (AnimatedContainer + GestureDetector)
                GestureDetector(
                  onVerticalDragStart: (details) {
                    _dragStartY = details.globalPosition.dy;
                  },
                  onVerticalDragUpdate: (details) {
                    final deltaY = details.globalPosition.dy - _dragStartY;
                    // 드래그 감도 조절 (30px 이상 움직이면 동작)
                    if (deltaY.abs() > 30) {
                      if (deltaY > 0 && !_isExpanded) {
                        // 아래로 드래그 -> 펼치기
                        setState(() {
                          _isExpanded = true;
                          _selectedDateKey = null; // 펼칠 땐 상세 보기 닫기
                        });
                        _dragStartY = details.globalPosition.dy;
                      } else if (deltaY < 0 && _isExpanded) {
                        // 위로 드래그 -> 접기
                        setState(() {
                          _isExpanded = false;
                        });
                        _dragStartY = details.globalPosition.dy;
                      }
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: _isExpanded ? expandedHeight : collapsedHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        if (_isExpanded)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                      ],
                    ),
                    child: _isExpanded
                        ? ExpandedCalendar(
                            calendarDays: calendarDays,
                            entriesByDay: entriesByDay,
                            selectedDateKey: _selectedDateKey,
                            currentMonth: _currentMonth,
                            state: state,
                            onDateSelected: (key) {
                              setState(() {
                                if (_selectedDateKey == key && !_isExpanded) {
                                  _selectedDateKey = null;
                                } else {
                                  _selectedDateKey = key;
                                  _isExpanded = false;
                                }
                              });
                            },
                          )
                        : CollapsedCalendar(
                            calendarDays: calendarDays,
                            entriesByDay: entriesByDay,
                            selectedDateKey: _selectedDateKey,
                            currentMonth: _currentMonth,
                            onDateSelected: (key) {
                              setState(() {
                                if (_selectedDateKey == key) {
                                  _selectedDateKey = null;
                                } else {
                                  _selectedDateKey = key;
                                }
                              });
                            },
                          ),
                  ),
                ),

                // 3. 접기/펼치기 버튼
                SizedBox(
                  height: _toggleButtonHeight,
                  child: IconButton(
                    icon: Icon(_isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                        if (_isExpanded) _selectedDateKey = null;
                      });
                    },
                  ),
                ),

                // 4. 선택된 날짜의 엔트리 리스트 (캘린더가 접혀있을 때만 보임)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: _isExpanded ? 0 : entryListHeight,
                  child: _isExpanded
                      ? const SizedBox.shrink()
                      : SizedBox.expand(
                          child: CalendarEntryList(
                            entriesByDay: entriesByDay,
                            selectedDateKey: _selectedDateKey,
                            state: state,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

