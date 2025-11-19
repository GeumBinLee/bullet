import '../../../models/bullet_entry.dart';
import 'entry_sort_type.dart';

/// Utility class for sorting entries
class EntrySortUtils {
  /// Sorts entries based on the specified sort type
  static List<BulletEntry> sortEntries(
    List<BulletEntry> entries,
    EntrySortType sortType,
    List<BulletEntry> manualOrder,
  ) {
    if (sortType == EntrySortType.manual) {
      if (manualOrder.isEmpty || manualOrder.length != entries.length) {
        return entries;
      }
      // 수동 정렬 순서에 맞춰 정렬 (존재하는 엔트리만, 최신 상태 사용)
      final entriesMap = {for (final entry in entries) entry.id: entry};
      final manualOrderIds = manualOrder.map((e) => e.id).toSet();
      final orderedEntries = <BulletEntry>[];

      // 수동 순서대로 추가 (최신 엔트리 상태 사용)
      for (final manualEntry in manualOrder) {
        final latestEntry = entriesMap[manualEntry.id];
        if (latestEntry != null) {
          orderedEntries.add(latestEntry);
        }
      }

      // 수동 순서에 없는 새로운 엔트리들을 뒤에 추가
      for (final entry in entries) {
        if (!manualOrderIds.contains(entry.id)) {
          orderedEntries.add(entry);
        }
      }

      return orderedEntries;
    }

    final sorted = [...entries];
    switch (sortType) {
      case EntrySortType.dateAscending:
        sorted.sort((a, b) => a.date.compareTo(b.date));
        break;
      case EntrySortType.dateDescending:
        sorted.sort((a, b) => b.date.compareTo(a.date));
        break;
      case EntrySortType.byKey:
        sorted.sort((a, b) {
          final orderA = a.keyStatus.order;
          final orderB = b.keyStatus.order;
          if (orderA != orderB) {
            return orderA.compareTo(orderB);
          }
          // 같은 키일 경우 날짜 내림차순으로 정렬
          return b.date.compareTo(a.date);
        });
        break;
      case EntrySortType.manual:
        // 이미 위에서 처리됨
        break;
    }
    return sorted;
  }
}

