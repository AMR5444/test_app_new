import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:share_plus/share_plus.dart';
import 'package:test_app_new/Quran_Section/data/Tafsir_api_Service.dart';
import 'package:test_app_new/core/settings/settings_cubit.dart';
import 'package:test_app_new/Quran_Section/data/audio_service.dart';
import 'package:test_app_new/Quran_Section/data/bookmark_service.dart';
import 'package:test_app_new/Quran_Section/data/note_service.dart';
import 'package:test_app_new/Quran_Section/models/ayah_model.dart';
import 'package:test_app_new/Quran_Section/models/bookmark_model.dart';
import 'package:test_app_new/Quran_Section/models/note_model.dart';
import 'dart:ui';

// Local color constants (avoids dependency on app_theme.dart)
const Color _kTextLight = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1A1A1A);
const Color _kPrimary = Color(0xFF1A5C38);

class AyahWidget extends StatefulWidget {
  final AyahModel ayah;
  final int surahNumber; //  إضافة رقم السورة

  const AyahWidget({super.key, required this.ayah, required this.surahNumber});

  @override
  State<AyahWidget> createState() => _AyahWidgetState();
}

class _AyahWidgetState extends State<AyahWidget> {
  bool _isHighlighted = false;
  bool _isLoadingTafsir = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _isHighlighted = !_isHighlighted;
        });
      },
      onLongPress: () => _showOptions(context),
      splashColor: Colors.brown.withOpacity(0.2),
      highlightColor: Colors.brown.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        color: _isHighlighted
            ? Colors.brown.withOpacity(0.08)
            : Colors.transparent,
        child: Text(
          "${widget.ayah.text} ﴿${widget.ayah.numberInSurah}﴾ ",
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.amiri(
            fontSize: context.select<SettingsCubit, double>(
              (c) => c.state.fontSize,
            ),
            height: 2.2,
            color:
                context.select<SettingsCubit, bool>((c) => c.state.isDarkMode)
                ? _kTextLight
                : _kTextPrimary,
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xfff5f0e1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'خيارات الآية',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _kTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Ayah preview
              Text(
                widget.ayah.text,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.amiri(fontSize: 16, height: 1.6),
              ),
              const Divider(height: 24),
              Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.copy),
                    title: const Text("نسخ الآية"),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.ayah.text));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("تم نسخ الآية")),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share),
                    title: const Text("مشاركة"),
                    onTap: () async {
                      await SharePlus.instance.share(
                        ShareParams(
                          text:
                              "${widget.ayah.text}\n - آية ${widget.ayah.numberInSurah}",
                        ),
                      );
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: const Text("إضافة للمفضلة"),
                    onTap: () async {
                      final box = Hive.box('favoritesBox');
                      final String uniqueKey =
                          "${widget.surahNumber}_${widget.ayah.numberInSurah}"; // ✅ مفتاح فريد

                      // ✅ التحقق من وجود الآية
                      if (box.containsKey(uniqueKey)) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("الآية موجودة بالفعل في المفضلة"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      // ✅ حفظ الآية مع رقم السورة
                      await box.put(uniqueKey, {
                        "text": widget.ayah.text,
                        "ayahNumber": widget.ayah.numberInSurah,
                        "surahNumber": widget.surahNumber,
                        "page": widget.ayah.page,
                      });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("تمت الإضافة للمفضلة")),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book),
                    title: const Text("التفسير"),
                    onTap: () async {
                      // ✅ حفظ كل حاجة قبل أي await
                      final navigator = Navigator.of(context);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      // إغلاق الـ bottom sheet
                      navigator.pop();

                      // انتظار frame
                      await Future.delayed(const Duration(milliseconds: 100));

                      if (!mounted) return;

                      // عرض loading
                      navigator.push(
                        PageRouteBuilder(
                          opaque: false,
                          barrierDismissible: false,
                          pageBuilder: (c, _, __) =>
                              const Center(child: CircularProgressIndicator()),
                        ),
                      );

                      try {
                        final String tafsir = await TafsirService().getTafsir(
                          widget.ayah.number,
                        );

                        if (!mounted) {
                          navigator.pop();
                          return;
                        }

                        // إغلاق loading
                        navigator.pop();

                        if (!mounted) return;

                        // التحقق من محتوى التفسير
                        final isError =
                            tafsir.contains('غير متوفر') ||
                            tafsir.contains('خطأ') ||
                            tafsir.contains('الاتصال');

                        if (isError) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text(tafsir)),
                          );
                          return;
                        }

                        // ✅ عرض التفسير مع blur
                        navigator.push(
                          PageRouteBuilder(
                            opaque: false, // ✅ مهم جداً للـ blur
                            barrierColor: Colors.black.withOpacity(
                              0.3,
                            ), // ✅ جديد
                            pageBuilder: (c, animation, secondaryAnimation) =>
                                BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 5,
                                    sigmaY: 5,
                                  ), // ✅ blur
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(c).pop(),
                                    child: Scaffold(
                                      backgroundColor: Colors.transparent,
                                      body: Center(
                                        child: Container(
                                          margin: const EdgeInsets.all(20),
                                          constraints: const BoxConstraints(
                                            maxHeight: 600,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Color(0xfff5f0e1),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                  Radius.circular(20),
                                                ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.brown.shade100,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.close,
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              c,
                                                            ).pop(),
                                                      ),
                                                      const Text(
                                                        "التفسير الميسر",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 48),
                                                    ],
                                                  ),
                                                ),
                                                Flexible(
                                                  child: SingleChildScrollView(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          20,
                                                        ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          widget.ayah.text,
                                                          textAlign:
                                                              TextAlign.right,
                                                          textDirection:
                                                              TextDirection.rtl,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 20,
                                                                height: 2,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        const Divider(
                                                          height: 30,
                                                        ),
                                                        Text(
                                                          tafsir,
                                                          textAlign:
                                                              TextAlign.right,
                                                          textDirection:
                                                              TextDirection.rtl,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 16,
                                                                height: 1.8,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) {
                          navigator.pop();
                          return;
                        }

                        navigator.pop();

                        if (!mounted) return;

                        scaffoldMessenger.showSnackBar(
                          const SnackBar(content: Text("حدث خطأ")),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.volume_up),
                    title: const Text("تشغيل الصوت"),
                    onTap: () async {
                      await AudioService.playAyah(widget.ayah.number);
                    },
                  ),
                  // في نهاية قائمة الـ options في _showOptions
                  ListTile(
                    leading: const Icon(Icons.bookmark_border),
                    title: const Text("إضافة إشارة مرجعية"),
                    onTap: () async {
                      final id =
                          '${widget.surahNumber}_${widget.ayah.numberInSurah}';

                      // التحقق من وجود bookmark
                      final hasBookmark = await BookmarkService.hasBookmark(
                        widget.surahNumber,
                        widget.ayah.numberInSurah,
                      );

                      if (hasBookmark) {
                        // حذف الـ bookmark
                        await BookmarkService.deleteBookmark(id);

                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("تم إزالة الإشارة المرجعية"),
                          ),
                        );
                      } else {
                        // إضافة bookmark جديد
                        final bookmark = BookmarkModel(
                          id: id,
                          surahNumber: widget.surahNumber,
                          ayahNumber: widget.ayah.numberInSurah,
                          ayahText: widget.ayah.text,
                          createdAt: DateTime.now(),
                        );

                        await BookmarkService.addBookmark(bookmark);

                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("تمت إضافة الإشارة المرجعية"),
                          ),
                        );
                      }
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.note_add),
                    title: const Text("إضافة ملاحظة"),
                    onTap: () async {
                      Navigator.pop(context); // إغلاق القائمة الحالية

                      // التحقق من وجود ملاحظة سابقة
                      final existingNote = await NoteService.getNote(
                        widget.surahNumber,
                        widget.ayah.numberInSurah,
                      );

                      if (!mounted) return;

                      final controller = TextEditingController(
                        text: existingNote?.noteText ?? '',
                      );

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(
                            "إضافة ملاحظة",
                            textAlign: TextAlign.right,
                          ),
                          content: TextField(
                            controller: controller,
                            maxLines: 5,
                            textDirection: TextDirection.rtl,
                            decoration: const InputDecoration(
                              hintText: "اكتب ملاحظتك هنا...",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("إلغاء"),
                            ),
                            if (existingNote != null)
                              TextButton(
                                onPressed: () async {
                                  await NoteService.deleteNote(existingNote.id);
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("تم حذف الملاحظة"),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "حذف",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            TextButton(
                              onPressed: () async {
                                final noteText = controller.text.trim();

                                if (noteText.isEmpty) {
                                  Navigator.pop(context);
                                  return;
                                }

                                final id =
                                    '${widget.surahNumber}_${widget.ayah.numberInSurah}';
                                final note = NoteModel(
                                  id: id,
                                  surahNumber: widget.surahNumber,
                                  ayahNumber: widget.ayah.numberInSurah,
                                  ayahText: widget.ayah.text,
                                  noteText: noteText,
                                  createdAt:
                                      existingNote?.createdAt ?? DateTime.now(),
                                  updatedAt: existingNote != null
                                      ? DateTime.now()
                                      : null,
                                );

                                if (existingNote != null) {
                                  await NoteService.updateNote(note);
                                } else {
                                  await NoteService.addNote(note);
                                }

                                if (!mounted) return;
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      existingNote != null
                                          ? "تم تحديث الملاحظة"
                                          : "تمت إضافة الملاحظة",
                                    ),
                                  ),
                                );
                              },
                              child: const Text("حفظ"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
