abstract final class NativeAdFactoryIds {
  static const native1aNoMedia = 'native_1a_no_media';
  static const native1aAdPlacement = 'native_1a_ad_placement';
  static const native1a = 'native_1a';
  static const native2a = 'native_2a';
  static const native3a = 'native_3a';
  static const native3b = 'native_3b';
  static const native5a = 'native_5a';
  static const native6b = 'native_6b';
  static const native6c = 'native_6c';
  static const native7b = 'native_7b';
  static const native8f = 'native_8f';
  static const native9 = 'native_9';
  static const nativeFullScreen = 'native_full_screen';

  static const all = <String>[
    native1aNoMedia,
    native1aAdPlacement,
    native1a,
    native2a,
    native3a,
    native3b,
    native5a,
    native6b,
    native6c,
    native7b,
    native8f,
    native9,
    nativeFullScreen,
  ];

  static String fromVariant(String? variant, {String fallback = native6b}) {
    final normalized = variant
        ?.trim()
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('-', '_');

    switch (normalized) {
      case native1aNoMedia:
      case '1a_no_media':
        return native1aNoMedia;
      case native1aAdPlacement:
      case '1a_ad_placement':
      case '1a_ad_placement_changes':
        return native1aAdPlacement;
      case native1a:
      case '1a':
        return native1a;
      case native2a:
      case '2a':
        return native2a;
      case native3a:
      case '3a':
        return native3a;
      case native3b:
      case '3b':
        return native3b;
      case native5a:
      case '5a':
        return native5a;
      case native6b:
      case '6b':
        return native6b;
      case native6c:
      case '6c':
        return native6c;
      case native7b:
      case '7b':
        return native7b;
      case native8f:
      case '8f':
        return native8f;
      case native9:
      case '9':
        return native9;
      case nativeFullScreen:
      case 'full_screen':
        return nativeFullScreen;
      default:
        return fallback;
    }
  }
}
