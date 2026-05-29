import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:share_plus/share_plus.dart';
import 'package:test_app_new/Quran_Section/data/LastPositionService.dart';
import 'package:test_app_new/Quran_Section/data/audio_service.dart';
import 'package:test_app_new/Quran_Section/data/bookmark_service.dart';
import 'package:test_app_new/Quran_Section/data/quran_api_service.dart';
import 'package:test_app_new/Quran_Section/models/LastRead_model.dart';
import 'package:test_app_new/Quran_Section/models/ayah_model.dart';
import 'package:test_app_new/Quran_Section/models/bookmark_model.dart';
import 'package:test_app_new/Quran_Section/models/surah_model.dart';
import 'package:test_app_new/Quran_Section/widgets/ayah_widget.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:test_app_new/settings/app_settings_controller.dart';

class MushafPageViewScreen extends StatefulWidget {
  final int surahNumber;
  final String? surahName;
  final int? highlightAyahNumber;
  final bool restoreLastPosition;
  final Function()? onPositionSaved; // ✅ Callback للتحديث

  const MushafPageViewScreen({
    super.key,
    required this.surahNumber,
    this.surahName,
    this.highlightAyahNumber,
    this.restoreLastPosition = false,
    this.onPositionSaved, //  جديد
  });

  @override
  State<MushafPageViewScreen> createState() => _MushafPageViewScreenState();
}

class _MushafPageViewScreenState extends State<MushafPageViewScreen> {
  late PageController _controller;
  final QuranApiService _api = QuranApiService();

  late Future<List<AyahModel>> _surahFuture;
  late Future<List<SurahModel>> _surahMetaFuture;
  int? _highlightedAyah;
  int _currentPageIndex = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _surahFuture = _api.fetchSurah(widget.surahNumber);
    _surahMetaFuture = _api.fetchSurahs();
    _highlightedAyah = widget.highlightAyahNumber;

    if (widget.restoreLastPosition) {
      _restoreLastPosition();
    }

    if (_highlightedAyah != null) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _highlightedAyah = null;
          });
        }
      });
    }
  }

  Future<void> _restoreLastPosition() async {
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

  @override
  void dispose() {
    _saveCurrentPosition();
    _controller.dispose();
    super.dispose();
  }

  void _saveCurrentPosition() async {
    final lastRead = LastRead(
      surahNumber: widget.surahNumber,
      pageIndex: _currentPageIndex,
    );
    await LastPositionService.saveLastPosition(lastRead);

    //  استدعاء callback للتحديث
    if (widget.onPositionSaved != null) {
      widget.onPositionSaved!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF07130D) : const Color(0xFFF5F7F2);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: FutureBuilder<List<AyahModel>>(
              future: _surahFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final ayahs = snapshot.data!;
                final grouped = <int, List<AyahModel>>{};
                for (final ayah in ayahs) {
                  grouped.putIfAbsent(ayah.page, () => []);
                  grouped[ayah.page]!.add(ayah);
                }
                final pages = grouped.values.toList();

                if (widget.highlightAyahNumber != null &&
                    !widget.restoreLastPosition) {
                  for (int i = 0; i < pages.length; i++) {
                    if (pages[i].any(
                      (a) => a.numberInSurah == widget.highlightAyahNumber,
                    )) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _controller.hasClients) {
                          _controller.jumpToPage(i);
                        }
                      });
                      break;
                    }
                  }
                }

                final currentPageAyahs =
                    pages[_currentPageIndex.clamp(0, pages.length - 1)];
                final progress = pages.isEmpty
                    ? 0.0
                    : (_currentPageIndex + 1) / pages.length;
                final lastAyah = currentPageAyahs.isEmpty
                    ? 1
                    : currentPageAyahs.last.numberInSurah;

                return Column(
                  children: [
                    FutureBuilder<List<SurahModel>>(
                      future: _surahMetaFuture,
                      builder: (context, metaSnap) {
                        SurahModel? meta;
                        if (metaSnap.hasData) {
                          for (final s in metaSnap.data!) {
                            if (s.number == widget.surahNumber) {
                              meta = s;
                              break;
                            }
                          }
                        }
                        return _ReaderTopBar(
                          surahName: widget.surahName ?? 'السورة',
                          revelationType: meta?.revelationType ?? 'مكية',
                          ayahCount: meta?.numberOfAyahs ?? ayahs.length,
                        );
                      },
                    ),
                    _SurahInfoCard(
                      reciter: AppSettingsController.instance.reciter,
                      lastAyah: lastAyah,
                      progress: progress,
                      onPlayTap: () async {
                        if (currentPageAyahs.isEmpty) return;
                        setState(() => _isPlaying = !_isPlaying);
                        await AudioService.playAyah(
                          currentPageAyahs.first.number,
                        );
                      },
                      onBookmarkTap: () async {
                        if (currentPageAyahs.isEmpty) return;
                        final ayah = currentPageAyahs.last;
                        final id =
                            '${widget.surahNumber}_${ayah.numberInSurah}';
                        await BookmarkService.addBookmark(
                          BookmarkModel(
                            id: id,
                            surahNumber: widget.surahNumber,
                            ayahNumber: ayah.numberInSurah,
                            ayahText: ayah.text,
                            createdAt: DateTime.now(),
                          ),
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم حفظ علامة للآية')),
                        );
                      },
                      onShareTap: () async {
                        if (currentPageAyahs.isEmpty) return;
                        final ayah = currentPageAyahs.last;
                        await SharePlus.instance.share(
                          ShareParams(
                            text:
                                '${ayah.text}\n﴿${ayah.numberInSurah}﴾ - ${widget.surahName ?? 'السورة'}',
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        child: PageView.builder(
                          key: ValueKey(_currentPageIndex),
                          controller: _controller,
                          reverse: true,
                          itemCount: pages.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final pageAyahs = pages[index];
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                12,
                                14,
                                110,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF0D1E17)
                                      : const Color(0xFFF8FAF7),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x14000000),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListView.separated(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    22,
                                    20,
                                    22,
                                  ),
                                  itemCount: pageAyahs.length,
                                  separatorBuilder: (_, __) => Divider(
                                    color: isDark
                                        ? const Color(0xFF1F3A30)
                                        : const Color(0xFFE2E7E2),
                                    height: 24,
                                  ),
                                  itemBuilder: (context, i) {
                                    final ayah = pageAyahs[i];
                                    return AyahWidget(
                                      ayah: ayah,
                                      surahNumber: widget.surahNumber,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 18,
            child: _ReaderBottomPlayerCard(
              surahName: widget.surahName,
              isPlaying: _isPlaying,
              onPlayPause: () => setState(() => _isPlaying = !_isPlaying),
              progress:
                  (_currentPageIndex + 1) /
                  604.0, // visual only, keeps logic untouched
            ),
          ),
        ],
      ),
    );
  }
}

class _ReaderTopBar extends StatelessWidget {
  final String surahName;
  final String revelationType;
  final int ayahCount;

  const _ReaderTopBar({
    required this.surahName,
    required this.revelationType,
    required this.ayahCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF0A3B28), Color(0xFF0F8B5F)]
              : const [Color(0xFF0B5D3F), Color(0xFF157347)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Text(
                    surahName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$revelationType • $ayahCount آية',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: Colors.white.withAlpha(220),
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahInfoCard extends StatelessWidget {
  final String reciter;
  final int lastAyah;
  final double progress;
  final VoidCallback onPlayTap;
  final VoidCallback onBookmarkTap;
  final VoidCallback onShareTap;

  const _SurahInfoCard({
    required this.reciter,
    required this.lastAyah,
    required this.progress,
    required this.onPlayTap,
    required this.onBookmarkTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E2219) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1B3A2F) : const Color(0xFFDEE4DD),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('القارئ: $reciter', style: const TextStyle(fontFamily: 'Cairo')),
          const SizedBox(height: 3),
          Text(
            'آخر قراءة: الآية $lastAyah',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: isDark
                  ? const Color(0xFF244136)
                  : const Color(0xFFE7EBE5),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF0F8B5F)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onShareTap,
                icon: const Icon(Icons.share_outlined, size: 16),
                label: const Text('مشاركة'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onBookmarkTap,
                icon: const Icon(Icons.bookmark_outline_rounded, size: 16),
                label: const Text('حفظ'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: onPlayTap,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F8B5F),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('تشغيل'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReaderBottomPlayerCard extends StatelessWidget {
  final String? surahName;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final double progress;

  const _ReaderBottomPlayerCard({
    this.surahName,
    required this.isPlaying,
    required this.onPlayPause,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? const Color(0xFF214032)
        : const Color(0xFFD8DDDA);
    final primaryText = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondary;

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) => ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
          child: Container(
            height: 74,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF112219) : Colors.white)
                  .withAlpha(225),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderColor, width: 0.8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  IconButton.filled(
                    onPressed: onPlayPause,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF0F8B5F),
                    ),
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          surahName ?? 'السورة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                          ),
                        ),
                        Text(
                          settings.reciter,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            color: secondaryText,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 3.5,
                            backgroundColor: isDark
                                ? const Color(0xFF2A473B)
                                : const Color(0xFFE3E8E3),
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF0F8B5F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
