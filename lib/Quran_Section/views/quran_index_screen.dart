import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:test_app_new/core/settings/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class QuranIndexScreen extends StatefulWidget {
  const QuranIndexScreen({super.key});

  @override
  State<QuranIndexScreen> createState() => _QuranIndexScreenState();
}

class _QuranIndexScreenState extends State<QuranIndexScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<SurahModel>> surahsFuture;
  LastRead? _lastPosition;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // ── FIX 1: separate the full list from the filtered view ──────────
  List<SurahModel> _allSurahs = [];
  List<SurahModel> _filteredSurahs = [];
  bool _isSearching = false; // true only while query is non-empty
  // ─────────────────────────────────────────────────────────────────

  final List<String> _tabs = [
    'السور',
    'الأجزاء',
    'المفضلة',
    'الإشارات',
    'الملاحظات',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _checkConnectionAndFetch();
    _loadLastPosition();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectionAndFetch() async {
    try {
      setState(() {
        surahsFuture = QuranApiService().fetchSurahs();
      });
      final surahs = await surahsFuture;
      if (mounted) {
        setState(() {
          _allSurahs = surahs;
          _filteredSurahs = surahs; // initialise filtered = all
        });
      }
    } catch (e) {
      setState(() {
        surahsFuture = Future.error('حدث خطأ في الاتصال');
      });
    }
  }

  Future<void> _loadLastPosition() async {
    final lastPos = await LastPositionService.getLastPosition();
    if (mounted) {
      setState(() {
        _lastPosition = lastPos;
      });
    }
  }

  /// Strip Arabic diacritics so search works without tashkeel
  String _stripDiacritics(String text) {
    return text.replaceAll(
      RegExp(
        r'[\u064B-\u065F\u0610-\u061A\u06D6-\u06DC\u06DF-\u06E4\u06E7\u06E8\u06EA-\u06ED]',
      ),
      '',
    );
  }

  // ── FIX 1: correct filter logic ───────────────────────────────────
  void _filterSurahs(String query) {
    final trimmed = query.trim();
    setState(() {
      if (trimmed.isEmpty) {
        // No query → show everything, leave search mode
        _isSearching = false;
        _filteredSurahs = _allSurahs;
      } else {
        _isSearching = true;
        final q = _stripDiacritics(trimmed.toLowerCase());
        _filteredSurahs = _allSurahs.where((s) {
          final nameClean = _stripDiacritics(s.name).toLowerCase();
          final engClean = s.englishName.toLowerCase();
          // Also strip diacritics from the english transliteration field
          final engTransClean = _stripDiacritics(s.englishName).toLowerCase();
          return nameClean.contains(q) ||
              engClean.contains(q) ||
              engTransClean.contains(q) ||
              s.number.toString() == trimmed;
        }).toList();
      }
    });
  }
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isDark = settings.isDarkMode;
        return Scaffold(
          backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                _buildLastReadBanner(isDark), // FIX 2 below
                _buildSearchBar(isDark),
                _buildTabBar(isDark),
                Expanded(child: _buildTabBarView(isDark)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        'القرآن الكريم',
        style: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textLight : AppColors.textPrimary,
        ),
      ),
    );
  }

  // ── FIX 2: resolve surah name dynamically from _allSurahs ─────────
  Widget _buildLastReadBanner(bool isDark) {
    if (_lastPosition == null) return const SizedBox.shrink();

    // Resolve surah name from the already-loaded list.
    // Falls back to a generic label if list isn't loaded yet.
    final surahNum = _lastPosition!.surahNumber;
    String surahName = 'السورة $surahNum';
    if (_allSurahs.isNotEmpty) {
      final match = _allSurahs.where((s) => s.number == surahNum);
      if (match.isNotEmpty) surahName = match.first.name;
    }

    // ayah number: we stored pageIndex, display it as a human label
    final pageLabel = 'صفحة ${_lastPosition!.pageIndex + 1}';

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MushafPageViewScreen(
              surahNumber: surahNum,
              restoreLastPosition: true, // ← tells screen to jump
              onPositionSaved: _loadLastPosition,
            ),
          ),
        );
        // Refresh banner after returning
        _loadLastPosition();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  pageLabel,
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'متابعة القراءة',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  surahName,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
            const Icon(Icons.bookmark, color: Color(0xFFF5A623), size: 22),
          ],
        ),
      ),
    );
  }
  // ─────────────────────────────────────────────────────────────────

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterSurahs,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: isDark ? AppColors.textLight : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'ابحث عن سورة...',
            hintTextDirection: TextDirection.rtl,
            hintStyle: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textMuted,
              size: 20,
            ),
            // Show clear button when typing
            suffixIcon: _isSearching
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _filterSurahs('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelStyle: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 13),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  Widget _buildTabBarView(bool isDark) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSurahsList(isDark),
        _buildEmptyState(
          isDark,
          'الأجزاء',
          'ستظهر هنا الأجزاء التي تضيفها أثناء القراءة.',
        ),
        _buildFavoritesList(isDark),
        _buildBookmarksList(isDark),
        _buildNotesList(isDark),
      ],
    );
  }

  // ── FIX 1 (cont.): use _filteredSurahs directly ───────────────────
  Widget _buildSurahsList(bool isDark) {
    // While data is still loading, show spinner
    if (_allSurahs.isEmpty) {
      return FutureBuilder<List<SurahModel>>(
        future: surahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return _buildErrorState(isDark);
          }
          // Data arrived — will be reflected via setState in
          // _checkConnectionAndFetch, trigger a rebuild
          return const SizedBox.shrink();
        },
      );
    }

    // ── KEY FIX: use _filteredSurahs which is always correct ──────
    final surahs = _filteredSurahs;

    if (surahs.isEmpty && _isSearching) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'لا توجد نتائج لـ "${_searchController.text}"',
              style: GoogleFonts.cairo(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: surahs.length,
      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.4),
      itemBuilder: (context, index) => _buildSurahTile(surahs[index], isDark),
    );
  }
  // ─────────────────────────────────────────────────────────────────

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'تعذر الاتصال',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تأكد من اتصالك بالإنترنت',
            style: GoogleFonts.cairo(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _checkConnectionAndFetch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahTile(SurahModel surah, bool isDark) {
    final isLastRead = _lastPosition?.surahNumber == surah.number;
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MushafPageViewScreen(
              surahNumber: surah.number,
              onPositionSaved: _loadLastPosition,
            ),
          ),
        );
        _loadLastPosition();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.englishName,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${surah.numberOfAyahs} آية • '
                    '${surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية'}',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isLastRead)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  'آخر قراءة',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  surah.name,
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
            const SizedBox(width: 12),
            _buildSurahNumber(surah.number, isDark, isLastRead),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahNumber(int number, bool isDark, bool isLastRead) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isLastRead ? AppColors.primary.withValues(alpha: 0.12) : null,
        border: Border.all(
          color: isLastRead
              ? AppColors.primary
              : (isDark
                    ? AppColors.accent.withValues(alpha: 0.4)
                    : AppColors.primary.withValues(alpha: 0.3)),
          width: isLastRead ? 1.8 : 1.5,
        ),
      ),
      child: Center(
        child: Text(
          '$number',
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.accent : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgCardDark : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_border,
              size: 28,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد عناصر بعد',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(bool isDark) {
    final box = Hive.box('favoritesBox');
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box box, _) {
        if (box.isEmpty) {
          return _buildEmptyState(
            isDark,
            'المفضلة',
            'ستظهر هنا المفضلة التي تضيفها\nأثناء القراءة.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
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
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                box.delete(key);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم حذف الآية من المفضلة',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: _buildAyahCard(
                text: "${ayah['text']} ﴿${ayah['ayahNumber']}﴾",
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MushafPageViewScreen(
                      surahNumber: ayah['surahNumber'],
                      highlightAyahNumber: ayah['ayahNumber'],
                      onPositionSaved: _loadLastPosition,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookmarksList(bool isDark) {
    return FutureBuilder<List<BookmarkModel>>(
      future: BookmarkService.getAllBookmarks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
            isDark,
            'الإشارات',
            'ستظهر هنا الإشارات التي تضيفها\nأثناء القراءة.',
          );
        }
        final bookmarks = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = bookmarks[index];
            return Dismissible(
              key: Key(bookmark.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) async {
                await BookmarkService.deleteBookmark(bookmark.id);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم حذف الإشارة المرجعية',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: _buildAyahCard(
                text: "${bookmark.ayahText} ﴿${bookmark.ayahNumber}﴾",
                isDark: isDark,
                subtitle: 'تم الإضافة: ${_formatDate(bookmark.createdAt)}',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MushafPageViewScreen(
                      surahNumber: bookmark.surahNumber,
                      highlightAyahNumber: bookmark.ayahNumber,
                      onPositionSaved: _loadLastPosition,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotesList(bool isDark) {
    return FutureBuilder<List<NoteModel>>(
      future: NoteService.getAllNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
            isDark,
            'الملاحظات',
            'ستظهر هنا الملاحظات التي تضيفها\nأثناء القراءة.',
          );
        }
        final notes = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgCardDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ExpansionTile(
                title: Text(
                  "${note.ayahText.substring(0, note.ayahText.length > 50 ? 50 : note.ayahText.length)}... ﴿${note.ayahNumber}﴾",
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.cairo(fontSize: 13),
                ),
                subtitle: Text(
                  note.updatedAt != null
                      ? 'آخر تحديث: ${_formatDate(note.updatedAt!)}'
                      : 'تم الإضافة: ${_formatDate(note.createdAt)}',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
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
                          style: GoogleFonts.cairo(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                await NoteService.deleteNote(note.id);
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 16,
                              ),
                              label: Text(
                                'حذف',
                                style: GoogleFonts.cairo(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MushafPageViewScreen(
                                    surahNumber: note.surahNumber,
                                    highlightAyahNumber: note.ayahNumber,
                                    onPositionSaved: _loadLastPosition,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.arrow_back, size: 14),
                              label: Text(
                                'الذهاب للآية',
                                style: GoogleFonts.cairo(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
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

  Widget _buildAyahCard({
    required String text,
    required bool isDark,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(
                fontSize: 17,
                height: 1.8,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
