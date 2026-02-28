import 'package:flutter/material.dart';
import 'package:test_app_new/Quran_Section/data/quran_api_service.dart';
import 'package:test_app_new/Quran_Section/models/ayah_model.dart';

class MushafReaderScreen extends StatefulWidget {
  final String surahName;
  final int surahNumber;
  const MushafReaderScreen({
    super.key,
    required this.surahName,
    required this.surahNumber,
  });

  @override
  State<MushafReaderScreen> createState() => _MushafReaderScreenState();
}

class _MushafReaderScreenState extends State<MushafReaderScreen> {
  late Future<List<AyahModel>> ayahsFuture;
  @override
  void initState() {
    super.initState();
    ayahsFuture = QuranApiService().fetchSurah(widget.surahNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.surahName), centerTitle: true),
      body: FutureBuilder<List<AyahModel>>(
        future: ayahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("قم بتحميل السورة "));
          }

          final ayahs = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ayahs.length,
            itemBuilder: (context, index) {
              final ayah = ayahs[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "${ayah.text} (${ayah.numberInSurah})",
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontSize: 22, height: 1.8),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
