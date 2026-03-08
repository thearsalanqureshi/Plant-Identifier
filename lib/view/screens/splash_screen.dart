import 'package:flutter/material.dart';
import '../../data/services/analytics_service.dart';
import '../../l10n/app_localizations.dart';
import '../screens/onboarding_screen.dart';
import '../../../app/theme/app_colors.dart';
import '../../../view_models/splash_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    debugPrint('💣 ${runtimeType} INIT STATE');

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final viewModel = Provider.of<SplashViewModel>(context, listen: false);

    // Log screen view
    AnalyticsService.logScreenView(screenName: 'Splash');
    debugPrint('📊 Analytics: Splash screen viewed');

    // Start progress animation
    _progressController.forward();

    // Initialize app dependencies
    await viewModel.initializeApp();

    // Navigate after total 3 seconds (matches loader duration)
    await viewModel.navigateAfterDelay();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('💣 ${runtimeType} BUILD CALLED');

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Centered Logo and Text
            _buildCenteredContent(screenHeight, screenWidth),
            // Bottom Progress Bar with controlled animation
            _buildAnimatedProgressBar(screenHeight, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildCenteredContent(double screenHeight, double screenWidth) {
    return Positioned(
      top: screenHeight * 0.35, // 35% from top
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Logo/Icon Container
          _buildLogo(screenWidth),
          SizedBox(height: screenHeight * 0.02), // 2% spacing
          // App Name Text
          _buildAppName(screenWidth),
        ],
      ),
    );
  }

  Widget _buildLogo(double screenWidth) {
    double logoSize = screenWidth * 0.25; // 25% of screen width

    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(logoSize / 2), // Perfect circle
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/images/app_logo.svg',
          width: logoSize * 0.6, // 60% of container
          height: logoSize * 0.6,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildAppName(double screenWidth) {
    return Container(
      width: screenWidth * 0.7, // 70% of screen width
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          AppLocalizations.of(context).splash_title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 24,
              ),
        ),
      ),
    );
  }

  Widget _buildAnimatedProgressBar(double screenHeight, double screenWidth) {
    double progressWidth = screenWidth * 0.8; // 80% of screen width
    double progressHeight = 14; // Fixed height

    return Positioned(
      bottom: screenHeight * 0.08, // 8% from bottom
      left: screenWidth * 0.1, // 10% from left (centers the bar)
      child: Container(
        width: progressWidth,
        height: progressHeight,
        decoration: BoxDecoration(
          color: AppColors.progressBackground,
          borderRadius: BorderRadius.circular(progressHeight / 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(progressHeight / 2),
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressController.value,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen,
                ),
                minHeight: progressHeight,
              );
            },
          ),
        ),
      ),
    );
  }
}


/*   ------ Correct but unresponsive
import 'package:flutter/material.dart';
import '../../../utils/responsive_helper.dart';
import '../../data/services/analytics_service.dart';
import '../../l10n/app_localizations.dart';
import '../screens/onboarding_screen.dart';
import '../../../app/theme/app_colors.dart';
import '../../../view_models/splash_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
     debugPrint('💣 ${runtimeType} INIT STATE');

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), 
    );
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final viewModel = Provider.of<SplashViewModel>(context, listen: false);

  
  // Log screen view
  AnalyticsService.logScreenView(screenName: 'Splash');
  debugPrint('📊 Analytics: Splash screen viewed');


    // Start progress animation
    _progressController.forward();

    // Initialize app dependencies
    await viewModel.initializeApp();

    // Navigate after total 3 seconds (matches loader duration)
    await viewModel.navigateAfterDelay();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
   Widget build(BuildContext context) {
    debugPrint('💣 ${runtimeType} BUILD CALLED');


    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        
        child: Stack(
          children: [
            // Centered Logo and Text
            _buildCenteredContent(),
            // Bottom Progress Bar with controlled animation
            _buildAnimatedProgressBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCenteredContent() {
    return Positioned(
      top: ResponsiveHelper.responsiveHeight(306, context),
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Logo/Icon Container - Exactly positioned as per design
          _buildLogo(),
          SizedBox(height: ResponsiveHelper.responsiveHeight(19, context)),
          // App Name Text - Exactly positioned as per design
          _buildAppName(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
  return Container(
    width: ResponsiveHelper.responsiveWidth(100, context),
    height: ResponsiveHelper.responsiveWidth(100, context),
    decoration: BoxDecoration(
      color: AppColors.primaryGreen,
      borderRadius: BorderRadius.circular(ResponsiveHelper.responsiveWidth(50, context)),
    ),
    child: Center(
      child: SvgPicture.asset(
        'assets/images/app_logo.svg', 
        width: ResponsiveHelper.responsiveWidth(60, context),
        height: ResponsiveHelper.responsiveWidth(60, context),
        fit: BoxFit.contain,
      ),
    ),
  );
}


  /*Widget _buildAppName() {
    return SizedBox(
      width: ResponsiveHelper.responsiveWidth(170, context),
      height: ResponsiveHelper.responsiveHeight(31, context),
      child: Text(
      //  'Plant Identifier',
      AppLocalizations.of(context).splash_title, 
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontSize: ResponsiveHelper.responsiveFontSize(24, context),
        ),
      ),
    );
  }*/

Widget _buildAppName() {
  return Container(
    width: MediaQuery.of(context).size.width * 0.7, // 70% of screen width
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        AppLocalizations.of(context).splash_title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontSize: ResponsiveHelper.responsiveFontSize(24, context),
        ),
      ),
    ),
  );
}


  Widget _buildAnimatedProgressBar() {
    return Positioned(
      bottom: ResponsiveHelper.responsiveHeight(66, context),
      left: ResponsiveHelper.responsiveWidth(38, context),
      child: Container(
        width: ResponsiveHelper.responsiveWidth(300, context),
        height: ResponsiveHelper.responsiveHeight(14.08, context),
        decoration: BoxDecoration(
          color: AppColors.progressBackground,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.responsiveWidth(70.42, context),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.responsiveWidth(70.42, context),
          ),
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressController.value, 
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen,
                ),
                minHeight: ResponsiveHelper.responsiveHeight(14.08, context),
              );
            },
          ),
        ),
      ),
    );
  }
}*/