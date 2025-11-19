import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/diary.dart';
import '../../../utils/device_type.dart';
import 'diary_card.dart';
import '../dialogs/add_diary_dialog.dart';
import '../dialogs/password_dialog.dart';

class DiaryTab extends StatelessWidget {
  const DiaryTab({super.key});

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
                            onTap: () => AddDiaryDialog.show(context),
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
                      return DiaryCard(diary: diary);
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
                  return DiaryCard(diary: diary);
                }),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('다이어리 추가'),
                subtitle: const Text('새로운 다이어리 만들기'),
                onTap: () => AddDiaryDialog.show(context),
              ),
            ],
          );
        }
      },
    );
  }

  static void navigateToDiary(BuildContext context, Diary diary) {
    if (diary.password != null && diary.password!.isNotEmpty) {
      PasswordDialog.show(context, diary);
    } else {
      context.push('/diary/${diary.id}');
    }
  }
}

