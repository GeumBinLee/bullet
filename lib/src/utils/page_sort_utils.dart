import '../models/diary_page.dart';

/// Utility class for sorting pages
class PageSortUtils {
  /// Sorts pages with index page always at the front.
  /// 인덱스 페이지를 항상 맨 앞에 두고, 나머지는 수동 순서(order)를 우선으로,
  /// order가 없으면 생성일 순(createdAt)으로 정렬한다.
  static List<DiaryPage> sortPages(List<DiaryPage> pages) {
    final sorted = [...pages];
    sorted.sort((a, b) {
      if (a.isIndexPage && !b.isIndexPage) return -1;
      if (!a.isIndexPage && b.isIndexPage) return 1;

      final orderA = a.order;
      final orderB = b.order;

      if (orderA != null && orderB != null && orderA != orderB) {
        return orderA.compareTo(orderB);
      } else if (orderA != null && orderB == null) {
        return -1;
      } else if (orderA == null && orderB != null) {
        return 1;
      }

      final createdAtComparison = a.createdAt.compareTo(b.createdAt);
      if (createdAtComparison != 0) {
        return createdAtComparison;
      }

      return a.id.compareTo(b.id);
    });
    return sorted;
  }
}

