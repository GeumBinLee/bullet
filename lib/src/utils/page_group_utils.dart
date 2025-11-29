import '../models/diary_page.dart';
import 'page_sort_utils.dart';

/// 페이지 그룹 정보
class PageGroup {
  final String? groupName; // 그룹 이름 (null이면 이름 없는 그룹)
  final List<DiaryPage> pages; // 그룹에 속한 페이지들

  PageGroup({
    required this.groupName,
    required this.pages,
  });
}

/// Utility class for grouping pages by name
class PageGroupUtils {
  /// 페이지를 이름별로 그룹화
  /// 이름이 설정된 페이지가 나타나기 전까지의 모든 페이지들을 그 그룹에 귀속
  /// 
  /// 예시:
  /// - 페이지1 (이름 없음)
  /// - 페이지2 (이름 없음)
  /// - 페이지3 (이름: "1월")
  /// - 페이지4 (이름 없음)
  /// - 페이지5 (이름: "2월")
  /// 
  /// 결과:
  /// - "1월" 그룹: [페이지1, 페이지2, 페이지3]
  /// - "2월" 그룹: [페이지4, 페이지5]
  static List<PageGroup> groupPages(List<DiaryPage> pages) {
    if (pages.isEmpty) return [];

    final groups = <PageGroup>[];
    final sortedPages = PageSortUtils.sortPages(pages);
    
    String? currentGroupName;
    final currentGroupPages = <DiaryPage>[];

    for (final page in sortedPages) {
      if (page.name != null && page.name!.trim().isNotEmpty) {
        // 이름이 있는 페이지를 만남
        // 이전에 그룹이 있었다면 저장
        if (currentGroupName != null && currentGroupPages.isNotEmpty) {
          groups.add(PageGroup(
            groupName: currentGroupName,
            pages: List.from(currentGroupPages),
          ));
          currentGroupPages.clear();
        }
        
        // 이름이 있는 페이지를 현재 그룹에 추가
        // (이전의 이름 없는 페이지들도 포함)
        currentGroupPages.add(page);
        
        // 새로운 그룹 시작 (이름 있는 페이지 포함)
        currentGroupName = page.name;
      } else {
        // 이름이 없는 페이지
        // 현재 그룹에 추가 (이름이 있는 페이지가 나타날 때까지 대기)
        currentGroupPages.add(page);
      }
    }

    // 마지막 그룹 추가
    if (currentGroupPages.isNotEmpty) {
      groups.add(PageGroup(
        groupName: currentGroupName,
        pages: currentGroupPages,
      ));
    }

    return groups;
  }
}

