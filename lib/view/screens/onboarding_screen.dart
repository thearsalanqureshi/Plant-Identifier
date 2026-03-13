import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/onboarding_view_model.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/onboarding_model.dart';
import '../../../app/navigation/navigation_service.dart';
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
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final isTablet = media.size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Consumer<OnboardingViewModel>(
          builder: (context, viewModel, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: viewModel.setCurrentPage,
                        itemCount: viewModel.onboardingPages.length,
                        itemBuilder: (context, index) {
                          return _buildPageContent(
                            context,
                            viewModel.onboardingPages[index],
                            l10n,
                            isTablet,
                          );
                        },
                      ),
                    ),
                    _buildBottomSection(
                      context,
                      viewModel,
                      l10n,
                      constraints.maxWidth,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageContent(
    BuildContext context,
    OnboardingModel page,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxContentWidth = isTablet ? 680.0 : 420.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildImageSection(context, page, isTablet),
                    const SizedBox(height: 24),
                    _buildTextContent(context, page, l10n, isTablet),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    OnboardingModel page,
    bool isTablet,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerSize = isTablet
        ? (screenWidth * 0.34).clamp(220.0, 360.0)
        : (screenWidth * 0.66).clamp(220.0, 320.0);

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: AppColors.lightGreenBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Image.asset(
          page.imagePath,
          width: containerSize * 0.8,
          height: containerSize * 0.8,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.local_florist,
              color: AppColors.primaryGreen,
              size: containerSize * 0.4,
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextContent(
    BuildContext context,
    OnboardingModel page,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 8),
      child: Column(
        children: [
          Text(
            _getLocalizedString(l10n, page.titleKey),
            textAlign: TextAlign.center,
            style: AppTypography.onboardingTitle.copyWith(
              fontSize: isTablet ? 34 : 28,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getLocalizedString(l10n, page.descriptionKey),
            textAlign: TextAlign.center,
            style: AppTypography.onboardingBody.copyWith(
              fontSize: isTablet ? 22 : 17,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    OnboardingViewModel viewModel,
    AppLocalizations l10n,
    double maxWidth,
  ) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth > 720 ? 560 : maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPageIndicators(viewModel),
            const SizedBox(height: 18),
            _buildActionButton(context, viewModel, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicators(OnboardingViewModel viewModel) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        viewModel.totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: index == viewModel.currentPageIndex ? 36 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: index == viewModel.currentPageIndex
                ? AppColors.activeDot
                : AppColors.inactiveDot,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    OnboardingViewModel viewModel,
    AppLocalizations l10n,
  ) {
    final currentPage = viewModel.onboardingPages[viewModel.currentPageIndex];
    final navigationService = Provider.of<NavigationService>(context, listen: false);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          if (viewModel.isLastPage) {
            await viewModel.completeOnboarding();
            navigationService.pushReplacementNamed('/language', arguments: {'showBackButton': false});
          } else {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Text(
          _getLocalizedString(l10n, currentPage.buttonTextKey),
          style: AppTypography.buttonText.copyWith(fontSize: 18),
        ),
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

// Before Refactoring 12/03/26 - 02:24pm 
/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/onboarding_view_model.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/onboarding_model.dart';
import '../../../app/navigation/navigation_service.dart';
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
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final isTablet = media.size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Consumer<OnboardingViewModel>(
          builder: (context, viewModel, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: viewModel.setCurrentPage,
                        itemCount: viewModel.onboardingPages.length,
                        itemBuilder: (context, index) {
                          return _buildPageContent(
                            context,
                            viewModel.onboardingPages[index],
                            l10n,
                            isTablet,
                          );
                        },
                      ),
                    ),
                    _buildBottomSection(
                      context,
                      viewModel,
                      l10n,
                      constraints.maxWidth,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageContent(
    BuildContext context,
    OnboardingModel page,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxContentWidth = isTablet ? 680.0 : 420.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildImageSection(context, page, isTablet),
                    const SizedBox(height: 24),
                    _buildTextContent(context, page, l10n, isTablet),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    OnboardingModel page,
    bool isTablet,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerSize = isTablet
        ? (screenWidth * 0.34).clamp(220.0, 360.0)
        : (screenWidth * 0.66).clamp(220.0, 320.0);

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: AppColors.lightGreenBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Image.asset(
          page.imagePath,
          width: containerSize * 0.8,
          height: containerSize * 0.8,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.local_florist,
              color: AppColors.primaryGreen,
              size: containerSize * 0.4,
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextContent(
    BuildContext context,
    OnboardingModel page,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getLocalizedString(l10n, page.titleKey),
            textAlign: TextAlign.center,
            style: AppTypography.onboardingTitle.copyWith(
              fontSize: isTablet ? 34 : 28,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getLocalizedString(l10n, page.descriptionKey),
            textAlign: TextAlign.center,
            style: AppTypography.onboardingBody.copyWith(
              fontSize: isTablet ? 22 : 17,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    OnboardingViewModel viewModel,
    AppLocalizations l10n,
    double maxWidth,
  ) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth > 720 ? 560 : maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPageIndicators(context, viewModel),
            const SizedBox(height: 18),
            _buildActionButton(context, viewModel, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicators(BuildContext context, OnboardingViewModel viewModel) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        viewModel.totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: index == viewModel.currentPageIndex ? 36 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: index == viewModel.currentPageIndex
                ? AppColors.activeDot
                : AppColors.inactiveDot,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    OnboardingViewModel viewModel,
    AppLocalizations l10n,
  ) {
    final currentPage = viewModel.onboardingPages[viewModel.currentPageIndex];
    final navigationService = Provider.of<NavigationService>(context, listen: false);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          if (viewModel.isLastPage) {
            await viewModel.completeOnboarding();
            navigationService.pushReplacementNamed('/language', arguments: {'showBackButton': false});
          } else {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Text(
          _getLocalizedString(l10n, currentPage.buttonTextKey),
          style: AppTypography.buttonText.copyWith(fontSize: 18),
        ),
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
}*/
