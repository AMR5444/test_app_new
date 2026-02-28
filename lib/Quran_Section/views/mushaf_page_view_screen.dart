import 'package:flutter/material.dart';
import 'package:test_app_new/Quran_Section/data/LastPositionService.dart';
import 'package:test_app_new/Quran_Section/data/quran_api_service.dart';
import 'package:test_app_new/Quran_Section/models/LastRead_model.dart';
import 'package:test_app_new/Quran_Section/models/ayah_model.dart';
import 'package:test_app_new/Quran_Section/widgets/ayah_widget.dart';

class MushafPageViewScreen extends StatefulWidget {
  final int surahNumber;
  final int? highlightAyahNumber;
  final bool restoreLastPosition;
  final Function()? onPositionSaved; // ✅ Callback للتحديث

  const MushafPageViewScreen({
    super.key,
    required this.surahNumber,
    this.highlightAyahNumber,
    this.restoreLastPosition = false,
    this.onPositionSaved, // ✅ جديد
  });

  @override
  State<MushafPageViewScreen> createState() => _MushafPageViewScreenState();
}

class _MushafPageViewScreenState extends State<MushafPageViewScreen> {
  late PageController _controller;
  final QuranApiService _api = QuranApiService();

  late Future<List<AyahModel>> _surahFuture;
  int? _highlightedAyah;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _surahFuture = _api.fetchSurah(widget.surahNumber);
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

    // ✅ استدعاء callback للتحديث
    if (widget.onPositionSaved != null) {
      widget.onPositionSaved!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f0e1),
      body: FutureBuilder<List<AyahModel>>(
        future: _surahFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final ayahs = snapshot.data!;

          final Map<int, List<AyahModel>> grouped = {};

          for (var ayah in ayahs) {
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

          return PageView.builder(
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

              return LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 35,
                    ),
                    child: FittedBox(
                      alignment: Alignment.topRight,
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          textDirection: TextDirection.rtl,
                          children: pageAyahs.map((ayah) {
                            final isHighlighted =
                                ayah.numberInSurah == _highlightedAyah;

                            return Container(
                              decoration: isHighlighted
                                  ? BoxDecoration(
                                      color: Colors.yellow.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    )
                                  : null,
                              child: AyahWidget(
                                ayah: ayah,
                                surahNumber: widget.surahNumber,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
