import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/diary.dart';
import '../../../models/diary_page.dart';
import '../../../models/bullet_entry.dart';
import '../../../utils/page_sort_utils.dart';
import '../../../utils/page_group_utils.dart';

/// 인덱스 페이지를 표시하는 위젯
/// 각 페이지의 요약 정보와 해당 페이지로 이동할 수 있는 버튼을 제공
class IndexPageView extends StatefulWidget {
  const IndexPageView({
    super.key,
    required this.diary,
    required this.diaryId,
    required this.state,
  });

  final Diary diary;
  final String diaryId;
  final BulletJournalState state;

  @override
  State<IndexPageView> createState() => _IndexPageViewState();
}

class _IndexPageViewState extends State<IndexPageView> {
  // 각 그룹의 펼침/접힘 상태 (기본값: false = 접힘)
  final Map<int, bool> _expandedGroups = {};

  @override
  Widget build(BuildContext context) {
    // 인덱스 페이지를 제외한 모든 페이지 가져오기
    final nonIndexPages = PageSortUtils.sortPages(
      widget.diary.pages.where((p) => !p.isIndexPage).toList(),
    );

    if (nonIndexPages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pages_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '페이지가 없습니다',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // 페이지를 그룹화
    final groups = PageGroupUtils.groupPages(nonIndexPages);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _buildGroupCard(context, group, index);
      },
    );
  }

  Widget _buildGroupCard(BuildContext context, PageGroup group, int groupIndex) {
    final isExpanded = _expandedGroups[groupIndex] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // 그룹 헤더 (클릭하면 펼치기/접기)
          InkWell(
            onTap: () {
              setState(() {
                _expandedGroups[groupIndex] = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      group.groupName ?? '제목 없음',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: group.groupName == null
                            ? Colors.grey.shade600
                            : null,
                        fontStyle: group.groupName == null
                            ? FontStyle.italic
                            : null,
                      ),
                    ),
                  ),
                  Text(
                    '${group.pages.length}개',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 그룹 내 페이지들 (펼쳐진 경우에만 표시)
          if (isExpanded)
            ...group.pages.map((page) => _buildPageCard(context, page)),
        ],
      ),
    );
  }

  Widget _buildPageCard(BuildContext context, DiaryPage page) {
    // 페이지의 엔트리 요약 정보 생성
    final entrySummary = _buildEntrySummary(page.entries);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          // 해당 페이지로 이동
          context.read<BulletJournalBloc>().add(
                BulletJournalEvent.setCurrentPageInDiary(
                  diaryId: widget.diaryId,
                  pageId: page.id,
                ),
              );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 페이지 이름 또는 제목 없음 표시
              Row(
                children: [
                  if (page.isFavorite)
                    Icon(
                      Icons.star,
                      size: 20,
                      color: Colors.amber.shade700,
                    ),
                  if (page.isFavorite) const SizedBox(width: 8),
                  Expanded(
                    child: page.name != null
                        ? Text(
                            page.name!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : Text(
                            '제목 없음',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      context.read<BulletJournalBloc>().add(
                            BulletJournalEvent.setCurrentPageInDiary(
                              diaryId: widget.diaryId,
                              pageId: page.id,
                            ),
                          );
                    },
                    tooltip: '페이지로 이동',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 엔트리 요약 정보
              if (entrySummary.isNotEmpty) ...[
                ...entrySummary,
                const SizedBox(height: 8),
              ],
              // 엔트리 개수 정보
              Text(
                '엔트리 ${page.entries.length}개',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 엔트리 요약 정보를 생성 (최대 3개까지 표시)
  List<Widget> _buildEntrySummary(List<BulletEntry> entries) {
    if (entries.isEmpty) {
      return [
        Text(
          '엔트리가 없습니다',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
      ];
    }

    // 최대 3개까지만 표시
    final displayEntries = entries.take(3).toList();
    final remainingCount = entries.length - displayEntries.length;

    return [
      ...displayEntries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              // 키 아이콘 또는 텍스트
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                child: Text(
                  _getEntryKeySymbol(entry),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.focus,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }),
      if (remainingCount > 0)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '외 $remainingCount개 더...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
    ];
  }

  /// 엔트리의 키 상태에 따른 심볼 반환
  String _getEntryKeySymbol(BulletEntry entry) {
    // keyStatus는 TaskStatus 타입이므로 id로 확인
    final statusId = entry.keyStatus.id;
    if (statusId == 'planned') return '•';
    if (statusId == 'inProgress') return '→';
    if (statusId == 'completed') return '✓';
    if (statusId == 'memo') return '-';
    if (statusId == 'etc') return '○';
    return '•'; // 기본값
  }
}

