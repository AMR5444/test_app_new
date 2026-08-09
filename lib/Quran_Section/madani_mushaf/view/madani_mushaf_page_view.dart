import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/Quran_Section/data/LastPositionService.dart';
import 'package:test_app_new/Quran_Section/data/quran_api_service.dart';
import 'package:test_app_new/Quran_Section/madani_mushaf/data/mushaf_layout_service.dart';
import 'package:test_app_new/Quran_Section/madani_mushaf/models/mushaf_page_layout_model.dart';
import 'package:test_app_new/Quran_Section/madani_mushaf/widgets/ayah_options_sheet.dart';
import 'package:test_app_new/Quran_Section/models/LastRead_model.dart';
import 'package:test_app_new/Quran_Section/models/ayah_model.dart';
import 'package:test_app_new/Quran_Section/models/surah_model.dart';
import 'package:test_app_new/core/settings/settings_cubit.dart';

const Color _kPageBg = Color(0xFFFDF8EE);
const Color _kPageBorder = Color(0xFFD4B896);
const Color _kHeaderBg = Color(0xFF1A5C38);
const Color _kGold = Color(0xFFC5A028);
const Color _kTextDark = Color(0xFF1A1A1A);
const Color _kDividerColor = Color(0xFFD4B896);

class MadaniMushafPageView extends StatefulWidget {
  final int surahNumber;
  final int? highlightAyahNumber;
  final bool restoreLastPosition;
  final Function()? onPositionSaved;

  const MadaniMushafPageView({
    super.key,
    required this.surahNumber,
    this.highlightAyahNumber,
    this.restoreLastPosition = false,
    this.onPositionSaved,
  });

  @override
  State<MadaniMushafPageView> createState() => _MadaniMushafPageViewState();
}

class _MadaniMushafPageViewState extends State<MadaniMushafPageView> {
  final PageController _controller = PageController();
  final QuranApiService _api = QuranApiService();
  final MushafLayoutService _layoutService = MushafLayoutService();

  late Future<_SurahData> _dataFuture;
  int? _highlightedAyah;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _highlightedAyah = widget.highlightAyahNumber;
    _dataFuture = _loadData();

    if (_highlightedAyah != null) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _highlightedAyah = null);
      });
    }
  }

  Future<_SurahData> _loadData() async {
    final results = await Future.wait([
      _api.fetchSurah(widget.surahNumber),
      _api.fetchSurahs(),
    ]);
    final ayahs = results[0] as List<AyahModel>;
    final surahs = results[1] as List<SurahModel>;

    final surah = surahs.firstWhere(
      (s) => s.number == widget.surahNumber,
      orElse: () => SurahModel(
        number: widget.surahNumber,
        name: 'السورة',
        englishName: '',
        numberOfAyahs: ayahs.length,
        revelationType: '',
      ),
    );

    final Map<int, List<AyahModel>> grouped = {};
    for (var ayah in ayahs) {
      grouped.putIfAbsent(ayah.page, () => []).add(ayah);
    }
    final absolutePages = grouped.keys.toList()..sort();

    return _SurahData(
      surah: surah,
      absolutePages: absolutePages,
      ayahsByPage: grouped,
    );
  }

  void _restorePosition(_SurahData data) async {
    if (!widget.restoreLastPosition) return;
    final lastPos = await LastPositionService.getLastPosition();
    if (lastPos != null &&
        lastPos.surahNumber == widget.surahNumber &&
        mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) {
          _controller.jumpToPage(lastPos.pageIndex);
          _currentPageIndex = lastPos.pageIndex;
        }
      });
    }
  }

  void _jumpToHighlightPage(_SurahData data) {
    if (widget.highlightAyahNumber == null || widget.restoreLastPosition)
      return;
    for (int i = 0; i < data.absolutePages.length; i++) {
      final ayahs = data.ayahsByPage[data.absolutePages[i]]!;
      if (ayahs.any((a) => a.numberInSurah == widget.highlightAyahNumber)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _controller.hasClients) _controller.jumpToPage(i);
        });
        break;
      }
    }
  }

  @override
  void dispose() {
    _savePosition();
    _controller.dispose();
    super.dispose();
  }

  void _savePosition() async {
    await LastPositionService.saveLastPosition(
      LastRead(surahNumber: widget.surahNumber, pageIndex: _currentPageIndex),
    );
    widget.onPositionSaved?.call();
  }

  void _onWordTap(int ayahNumberInSurah) {
    setState(() {
      _highlightedAyah = _highlightedAyah == ayahNumberInSurah
          ? null
          : ayahNumberInSurah;
    });
  }

  void _onWordLongPress(
    _SurahData data,
    int absolutePage,
    int ayahNumberInSurah,
  ) {
    final ayah = data.ayahsByPage[absolutePage]!.firstWhere(
      (a) => a.numberInSurah == ayahNumberInSurah,
    );
    showAyahOptionsSheet(context, ayah: ayah, surahNumber: widget.surahNumber);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isDark = settings.isDarkMode;
        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF0D1F16)
              : const Color(0xFFEDE8DC),
          body: FutureBuilder<_SurahData>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: _kHeaderBg),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text('حدث خطأ: ${snapshot.error}'));
              }

              final data = snapshot.data!;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _restorePosition(data);
                _jumpToHighlightPage(data);
              });

              return Column(
                children: [
                  _buildAppBar(data.surah, isDark),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      reverse: true,
                      itemCount: data.absolutePages.length,
                      onPageChanged: (i) =>
                          setState(() => _currentPageIndex = i),
                      itemBuilder: (context, index) => _buildMushafPage(
                        data,
                        data.absolutePages[index],
                        index,
                        isDark,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAppBar(SurahModel surah, bool isDark) {
    return Container(
      color: _kHeaderBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _normalizeSurahName(surah.name),
                style: GoogleFonts.amiri(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMushafPage(
    _SurahData data,
    int absolutePage,
    int pageIndex,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2B20) : _kPageBg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: _kPageBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildPageHeader(absolutePage, data.surah, isDark),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: FutureBuilder<MushafPageLayoutModel>(
                  future: _layoutService.fetchPage(absolutePage),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: _kHeaderBg),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'تعذر تحميل الصفحة:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    final layout = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        children: layout.lines
                            .map(
                              (line) =>
                                  _buildLine(data, absolutePage, line, isDark),
                            )
                            .toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
            _buildPageFooter(pageIndex, data.absolutePages.length, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLine(
    _SurahData data,
    int absolutePage,
    MushafLineModel line,
    bool isDark,
  ) {
    switch (line.type) {
      case 'surah-header':
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: _kGold.withValues(alpha: 0.5)),
            ),
          ),
          child: Text(
            line.surahHeaderText ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _kHeaderBg,
            ),
          ),
        );

      case 'basmala':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            kBasmalaText,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 19,
              color: isDark ? Colors.white : _kTextDark,
            ),
          ),
        );

      default: // text
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              alignment: WrapAlignment.center,
              children: line.words.map((word) {
                final isHL = word.ayahNumberInSurah == _highlightedAyah;
                return GestureDetector(
                  onTap: () => _onWordTap(word.ayahNumberInSurah),
                  onLongPress: () => _onWordLongPress(
                    data,
                    absolutePage,
                    word.ayahNumberInSurah,
                  ),
                  child: Container(
                    decoration: isHL
                        ? BoxDecoration(
                            color: Colors.yellow.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(3),
                          )
                        : null,
                    child: Text(
                      '${word.text} ',
                      style: GoogleFonts.amiri(
                        fontSize: 19,
                        height: 2.1,
                        color: isDark ? Colors.white : _kTextDark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
    }
  }

  Widget _buildPageHeader(int pageNumber, SurahModel surah, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _kDividerColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'الجزء ${_getJuzNumber(pageNumber)}',
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: isDark ? Colors.white54 : _kHeaderBg,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: _kGold.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$pageNumber',
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: _kGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            _normalizeSurahName(surah.name),
            style: GoogleFonts.amiri(
              fontSize: 13,
              color: isDark ? Colors.white70 : _kHeaderBg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageFooter(int pageIndex, int totalPages, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _kDividerColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages > 7 ? 7 : totalPages, (i) {
          final mid = totalPages > 7 ? 3 : pageIndex;
          final displayIndex = totalPages > 7
              ? (pageIndex - mid + i).clamp(0, totalPages - 1)
              : i;
          final isCurrent = displayIndex == pageIndex;
          return Container(
            width: isCurrent ? 16 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isCurrent
                  ? _kHeaderBg
                  : (isDark ? Colors.white24 : _kDividerColor),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  int _getJuzNumber(int page) => ((page - 1) ~/ 20 + 1).clamp(1, 30);
}

class _SurahData {
  final SurahModel surah;
  final List<int> absolutePages; // أرقام صفحات المصحف الفعلية (1-604)
  final Map<int, List<AyahModel>> ayahsByPage;
  _SurahData({
    required this.surah,
    required this.absolutePages,
    required this.ayahsByPage,
  });
}

String _normalizeSurahName(String name) {
  final trimmed = name.trim();
  return trimmed.startsWith('سورة')
      ? trimmed.replaceFirst(RegExp(r'^سورة\s*'), '').trim()
      : trimmed;
}
