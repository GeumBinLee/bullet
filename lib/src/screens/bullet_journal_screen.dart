import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../blocs/bullet_journal_bloc.dart';
import '../data/key_definitions.dart';
import '../models/bullet_entry.dart';
import '../models/key_definition.dart';
import '../models/diary.dart';
import '../widgets/key_bullet_icon.dart';
import '../providers/app_settings_provider.dart';
import '../utils/device_type.dart';

class BulletJournalScreen extends StatefulWidget {
  const BulletJournalScreen({super.key});

  @override
  State<BulletJournalScreen> createState() => _BulletJournalScreenState();
}

class _BulletJournalScreenState extends State<BulletJournalScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _DiaryTab(),
    _CalendarTab(),
    _MyPageTab(),
  ];

  final List<String> _titles = const ['다이어리', '캘린더', '마이페이지'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex]), centerTitle: true),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: '다이어리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class _DiaryTab extends StatelessWidget {
  const _DiaryTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulletJournalBloc, BulletJournalState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final deviceType = DeviceTypeDetector.getDeviceType(context);
        final orientation = DeviceTypeDetector.getDeviceOrientation(context);

        // 모바일 세로 또는 리스트가 적을 때는 ListView 사용
        final useGridView = (deviceType == DeviceType.tablet ||
                deviceType == DeviceType.desktop ||
                (deviceType == DeviceType.mobile &&
                    orientation == DeviceOrientation.landscape)) &&
            state.diaries.isNotEmpty;

        if (useGridView) {
          // Grid 레이아웃
          int crossAxisCount = 2;
          if (deviceType == DeviceType.desktop) {
            crossAxisCount = orientation == DeviceOrientation.landscape ? 4 : 3;
          } else if (deviceType == DeviceType.tablet) {
            crossAxisCount = orientation == DeviceOrientation.landscape ? 3 : 2;
          } else {
            // 모바일 가로
            crossAxisCount = 2;
          }

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '다이어리 목록',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (state.diaries.isEmpty)
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        '다이어리가 없습니다. 아래 버튼을 눌러 추가하세요.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: GridView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: state.diaries.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.diaries.length) {
                        // Add button
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () => _DiaryTab._showAddDiaryDialog(context),
                            borderRadius: BorderRadius.circular(16),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline, size: 48),
                                SizedBox(height: 8),
                                Text('다이어리 추가'),
                              ],
                            ),
                          ),
                        );
                      }

                      final diary = state.diaries[index];
                      return _DiaryCard(diary: diary);
                    },
                  ),
                ),
            ],
          );
        } else {
          // List 레이아웃 (모바일 세로)
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '다이어리 목록',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (state.diaries.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '다이어리가 없습니다. 아래 버튼을 눌러 추가하세요.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...state.diaries.map((diary) {
                  return _DiaryCard(diary: diary);
                }),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('다이어리 추가'),
                subtitle: const Text('새로운 다이어리 만들기'),
                onTap: () => _DiaryTab._showAddDiaryDialog(context),
              ),
            ],
          );
        }
      },
    );
  }

  static void _showAddDiaryDialog(BuildContext context) {
    final bloc = context.read<BulletJournalBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => _AddDiaryDialog(bloc: bloc),
    );
  }

  static void _navigateToDiary(BuildContext context, Diary diary) {
    if (diary.password != null && diary.password!.isNotEmpty) {
      _showPasswordDialog(context, diary);
    } else {
      context.push('/diary/${diary.id}');
    }
  }

  static void _showPasswordDialog(BuildContext context, Diary diary) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${diary.name} 잠금 해제'),
        content: TextField(
          controller: passwordController,
          decoration: const InputDecoration(
            labelText: '비밀번호',
            hintText: '비밀번호를 입력하세요',
          ),
          obscureText: true,
          autofocus: true,
          onSubmitted: (value) {
            if (value == diary.password) {
              context.pop();
              context.push('/diary/${diary.id}');
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('비밀번호가 일치하지 않습니다')));
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              if (passwordController.text == diary.password) {
                context.pop();
                context.push('/diary/${diary.id}');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('비밀번호가 일치하지 않습니다')),
                );
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

class _DiaryCard extends StatelessWidget {
  const _DiaryCard({required this.diary});

  final Diary diary;

  @override
  Widget build(BuildContext context) {
    // 전체 페이지 엔트리 개수 계산
    int totalEntries = diary.entries.length;
    for (final page in diary.pages) {
      totalEntries += page.entries.length;
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 0,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          if (diary.password != null && diary.password!.isNotEmpty) {
            _showPasswordDialog(context, diary);
          } else {
            _DiaryTab._navigateToDiary(context, diary);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                color: Color(diary.colorValue),
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 노트 아이콘과 잠금 아이콘
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note,
                      size: 48,
                      color: Color(diary.colorValue),
                    ),
                    if (diary.password != null &&
                        diary.password!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.lock,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // 이름과 더보기 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        diary.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                '삭제',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('다이어리 삭제'),
                              content: Text(
                                '${diary.name} 다이어리를 삭제하시겠습니까?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => context.pop(),
                                  child: const Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.read<BulletJournalBloc>().add(
                                          BulletJournalEvent.deleteDiary(
                                            diary.id,
                                          ),
                                        );
                                    context.pop();
                                  },
                                  child: const Text(
                                    '삭제',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                if (diary.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    diary.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '$totalEntries개의 엔트리',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPasswordDialog(BuildContext context, Diary diary) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${diary.name} 잠금 해제'),
        content: TextField(
          controller: passwordController,
          decoration: const InputDecoration(
            labelText: '비밀번호',
            hintText: '비밀번호를 입력하세요',
          ),
          obscureText: true,
          autofocus: true,
          onSubmitted: (value) {
            if (value == diary.password) {
              context.pop();
              context.push('/diary/${diary.id}');
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('비밀번호가 일치하지 않습니다')));
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              if (passwordController.text == diary.password) {
                context.pop();
                context.push('/diary/${diary.id}');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('비밀번호가 일치하지 않습니다')),
                );
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

class _AddDiaryDialog extends StatefulWidget {
  const _AddDiaryDialog({required this.bloc});

  final BulletJournalBloc bloc;

  @override
  State<_AddDiaryDialog> createState() => _AddDiaryDialogState();
}

class _AddDiaryDialogState extends State<_AddDiaryDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passwordController = TextEditingController();
  int _selectedColor = 0xFF4CAF50;
  bool _usePassword = false;

  static const List<int> _colorOptions = [
    0xFF4CAF50, // Green
    0xFF2196F3, // Blue
    0xFF9C27B0, // Purple
    0xFFFF9800, // Orange
    0xFFE91E63, // Pink
    0xFF00BCD4, // Cyan
    0xFFFF5722, // Deep Orange
    0xFF795548, // Brown
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('다이어리 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '다이어리 이름',
                hintText: '예: 개인 일기, 업무 일지',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '설명',
                hintText: '이 다이어리에 대해 설명해주세요',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('색상 선택:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color
                            ? Colors.black
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('비밀번호 설정'),
              value: _usePassword,
              onChanged: (value) {
                setState(() {
                  _usePassword = value ?? false;
                  if (!_usePassword) {
                    _passwordController.clear();
                  }
                });
              },
            ),
            if (_usePassword) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  hintText: '비밀번호를 입력하세요',
                ),
                obscureText: true,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('취소')),
        TextButton(
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('다이어리 이름을 입력해주세요')));
              return;
            }

            if (_usePassword && _passwordController.text.isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('비밀번호를 입력해주세요')));
              return;
            }

            final diary = Diary(
              id: 'diary-${DateTime.now().millisecondsSinceEpoch}',
              name: _nameController.text,
              description: _descriptionController.text,
              createdAt: DateTime.now(),
              colorValue: _selectedColor,
              password: _usePassword ? _passwordController.text : null,
            );

            widget.bloc.add(BulletJournalEvent.addDiary(diary));

            context.pop();
          },
          child: const Text('추가'),
        ),
      ],
    );
  }
}

class _CalendarTab extends StatefulWidget {
  const _CalendarTab();

  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<_CalendarTab>
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

        // 데이터 처리 로직 (기존과 동일)
        final allEntries = <BulletEntry>[...state.entries];
        for (final diary in state.diaries) {
          // 다이어리의 모든 페이지에서 엔트리 수집
          for (final page in diary.pages) {
            allEntries.addAll(page.entries);
          }
        }

        final entriesByDay = <String, List<BulletEntry>>{};
        for (final entry in allEntries) {
          final key = _dayKey(entry.date);
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
                  SizedBox(
                    height: _headerHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(
                                _currentMonth.year,
                                _currentMonth.month - 1,
                              );
                            });
                          },
                        ),
                        Text(
                          '${_currentMonth.year}년 ${_currentMonth.month}월',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(
                                _currentMonth.year,
                                _currentMonth.month + 1,
                              );
                            });
                          },
                        ),
                      ],
                    ),
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
                            child: _buildLandscapeCalendar(
                                currentMonthDays, entriesByDay, context, state),
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
                            child: _buildEntryList(entriesByDay, state),
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
                SizedBox(
                  height: _headerHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime(
                              _currentMonth.year,
                              _currentMonth.month - 1,
                            );
                          });
                        },
                      ),
                      Text(
                        '${_currentMonth.year}년 ${_currentMonth.month}월',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime(
                              _currentMonth.year,
                              _currentMonth.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
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
                        ? _buildExpandedCalendar(
                            calendarDays, entriesByDay, context, state)
                        : _buildCollapsedCalendar(calendarDays, entriesByDay),
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
                // 접혔을 때만 표시되며, 화면의 1/3 공간을 차지
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: _isExpanded ? 0 : entryListHeight,
                  child: _isExpanded
                      ? const SizedBox.shrink()
                      : SizedBox.expand(
                          child: _buildEntryList(entriesByDay, state),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 펼쳐진 캘린더 빌드 (내용이 꽉 차게)
  Widget _buildExpandedCalendar(
    List<DateTime> calendarDays,
    Map<String, List<BulletEntry>> entriesByDay,
    BuildContext context,
    BulletJournalState state,
  ) {
    return Column(
      children: [
        // 요일 헤더
        _buildWeekHeader(),
        const Divider(height: 1),
        // 그리드
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              // 스크롤 막기 (화면에 딱 맞추기 위해)
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                // 비율을 1로 고정하지 않고 화면 높이에 맞게 조정될 수 있도록 함
                // 다만 GridView는 aspect ratio가 중요하므로
                // Expanded 내부에서 비율을 맞추기 위해 childAspectRatio를 조정하거나
                // 단순히 fit하게 둡니다. 여기선 1로 두고 남는 공간은 공백 처리
                childAspectRatio: 0.7, // 세로로 좀 더 길게
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: calendarDays.length,
              itemBuilder: (context, index) {
                final day = calendarDays[index];
                final key = _dayKey(day);
                final entries = entriesByDay[key] ?? [];
                final isToday = _isSameDay(day, DateTime.now());
                final isCurrentMonth = day.month == _currentMonth.month;

                return GestureDetector(
                  onTap: () {
                    if (entries.isNotEmpty || isCurrentMonth) {
                      setState(() {
                        if (_selectedDateKey == key && !_isExpanded) {
                          // 접힌 상태에서 같은 날짜를 다시 클릭하면 선택 해제
                          _selectedDateKey = null;
                        } else {
                          // 날짜 선택하고 접힌 상태로 변경
                          _selectedDateKey = key;
                          _isExpanded = false;
                        }
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _selectedDateKey == key
                          ? Colors.teal.shade50
                          : Colors.white,
                      border: Border.all(
                        color: _selectedDateKey == key
                            ? Colors.teal
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Center(
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
                                    fontSize: 14,
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: !isCurrentMonth
                                        ? Colors.grey.shade300
                                        : isToday
                                            ? Colors.white
                                            : _getDayColor(day),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: entries.length > 3 ? 3 : entries.length,
                            itemBuilder: (context, idx) {
                              final entry = entries[idx];
                              final diaryInfo =
                                  _findDiaryForEntry(state, entry);
                              final hasDiary = diaryInfo?.id != null;

                              return GestureDetector(
                                onTap: hasDiary
                                    ? () {
                                        final diary = state.diaries.firstWhere(
                                          (d) => d.id == diaryInfo!.id,
                                        );
                                        _DiaryTab._navigateToDiary(
                                            context, diary);
                                      }
                                    : null,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 2),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade100,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    entry.focus,
                                    style: const TextStyle(fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (entries.length > 3)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '+${entries.length - 3}',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.teal.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // 접힌 캘린더 빌드 (기존 로직 유지하되 크기 조정)
  Widget _buildCollapsedCalendar(
    List<DateTime> calendarDays,
    Map<String, List<BulletEntry>> entriesByDay,
  ) {
    return Column(
      children: [
        _buildWeekHeader(isSmall: true),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.1, // 약간 납작하게
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: calendarDays.length,
            itemBuilder: (context, index) {
              final day = calendarDays[index];
              final key = _dayKey(day);
              final entries = entriesByDay[key] ?? [];
              final isToday = _isSameDay(day, DateTime.now());
              final isCurrentMonth = day.month == _currentMonth.month;
              final isSelected = _selectedDateKey == key;

              return GestureDetector(
                onTap: () {
                  if (entries.isNotEmpty || isCurrentMonth) {
                    setState(() {
                      if (_selectedDateKey == key) {
                        _selectedDateKey = null;
                      } else {
                        _selectedDateKey = key;
                      }
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color:
                        isSelected ? Colors.teal.shade50 : Colors.transparent,
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
                                      : _getDayColor(day),
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

  // 가로 화면용 캘린더: 현재 달의 날짜만 표시 (1일부터 마지막 날까지)
  Widget _buildLandscapeCalendar(
    List<DateTime> currentMonthDays,
    Map<String, List<BulletEntry>> entriesByDay,
    BuildContext context,
    BulletJournalState state,
  ) {
    final firstDay = currentMonthDays.first;
    final firstWeekday = firstDay.weekday; // 1(월) ~ 7(일)

    // 첫 주의 빈칸 개수 (요일 - 1)
    final leadingEmptyDays = firstWeekday - 1;

    // 전체 아이템 개수 = 빈칸 + 날짜 개수
    final totalItems = leadingEmptyDays + currentMonthDays.length;

    return Column(
      children: [
        // 요일 헤더
        _buildWeekHeader(),
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
                    final key = _dayKey(day);
                    final entries = entriesByDay[key] ?? [];
                    final isToday = _isSameDay(day, DateTime.now());
                    final isSelected = _selectedDateKey == key;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedDateKey == key) {
                            _selectedDateKey = null;
                          } else {
                            _selectedDateKey = key;
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              isSelected ? Colors.teal.shade50 : Colors.white,
                          border: Border.all(
                            color:
                                isSelected ? Colors.teal : Colors.grey.shade200,
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
                                          : _getDayColor(day),
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

  Widget _buildWeekHeader({bool isSmall = false}) {
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

  Widget _buildEntryList(
    Map<String, List<BulletEntry>> entriesByDay,
    BulletJournalState state,
  ) {
    if (_selectedDateKey == null || entriesByDay[_selectedDateKey] == null) {
      return const Center(
        child: Text(
          '날짜를 선택하여 일정을 확인하세요',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: entriesByDay[_selectedDateKey]!.map((entry) {
              final diaryInfo = _findDiaryForEntry(state, entry);
              final hasDiary = diaryInfo?.id != null;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(entry.focus),
                  subtitle: Text('${entry.tasks.length}개의 작업'),
                  trailing: hasDiary ? const Icon(Icons.arrow_forward) : null,
                  onTap: hasDiary
                      ? () {
                          final diary = state.diaries.firstWhere(
                            (d) => d.id == diaryInfo!.id,
                          );
                          _DiaryTab._navigateToDiary(context, diary);
                        }
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getDayColor(DateTime day) {
    if (day.weekday == 7) return Colors.red.shade700;
    if (day.weekday == 6) return Colors.blue.shade700;
    return Colors.black87;
  }

  // Helper methods (기존과 동일)
  ({String? name, String? id})? _findDiaryForEntry(
    BulletJournalState state,
    BulletEntry entry,
  ) {
    if (state.entries.any((e) => e.id == entry.id)) {
      return (name: '기본', id: null);
    }
    for (final diary in state.diaries) {
      if (diary.entries.any((e) => e.id == entry.id)) {
        return (name: diary.name, id: diary.id);
      }
    }
    return null;
  }

  String _dayKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _MyPageTab extends StatelessWidget {
  const _MyPageTab();

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsProvider.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '설정',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.vpn_key),
          title: const Text('키 설정'),
          subtitle: const Text('불렛 키 및 작업 상태 관리'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const _KeySettingsScreen(),
                fullscreenDialog: false,
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.palette),
          title: const Text('테마'),
          subtitle: Text(
            _getThemeModeText(settings?.themeMode ?? ThemeMode.light),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showThemeDialog(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.font_download),
          title: const Text('글씨체'),
          subtitle: Text(_getFontFamilyText(settings?.fontFamily)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showFontFamilyDialog(context);
          },
        ),
        const Divider(),
      ],
    );
  }

  static String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '라이트 모드';
      case ThemeMode.dark:
        return '다크 모드';
      case ThemeMode.system:
        return '시스템 설정 따르기';
    }
  }

  static String _getFontFamilyText(String? fontFamily) {
    if (fontFamily == null) {
      return '시스템 기본';
    }
    switch (fontFamily) {
      case 'NotoSansKR':
        return 'Noto Sans KR';
      case 'NanumGothic':
        return '나눔고딕';
      case 'NanumMyeongjo':
        return '나눔명조';
      case 'NanumPen':
        return '나눔펜';
      default:
        return fontFamily;
    }
  }

  static void _showThemeDialog(BuildContext context) {
    final settings = AppSettingsProvider.of(context);
    if (settings == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테마 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('라이트 모드'),
              value: ThemeMode.light,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settings.onThemeChanged(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('다크 모드'),
              value: ThemeMode.dark,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settings.onThemeChanged(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('시스템 설정 따르기'),
              value: ThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settings.onThemeChanged(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  static void _showFontFamilyDialog(BuildContext context) {
    final settings = AppSettingsProvider.of(context);
    if (settings == null) return;

    final fontFamilies = [
      (null, '시스템 기본'),
      ('NotoSansKR', 'Noto Sans KR'),
      ('NanumGothic', '나눔고딕'),
      ('NanumMyeongjo', '나눔명조'),
      ('NanumPen', '나눔펜'),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('글씨체 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: fontFamilies.map((font) {
            TextStyle? textStyle;
            if (font.$1 == null) {
              textStyle = null; // 시스템 기본
            } else {
              switch (font.$1) {
                case 'NotoSansKR':
                  textStyle = GoogleFonts.notoSansKr();
                  break;
                case 'NanumGothic':
                  textStyle = GoogleFonts.nanumGothic();
                  break;
                case 'NanumMyeongjo':
                  textStyle = GoogleFonts.nanumMyeongjo();
                  break;
                case 'NanumPen':
                  textStyle = GoogleFonts.nanumPenScript();
                  break;
                default:
                  textStyle = null;
              }
            }

            return RadioListTile<String?>(
              title: Text(font.$2, style: textStyle),
              value: font.$1,
              groupValue: settings.fontFamily,
              onChanged: (value) {
                settings.onFontFamilyChanged(value ?? '');
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
}

class _KeySettingsScreen extends StatelessWidget {
  const _KeySettingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('키 설정')),
      body: BlocBuilder<BulletJournalBloc, BulletJournalState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '기본 키',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...defaultKeyDefinitions.map((definition) {
                final isMapped = state.statusKeyMapping.values.contains(
                  definition.id,
                );
                final mappedStatusId = state.statusKeyMapping.entries
                    .where((e) => e.value == definition.id)
                    .map((e) => e.key)
                    .firstOrNull;
                return ListTile(
                  leading: KeyBulletIcon(definition: definition),
                  title: Text(definition.label),
                  subtitle: Text(definition.description),
                  trailing: isMapped
                      ? Chip(
                          label: Text(
                            _statusLabelForChip(mappedStatusId!, state),
                          ),
                          backgroundColor: Colors.teal.shade100,
                        )
                      : null,
                );
              }),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '커스텀 키',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (state.customKeys.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '커스텀 키가 없습니다. 아래 버튼을 눌러 추가하세요.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...state.customKeys.map((definition) {
                  final isMapped = state.statusKeyMapping.values.contains(
                    definition.id,
                  );
                  final mappedStatusId = state.statusKeyMapping.entries
                      .where((e) => e.value == definition.id)
                      .map((e) => e.key)
                      .firstOrNull;
                  return ListTile(
                    leading: KeyBulletIcon(definition: definition),
                    title: Text(definition.label),
                    subtitle: Text(definition.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isMapped)
                          Chip(
                            label: Text(
                              _statusLabelForChip(mappedStatusId!, state),
                            ),
                            backgroundColor: Colors.teal.shade100,
                          ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            ...state.taskStatuses.map((status) {
                              return PopupMenuItem(
                                value: 'assign_${status.id}',
                                child: Text('${status.label}에 사용'),
                              );
                            }),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                '삭제',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') {
                              context.read<BulletJournalBloc>().add(
                                    BulletJournalEvent.deleteCustomKey(
                                      definition.id,
                                    ),
                                  );
                            } else if (value.startsWith('assign_')) {
                              final statusId = value.replaceFirst(
                                'assign_',
                                '',
                              );
                              final status = state.taskStatuses.firstWhere(
                                (s) => s.id == statusId,
                              );
                              context.read<BulletJournalBloc>().add(
                                    BulletJournalEvent.updateStatusKey(
                                      status: status,
                                      keyId: definition.id,
                                    ),
                                  );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '작업 상태 종류',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '커스텀 작업 상태를 삭제하면, 해당 상태를 사용하던 작업들이 "기타"로 자동 변경됩니다.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...state.taskStatuses.map((status) {
                final isDefault = TaskStatus.defaultStatuses.any(
                  (s) => s.id == status.id,
                );
                // 기본 엔트리와 다이어리 엔트리 모두에서 사용 중인지 확인
                bool hasTasks = state.entries.any(
                  (entry) =>
                      entry.tasks.any((task) => task.status.id == status.id),
                );
                if (!hasTasks) {
                  hasTasks = state.diaries.any(
                    (diary) => diary.entries.any(
                      (entry) => entry.tasks.any(
                        (task) => task.status.id == status.id,
                      ),
                    ),
                  );
                }
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: Text(
                      '${status.order + 1}',
                      style: TextStyle(color: Colors.teal.shade900),
                    ),
                  ),
                  title: Text(status.label),
                  subtitle: Text('순서: ${status.order + 1}'),
                  trailing: isDefault
                      ? const Chip(
                          label: Text('기본'),
                          backgroundColor: Colors.grey,
                        )
                      : hasTasks
                          ? const Chip(
                              label: Text('사용 중'),
                              backgroundColor: Colors.orange,
                            )
                          : IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // 해당 상태를 사용하는 작업 개수 확인
                                int taskCount = 0;
                                for (final entry in state.entries) {
                                  taskCount += entry.tasks
                                      .where(
                                          (task) => task.status.id == status.id)
                                      .length;
                                }
                                for (final diary in state.diaries) {
                                  for (final entry in diary.entries) {
                                    taskCount += entry.tasks
                                        .where(
                                          (task) => task.status.id == status.id,
                                        )
                                        .length;
                                  }
                                }

                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: Text('${status.label} 삭제'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${status.label} 작업 상태를 삭제하시겠습니까?\n해당 상태를 사용하던 작업들이 자동으로 "기타"로 변경됩니다.',
                                        ),
                                        if (taskCount > 0) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12.0),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                8,
                                              ),
                                              border: Border.all(
                                                color: Colors.orange.shade200,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.warning_amber_rounded,
                                                  size: 20,
                                                  color: Colors.orange.shade700,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    '이 상태를 사용하는 작업 $taskCount개가 "기타"로 자동 변경됩니다.',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors
                                                          .orange.shade900,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => context.pop(),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context.read<BulletJournalBloc>().add(
                                                BulletJournalEvent
                                                    .deleteTaskStatus(
                                                  status.id,
                                                ),
                                              );
                                          context.pop();
                                        },
                                        child: const Text(
                                          '삭제',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                );
              }),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('작업 상태 추가'),
                subtitle: const Text('새로운 작업 상태 종류 추가'),
                onTap: () => _KeySettingsScreen._showAddStatusDialog(context),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '키 추가',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('커스텀 키 추가'),
                subtitle: const Text('그림을 그려서 불렛 모양 만들기'),
                onTap: () => _KeySettingsScreen._showCustomKeyDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }

  static void _showCustomKeyDialog(BuildContext context) {
    final bloc = context.read<BulletJournalBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => _CustomKeyDialog(bloc: bloc),
    );
  }

  static void _showAddStatusDialog(BuildContext context) {
    final bloc = context.read<BulletJournalBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => _AddStatusDialog(bloc: bloc),
    );
  }

  static String _statusLabelForChip(String statusId, BulletJournalState state) {
    final status = state.taskStatuses.firstWhere(
      (s) => s.id == statusId,
      orElse: () => TaskStatus(id: statusId, label: statusId, order: 999),
    );
    return status.label;
  }
}

class _CustomKeyDialog extends StatefulWidget {
  const _CustomKeyDialog({required this.bloc});

  final BulletJournalBloc bloc;

  @override
  State<_CustomKeyDialog> createState() => _CustomKeyDialogState();
}

class _CustomKeyDialogState extends State<_CustomKeyDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _textController = TextEditingController();
  final _drawingController = _DrawingController();
  TaskStatus? _selectedStatus;
  bool _useText = false; // true면 텍스트, false면 그림

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocBuilder<BulletJournalBloc, BulletJournalState>(
        builder: (context, state) {
          return AlertDialog(
            title: const Text('커스텀 키 추가'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '키 이름',
                      hintText: '예: 별표',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '설명',
                      hintText: '이 키를 언제 사용하나요?',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('작업 상태 종류 선택:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TaskStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: '상태 종류',
                      border: OutlineInputBorder(),
                    ),
                    items: state.taskStatuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('그림 그리기'),
                        icon: Icon(Icons.edit),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('텍스트 입력'),
                        icon: Icon(Icons.text_fields),
                      ),
                    ],
                    selected: {_useText},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() {
                        _useText = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_useText) ...[
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: '키 텍스트',
                        hintText: '예: ★, ⭐, ✓',
                        helperText: '표시할 텍스트나 기호를 입력하세요 (최대 3자)',
                      ),
                      maxLength: 3,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ] else ...[
                    const Text('그림 그리기:'),
                    const SizedBox(height: 8),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRect(
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              final localPosition = details.localPosition;
                              final clampedX = localPosition.dx.clamp(
                                0.0,
                                200.0,
                              );
                              final clampedY = localPosition.dy.clamp(
                                0.0,
                                200.0,
                              );
                              _drawingController.addPoint(
                                Offset(clampedX, clampedY),
                              );
                            });
                          },
                          onPanStart: (details) {
                            setState(() {
                              final localPosition = details.localPosition;
                              final clampedX = localPosition.dx.clamp(
                                0.0,
                                200.0,
                              );
                              final clampedY = localPosition.dy.clamp(
                                0.0,
                                200.0,
                              );
                              _drawingController.addPoint(
                                Offset(clampedX, clampedY),
                              );
                            });
                          },
                          onPanEnd: (_) {
                            setState(() {
                              _drawingController.endStroke();
                            });
                          },
                          child: CustomPaint(
                            size: const Size(200, 200),
                            painter: _DrawingPainter(_drawingController.paths),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _drawingController.clear();
                        });
                      },
                      child: const Text('지우기'),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  if (_nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('키 이름을 입력해주세요')),
                    );
                    return;
                  }
                  if (_selectedStatus == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('작업 상태 종류를 선택해주세요')),
                    );
                    return;
                  }

                  if (!_useText && _drawingController.paths.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('그림을 그리거나 텍스트를 입력해주세요')),
                    );
                    return;
                  }

                  if (_useText && _textController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('텍스트를 입력해주세요')),
                    );
                    return;
                  }

                  String svgData;
                  if (_useText) {
                    // 텍스트를 SVG로 변환
                    svgData = _textToSvg(_textController.text);
                  } else {
                    svgData = _drawingController.toSvg();
                  }

                  final definition = KeyDefinition(
                    id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
                    label: _nameController.text,
                    description: _descriptionController.text,
                    shape: KeyShape.custom,
                    svgData: svgData,
                  );

                  widget.bloc.add(BulletJournalEvent.addCustomKey(definition));

                  // 선택한 상태에 키 매핑
                  widget.bloc.add(
                    BulletJournalEvent.updateStatusKey(
                      status: _selectedStatus!,
                      keyId: definition.id,
                    ),
                  );

                  context.pop();
                },
                child: const Text('추가'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _textToSvg(String text) {
    // 텍스트를 SVG로 변환 (중앙 정렬)
    return '''
<svg width="24" height="24" xmlns="http://www.w3.org/2000/svg">
  <text x="12" y="18" font-family="Arial, sans-serif" font-size="16" text-anchor="middle" dominant-baseline="middle">$text</text>
</svg>
''';
  }
}

class _DrawingController {
  final List<List<Offset>> paths = [];

  void addPoint(Offset point) {
    if (paths.isEmpty) {
      paths.add([point]);
    } else {
      paths.last.add(point);
    }
  }

  void endStroke() {
    if (paths.isNotEmpty && paths.last.isNotEmpty) {
      paths.add([]);
    }
  }

  void clear() {
    paths.clear();
  }

  String toSvg() {
    if (paths.isEmpty) {
      return '<svg width="24" height="24" xmlns="http://www.w3.org/2000/svg"></svg>';
    }

    const sourceSize = 200.0;
    const targetSize = 24.0;
    const scale = targetSize / sourceSize;

    final buffer = StringBuffer(
      '<svg width="24" height="24" xmlns="http://www.w3.org/2000/svg">',
    );
    for (final path in paths) {
      if (path.length < 2) continue;
      buffer.write('<path d="M');
      for (var i = 0; i < path.length; i++) {
        if (i > 0) buffer.write(' L');
        final scaledX = (path[i].dx * scale).toStringAsFixed(2);
        final scaledY = (path[i].dy * scale).toStringAsFixed(2);
        buffer.write('$scaledX,$scaledY');
      }
      buffer.write(
        '" stroke="black" stroke-width="1.5" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
      );
    }
    buffer.write('</svg>');
    return buffer.toString();
  }
}

class _DrawingPainter extends CustomPainter {
  _DrawingPainter(this.paths);

  final List<List<Offset>> paths;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final path in paths) {
      if (path.length < 2) continue;
      final drawingPath = Path()..moveTo(path[0].dx, path[0].dy);
      for (var i = 1; i < path.length; i++) {
        drawingPath.lineTo(path[i].dx, path[i].dy);
      }
      canvas.drawPath(drawingPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AddStatusDialog extends StatefulWidget {
  const _AddStatusDialog({required this.bloc});

  final BulletJournalBloc bloc;

  @override
  State<_AddStatusDialog> createState() => _AddStatusDialogState();
}

class _AddStatusDialogState extends State<_AddStatusDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocBuilder<BulletJournalBloc, BulletJournalState>(
        builder: (context, state) {
          final maxOrder = state.taskStatuses.isEmpty
              ? 0
              : state.taskStatuses
                  .map((s) => s.order)
                  .reduce((a, b) => a > b ? a : b);
          return AlertDialog(
            title: const Text('작업 상태 추가'),
            content: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '상태 이름',
                hintText: '예: 검토 중, 보류',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  if (_nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('상태 이름을 입력해주세요')),
                    );
                    return;
                  }

                  final newStatus = TaskStatus(
                    id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
                    label: _nameController.text,
                    order: maxOrder + 1,
                  );

                  widget.bloc.add(BulletJournalEvent.addTaskStatus(newStatus));

                  context.pop();
                },
                child: const Text('추가'),
              ),
            ],
          );
        },
      ),
    );
  }
}
