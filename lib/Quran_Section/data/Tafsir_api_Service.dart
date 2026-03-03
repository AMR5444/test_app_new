import 'package:dio/dio.dart';
import 'package:hive_flutter/adapters.dart';

class TafsirService {
  final Dio _dio = Dio();

  Future<String> getTafsir(int ayahNumber) async {
    try {
      final box = await Hive.openBox('tafsirBox');

      // لو موجود في الكاش
      if (box.containsKey(ayahNumber)) {
        final cached = box.get(ayahNumber);
        if (cached != null && cached.toString().isNotEmpty) {
          return cached.toString();
        }
      }

      // لو مش موجود → هات من API
      final response = await _dio.get(
        'https://api.alquran.cloud/v1/ayah/$ayahNumber/ar.muyassar',
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      // ✅ التحقق المتسلسل من كل level
      final data = response.data;
      if (data == null) {
        return 'التفسير غير متوفر';
      }

      final dataField = data['data'];
      if (dataField == null) {
        return 'التفسير غير متوفر';
      }

      final textField = dataField['text'];
      if (textField == null) {
        return 'التفسير غير متوفر';
      }

      // ✅ تحويل لـ String بشكل آمن
      final tafsir = textField.toString();

      if (tafsir.isEmpty || tafsir == 'null') {
        return 'التفسير غير متوفر';
      }

      // حفظ في الكاش
      await box.put(ayahNumber, tafsir);

      return tafsir;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'انتهت مهلة الاتصال';
      } else if (e.type == DioExceptionType.connectionError) {
        return 'تأكد من اتصالك بالإنترنت';
      }
      return 'حدث خطأ في تحميل التفسير';
    } catch (e) {
      return 'حدث خطأ في تحميل التفسير';
    }
  }
}
