import '../models/diary_page.dart';

/// Utility class for sorting pages
class PageSortUtils {
  /// Sorts pages with index page always at the front
  /// 인덱스 페이지를 항상 맨 앞에 배치하고 나머지는 생성일 순으로 정렬
  static List<DiaryPage> sortPages(List<DiaryPage> pages) {
    final sorted = [...pages];
    sorted.sort((a, b) {
      // 인덱스 페이지는 항상 맨 앞
      if (a.isIndexPage && !b.isIndexPage) return -1;
      if (!a.isIndexPage && b.isIndexPage) return 1;
      // 둘 다 인덱스 페이지이거나 둘 다 아닌 경우 생성일 순으로 정렬
      return a.createdAt.compareTo(b.createdAt);
    });
    return sorted;
  }
}

