import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_app_new/azkr_section/models/azkar_model.dart';

class AzkarApi {
  static const String url =
      'https://raw.githubusercontent.com/nawafalqari/azkar-api/56df51279ab6eb86dc2f6202c7de26c8948331c1/azkar.json?fbclid=IwY2xjawPtrBhleHRuA2FlbQIxMABicmlkETEzQXNFYks1TWZZR3B6RlhEc3J0YwZhcHBfaWQQMjIyMDM5MTc4ODIwMDg5MgABHoo8p_IjcyrO-8pgtcvgL3qBdiro3oJty00MraY1NBwAxMo7LmJqbxzqsuyd_aem_1XmgtPYI4l4uiQe8iclHyQ';

  Future<List<ZekrItem>> fetchAzkar(String category) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load azkar');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    // ignore: avoid_print
    print(data.keys);
    final List list = data[category] ?? [];
    return list
        .where((e) => e is Map<String, dynamic> && e['count'] != 'stop')
        .map<ZekrItem>((e) => ZekrItem.fromJson(e))
        .toList();
  }
}
