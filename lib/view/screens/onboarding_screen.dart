import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../../../utils/responsive_helper.dart';
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
    debugPrint('💣 ${widget.runtimeType} INIT STATE CALLED');
    AnalyticsService.logScreenView(screenName: 'Onboarding');
    debugPrint('📊 Analytics: Onboarding screen viewed');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('💣 ${runtimeType} BUILD CALLED');
    final l10n = AppLocalizations.of(context);

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallDevice = screenHeight < 700;
    final isTablet = screenWidth > 600;



    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Consumer<OnboardingViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      viewModel.setCurrentPage(index);
                    },
                    children: [
                      for (int i = 0; i < viewModel.onboardingPages.length; i++)
                        _buildPageContent(
                          context,
                          viewModel.onboardingPages[i],
                          l10n,
                          screenHeight,
                          screenWidth,
                          isSmallDevice,
                          isTablet,
                        ),
                    ],
                  ),
                ),
                _buildBottomSection(
                    context,
                    viewModel,
                    l10n,
                    screenHeight,
                    isSmallDevice
                ),
              ],
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
      double screenHeight,
      double screenWidth,
      bool isSmallDevice,
      bool isTablet,
      ) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          SizedBox(height: screenHeight * (isSmallDevice ? 0.08 : 0.10)),
          _buildImageSection(context, page, screenHeight, screenWidth, isTablet),
          SizedBox(height: screenHeight * (isSmallDevice ? 0.05 : 0.13)),
          // _buildTextContent(context, page, l10n, screenWidth, isSmallDevice, isTablet),
          _buildTextContent(context, page, l10n, screenHeight, screenWidth, isSmallDevice, isTablet),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildImageSection(
      BuildContext context,
      OnboardingModel page,
      double screenHeight,
      double screenWidth,
      bool isTablet,
      ) {
    double containerSize = isTablet
        ? screenWidth * 0.50
        : screenWidth * 0.80;

    double imageSize = containerSize * 0.8;

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: AppColors.lightGreenBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Image.asset(
          page.imagePath,
          width: imageSize,
          height: imageSize,
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
    );
  }

Widget _buildTextContent(
  BuildContext context,
  OnboardingModel page,
  AppLocalizations l10n,
  double screenHeight,
  double screenWidth,
  bool isSmallDevice,
  bool isTablet,
) {
  double horizontalPadding = isTablet
      ? screenWidth * 0.19
      : screenWidth * 0.13;

  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title - font-weight: 900 (Black), line-height: 100%
        Text(
          _getLocalizedString(l10n, page.titleKey),
          textAlign: TextAlign.center,
          style: AppTypography.onboardingTitle.copyWith(
            fontSize: isTablet ? 32 : (isSmallDevice ? 20 : 22), // Changed to 22px
            fontWeight: FontWeight.w900, // Added Black weight
            height: 1.0, // Changed to 100% line-height
          ),
        ),
        
        SizedBox(height: screenHeight * 0.02),
        
        // Description - font-weight: 500 (Medium), line-height: 100%
        Text(
          _getLocalizedString(l10n, page.descriptionKey),
          textAlign: TextAlign.center,
          style: AppTypography.onboardingBody.copyWith(
            fontSize: isTablet ? 18 : (isSmallDevice ? 14 : 16),
            fontWeight: FontWeight.w500, // Medium weight (already correct)
            height: 1.3, // Changed to 100% line-height
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
      double screenHeight,
      bool isSmallDevice,
      ) {
    return Container(
      padding: EdgeInsets.only(
      //  bottom: screenHeight * (isSmallDevice ? 0.03 : 0.05),
      bottom: 50
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPageIndicators(context, viewModel),
          SizedBox(height: screenHeight * 0.05),
          _buildActionButton(context, viewModel, l10n),
        ],
      ),
    );
  }

  Widget _buildPageIndicators(BuildContext context, OnboardingViewModel viewModel) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          viewModel.totalPages,
              (index) => Container(
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.9,
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
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
          style: AppTypography.buttonText.copyWith(
            fontSize: 18,
          ),
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