import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:share_plus/share_plus.dart';
import 'package:test_app_new/Quran_Section/data/Tafsir_api_Service.dart';
import 'package:test_app_new/Quran_Section/data/audio_service.dart';
import 'package:test_app_new/Quran_Section/data/bookmark_service.dart';
import 'package:test_app_new/Quran_Section/data/note_service.dart';
import 'package:test_app_new/Quran_Section/models/ayah_model.dart';
import 'package:test_app_new/Quran_Section/models/bookmark_model.dart';
import 'package:test_app_new/Quran_Section/models/note_model.dart';

const Color _kTextLight = Color(0xFFFFFFFF);
const Color _kTextPrimary = Color(0xFF1A1A1A);

void showAyahOptionsSheet(
  BuildContext context, {
  required AyahModel ayah,
  required int surahNumber,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1C2B20)
        : const Color(0xfff5f0e1),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'خيارات الآية',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? _kTextLight
                              : _kTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ayah.text,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? _kTextLight
                          : _kTextPrimary,
                    ),
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.copy),
                          title: const Text("نسخ الآية"),
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: ayah.text));
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
                                    "${ayah.text}\n - آية ${ayah.numberInSurah}",
                              ),
                            );
                            if (context.mounted) Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.bookmark),
                          title: const Text("إضافة للمفضلة"),
                          onTap: () async {
                            final box = Hive.box('favoritesBox');
                            final uniqueKey =
                                "${surahNumber}_${ayah.numberInSurah}";

                            if (box.containsKey(uniqueKey)) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "الآية موجودة بالفعل في المفضلة",
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            await box.put(uniqueKey, {
                              "text": ayah.text,
                              "ayahNumber": ayah.numberInSurah,
                              "surahNumber": surahNumber,
                              "page": ayah.page,
                            });

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("تمت الإضافة للمفضلة"),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.menu_book),
                          title: const Text("التفسير"),
                          onTap: () async {
                            final navigator = Navigator.of(context);
                            final scaffoldMessenger = ScaffoldMessenger.of(
                              context,
                            );
                            navigator.pop();
                            await Future.delayed(
                              const Duration(milliseconds: 100),
                            );
                            if (!context.mounted) return;

                            navigator.push(
                              PageRouteBuilder(
                                opaque: false,
                                barrierDismissible: false,
                                pageBuilder: (c, _, __) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );

                            try {
                              final tafsir = await TafsirService().getTafsir(
                                ayah.number,
                              );
                              navigator.pop();
                              if (!context.mounted) return;

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

                              navigator.push(
                                PageRouteBuilder(
                                  opaque: false,
                                  barrierColor: Colors.black.withValues(
                                    alpha: 0.3,
                                  ),
                                  pageBuilder: (c, animation, secondaryAnimation) => BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 5,
                                      sigmaY: 5,
                                    ),
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
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(c).brightness ==
                                                      Brightness.dark
                                                  ? const Color(0xFF1C2B20)
                                                  : const Color(0xfff5f0e1),
                                              borderRadius:
                                                  const BorderRadius.all(
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Theme.of(
                                                                c,
                                                              ).brightness ==
                                                              Brightness.dark
                                                          ? Colors
                                                                .brown
                                                                .shade900
                                                          : Colors
                                                                .brown
                                                                .shade100,
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
                                                        const SizedBox(
                                                          width: 48,
                                                        ),
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
                                                            ayah.text,
                                                            textAlign:
                                                                TextAlign.right,
                                                            textDirection:
                                                                TextDirection
                                                                    .rtl,
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
                                                                TextDirection
                                                                    .rtl,
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
                              navigator.pop();
                              if (!context.mounted) return;
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
                            await AudioService.playAyah(ayah.number);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.bookmark_border),
                          title: const Text("إضافة إشارة مرجعية"),
                          onTap: () async {
                            final id = '${surahNumber}_${ayah.numberInSurah}';
                            final hasBookmark =
                                await BookmarkService.hasBookmark(
                                  surahNumber,
                                  ayah.numberInSurah,
                                );

                            if (hasBookmark) {
                              await BookmarkService.deleteBookmark(id);
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("تم إزالة الإشارة المرجعية"),
                                ),
                              );
                            } else {
                              final bookmark = BookmarkModel(
                                id: id,
                                surahNumber: surahNumber,
                                ayahNumber: ayah.numberInSurah,
                                ayahText: ayah.text,
                                createdAt: DateTime.now(),
                              );
                              await BookmarkService.addBookmark(bookmark);
                              if (!context.mounted) return;
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
                            Navigator.pop(context);
                            final existingNote = await NoteService.getNote(
                              surahNumber,
                              ayah.numberInSurah,
                            );
                            if (!context.mounted) return;

                            final controller = TextEditingController(
                              text: existingNote?.noteText ?? '',
                            );

                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
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
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: const Text("إلغاء"),
                                  ),
                                  if (existingNote != null)
                                    TextButton(
                                      onPressed: () async {
                                        await NoteService.deleteNote(
                                          existingNote.id,
                                        );
                                        if (!dialogContext.mounted) return;
                                        Navigator.pop(dialogContext);
                                        ScaffoldMessenger.of(
                                          dialogContext,
                                        ).showSnackBar(
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
                                        Navigator.pop(dialogContext);
                                        return;
                                      }
                                      final id =
                                          '${surahNumber}_${ayah.numberInSurah}';
                                      final note = NoteModel(
                                        id: id,
                                        surahNumber: surahNumber,
                                        ayahNumber: ayah.numberInSurah,
                                        ayahText: ayah.text,
                                        noteText: noteText,
                                        createdAt:
                                            existingNote?.createdAt ??
                                            DateTime.now(),
                                        updatedAt: existingNote != null
                                            ? DateTime.now()
                                            : null,
                                      );
                                      if (existingNote != null) {
                                        await NoteService.updateNote(note);
                                      } else {
                                        await NoteService.addNote(note);
                                      }
                                      if (!dialogContext.mounted) return;
                                      Navigator.pop(dialogContext);
                                      ScaffoldMessenger.of(
                                        dialogContext,
                                      ).showSnackBar(
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
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
