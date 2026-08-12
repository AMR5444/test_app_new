class SettingsState {
  final bool isDarkMode;
  final bool prayerNotifications;
  final bool adhanEnabled;
  final bool iqamaEnabled;
  final int prayerReminderMinutes;
  final bool azkarNotifications;
  final String reciter;
  final String language;
  final String selectedAdhanVoiceId;
  final String selectedIqamaVoiceId;

  const SettingsState({
    this.isDarkMode = false,
    this.prayerNotifications = true,
    this.adhanEnabled = true,
    this.iqamaEnabled = true,
    this.prayerReminderMinutes = 15,
    this.azkarNotifications = true,
    this.reciter = 'مشاري راشد العفاسي',
    this.language = 'العربية',
    this.selectedAdhanVoiceId = 'default_adhan',
    this.selectedIqamaVoiceId = 'default_iqama',
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? prayerNotifications,
    bool? adhanEnabled,
    bool? iqamaEnabled,
    int? prayerReminderMinutes,
    bool? azkarNotifications,
    String? reciter,
    String? language,
    String? selectedAdhanVoiceId,
    String? selectedIqamaVoiceId,
  }) => SettingsState(
    isDarkMode: isDarkMode ?? this.isDarkMode,
    prayerNotifications: prayerNotifications ?? this.prayerNotifications,
    adhanEnabled: adhanEnabled ?? this.adhanEnabled,
    iqamaEnabled: iqamaEnabled ?? this.iqamaEnabled,
    prayerReminderMinutes: prayerReminderMinutes ?? this.prayerReminderMinutes,
    azkarNotifications: azkarNotifications ?? this.azkarNotifications,
    reciter: reciter ?? this.reciter,
    language: language ?? this.language,
    selectedAdhanVoiceId: selectedAdhanVoiceId ?? this.selectedAdhanVoiceId,
    selectedIqamaVoiceId: selectedIqamaVoiceId ?? this.selectedIqamaVoiceId,
  );
}
