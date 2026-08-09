import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:test_app_new/Quran_Section/data/LastPositionService.dart';
import 'package:test_app_new/Quran_Section/madani_mushaf/global_ayah_utils.dart';
import 'package:test_app_new/Quran_Section/models/LastRead_model.dart';
import 'package:test_app_new/Quran_Section/models/ayah_model.dart';
import 'package:test_app_new/Quran_Section/widgets/ayah_options_sheet.dart';
import 'package:test_app_new/core/settings/settings_cubit.dart';

const Color _kHeaderBg = Color(0xFF1A5C38);
const Color _kGold = Color(0xFFC5A028);

/// رقم الجزء لأول آية في الصفحة، محسوب من بيانات الباكيدج نفسها (pageData + getJuzNumber)
int _juzForPage(int page) {
  final firstEntry = (pageData[page - 1] as List).first as Map;
  return getJuzNumber(firstEntry['surah'] as int, firstEntry['start'] as int);
}

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
  late final PageController _controller;
  int _currentPage = 1; // رقم صفحة المصحف الفعلي (1-604)
  List<HighlightVerse> _highlights = [];

  @override
  void initState() {
    super.initState();

    final startPage = widget.restoreLastPosition
        ? null // هيتحدد في _restoreIfNeeded بعد الفريم الأول
        : getPageNumber(widget.surahNumber, widget.highlightAyahNumber ?? 1);

    _currentPage = startPage ?? 1;
    _controller = PageController(initialPage: (_currentPage - 1));

    if (widget.highlightAyahNumber != null) {
      _highlights = [
        HighlightVerse(
          surah: widget.surahNumber,
          verseNumber: widget.highlightAyahNumber!,
          page: _currentPage,
          color: Colors.amber.withValues(alpha: 0.4),
        ),
      ];
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _highlights = []);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreIfNeeded());
  }

  Future<void> _restoreIfNeeded() async {
    if (!widget.restoreLastPosition) return;
    final lastPos = await LastPositionService.getLastPosition();
    if (lastPos != null && mounted && _controller.hasClients) {
      // pageIndex بقى بيخزّن رقم صفحة المصحف المطلق (0-indexed) دلوقتي.
      _controller.jumpToPage(lastPos.pageIndex);
      setState(() => _currentPage = lastPos.pageIndex + 1);
    }
  }

  @override
  void dispose() {
    LastPositionService.saveLastPosition(
      LastRead(surahNumber: widget.surahNumber, pageIndex: _currentPage - 1),
    );
    widget.onPositionSaved?.call();
    _controller.dispose();
    super.dispose();
  }

  void _onAyahLongPress(
    int surahNumber,
    int verseNumber,
    LongPressStartDetails details,
  ) {
    setState(() {
      _highlights = [
        HighlightVerse(
          surah: surahNumber,
          verseNumber: verseNumber,
          page: _currentPage,
          color: Colors.amber.withValues(alpha: 0.35),
        ),
      ];
    });

    final ayah = AyahModel(
      number: globalAyahNumber(surahNumber, verseNumber),
      numberInSurah: verseNumber,
      text: getVerse(surahNumber, verseNumber),
      page: _currentPage,
    );

    showAyahOptionsSheet(context, ayah: ayah, surahNumber: surahNumber);
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
          body: SafeArea(
            child: QuranPageView(
              pageController: _controller,
              isDarkMode: isDark,
              isTajweed: true,
              highlights: _highlights,
              onLongPress: _onAyahLongPress,
              onPageChanged: (page) => setState(() => _currentPage = page),
              topBar: _buildPageInfoBar(isDark),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageInfoBar(bool isDark) {
    final juz = _juzForPage(_currentPage);
    final hizbText = getCurrentHizbTextForPage(_currentPage);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : _kHeaderBg).withValues(
                  alpha: 0.08,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: isDark ? Colors.white70 : _kHeaderBg,
                size: 14,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(color: _kGold.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'الجزء $juz',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? _kGold : _kHeaderBg,
              ),
            ),
          ),
          if (hizbText.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              hizbText,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? Colors.white54
                    : _kHeaderBg.withValues(alpha: 0.7),
              ),
            ),
          ],
          const Spacer(),
          Text(
            'صفحة $_currentPage',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : _kHeaderBg,
            ),
          ),
        ],
      ),
    );
  }
}
