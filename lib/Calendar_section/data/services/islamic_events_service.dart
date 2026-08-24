import 'package:test_app_new/Calendar_section/data/models/islamic_event.dart';

class IslamicEventsService {
  const IslamicEventsService();

  static const List<IslamicEvent> _events = [
    IslamicEvent(
      id: 'hijri_new_year',
      title: 'رأس السنة الهجرية',
      hijriDay: 1,
      hijriMonth: 1,
    ),

    IslamicEvent(
      id: 'ashura',
      title: 'يوم عاشوراء',
      hijriDay: 10,
      hijriMonth: 1,
    ),

    IslamicEvent(
      id: 'sacred_months_start',
      title: 'بداية الأشهر الحرم',
      hijriDay: 1,
      hijriMonth: 7,
    ),

    IslamicEvent(
      id: 'isra_miraj',
      title: 'الإسراء والمعراج',
      hijriDay: 27,
      hijriMonth: 7,
    ),

    IslamicEvent(
      id: 'mid_shaban',
      title: 'ليلة النصف من شعبان',
      hijriDay: 15,
      hijriMonth: 8,
    ),

    IslamicEvent(
      id: 'ramadan_start',
      title: 'بداية شهر رمضان',
      hijriDay: 1,
      hijriMonth: 9,
    ),

    IslamicEvent(
      id: 'lailat_al_qadr',
      title: 'ليلة القدر',
      hijriDay: 27,
      hijriMonth: 9,
    ),

    IslamicEvent(
      id: 'eid_fitr',
      title: 'عيد الفطر',
      hijriDay: 1,
      hijriMonth: 10,
    ),

    IslamicEvent(
      id: 'dhul_hijjah_start',
      title: 'بداية عشر ذي الحجة',
      hijriDay: 1,
      hijriMonth: 12,
    ),

    IslamicEvent(id: 'arafah', title: 'يوم عرفة', hijriDay: 9, hijriMonth: 12),
    IslamicEvent(
      id: 'eid_adha',
      title: 'عيد الأضحى',
      hijriDay: 10,
      hijriMonth: 12,
    ),

    IslamicEvent(id: 'white_days_13', title: 'صيام الأيام البيض', hijriDay: 13),
    IslamicEvent(id: 'white_days_14', title: 'صيام الأيام البيض', hijriDay: 14),
    IslamicEvent(id: 'white_days_15', title: 'صيام الأيام البيض', hijriDay: 15),
  ];

  List<IslamicEvent> eventsFor(int hijriDay, int hijriMonth) {
    return _events
        .where((event) => event.matchesHijriDate(hijriDay, hijriMonth))
        .toList(growable: false);
  }
}
