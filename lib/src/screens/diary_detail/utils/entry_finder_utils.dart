import '../../../models/bullet_entry.dart';
import '../../../models/diary_section.dart';

/// Finds an entry by ID across all sections and unassigned entries.
BulletEntry? findEntryById(
  String entryId,
  List<DiarySection> sections,
  Map<String, List<BulletEntry>> entriesBySection,
  List<BulletEntry> unassignedEntries,
) {
  // 섹션 내 엔트리에서 찾기
  for (final section in sections) {
    final entries = entriesBySection[section.id] ?? [];
    try {
      final entry = entries.firstWhere((e) => e.id == entryId);
      return entry;
    } catch (e) {
      // 찾지 못함, 계속 진행
    }
  }
  // 섹션 없음 엔트리에서 찾기
  try {
    final unassignedEntry =
        unassignedEntries.firstWhere((e) => e.id == entryId);
    return unassignedEntry;
  } catch (e) {
    // 찾지 못함
  }
  return null;
}

