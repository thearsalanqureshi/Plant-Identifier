import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/navigation/navigation_service.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../data/models/ad_config_model.dart';
import '../../../data/models/onboarding_model.dart';
import '../../view_models/ad_config_view_model.dart';
import '../../../view_models/onboarding_view_model.dart';
import '../widgets/ads/native_ad_factory_ids.dart';
import '../../data/services/analytics_service.dart';
import '../../l10n/app_localizations.dart';
import 'onboarding_native_ad_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _hasShownOnboardingNativeAd = false;
  bool _isAdvancing = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView(screenName: 'Onboarding');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    final isFoldable =
        screenSize.shortestSide >= 480 && screenSize.shortestSide < 600;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Consumer<OnboardingViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: viewModel.onboardingPages.length,
                    onPageChanged: viewModel.setCurrentPage,
                    itemBuilder: (context, index) {
                      return _OnboardingContent(
                        page: viewModel.onboardingPages[index],
                        l10n: l10n,
                        isTablet: isTablet,
                        isFoldable: isFoldable,
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  left: false,
                  bottom: true,
                  right: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: isTablet ? 16 : (isFoldable ? 8 : 24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPageIndicators(viewModel),
                        SizedBox(height: isTablet ? 24 : 32),
                        _buildActionButton(context, viewModel),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageIndicators(OnboardingViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(viewModel.totalPages, (index) {
        final isActive = index == viewModel.currentPageIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: isActive ? 39 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGreen : AppColors.inactiveDot,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    OnboardingViewModel viewModel,
  ) {
    final currentPage = viewModel.onboardingPages[viewModel.currentPageIndex];
    final navigationService = context.read<NavigationService>();
    final l10n = AppLocalizations.of(context);

    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    final isFoldable =
        screenSize.shortestSide >= 480 && screenSize.shortestSide < 600;

    // Adaptive button dimensions
    final buttonWidth = isTablet
        ? 400.0
        : (screenSize.width > 600 ? 343.0 : double.infinity);
    final buttonHeight = isFoldable
        ? 52.0
        : (screenSize.width < 360 ? 56.0 : 60.0);
    final buttonFontSize = isFoldable
        ? 16.0
        : (screenSize.width < 360 ? 17.0 : 18.0);
    final horizontalPadding = isTablet ? 32.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Center(
        child: SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: () => _handleActionButtonPressed(
              context,
              viewModel,
              navigationService,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              _getLocalizedString(l10n, currentPage.buttonTextKey),
              style: AppTypography.buttonText.copyWith(
                fontFamily: 'DMSans',
                fontSize: buttonFontSize,
                fontWeight: FontWeight.w700,
                height: 1.302,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleActionButtonPressed(
    BuildContext context,
    OnboardingViewModel viewModel,
    NavigationService navigationService,
  ) async {
    if (_isAdvancing) {
      return;
    }

    _isAdvancing = true;

    try {
      if (viewModel.isLastPage) {
        await viewModel.completeOnboarding();
        navigationService.pushReplacementNamed(AppRoutes.home);
        return;
      }

      final adConfig = context.read<AdConfigViewModel>().config;
      if (_shouldShowOnboardingNativeAd(adConfig, viewModel)) {
        await _showOnboardingNativeAd(context, adConfig);
        if (!mounted) {
          return;
        }
      }

      await _goToNextOnboardingPage();
    } finally {
      if (mounted) {
        _isAdvancing = false;
      }
    }
  }

  bool _shouldShowOnboardingNativeAd(
    AdConfigModel config,
    OnboardingViewModel viewModel,
  ) {
    return viewModel.currentPageIndex == 1 &&
        !_hasShownOnboardingNativeAd &&
        config.isAdsMasterEnabled &&
        config.onboardingNativeEnabled &&
        config.onboardingNativeAdId.trim().isNotEmpty;
  }

  Future<void> _showOnboardingNativeAd(
    BuildContext context,
    AdConfigModel config,
  ) async {
    _hasShownOnboardingNativeAd = true;

    final factoryId = NativeAdFactoryIds.fromVariant(
      config.onboardingNativeVariant,
      fallback: NativeAdFactoryIds.nativeFullScreen,
    );

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'onboarding_full_screen_native'),
        builder: (_) => OnboardingNativeAdScreen(
          adUnitId: config.onboardingNativeAdId,
          factoryId: factoryId,
          variant: factoryId,
          ctaColor: config.nativeCtaColor,
          textColor: config.nativeTextColor,
        ),
      ),
    );
  }

  Future<void> _goToNextOnboardingPage() async {
    if (!_pageController.hasClients) {
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  static String _getLocalizedString(AppLocalizations l10n, String key) {
    switch (key) {
      case 'onboarding_title_identify':
        return l10n.onboarding_title_identify;
      case 'onboarding_body_identify':
        return l10n.onboarding_body_identify;
      case 'onboarding_title_diagnose':
        return l10n.onboarding_title_diagnose;
      case 'onboarding_body_diagnose':
        return l10n.onboarding_body_diagnose;
      case 'onboarding_title_care':
        return l10n.onboarding_title_care;
      case 'onboarding_body_care':
        return l10n.onboarding_body_care;
      case 'onboarding_next':
        return l10n.onboarding_next;
      case 'onboarding_lets_go':
        return l10n.onboarding_lets_go;
      default:
        return key;
    }
  }
}

class _OnboardingContent extends StatelessWidget {
  final OnboardingModel page;
  final AppLocalizations l10n;
  final bool isTablet;
  final bool isFoldable;

  const _OnboardingContent({
    required this.page,
    required this.l10n,
    this.isTablet = false,
    this.isFoldable = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final isLandscape = screenWidth > screenHeight;
    final isSmallPhone = screenWidth < 360;

    final titleSize = _getResponsiveTitleSize(
      screenWidth,
      isTablet,
      isFoldable,
    );
    final bodySize = _getResponsiveBodySize(screenWidth, isTablet, isFoldable);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        final imageCardSize = _getImageCardSize(
          screenSize,
          availableHeight,
          isTablet,
          isFoldable,
          isLandscape,
        );

        final imageSize = _getImageSize(imageCardSize, isTablet);
        final textMaxWidth = _getTextMaxWidth(
          screenWidth,
          isTablet,
          isFoldable,
        );

        final imageToTextSpacing = _getImageToTextSpacing(
          availableHeight,
          isLandscape,
          isTablet,
          isFoldable,
        );

        final content = Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: textMaxWidth, minWidth: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: imageCardSize.width,
                  height: imageCardSize.height,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreenBg,
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 12),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: Image.asset(
                        page.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.local_florist,
                            color: AppColors.primaryGreen,
                            size: imageSize * 0.5,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: imageToTextSpacing + 48),
                Text(
                  _getLocalizedString(l10n, page.titleKey),
                  textAlign: TextAlign.center,
                  style: AppTypography.onboardingTitle.copyWith(
                    fontFamily: 'DMSans',
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    height: 1.302,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: isSmallPhone ? 8 : 12),
                Text(
                  _getLocalizedString(l10n, page.descriptionKey),
                  textAlign: TextAlign.center,
                  style: AppTypography.onboardingBody.copyWith(
                    fontFamily: 'DMSans',
                    fontSize: bodySize,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: AppColors.mediumGray,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        );

        /*return SizedBox(
        height: constraints.maxHeight,
        child: Column(
          children: [
            SizedBox(height: topSpacing),

            /// Pushes the whole content group slightly downward in a responsive way
            Spacer(flex: isLandscape ? 1 : 3),

            Center(child: content),

            Spacer(flex: isLandscape ? 1 : 2),
          ],
        ),
      );*/

        return SizedBox(
          height: constraints.maxHeight,
          child: Column(
            children: [
              SizedBox(height: availableHeight * 0.12),

              Center(child: content),

              SizedBox(height: availableHeight * 0.12),
            ],
          ),
        );
      },
    );
  }

  double _getResponsiveTitleSize(
    double screenWidth,
    bool isTablet,
    bool isFoldable,
  ) {
    if (isTablet) return 28.0;
    if (isFoldable) return 24.0;
    if (screenWidth < 360) return 20.0;
    return 22.0;
  }

  double _getResponsiveBodySize(
    double screenWidth,
    bool isTablet,
    bool isFoldable,
  ) {
    if (isTablet) return 18.0;
    if (isFoldable) return 16.0;
    if (screenWidth < 360) return 14.0;
    return 16.0;
  }

  Size _getImageCardSize(
    Size screenSize,
    double availableHeight,
    bool isTablet,
    bool isFoldable,
    bool isLandscape,
  ) {
    if (isTablet) {
      final side = (screenSize.width * 0.32).clamp(260.0, 380.0);
      return Size(side, side);
    }

    if (isFoldable) {
      if (isLandscape) return const Size(220, 220);
      return const Size(284, 284);
    }

    if (isLandscape) {
      return const Size(200, 200);
    }

    final side = (screenSize.width * 0.79).clamp(280.0, 328.0);
    return Size(side, side);
  }

  double _getImageSize(Size imageCardSize, bool isTablet) {
    if (isTablet) return imageCardSize.width * 0.65;
    return imageCardSize.width * 0.7;
  }

  double _getImageToTextSpacing(
    double availableHeight,
    bool isLandscape,
    bool isTablet,
    bool isFoldable,
  ) {
    if (isLandscape) return 24.0;
    if (isTablet) return 34.0;
    if (isFoldable) return 30.0;

    if (availableHeight >= 900) return 40.0;
    if (availableHeight >= 800) return 34.0;
    if (availableHeight >= 700) return 28.0;
    return 24.0;
  }

  /* double _getBottomSpacing(
  double availableHeight,
  bool isLandscape,
  bool isTablet,
) {
  if (isLandscape) return 12.0;
  if (isTablet) return 28.0;
  if (availableHeight >= 900) return 28.0;
  if (availableHeight >= 800) return 22.0;
  return 16.0;
}*/

  double _getTextMaxWidth(double screenWidth, bool isTablet, bool isFoldable) {
    if (isTablet) return 620.0;
    if (isFoldable) return 420.0;
    if (screenWidth >= 430) return 360.0;
    if (screenWidth >= 390) return 340.0;
    return 320.0;
  }

  static String _getLocalizedString(AppLocalizations l10n, String key) {
    switch (key) {
      case 'onboarding_title_identify':
        return l10n.onboarding_title_identify;
      case 'onboarding_body_identify':
        return l10n.onboarding_body_identify;
      case 'onboarding_title_diagnose':
        return l10n.onboarding_title_diagnose;
      case 'onboarding_body_diagnose':
        return l10n.onboarding_body_diagnose;
      case 'onboarding_title_care':
        return l10n.onboarding_title_care;
      case 'onboarding_body_care':
        return l10n.onboarding_body_care;
      default:
        return key;
    }
  }
}

/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/navigation/navigation_service.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/onboarding_model.dart';
import '../../../view_models/onboarding_view_model.dart';
import '../../data/services/analytics_service.dart';
import '../../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView(screenName: 'Onboarding');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    final isFoldable = screenSize.shortestSide >= 480 && screenSize.shortestSide < 600;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Consumer<OnboardingViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: viewModel.onboardingPages.length,
                    onPageChanged: viewModel.setCurrentPage,
                    itemBuilder: (context, index) {
                      return _OnboardingContent(
                        page: viewModel.onboardingPages[index],
                        l10n: l10n,
                        isTablet: isTablet,
                        isFoldable: isFoldable,
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  left: false,
                  bottom: true,
                  right: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: isTablet ? 16 : (isFoldable ? 8 : 24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPageIndicators(viewModel),
                        SizedBox(height: isTablet ? 24 : 32),
                        _buildActionButton(context, viewModel),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageIndicators(OnboardingViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        viewModel.totalPages,
            (index) {
          final isActive = index == viewModel.currentPageIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: isActive ? 39 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryGreen
                  : AppColors.inactiveDot,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, OnboardingViewModel viewModel) {
    final currentPage =
    viewModel.onboardingPages[viewModel.currentPageIndex];
    final navigationService = context.read<NavigationService>();
    final l10n = AppLocalizations.of(context)!;

    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    final isFoldable = screenSize.shortestSide >= 480 && screenSize.shortestSide < 600;

    // Adaptive button dimensions
    final buttonWidth = isTablet ? 400.0 : (screenSize.width > 600 ? 343.0 : double.infinity);
    final buttonHeight = isFoldable ? 52.0 : (screenSize.width < 360 ? 56.0 : 60.0);
    final buttonFontSize = isFoldable ? 16.0 : (screenSize.width < 360 ? 17.0 : 18.0);
    final horizontalPadding = isTablet ? 32.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Center(
        child: SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: () async {
              if (viewModel.isLastPage) {
                await viewModel.completeOnboarding();
                navigationService.pushReplacementNamed(
                  '/language',
                  arguments: {'showBackButton': false},
                );
                return;
              }

              await _pageController.nextPage(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              _getLocalizedString(l10n, currentPage.buttonTextKey),
              style: AppTypography.buttonText.copyWith(
                fontFamily: 'DMSans',
                fontSize: buttonFontSize,
                fontWeight: FontWeight.w700,
                height: 1.302,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _getLocalizedString(
      AppLocalizations l10n, String key) {
    switch (key) {
      case 'onboarding_title_identify':
        return l10n.onboarding_title_identify;
      case 'onboarding_body_identify':
        return l10n.onboarding_body_identify;
      case 'onboarding_title_diagnose':
        return l10n.onboarding_title_diagnose;
      case 'onboarding_body_diagnose':
        return l10n.onboarding_body_diagnose;
      case 'onboarding_title_care':
        return l10n.onboarding_title_care;
      case 'onboarding_body_care':
        return l10n.onboarding_body_care;
      case 'onboarding_next':
        return l10n.onboarding_next;
      case 'onboarding_lets_go':
        return l10n.onboarding_lets_go;
      default:
        return key;
    }
  }
}

class _OnboardingContent extends StatelessWidget {
  final OnboardingModel page;
  final AppLocalizations l10n;
  final bool isTablet;
  final bool isFoldable;

  const _OnboardingContent({
    required this.page,
    required this.l10n,
    this.isTablet = false,
    this.isFoldable = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final isLandscape = screenWidth > screenHeight;
    final isSmallPhone = screenWidth < 360;

    // Responsive typography
    final titleSize = _getResponsiveTitleSize(screenWidth, isTablet, isFoldable);
    final bodySize = _getResponsiveBodySize(screenWidth, isTablet, isFoldable);

    final imageCardSize = _getImageCardSize(screenSize, isTablet, isFoldable, isLandscape);
    final imageSize = _getImageSize(imageCardSize, isTablet);
    final textMaxWidth = _getTextMaxWidth(screenWidth, isTablet, isFoldable);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final topSpacing = _getTopSpacing(availableHeight, isLandscape, isFoldable);
        final imageToTextSpacing = _getImageToTextSpacing(availableHeight, isLandscape, isFoldable);
        final bottomSpacing = _getBottomSpacing(availableHeight, isLandscape);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  SizedBox(height: topSpacing),

                  /// IMAGE CARD
                  Container(
                    width: imageCardSize.width,
                    height: imageCardSize.height,
                    decoration: BoxDecoration(
                      color: AppColors.lightGreenBg,
                      borderRadius: BorderRadius.circular(isTablet ? 20 : 10),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: Image.asset(
                          page.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.local_florist,
                              color: AppColors.primaryGreen,
                              size: imageSize * 0.5,
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: imageToTextSpacing),

                  /// TEXT CONTENT - FIXED: Proper constraints for text
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: textMaxWidth,
                        minWidth: 200,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getLocalizedString(l10n, page.titleKey),
                            textAlign: TextAlign.center,
                            style: AppTypography.onboardingTitle.copyWith(
                              fontFamily: 'DMSans',
                              fontSize: titleSize,
                              fontWeight: FontWeight.w900,
                              height: 1.302,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: isSmallPhone ? 8 : 12),
                          Text(
                            _getLocalizedString(l10n, page.descriptionKey),
                            textAlign: TextAlign.center,
                            style: AppTypography.onboardingBody.copyWith(
                              fontFamily: 'DMSans',
                              fontSize: bodySize,
                              fontWeight: FontWeight.w500,
                              height: 1.4,  // FIXED: Better line height for readability
                              color: AppColors.mediumGray,
                            ),
                            softWrap: true,  // FIXED: Ensure text wraps
                            overflow: TextOverflow.visible,  // FIXED: No truncation
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// Flexible space at bottom
                  SizedBox(height: bottomSpacing),
                ],
              ),
            ),
          );
      },
    );
  }

  double _getResponsiveTitleSize(double screenWidth, bool isTablet, bool isFoldable) {
    if (isTablet) return 28.0;
    if (isFoldable) return 24.0;
    if (screenWidth < 360) return 20.0;
    return 22.0;
  }

  double _getResponsiveBodySize(double screenWidth, bool isTablet, bool isFoldable) {
    if (isTablet) return 18.0;
    if (isFoldable) return 16.0;
    if (screenWidth < 360) return 14.0;
    return 16.0;
  }

  /* _getTopSpacing(double screenHeight, bool isLandscape, bool isFoldable) {
    if (isLandscape) return 16.0;
    if (isFoldable) return 32.0;
    // Fixed range, not percentage-based
    return screenHeight > 800 ? 60.0 : 40.0;
  }*/

  double _getTopSpacing(double availableHeight, bool isLandscape, bool isFoldable) {
    if (isLandscape) return 16.0;
    if (isFoldable) return 28.0;
    if (availableHeight >= 760) return 56.0;
    if (availableHeight >= 700) return 44.0;
    return 32.0;
  }

  Size _getImageCardSize(Size screenSize, bool isTablet, bool isFoldable, bool isLandscape) {
    if (isTablet) {
      final width = screenSize.width * 0.35;  // Smaller percentage for tablets
      return Size(width.clamp(280.0, 400.0), width.clamp(280.0, 400.0));
    }

    if (isFoldable) {
      if (isLandscape) {
        return const Size(240, 240);
      }
      return const Size(280, 280);
    }

    if (isLandscape) {
      return const Size(200, 200);
    }

    final width = (screenSize.width * 0.95).clamp(300.0, 320.0);
    return Size(width, width);
  }

  double _getImageSize(Size imageCardSize, bool isTablet) {
    if (isTablet) return imageCardSize.width * 0.65;
    return imageCardSize.width * 0.7;
  }

  double _getImageToTextSpacing(double availableHeight, bool isLandscape, bool isFoldable) {
    if (isLandscape) return 20.0;
    if (isFoldable) return 24.0;
    if (availableHeight >= 760) return 28.0;
    return 22.0;
  }

  double _getBottomSpacing(double availableHeight, bool isLandscape) {
    if (isLandscape) return 12.0;
    if (availableHeight >= 760) return 20.0;
    return 12.0;
  }

  double _getTextMaxWidth(double screenWidth, bool isTablet, bool isFoldable) {
    if (isTablet) return 600.0;
    if (isFoldable) return 450.0;
    if (screenWidth > 600) return 450.0;
    return 340.0;  // FIXED: Increased from 306 to allow more text space
  }

  /*
  EdgeInsets _getContentPadding(double screenWidth, bool isTablet) {
    if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0);
    }
    return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);
  }
  */


  static String _getLocalizedString(
      AppLocalizations l10n, String key) {
    switch (key) {
      case 'onboarding_title_identify':
        return l10n.onboarding_title_identify;
      case 'onboarding_body_identify':
        return l10n.onboarding_body_identify;
      case 'onboarding_title_diagnose':
        return l10n.onboarding_title_diagnose;
      case 'onboarding_body_diagnose':
        return l10n.onboarding_body_diagnose;
      case 'onboarding_title_care':
        return l10n.onboarding_title_care;
      case 'onboarding_body_care':
        return l10n.onboarding_body_care;
      default:
        return key;
    }
  }
}*/
