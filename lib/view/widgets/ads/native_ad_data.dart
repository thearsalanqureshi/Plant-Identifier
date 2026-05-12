class NativeAdData {
  final String title;
  final String body;
  final String cta;
  final String? logoAsset;
  final String? mediaAsset;

  const NativeAdData({
    required this.title,
    required this.body,
    required this.cta,
    this.logoAsset,
    this.mediaAsset,
  });

  static const String defaultTitle = 'Easypaisa - Mobile Load';
  static const String defaultBody = 'A warm welcome to our new customers.';
  static const String defaultCta = 'Install';

  static const String easypaisaLogoAsset =
      'assets/images/native_1a_easypaisa_logo.svg';
  static const String easypaisaLogoFallbackAsset =
      'assets/images/native_1a_easypaisa_logo.png';

  static const String native1aMediaSvgAsset = 'assets/images/native_1a.svg';
  static const String native2aMediaSvgAsset = 'assets/images/native_2a.svg';
  static const String native5aMediaSvgAsset = 'assets/images/native_5(a).svg';
  static const String native5aSideMediaSvgAsset =
      'assets/images/native_5(a2).svg';

  static const String native1aMediaFallbackAsset =
      'assets/images/native_1a.png';
  static const String native2aMediaFallbackAsset =
      'assets/images/native_2a.png';
  static const String native5aMediaFallbackAsset =
      'assets/images/native_5(a).png';
  static const String native5aSideMediaFallbackAsset =
      'assets/images/native_5(a2).png';

  static const String native1aMediaAsset = native1aMediaSvgAsset;
  static const String native2aMediaAsset = native2aMediaSvgAsset;
  static const String native5aMediaAsset = native5aMediaSvgAsset;
  static const String native5aSideMediaAsset = native5aSideMediaSvgAsset;

  static const NativeAdData dummy = NativeAdData(
    title: defaultTitle,
    body: defaultBody,
    cta: defaultCta,
    logoAsset: easypaisaLogoAsset,
    mediaAsset: native1aMediaAsset,
  );

  static const NativeAdData dummyNoMedia = NativeAdData(
    title: defaultTitle,
    body: defaultBody,
    cta: defaultCta,
    logoAsset: easypaisaLogoAsset,
  );

  NativeAdData copyWith({
    String? title,
    String? body,
    String? cta,
    String? logoAsset,
    String? mediaAsset,
  }) {
    return NativeAdData(
      title: title ?? this.title,
      body: body ?? this.body,
      cta: cta ?? this.cta,
      logoAsset: logoAsset ?? this.logoAsset,
      mediaAsset: mediaAsset ?? this.mediaAsset,
    );
  }
}
