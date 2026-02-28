import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:test_app_new/Quran_Section/data/LastPositionService.dart';
import 'package:test_app_new/Quran_Section/data/bookmark_service.dart';
import 'package:test_app_new/Quran_Section/data/note_service.dart';
import 'package:test_app_new/Quran_Section/data/quran_api_service.dart';
import 'package:test_app_new/Quran_Section/models/LastRead_model.dart';
import 'package:test_app_new/Quran_Section/models/bookmark_model.dart';
import 'package:test_app_new/Quran_Section/models/note_model.dart';
import 'package:test_app_new/Quran_Section/models/surah_model.dart';
import 'package:test_app_new/Quran_Section/views/mushaf_page_view_screen.dart';

class QuranIndexScreen extends StatefulWidget {
  const QuranIndexScreen({super.key});

  @override
  State<QuranIndexScreen> createState() => _QuranIndexScreenState();
}

class _QuranIndexScreenState extends State<QuranIndexScreen> {
  late Future<List<SurahModel>> surahsFuture;
  LastRead? _lastPosition;

  @override
  void initState() {
    super.initState();
    surahsFuture = QuranApiService().fetchSurahs();
    _loadLastPosition();
  }

  Future<void> _loadLastPosition() async {
    final lastPos = await LastPositionService.getLastPosition();
    if (mounted) {
      setState(() {
        _lastPosition = lastPos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // ✅ تغيير من 2 لـ 4
      child: Scaffold(
        appBar: AppBar(
          title: const Text("القرآن الكريم"),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true, // ✅ عشان التابات تكون scrollable
            tabs: [
              Tab(text: "الفهرس"),
              Tab(text: "المفضلة"),
              Tab(text: "الإشارات"),
              Tab(text: "الملاحظات"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSurahsList(),
            _buildFavoritesList(),
            _buildBookmarksList(), // ✅ جديد
            _buildNotesList(), // ✅ جديد
          ],
        ),
      ),
    );
  }

  Widget _buildSurahsList() {
    return FutureBuilder<List<SurahModel>>(
      future: surahsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "حدث خطأ أثناء تحميل السور:\n${snapshot.error}",
              textAlign: TextAlign.center,
            ),
          );
        }

        final surahs = snapshot.data ?? [];
        if (surahs.isEmpty) {
          return const Center(child: Text("لا توجد سور للعرض"));
        }

        return Column(
          children: [
            if (_lastPosition != null)
              Builder(
                builder: (context) {
                  final surahNumber = _lastPosition!.surahNumber;

                  final surah = surahs.firstWhere(
                    (s) => s.number == surahNumber,
                    orElse: () => surahs.first,
                  );

                  return Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.brown.shade300, Colors.brown.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MushafPageViewScreen(
                                surahNumber: surahNumber,
                                restoreLastPosition: true,
                                onPositionSaved:
                                    _loadLastPosition, // ✅ Callback
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.arrow_back, color: Colors.white),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    "متابعة القراءة",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    surah.name,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.bookmark,
                                color: Colors.white,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            Expanded(
              child: ListView.builder(
                itemCount: surahs.length,
                itemBuilder: (context, index) {
                  final surah = surahs[index];

                  return ListTile(
                    leading: CircleAvatar(child: Text("${surah.number}")),
                    title: Text(surah.name, textDirection: TextDirection.rtl),
                    subtitle: Text(
                      "${surah.numberOfAyahs} آية - ${surah.revelationType}",
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MushafPageViewScreen(
                            surahNumber: surah.number,
                            onPositionSaved: _loadLastPosition, // ✅ Callback
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFavoritesList() {
    final box = Hive.box('favoritesBox');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box box, _) {
        if (box.isEmpty) {
          return const Center(child: Text("لا يوجد آيات مفضلة"));
        }

        return ListView.builder(
          itemCount: box.length,
          itemBuilder: (context, index) {
            final key = box.keyAt(index);
            final ayah = box.get(key);

            return Dismissible(
              key: Key(key.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                box.delete(key);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم حذف الآية من المفضلة")),
                );
              },
              child: Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(
                    "${ayah['text']} ﴿${ayah['ayahNumber']}﴾",
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MushafPageViewScreen(
                          surahNumber: ayah['surahNumber'],
                          highlightAyahNumber: ayah['ayahNumber'],
                          onPositionSaved: _loadLastPosition, // ✅ Callback
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // إضافة في QuranIndexScreen

  Widget _buildBookmarksList() {
    return FutureBuilder<List<BookmarkModel>>(
      future: BookmarkService.getAllBookmarks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("لا توجد إشارات مرجعية"));
        }

        final bookmarks = snapshot.data!;

        return ListView.builder(
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = bookmarks[index];

            return Dismissible(
              key: Key(bookmark.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) async {
                await BookmarkService.deleteBookmark(bookmark.id);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم حذف الإشارة المرجعية")),
                );
              },
              child: Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  leading: const Icon(Icons.bookmark, color: Colors.brown),
                  title: Text(
                    "${bookmark.ayahText} ﴿${bookmark.ayahNumber}﴾",
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "تم الإضافة: ${_formatDate(bookmark.createdAt)}",
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MushafPageViewScreen(
                          surahNumber: bookmark.surahNumber,
                          highlightAyahNumber: bookmark.ayahNumber,
                          onPositionSaved: _loadLastPosition,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotesList() {
    return FutureBuilder<List<NoteModel>>(
      future: NoteService.getAllNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("لا توجد ملاحظات"));
        }

        final notes = snapshot.data!;

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];

            return Card(
              margin: const EdgeInsets.all(12),
              child: ExpansionTile(
                leading: const Icon(Icons.note, color: Colors.brown),
                title: Text(
                  "${note.ayahText.substring(0, note.ayahText.length > 50 ? 50 : note.ayahText.length)}... ﴿${note.ayahNumber}﴾",
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                subtitle: Text(
                  note.updatedAt != null
                      ? "آخر تحديث: ${_formatDate(note.updatedAt!)}"
                      : "تم الإضافة: ${_formatDate(note.createdAt)}",
                  textAlign: TextAlign.right,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          note.noteText,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                await NoteService.deleteNote(note.id);
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("تم حذف الملاحظة"),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text("حذف"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MushafPageViewScreen(
                                      surahNumber: note.surahNumber,
                                      highlightAyahNumber: note.ayahNumber,
                                      onPositionSaved: _loadLastPosition,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.arrow_back),
                              label: const Text("الذهاب للآية"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // دالة مساعدة لتنسيق التاريخ
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
