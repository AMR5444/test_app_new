import 'package:hive_flutter/adapters.dart';
import 'package:test_app_new/Quran_Section/models/note_model.dart';

class NoteService {
  static const String _boxName = 'notesBox';

  /// إضافة note
  static Future<void> addNote(NoteModel note) async {
    final box = await Hive.openBox(_boxName);
    await box.put(note.id, note.toJson());
  }

  /// تحديث note
  static Future<void> updateNote(NoteModel note) async {
    final box = await Hive.openBox(_boxName);
    final updatedNote = NoteModel(
      id: note.id,
      surahNumber: note.surahNumber,
      ayahNumber: note.ayahNumber,
      ayahText: note.ayahText,
      noteText: note.noteText,
      createdAt: note.createdAt,
      updatedAt: DateTime.now(),
    );
    await box.put(updatedNote.id, updatedNote.toJson());
  }

  /// حذف note
  static Future<void> deleteNote(String id) async {
    final box = await Hive.openBox(_boxName);
    await box.delete(id);
  }

  /// الحصول على note لآية معينة
  static Future<NoteModel?> getNote(int surahNumber, int ayahNumber) async {
    final box = await Hive.openBox(_boxName);
    final id = '${surahNumber}_$ayahNumber';
    final data = box.get(id);

    if (data != null) {
      return NoteModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  /// الحصول على كل الـ notes
  static Future<List<NoteModel>> getAllNotes() async {
    final box = await Hive.openBox(_boxName);
    final notes = <NoteModel>[];

    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        notes.add(NoteModel.fromJson(Map<String, dynamic>.from(data)));
      }
    }

    // ترتيب حسب آخر تحديث (الأحدث أولاً)
    notes.sort((a, b) {
      final aDate = a.updatedAt ?? a.createdAt;
      final bDate = b.updatedAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
    return notes;
  }
}
