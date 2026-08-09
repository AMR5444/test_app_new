import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:share_plus/share_plus.dart';
import 'package:test_app_new/Quran_Section/data/LastPositionService.dart';
import 'package:test_app_new/Quran_Section/data/quran_api_service.dart';
import 'package:test_app_new/Quran_Section/models/LastRead_model.dart';
import 'package:test_app_new/Quran_Section/models/surah_model.dart';
import 'package:test_app_new/core/settings/settings_cubit.dart';
import 'package:test_app_new/core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LastRead? _lastPosition;
  SurahModel? _lastSurah;
  bool _loadingSurah = false;

  // Daily verse (static for now - can be made dynamic)
  final Map<String, String> _dailyAyah = {
    'text': 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
    'source': 'سورة البقرة • ١٥٢',
  };

  final Map<String, dynamic> _prayerTimes = {
    'الفجر': '٤:٤٣',
    'الشروق': '٦:٠٥',
    'الظهر': '١٢:٣٤',
    'العصر': '٣:٥٨',
    'المغرب': '٦:٤٢',
    'العشاء': '',
  };
  final String _nextPrayer = 'الظهر';
  final String _nextPrayerTime = '١٢:٣٤ م';

  // Daily stats
  int _azkarDone = 3;
  int _azkarTotal = 4;
  int _readingMinutes = 15;
  int _readingTarget = 20;

  @override
  void initState() {
    super.initState();
    _loadLastPosition();
  }

  Future<void> _loadLastPosition() async {
    final lastPos = await LastPositionService.getLastPosition();
    if (!mounted) return;
    setState(() {
      _lastPosition = lastPos;
    });
    if (lastPos != null) {
      _loadSurahInfo(lastPos.surahNumber);
    }
  }

  Future<void> _loadSurahInfo(int surahNumber) async {
    if (_loadingSurah) return;
    setState(() => _loadingSurah = true);
    try {
      final surahs = await QuranApiService().fetchSurahs();
      if (!mounted) return;
      setState(() {
        _lastSurah = surahs.firstWhere(
          (s) => s.number == surahNumber,
          orElse: () => surahs.first,
        );
        _loadingSurah = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingSurah = false);
    }
  }

  String _getHijriDate() {
    // Returns a static Hijri date string (dynamic impl requires a package)
    final now = DateTime.now();
    final days = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    return '${days[now.weekday % 7]} • ١٢ رمضان ١٤٤٧';
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isDark = settings.isDarkMode;
        return Scaffold(
          backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(isDark),
                  _buildPrayerCard(isDark),
                  _buildDailyAyah(isDark),
                  _buildQuickAccess(isDark),
                  if (_lastPosition != null) _buildLastRead(isDark),
                  _buildDailyStats(isDark),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgCardDark : Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 18,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'السلام عليكم',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              Text(
                _getHijriDate(),
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard(bool isDark) {
    final prayers = ['الفجر', 'الشروق', 'الظهر', 'العصر', 'المغرب'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.prayerGradientStart, AppColors.prayerGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'القاهرة',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, _) {
                        return Text(
                          'متبقي ٢:١٥:١٧',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'الصلاة القادمة • $_nextPrayer',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      _nextPrayerTime,
                      style: GoogleFonts.cairo(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: prayers.map((name) {
                final isNext = name == _nextPrayer;
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: isNext
                            ? BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              )
                            : null,
                        child: Column(
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: isNext
                                    ? AppColors.primary
                                    : Colors.white70,
                                fontWeight: isNext
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              _prayerTimes[name] ?? '',
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                color: isNext
                                    ? AppColors.primary
                                    : Colors.white60,
                                fontWeight: isNext
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyAyah(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: '${_dailyAyah['text']}\n— ${_dailyAyah['source']}',
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.share_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'مشاركة',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'آية اليوم',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgCardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _dailyAyah['text']!,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    fontSize: 22,
                    height: 1.9,
                    color: isDark ? AppColors.textLight : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '— ${_dailyAyah['source']} —',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(bool isDark) {
    final items = [
      {'icon': Icons.explore_outlined, 'label': 'القبلة', 'tab': 3},
      {'icon': Icons.auto_awesome_outlined, 'label': 'الأذكار', 'tab': 2},
      {'icon': Icons.menu_book_outlined, 'label': 'المصحف', 'tab': 1},
      {'icon': Icons.history, 'label': 'أخر قراءة', 'tab': 1},
      {'icon': Icons.favorite_outline, 'label': 'المفضلة', 'tab': 1},
      {'icon': Icons.touch_app_outlined, 'label': 'التسبيح', 'tab': 2},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => widget.onNavigate(item['tab'] as int),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgCardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['label'] as String,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textLight
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLastRead(bool isDark) {
    if (_lastPosition == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => widget.onNavigate(1),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.08),
                AppColors.primary.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.arrow_back_ios,
                size: 14,
                color: AppColors.primary,
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'متابعة القراءة',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    _lastSurah != null
                        ? '${_lastSurah!.name} • آية ${_lastPosition!.pageIndex + 1}'
                        : 'سورة الكهف • آية ٢٤',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '١٨',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyStats(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'إنجازاتك اليومية',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  label: 'القراءة',
                  value: '$_readingMinutes د',
                  subtitle: 'هدف $_readingTarget د',
                  progress: _readingMinutes / _readingTarget,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  isDark: isDark,
                  label: 'الأذكار',
                  value: '${(_azkarDone / _azkarTotal * 100).round()}٪',
                  subtitle: '$_azkarDone من $_azkarTotal',
                  progress: _azkarDone / _azkarTotal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required String label,
    required String value,
    required String subtitle,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: AppColors.accentLight,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
