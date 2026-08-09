import 'package:qcf_quran_plus/qcf_quran_plus.dart';

int globalAyahNumber(int surahNumber, int verseNumber) {
  int total = 0;
  for (int s = 1; s < surahNumber; s++) {
    total += getVerseCount(s);
  }
  return total + verseNumber;
}
