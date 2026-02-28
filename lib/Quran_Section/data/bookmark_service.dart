import 'package:hive_flutter/adapters.dart';
import 'package:test_app_new/Quran_Section/models/bookmark_model.dart';

class BookmarkService {
  static const String _boxName = 'bookmarksBox';

  /// إضافة bookmark
  static Future<void> addBookmark(BookmarkModel bookmark) async {
    final box = await Hive.openBox(_boxName);
    await box.put(bookmark.id, bookmark.toJson());
  }

  /// حذف bookmark
  static Future<void> deleteBookmark(String id) async {
    final box = await Hive.openBox(_boxName);
    await box.delete(id);
  }

  /// التحقق من وجود bookmark
  static Future<bool> hasBookmark(int surahNumber, int ayahNumber) async {
    final box = await Hive.openBox(_boxName);
    final id = '${surahNumber}_$ayahNumber';
    return box.containsKey(id);
  }

  /// الحصول على كل الـ bookmarks
  static Future<List<BookmarkModel>> getAllBookmarks() async {
    final box = await Hive.openBox(_boxName);
    final bookmarks = <BookmarkModel>[];

    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        bookmarks.add(BookmarkModel.fromJson(Map<String, dynamic>.from(data)));
      }
    }

    // ترتيب حسب التاريخ (الأحدث أولاً)
    bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bookmarks;
  }
}
