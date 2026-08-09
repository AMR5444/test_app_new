// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:test_app_new/Quran_Section/data/LastPositionService.dart';
// import 'package:test_app_new/Quran_Section/data/quran_api_service.dart';
// import 'package:test_app_new/Quran_Section/models/LastRead_model.dart';
// import 'package:test_app_new/Quran_Section/models/ayah_model.dart';
// import 'package:test_app_new/Quran_Section/models/surah_model.dart';
// import 'package:test_app_new/Quran_Section/widgets/ayah_widget.dart';
// import 'package:test_app_new/core/settings/settings_cubit.dart';

// // ألوان ورقة المصحف
// const Color _kPageBg = Color(0xFFFDF8EE);
// const Color _kPageBorder = Color(0xFFD4B896);
// const Color _kFrameColor = Color(0xFF8B5E3C);
// const Color _kHeaderBg = Color(0xFF1A5C38);
// const Color _kGold = Color(0xFFC5A028);
// const Color _kTextDark = Color(0xFF1A1A1A);
// const Color _kDividerColor = Color(0xFFD4B896);

// class MushafPageViewScreen extends StatefulWidget {
//   final int surahNumber;
//   final int? highlightAyahNumber;
//   final bool restoreLastPosition;
//   final Function()? onPositionSaved;

//   const MushafPageViewScreen({
//     super.key,
//     required this.surahNumber,
//     this.highlightAyahNumber,
//     this.restoreLastPosition = false,
//     this.onPositionSaved,
//   });

//   @override
//   State<MushafPageViewScreen> createState() => _MushafPageViewScreenState();
// }

// class _MushafPageViewScreenState extends State<MushafPageViewScreen> {
//   late PageController _controller;
//   final QuranApiService _api = QuranApiService();

//   late Future<_SurahData> _dataFuture;
//   int? _highlightedAyah;
//   int _currentPageIndex = 0;
//   List<List<AyahModel>> _pages = [];

//   @override
//   void initState() {
//     super.initState();
//     _controller = PageController();
//     _highlightedAyah = widget.highlightAyahNumber;
//     _dataFuture = _loadData();

//     if (_highlightedAyah != null) {
//       Future.delayed(const Duration(seconds: 3), () {
//         if (mounted) setState(() => _highlightedAyah = null);
//       });
//     }
//   }

//   Future<_SurahData> _loadData() async {
//     final results = await Future.wait([
//       _api.fetchSurah(widget.surahNumber),
//       QuranApiService().fetchSurahs(),
//     ]);

//     final ayahs = results[0] as List<AyahModel>;
//     final surahs = results[1] as List<SurahModel>;

//     final surah = surahs.firstWhere(
//       (s) => s.number == widget.surahNumber,
//       orElse: () => SurahModel(
//         number: widget.surahNumber,
//         name: 'السورة',
//         englishName: '',
//         numberOfAyahs: ayahs.length,
//         revelationType: '',
//       ),
//     );

//     // تجميع الآيات في صفحات
//     final Map<int, List<AyahModel>> grouped = {};
//     for (var ayah in ayahs) {
//       grouped.putIfAbsent(ayah.page, () => []).add(ayah);
//     }
//     final sortedKeys = grouped.keys.toList()..sort();
//     final pages = sortedKeys.map((k) => grouped[k]!).toList();

//     return _SurahData(surah: surah, pages: pages);
//   }

//   Future<void> _restorePosition(_SurahData data) async {
//     if (!widget.restoreLastPosition) return;
//     final lastPos = await LastPositionService.getLastPosition();
//     if (lastPos != null &&
//         lastPos.surahNumber == widget.surahNumber &&
//         mounted) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted && _controller.hasClients) {
//           _controller.jumpToPage(lastPos.pageIndex);
//           _currentPageIndex = lastPos.pageIndex;
//         }
//       });
//     }
//   }

//   void _jumpToHighlightPage(List<List<AyahModel>> pages) {
//     if (widget.highlightAyahNumber == null || widget.restoreLastPosition)
//       return;
//     for (int i = 0; i < pages.length; i++) {
//       if (pages[i].any((a) => a.numberInSurah == widget.highlightAyahNumber)) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted && _controller.hasClients) _controller.jumpToPage(i);
//         });
//         break;
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _savePosition();
//     _controller.dispose();
//     super.dispose();
//   }

//   void _savePosition() async {
//     await LastPositionService.saveLastPosition(
//       LastRead(surahNumber: widget.surahNumber, pageIndex: _currentPageIndex),
//     );
//     widget.onPositionSaved?.call();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<SettingsCubit, SettingsState>(
//       builder: (context, settings) {
//         final isDark = settings.isDarkMode;
//         return Scaffold(
//           backgroundColor: isDark
//               ? const Color(0xFF0D1F16)
//               : const Color(0xFFEDE8DC),
//           body: FutureBuilder<_SurahData>(
//             future: _dataFuture,
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return const Center(
//                   child: CircularProgressIndicator(color: _kHeaderBg),
//                 );
//               }
//               if (snapshot.hasError) {
//                 return Center(child: Text('حدث خطأ: ${snapshot.error}'));
//               }

//               final data = snapshot.data!;
//               _pages = data.pages;

//               // restore / jump بعد البناء
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 _restorePosition(data);
//                 _jumpToHighlightPage(data.pages);
//               });

//               return Column(
//                 children: [
//                   _buildAppBar(data.surah, isDark),
//                   Expanded(
//                     child: PageView.builder(
//                       controller: _controller,
//                       reverse: true,
//                       itemCount: data.pages.length,
//                       onPageChanged: (i) =>
//                           setState(() => _currentPageIndex = i),
//                       itemBuilder: (context, index) => _buildMushafPage(
//                         context,
//                         data.surah,
//                         data.pages[index],
//                         index,
//                         data.pages.length,
//                         isDark,
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   // ─── AppBar ───────────────────────────────────────────────────────────────
//   Widget _buildAppBar(SurahModel surah, bool isDark) {
//     // تنظيف الاسم في الـ AppBar أيضاً
//     final displayName = _normalizeSurahName(surah.name);

//     return Container(
//       color: _kHeaderBg,
//       child: SafeArea(
//         bottom: false,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           child: Row(
//             children: [
//               // زر الرجوع
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   width: 36,
//                   height: 36,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withValues(alpha: 0.15),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(
//                     Icons.arrow_forward_ios,
//                     color: Colors.white,
//                     size: 16,
//                   ),
//                 ),
//               ),
//               const Spacer(),
//               // اسم السورة + معلومات
//               Column(
//                 children: [
//                   Text(
//                     displayName,
//                     style: GoogleFonts.amiri(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     '${surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية'} • ${surah.numberOfAyahs} آية',
//                     style: GoogleFonts.cairo(
//                       fontSize: 12,
//                       color: Colors.white70,
//                     ),
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               // زر القائمة
//               Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withValues(alpha: 0.15),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(
//                   Icons.more_vert,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ─── صفحة المصحف ──────────────────────────────────────────────────────────
//   Widget _buildMushafPage(
//     BuildContext context,
//     SurahModel surah,
//     List<AyahModel> pageAyahs,
//     int pageIndex,
//     int totalPages,
//     bool isDark,
//   ) {
//     final isFirstPage = pageAyahs.any((a) => a.numberInSurah == 1);
//     final pageNumber = pageAyahs.isNotEmpty ? pageAyahs.first.page : 0;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       child: Container(
//         decoration: BoxDecoration(
//           color: isDark ? const Color(0xFF1C2B20) : _kPageBg,
//           borderRadius: BorderRadius.circular(4),
//           border: Border.all(color: _kPageBorder, width: 1.5),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.18),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             // ─ هيدر الصفحة (رقم الجزء + رقم الصفحة + اسم السورة)
//             _buildPageHeader(pageNumber, surah, isDark),

//             // ─ إطار الآيات
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//                 child: Column(
//                   children: [
//                     if (isFirstPage &&
//                         widget.surahNumber != 1 &&
//                         widget.surahNumber != 9)
//                       _buildBasmala(isDark),
//                     Expanded(
//                       child: LayoutBuilder(
//                         builder: (context, constraints) {
//                           return SingleChildScrollView(
//                             child: SizedBox(
//                               width: constraints.maxWidth,
//                               child: Directionality(
//                                 textDirection: TextDirection.rtl,
//                                 child: Wrap(
//                                   alignment: WrapAlignment.end,
//                                   children: pageAyahs.map((ayah) {
//                                     String text = ayah.text.trim();

//                                     // 🚨 الحل الحقيقي: احذف البسملة فقط لو هي أول آية في السورة
//                                     final isFirstAyahInSurah =
//                                         ayah.numberInSurah == 1;

//                                     final isNotFatihaOrTawbah =
//                                         widget.surahNumber != 1 &&
//                                         widget.surahNumber != 9;

//                                     if (isFirstAyahInSurah &&
//                                         isNotFatihaOrTawbah) {
//                                       // نشيل البسملة حتى لو شكلها مختلف
//                                       text = text
//                                           .replaceAll(
//                                             RegExp(r'بِ?سۡمِ.*?الرَّحِيمِ'),
//                                             '',
//                                           )
//                                           .trim();
//                                     }

//                                     final displayAyah = AyahModel(
//                                       number: ayah.number,
//                                       numberInSurah: ayah.numberInSurah,
//                                       text: text,
//                                       page: ayah.page,
//                                     );

//                                     final isHL =
//                                         ayah.numberInSurah == _highlightedAyah;

//                                     return Container(
//                                       decoration: isHL
//                                           ? BoxDecoration(
//                                               color: Colors.yellow.withValues(
//                                                 alpha: 0.35,
//                                               ),
//                                               borderRadius:
//                                                   BorderRadius.circular(4),
//                                             )
//                                           : null,
//                                       child: AyahWidget(
//                                         ayah: displayAyah,
//                                         surahNumber: widget.surahNumber,
//                                       ),
//                                     );
//                                   }).toList(),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // ─ فوتر الصفحة
//             _buildPageFooter(pageIndex, totalPages, isDark),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPageHeader(int pageNumber, SurahModel surah, bool isDark) {
//     final shortName = _normalizeSurahName(surah.name);

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       decoration: BoxDecoration(
//         border: Border(bottom: BorderSide(color: _kDividerColor, width: 1)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'الجزء ${_getJuzNumber(pageNumber)}',
//             style: GoogleFonts.cairo(
//               fontSize: 11,
//               color: isDark ? Colors.white54 : _kFrameColor,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           // زخرفة وسطى
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
//             decoration: BoxDecoration(
//               border: Border.all(color: _kGold.withValues(alpha: 0.5)),
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Text(
//               '$pageNumber',
//               style: GoogleFonts.cairo(
//                 fontSize: 11,
//                 color: _kGold,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Text(
//             shortName,
//             style: GoogleFonts.amiri(
//               fontSize: 13,
//               color: isDark ? Colors.white70 : _kFrameColor,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBasmala(bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Text(
//         'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
//         textAlign: TextAlign.center,
//         style: GoogleFonts.amiri(
//           fontSize: 20,
//           color: isDark ? Colors.white : _kTextDark,
//           height: 2,
//         ),
//       ),
//     );
//   }

//   bool _ayahsContainBasmala(List<AyahModel> ayahs) {
//     if (ayahs.isEmpty) return false;
//     final firstText = ayahs.first.text.trim();
//     return firstText.contains('بسم الله') ||
//         firstText.contains('بِسۡمِ ٱللَّهِ');
//   }

//   Widget _buildPageFooter(int pageIndex, int totalPages, bool isDark) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       decoration: BoxDecoration(
//         border: Border(top: BorderSide(color: _kDividerColor, width: 1)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: List.generate(totalPages > 7 ? 7 : totalPages, (i) {
//           // نعرض نقاط حول الصفحة الحالية
//           final mid = totalPages > 7 ? 3 : pageIndex;
//           final displayIndex = totalPages > 7
//               ? (pageIndex - mid + i).clamp(0, totalPages - 1)
//               : i;
//           final isCurrent = displayIndex == pageIndex;
//           return Container(
//             width: isCurrent ? 16 : 6,
//             height: 6,
//             margin: const EdgeInsets.symmetric(horizontal: 2),
//             decoration: BoxDecoration(
//               color: isCurrent
//                   ? _kHeaderBg
//                   : (isDark ? Colors.white24 : _kDividerColor),
//               borderRadius: BorderRadius.circular(3),
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   // حساب الجزء من رقم الصفحة (تقريبي - 20 صفحة لكل جزء)
//   int _getJuzNumber(int page) => ((page - 1) ~/ 20 + 1).clamp(1, 30);
// }

// // ─── Data class ──────────────────────────────────────────────────────────────
// class _SurahData {
//   final SurahModel surah;
//   final List<List<AyahModel>> pages;
//   _SurahData({required this.surah, required this.pages});
// }

// String _normalizeSurahName(String name) {
//   final trimmed = name.trim();
//   return trimmed.startsWith('سورة')
//       ? trimmed.replaceFirst(RegExp(r'^سورة\s*'), '').trim()
//       : trimmed;
// }
