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

// إجمالي صفحات المصحف الفعلية (المصحف المدني القياسي 604 صفحة)
const int _kTotalMushafPages = 604;

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
  PageController? _controller;
  final QuranApiService _api = QuranApiService();
  final MushafLayoutService _layoutService = MushafLayoutService();

  // كاش خفيف لآيات كل سورة تم فتحها فعلاً (مطلوبة لعرض التفسير/الخيارات)
  // بيتملى عند الحاجة بس، مش كل الـ 114 سورة مقدمًا.
  final Map<int, List<AyahModel>> _ayahsCache = {};
  List<SurahModel>? _surahsList;

  String? _initError;
  String? _highlightedKey; // "surahNumber:ayahNumberInSurah"
  int _currentAbsolutePage = 1; // 1..604
  int _currentSurahNumber = 1;

  @override
  void initState() {
    super.initState();
    _currentSurahNumber = widget.surahNumber;
    if (widget.highlightAyahNumber != null) {
      _highlightedKey = '${widget.surahNumber}:${widget.highlightAyahNumber}';
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _highlightedKey = null);
      });
    }
    _init();
    _api
        .fetchSurahs()
        .then((s) {
          if (mounted) setState(() => _surahsList = s);
        })
        .catchError((_) {});
  }

  Future<void> _init() async {
    try {
      final page = await _resolveInitialPage();
      if (!mounted) return;
      setState(() {
        _currentAbsolutePage = page;
        _controller = PageController(initialPage: page - 1);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _initError = e.toString());
    }
  }

  Future<List<AyahModel>> _ayahsForSurah(int surahNumber) async {
    final cached = _ayahsCache[surahNumber];
    if (cached != null) return cached;
    final ayahs = await _api.fetchSurah(surahNumber);
    _ayahsCache[surahNumber] = ayahs;
    return ayahs;
  }

  Future<int> _resolveInitialPage() async {
    if (widget.restoreLastPosition) {
      final lastPos = await LastPositionService.getLastPosition();
      if (lastPos != null &&
          lastPos.pageIndex >= 1 &&
          lastPos.pageIndex <= _kTotalMushafPages) {
        _currentSurahNumber = lastPos.surahNumber;
        return lastPos.pageIndex;
      }
    }

    final ayahs = await _ayahsForSurah(widget.surahNumber);
    if (ayahs.isEmpty) return 1;

    if (widget.highlightAyahNumber != null) {
      final match = ayahs.where(
        (a) => a.numberInSurah == widget.highlightAyahNumber,
      );
      if (match.isNotEmpty) return match.first.page;
    }

    final pages = ayahs.map((a) => a.page).toList()..sort();
    return pages.first;
  }

  @override
  void dispose() {
    _savePosition();
    _controller?.dispose();
    super.dispose();
  }

  void _savePosition() async {
    await LastPositionService.saveLastPosition(
      LastRead(
        surahNumber: _currentSurahNumber,
        pageIndex: _currentAbsolutePage,
      ),
    );
    widget.onPositionSaved?.call();
  }

  void _onWordTap(int surahNumber, int ayahNumberInSurah) {
    final key = '$surahNumber:$ayahNumberInSurah';
    setState(() {
      _highlightedKey = _highlightedKey == key ? null : key;
    });
  }

  void _onWordLongPress(int surahNumber, int ayahNumberInSurah) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    AyahModel? ayah;
    try {
      final ayahs = await _ayahsForSurah(surahNumber);
      final match = ayahs.where((a) => a.numberInSurah == ayahNumberInSurah);
      if (match.isNotEmpty) ayah = match.first;
    } catch (_) {
      // هيتعامل معاه تحت كـ null
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // اقفل اللودينج

    if (ayah == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تحديد الآية، حاول مرة أخرى')),
      );
      return;
    }

    showAyahOptionsSheet(context, ayah: ayah, surahNumber: surahNumber);
  }

  // بيتسجل أول سورة تظهر في الصفحة (من أول كلمة/سطر) عشان نعرض اسمها في
  // الهيدر والفوتر صح حتى لو الصفحة فيها آخر سورة وأول سورة تانية.
  void _reportPageSurah(int absolutePage, int surahNumber) {
    if (absolutePage != _currentAbsolutePage) return;
    if (_currentSurahNumber == surahNumber) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _currentSurahNumber = surahNumber);
    });
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
          body: _initError != null
              ? Center(child: Text('حدث خطأ: $_initError'))
              : (_controller == null
                    ? const Center(
                        child: CircularProgressIndicator(color: _kHeaderBg),
                      )
                    : Column(
                        children: [
                          _buildAppBar(isDark),
                          Expanded(
                            child: PageView.builder(
                              controller: _controller,
                              reverse: true,
                              itemCount: _kTotalMushafPages,
                              onPageChanged: (i) =>
                                  setState(() => _currentAbsolutePage = i + 1),
                              itemBuilder: (context, index) =>
                                  _buildMushafPage(index + 1, isDark),
                            ),
                          ),
                        ],
                      )),
        );
      },
    );
  }

  Widget _buildAppBar(bool isDark) {
    final surahName = _surahsList
        ?.where((s) => s.number == _currentSurahNumber)
        .map((s) => s.name)
        .cast<String?>()
        ._firstOrNullSafe;

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
                _normalizeSurahName(surahName ?? 'المصحف الشريف'),
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

  Widget _buildMushafPage(int absolutePage, bool isDark) {
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
            _buildPageHeader(absolutePage, isDark),
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

                    // حدد سورة الصفحة من أول عنصر فيها (عنوان سورة لو موجود
                    // وإلا أول كلمة) عشان الهيدر يبقى صحيح حتى في صفحات
                    // الانتقال بين سورتين.
                    final headerLine = layout.lines
                        .where((l) => l.type == 'surah-header')
                        .toList();
                    int? pageSurah = headerLine.isNotEmpty
                        ? headerLine.first.surahHeaderNumber
                        : null;
                    if (pageSurah == null) {
                      for (final l in layout.lines) {
                        if (l.words.isNotEmpty) {
                          pageSurah = l.words.first.surahNumber;
                          break;
                        }
                      }
                    }
                    if (pageSurah != null) {
                      _reportPageSurah(absolutePage, pageSurah);
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: layout.lines
                            .map((line) => _buildLine(line, isDark))
                            .toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
            _buildPageFooter(absolutePage, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLine(MushafLineModel line, bool isDark) {
    switch (line.type) {
      case 'surah-header':
        // شريط عنوان السورة على شكل الإطار المزخرف في المصحف المطبوع
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16311F) : const Color(0xFFEFE6CE),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _kGold.withValues(alpha: 0.8),
              width: 1.4,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            line.surahHeaderText ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.amiriQuran(
              fontSize: 19,
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
            style: GoogleFonts.amiriQuran(
              fontSize: 20,
              color: isDark ? Colors.white : _kTextDark,
            ),
          ),
        );

      default: // text
        // كل "line" في بيانات المصحف بتمثل سطر واحد كامل زي المصحف
        // المطبوع فعليًا، فلازم يتعرض في صف واحد ممتد (justified) بدل
        // Wrap اللي كان بيلف الكلام على أكثر من سطر ويكسر شكل الصفحة.
        return LayoutBuilder(
          builder: (context, constraints) {
            final fontSize = _lineFontSize(constraints.maxWidth);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  mainAxisAlignment: line.words.length > 1
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: line.words.map((word) {
                    final key = '${word.surahNumber}:${word.ayahNumberInSurah}';
                    final isHL = key == _highlightedKey;
                    final parsed = _splitAyahMarker(word.text);
                    return GestureDetector(
                      onTap: () =>
                          _onWordTap(word.surahNumber, word.ayahNumberInSurah),
                      onLongPress: () => _onWordLongPress(
                        word.surahNumber,
                        word.ayahNumberInSurah,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: isHL
                            ? BoxDecoration(
                                color: Colors.yellow.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(3),
                              )
                            : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              parsed.wordText,
                              style: GoogleFonts.amiriQuran(
                                fontSize: fontSize,
                                height: 2.0,
                                color: isDark ? Colors.white : _kTextDark,
                              ),
                            ),
                            if (parsed.ayahMarker != null)
                              _AyahMarkerBadge(
                                digits: parsed.ayahMarker!,
                                fontSize: fontSize,
                                isDark: isDark,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
    }
  }

  // حجم خط ديناميكي بناءً على عرض الصفحة المتاح فعليًا (مش على حجم جهاز
  // ثابت)، عشان يتصرف صح على أي شاشة موبايل بدون تكسير أو overflow.
  double _lineFontSize(double lineWidth) {
    final size = lineWidth / 20;
    return size.clamp(13.0, 22.0);
  }

  // بيانات المصحف بتحط رقم الآية (بالأرقام العربية الهندية زي ١٢٣) ملزّق
  // في نهاية آخر كلمة في الآية (مثلاً "لِّلْمُتَّقِينَ ٢"). هنا بنفصله
  // عن الكلمة عشان نرسمه كعلامة آية دائرية مزخرفة بدل ما يفضل نص عادي.
  _ParsedWord _splitAyahMarker(String text) {
    final match = RegExp(r'^(.*?)[\s]*([٠-٩]+)$').firstMatch(text.trim());
    if (match == null) return _ParsedWord(text, null);
    final wordPart = match.group(1)!.trim();
    final digits = match.group(2)!;
    if (wordPart.isEmpty) {
      // الكلمة كلها رقم آية (نادر، بس للحماية)
      return _ParsedWord('', digits);
    }
    return _ParsedWord(wordPart, digits);
  }

  Widget _buildPageHeader(int pageNumber, bool isDark) {
    final surahName = _surahsList
        ?.where((s) => s.number == _currentSurahNumber)
        .map((s) => s.name)
        .cast<String?>()
        ._firstOrNullSafe;

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
            _normalizeSurahName(surahName ?? ''),
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

  Widget _buildPageFooter(int absolutePage, bool isDark) {
    final pageIndex = absolutePage - 1;
    const totalPages = _kTotalMushafPages;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _kDividerColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(7, (i) {
          const mid = 3;
          final displayIndex = (pageIndex - mid + i).clamp(0, totalPages - 1);
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

String _normalizeSurahName(String name) {
  final trimmed = name.trim();
  return trimmed.startsWith('سورة')
      ? trimmed.replaceFirst(RegExp(r'^سورة\s*'), '').trim()
      : trimmed;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get _firstOrNullSafe => isEmpty ? null : first;
}

class _ParsedWord {
  final String wordText;
  final String? ayahMarker; // أرقام عربية هندية زي "٢"
  _ParsedWord(this.wordText, this.ayahMarker);
}

// علامة نهاية الآية على شكل دائرة مزخرفة زي المصحف المطبوع، بدل ما رقم
// الآية يفضل ملزّق كنص عادي جوه الكلمة.
class _AyahMarkerBadge extends StatelessWidget {
  final String digits;
  final double fontSize;
  final bool isDark;

  const _AyahMarkerBadge({
    required this.digits,
    required this.fontSize,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final size = fontSize * 1.15;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _kGold.withValues(alpha: 0.9), width: 1.1),
          color: isDark ? const Color(0xFF16311F) : const Color(0xFFFBF3DD),
        ),
        child: Text(
          digits,
          textAlign: TextAlign.center,
          style: GoogleFonts.amiriQuran(
            fontSize: fontSize * 0.5,
            fontWeight: FontWeight.bold,
            color: _kGold,
            height: 1,
          ),
        ),
      ),
    );
  }
}
