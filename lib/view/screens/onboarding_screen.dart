import 'package:flutter/material.dart';
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
        child: Consumer<OnboardingViewModel>(
          builder: (context, viewModel, _) {
            return Stack(
              children: [
                /// PAGE VIEW - Now fully responsive
                PageView.builder(
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

                /// BOTTOM CONTROLS
                Column(
                  children: [
                    const Spacer(),
                    _buildPageIndicators(viewModel),
                    SizedBox(height: isTablet ? 24 : 32),
                    _buildActionButton(context, viewModel),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom +
                          (isTablet ? 16 : (isFoldable ? 8 : 24)),  // 24 for phones
                    ),
                  ],
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

    // Fixed dimensions - no percentage-based calculations
    final topSpacing = _getTopSpacing(screenHeight, isLandscape, isFoldable);
    final imageCardSize = _getImageCardSize(screenSize, isTablet, isFoldable, isLandscape);
    final imageSize = _getImageSize(imageCardSize, isTablet);
    final imageToTextSpacing = _getImageToTextSpacing(isLandscape, isFoldable);
    final textMaxWidth = _getTextMaxWidth(screenWidth, isTablet, isFoldable);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,  // ← FIXED: Changed from center
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

                  /// ONLY FOR PHONES - Add extra spacing before text
                  if (!isTablet && !isFoldable)
                    SizedBox(height: 120),

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
                  SizedBox(height: isLandscape ? 20 : 40),
                ],
              ),
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

  double _getTopSpacing(double screenHeight, bool isLandscape, bool isFoldable) {
    // Landscape mode - minimal spacing
    if (isLandscape) return 16.0;

    // Foldable devices - moderate spacing
    if (isFoldable) return 32.0;

    // PHONES ONLY - Push content downward
    // Tall phones (e.g., Pixel Fold open, Galaxy S23 Ultra, iPhone Pro Max)
    if (screenHeight > 800) {
      return 110.0;  // Increased from 60 to push down more
    }
    // Normal phones (e.g., iPhone SE, Pixel 5, standard devices)
    else {
      return 150.0;  // Increased from 40 to push down significantly
    }
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

  double _getImageToTextSpacing(bool isLandscape, bool isFoldable) {
    if (isLandscape) return 20.0;
    if (isFoldable) return 28.0;
    return 32.0;
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
}

// Refined ver of OB1 + OB2 --- Not suitable for large screen
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

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Consumer<OnboardingViewModel>(
          builder: (context, viewModel, _) {
            return Stack(
              children: [
                /// PAGE VIEW
                PageView.builder(
                  controller: _pageController,
                  itemCount: viewModel.onboardingPages.length,
                  onPageChanged: viewModel.setCurrentPage,
                  itemBuilder: (context, index) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 375),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _OnboardingContent(
                            page: viewModel.onboardingPages[index],
                            l10n: l10n,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                /// BOTTOM CONTROLS
                Column(
                  children: [
                    const Spacer(),
                    _buildPageIndicators(viewModel),
                    const SizedBox(height: 24),
                    _buildActionButton(context, viewModel),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 8,
                    ),
                  ],
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

    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SizedBox(
        width: screenWidth > 375 ? 343 : double.infinity,
        height: screenWidth < 360 ? 56 : 60,
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
              fontSize: screenWidth < 360 ? 17 : 18,
              fontWeight: FontWeight.w700,
              height: 1.302,
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

  const _OnboardingContent({
    required this.page,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final titleSize = screenWidth < 360 ? 20.0 : 22.0;
    final bodySize = screenWidth < 360 ? 15.0 : 16.0;

    /// Adaptive but controlled (not % random)
    final imageHeight = (screenHeight * 0.30).clamp(260.0, 310.0);
    final topSpacing = (screenHeight * 0.07).clamp(50.0, 70.0);
    final imageToText = (screenHeight * 0.035).clamp(24.0, 48.0);

    return Column(
      children: [
        SizedBox(height: topSpacing),

        /// IMAGE CARD
        Container(
          width: 298,
          height: imageHeight,
          decoration: BoxDecoration(
            color: AppColors.lightGreenBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: SizedBox(
              width: 216,
              height: 216,
              child: Image.asset(
                page.imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        SizedBox(height: imageToText),

        /// TEXT
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 306),
          child: Column(
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
              const SizedBox(height: 12),
              Text(
                _getLocalizedString(l10n, page.descriptionKey),
                textAlign: TextAlign.center,
                style: AppTypography.onboardingBody.copyWith(
                  fontFamily: 'DMSans',
                  fontSize: bodySize,
                  fontWeight: FontWeight.w500,
                  height: 1.302,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),
      ],
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
      default:
        return key;
    }
  }
}*/


// Temporarily keep it - A merger of OB1 and OB2 - Not suitable for large screens
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

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Consumer<OnboardingViewModel>(
          builder: (context, viewModel, _) {
            return Stack(  // ← Changed to Stack
              children: [
                // PageView with full-screen content (slides)
                PageView.builder(
                  controller: _pageController,
                  itemCount: viewModel.onboardingPages.length,
                  onPageChanged: viewModel.setCurrentPage,
                  itemBuilder: (context, index) {
                    return Container(  // ← Full-screen container
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 375),
                          child: _OnboardingContent(
                            page: viewModel.onboardingPages[index],
                            l10n: l10n,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Fixed Dots and Button (outside PageView)
                Column(
                  children: [
                    const Spacer(),  // Pushes content to bottom
                    _buildPageIndicators(context, viewModel),
                    const SizedBox(height: 24),
                    _buildActionButton(context, viewModel),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageIndicators(BuildContext context, OnboardingViewModel viewModel) {
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
              color: isActive ? AppColors.primaryGreen : AppColors.inactiveDot,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, OnboardingViewModel viewModel) {
    final currentPage = viewModel.onboardingPages[viewModel.currentPageIndex];
    final navigationService = context.read<NavigationService>();
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width > 375 ? 343 : double.infinity,
        height: MediaQuery.of(context).size.width < 360 ? 56.0 : 60.0,
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
              fontSize: MediaQuery.of(context).size.width < 360 ? 17.0 : 18.0,
              fontWeight: FontWeight.w700,
              height: 1.302,
            ),
          ),
        ),
      ),
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

// Separate widget for content (slides)
class _OnboardingContent extends StatelessWidget {
  final OnboardingModel page;
  final AppLocalizations l10n;

  const _OnboardingContent({
    required this.page,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.of(context).size.height;

    final titleSize = screenWidth < 360 ? 20.0 : 22.0;
    final bodySize = screenWidth < 360 ? 15.0 : 16.0;
    final imageHeight = screenHeight * 0.32;

    return Column(
      children: [
        SizedBox(height: screenHeight * 0.06),

        // Image Card
        Container(
          width: 298,
          height: imageHeight.clamp(260.0, 310.0),
          decoration: BoxDecoration(
            color: AppColors.lightGreenBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: SizedBox(
              width: 216,
              height: 216,
              child: Image.asset(
                page.imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        SizedBox(height: screenHeight * 0.035),

        // Text Content
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 306),
          child: Column(
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
              const SizedBox(height: 12),
              Text(
                _getLocalizedString(l10n, page.descriptionKey),
                textAlign: TextAlign.center,
                style: AppTypography.onboardingBody.copyWith(
                  fontFamily: 'DMSans',
                  fontSize: bodySize,
                  fontWeight: FontWeight.w500,
                  height: 1.302,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),

        const Spacer(), // Pushes content up to create space at bottom
      ],
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
      default:
        return key;
    }
  }
}*/

// Widget: PageView.builder (nested inside Column)
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

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Consumer<OnboardingViewModel>(
          builder: (context, viewModel, _) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 375),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: viewModel.onboardingPages.length,
                          onPageChanged: viewModel.setCurrentPage,
                          itemBuilder: (context, index) {
                            return _OnboardingPage(
                              page: viewModel.onboardingPages[index],
                              l10n: l10n,
                              pageController: _pageController,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingModel page;
  final AppLocalizations l10n;
  final PageController pageController;

  const _OnboardingPage({
    required this.page,
    required this.l10n,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final titleSize = screenWidth < 360 ? 20.0 : 22.0;
    final bodySize = screenWidth < 360 ? 15.0 : 16.0;
    final buttonHeight = screenWidth < 360 ? 56.0 : 60.0;
    final buttonFontSize = screenWidth < 360 ? 17.0 : 18.0;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.32;

    final viewModel = context.watch<OnboardingViewModel>();

    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.06),


        /// IMAGE CARD
        Container(
          width: 298,
    height: imageHeight.clamp(260.0, 310.0),
          decoration: BoxDecoration(
            color: AppColors.lightGreenBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: SizedBox(
              width: 216,
              height: 216,
              child: Image.asset(
                page.imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),


    SizedBox(height: MediaQuery.of(context).size.height * 0.035),

        /// TEXT
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 306),
          child: Column(
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
              const SizedBox(height: 12),
              Text(
                _getLocalizedString(l10n, page.descriptionKey),
                textAlign: TextAlign.center,
                style: AppTypography.onboardingBody.copyWith(
                  fontFamily: 'DMSans',
                  fontSize: bodySize,
                  fontWeight: FontWeight.w500,
                  height: 1.302,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),

        /// 🔥 FIXED BOTTOM LAYOUT
            const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// DOTS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  viewModel.totalPages,
                      (index) {
                    final isActive =
                        index == viewModel.currentPageIndex;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: isActive ? 39 : 8,
                      height: 8,
                      margin:
                      const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryGreen
                            : AppColors.inactiveDot,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ),

    const SizedBox(height: 24),

              /// BUTTON
              Center(
                child: SizedBox(
    width: MediaQuery.of(context).size.width > 375
    ? 343
        : double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () async {
                      final navigationService =
                      context.read<NavigationService>();

                      if (viewModel.isLastPage) {
                        await viewModel.completeOnboarding();
                        navigationService.pushReplacementNamed(
                          '/language',
                          arguments: {'showBackButton': false},
                        );
                        return;
                      }

                      await pageController.nextPage(
                        duration:
                        const Duration(milliseconds: 280),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      _getLocalizedString(
                          l10n, page.buttonTextKey),
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

    SizedBox(height: MediaQuery.of(context).padding.bottom + 8),

        ],
    ),
      ],
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
}*/


// Padding and overflow issue (After white screen issue)
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

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Consumer<OnboardingViewModel>(
          builder: (context, viewModel, _) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 375),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: viewModel.onboardingPages.length,
                          onPageChanged: viewModel.setCurrentPage,
                          itemBuilder: (context, index) {
                            return _OnboardingPage(
                              page: viewModel.onboardingPages[index],
                              l10n: l10n,
                            );
                          },
                        ),
                      ),
                      _BottomSection(
                        pageController: _pageController,
                        viewModel: viewModel,
                        l10n: l10n,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingModel page;
  final AppLocalizations l10n;

  const _OnboardingPage({
    required this.page,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final titleSize = screenWidth < 360 ? 20.0 : 22.0;
    final bodySize = screenWidth < 360 ? 15.0 : 16.0;

    return Column(
      children: [
        const SizedBox(height: 70),

        /// IMAGE CARD
        Container(
          width: 298,
          height: 310,
          decoration: BoxDecoration(
            color: AppColors.lightGreenBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: SizedBox(
              width: 216,
              height: 216,
              child: Image.asset(
                page.imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        const SizedBox(height: 110),

        /// TEXT
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 306),
          child: Column(
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
              const SizedBox(height: 12),
              Text(
                _getLocalizedString(l10n, page.descriptionKey),
                textAlign: TextAlign.center,
                style: AppTypography.onboardingBody.copyWith(
                  fontFamily: 'DMSans',
                  fontSize: bodySize,
                  fontWeight: FontWeight.w500,
                  height: 1.302,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),

      //  const Spacer(),
     const SizedBox(height: 120),
      ],
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

class _BottomSection extends StatelessWidget {
  final PageController pageController;
  final OnboardingViewModel viewModel;
  final AppLocalizations l10n;

  const _BottomSection({
    required this.pageController,
    required this.viewModel,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final buttonHeight = screenWidth < 360 ? 56.0 : 60.0;
    final fontSize = screenWidth < 360 ? 17.0 : 18.0;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// DOTS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              viewModel.totalPages,
              (index) {
                final isActive = index == viewModel.currentPageIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: isActive ? 39 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 6), // gap = 12
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryGreen
                        : AppColors.inactiveDot,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 48),

          /// BUTTON
          SizedBox(
            width: 343,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: () async {
                final navigationService =
                    Provider.of<NavigationService>(context, listen: false);

                if (viewModel.isLastPage) {
                  await viewModel.completeOnboarding();
                  navigationService.pushReplacementNamed(
                    '/language',
                    arguments: {'showBackButton': false},
                  );
                  return;
                }

                await pageController.nextPage(
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
                _OnboardingPage._getLocalizedString(
                  l10n,
                  viewModel.onboardingPages[viewModel.currentPageIndex]
                      .buttonTextKey,
                ),
                style: AppTypography.buttonText.copyWith(
                  fontFamily: 'DMSans',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  height: 1.302,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}*/

// Must keep this file
/*import 'dart:math' as math;
import 'package:flutter/material.dart';
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

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Consumer<OnboardingViewModel>(
          builder: (context, viewModel, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final frameWidth = math.min(
                  constraints.maxWidth,
                  _OnboardingSpec.frameMaxWidth,
                );

                return Center(
                  child: SizedBox(
                    width: frameWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _OnboardingSpec.horizontalPadding,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: viewModel.onboardingPages.length,
                              onPageChanged: viewModel.setCurrentPage,
                              itemBuilder: (context, index) {
                                return _buildPageContent(
                                  context: context,
                                  page: viewModel.onboardingPages[index],
                                  l10n: l10n,
                                );
                              },
                            ),
                          ),
                          _buildBottomSection(
                            context: context,
                            viewModel: viewModel,
                            l10n: l10n,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageContent({
    required BuildContext context,
    required OnboardingModel page,
    required AppLocalizations l10n,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final shouldScroll =
            constraints.maxHeight < 560 || textScale > 1.15;

        final content = _buildPageBody(
          context: context,
          page: page,
          l10n: l10n,
          maxWidth: constraints.maxWidth,
        );

        if (!shouldScroll) {
          return Align(
            alignment: Alignment.topCenter,
            child: content,
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: content,
        );
      },
    );
  }

  Widget _buildPageBody({
    required BuildContext context,
    required OnboardingModel page,
    required AppLocalizations l10n,
    required double maxWidth,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: _OnboardingSpec.topSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildImageSection(
            context: context,
            page: page,
            maxWidth: maxWidth,
          ),
          const SizedBox(height: _OnboardingSpec.imageToTextSpacing),
          _buildTextContent(
            context: context,
            page: page,
            l10n: l10n,
            maxWidth: maxWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection({
    required BuildContext context,
    required OnboardingModel page,
    required double maxWidth,
  }) {
    final cardWidth = math.min(_OnboardingSpec.imageCardWidth, maxWidth);
    final imageSize = cardWidth * (_OnboardingSpec.imageSize / _OnboardingSpec.imageCardWidth);

    return Center(
      child: SizedBox(
        width: cardWidth,
        child: AspectRatio(
          aspectRatio: _OnboardingSpec.imageCardAspectRatio,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.lightGreenBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: SizedBox.square(
                dimension: imageSize,
                child: Image.asset(
                  page.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.local_florist,
                      color: AppColors.primaryGreen,
                      size: imageSize * 0.42,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent({
    required BuildContext context,
    required OnboardingModel page,
    required AppLocalizations l10n,
    required double maxWidth,
  }) {
    final textWidth = math.min(_OnboardingSpec.textWidth, maxWidth);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final titleFontSize =
        screenWidth < 360 ? _OnboardingSpec.titleFontSizeSmall : _OnboardingSpec.titleFontSize;
    final bodyFontSize =
        screenWidth < 360 ? _OnboardingSpec.bodyFontSizeSmall : _OnboardingSpec.bodyFontSize;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: textWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getLocalizedString(l10n, page.titleKey),
              textAlign: TextAlign.center,
              style: AppTypography.onboardingTitle.copyWith(
                fontFamily: 'DMSans',
                fontSize: titleFontSize,
                fontWeight: FontWeight.w900,
                height: 1.0,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: _OnboardingSpec.titleToBodySpacing),
            Text(
              _getLocalizedString(l10n, page.descriptionKey),
              textAlign: TextAlign.center,
              softWrap: true,
              style: AppTypography.onboardingBody.copyWith(
                fontFamily: 'DMSans',
                fontSize: bodyFontSize,
                fontWeight: FontWeight.w500,
                height: 1.0,
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection({
    required BuildContext context,
    required OnboardingViewModel viewModel,
    required AppLocalizations l10n,
  }) {
    final availableWidth = MediaQuery.sizeOf(context).width;
    final buttonHeight =
        availableWidth < 360 ? _OnboardingSpec.buttonHeightSmall : _OnboardingSpec.buttonHeight;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: _OnboardingSpec.bottomSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPageIndicators(viewModel),
            const SizedBox(height: _OnboardingSpec.indicatorToButtonSpacing),
            SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: ElevatedButton(
                onPressed: () async {
                  final navigationService =
                      Provider.of<NavigationService>(context, listen: false);

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
                  _getLocalizedString(
                    l10n,
                    viewModel.onboardingPages[viewModel.currentPageIndex]
                        .buttonTextKey,
                  ),
                  style: AppTypography.buttonText.copyWith(
                    fontFamily: 'DMSans',
                    fontSize: availableWidth < 360
                        ? _OnboardingSpec.buttonFontSizeSmall
                        : _OnboardingSpec.buttonFontSize,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ],
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
            curve: Curves.easeOutCubic,
            width: isActive ? _OnboardingSpec.activeIndicatorWidth : _OnboardingSpec.indicatorSize,
            height: _OnboardingSpec.indicatorSize,
            margin: const EdgeInsets.symmetric(
              horizontal: _OnboardingSpec.indicatorSpacing,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryGreen
                  : AppColors.inactiveDot.withOpacity(0.9),
              borderRadius: BorderRadius.circular(100),
            ),
          );
        },
      ),
    );
  }

  String _getLocalizedString(AppLocalizations l10n, String key) {
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

class _OnboardingSpec {
  static const double frameMaxWidth = 375;
  static const double horizontalPadding = 16;

  static const double topSpacing = 58;
  static const double imageCardWidth = 298;
  static const double imageCardAspectRatio = 298 / 310;
  static const double imageSize = 216;
  static const double imageToTextSpacing = 66;

  static const double textWidth = 306;
  static const double titleFontSize = 22;
  static const double titleFontSizeSmall = 20;
  static const double bodyFontSize = 16;
  static const double bodyFontSizeSmall = 15;
  static const double titleToBodySpacing = 12;

  static const double indicatorSize = 8;
  static const double activeIndicatorWidth = 39;
  static const double indicatorSpacing = 4;
  static const double indicatorToButtonSpacing = 40;

  static const double buttonHeight = 60;
  static const double buttonHeightSmall = 56;
  static const double buttonFontSize = 18;
  static const double buttonFontSizeSmall = 17;
  static const double bottomSpacing = 16;
}*/
