import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../l10n/app_localizations.dart';
import '../../view_models/light_meter_view_model.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../app/navigation/navigation_service.dart';
import '../../app/navigation/app_routes.dart';

class LightMeterScreen extends StatefulWidget {
  const LightMeterScreen({super.key});

  @override
  State<LightMeterScreen> createState() => _LightMeterScreenState();
}

class _LightMeterScreenState extends State<LightMeterScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('💣 ${runtimeType} INIT STATE');
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final viewModel = Provider.of<LightMeterViewModel>(context, listen: false);
    await viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('💣 ${runtimeType} BUILD CALLED');

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<LightMeterViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isInitialized && viewModel.errorMessage.isEmpty) {
          return _buildLoadingScreen(context, screenHeight, screenWidth);
        }

        if (viewModel.errorMessage.isNotEmpty) {
          return _buildErrorScreen(context, viewModel.errorMessage, screenHeight, screenWidth);
        }

        return _buildMainScreen(context, viewModel, screenHeight, screenWidth);
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context, double screenHeight, double screenWidth) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryGreen),
            SizedBox(height: screenHeight * 0.02),
            Text(
              AppLocalizations.of(context).light_meter_initializing,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String error, double screenHeight, double screenWidth) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.white, size: 48),
              SizedBox(height: screenHeight * 0.02),
              Text(
                AppLocalizations.of(context).light_meter_initializing,
                style: AppTypography.bodyLarge.copyWith(color: AppColors.white),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                error,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
              ),
              SizedBox(height: screenHeight * 0.03),
              ElevatedButton(
                onPressed: _initializeServices,
                child: Text(AppLocalizations.of(context).light_meter_retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainScreen(BuildContext context, LightMeterViewModel viewModel,
      double screenHeight, double screenWidth) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Blurred Camera Background
          if (viewModel.cameraController != null)
            _buildBlurredCameraBackground(context, viewModel)
          else
            Container(color: Colors.black),

          // UI Content - WRAPPED in SafeArea (stays visible)
          SafeArea(
            child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  _buildAppBar(context, screenWidth),
                  SizedBox(height: screenHeight * 0.02),
                  _buildInstructionText(context, screenWidth),
                  SizedBox(height: screenHeight * 0.05),
                  _buildCameraCircle(context, viewModel, screenWidth),
                  SizedBox(height: screenHeight * 0.07),
                  _buildLightStatusCards(context, viewModel, screenWidth),
                  const Spacer(),
                  _buildActionButtons(context, viewModel, screenHeight, screenWidth),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    
  }

  Widget _buildBlurredCameraBackground(BuildContext context, LightMeterViewModel viewModel) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: CameraPreview(viewModel.cameraController!),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context).light_meter_title,
              textAlign: TextAlign.center,
              style: AppTypography.languageItem.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.white),
            onPressed: () {
              Provider.of<NavigationService>(context, listen: false)
                  .pushNamed(AppRoutes.lightMeterInfo);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionText(BuildContext context, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.12),
      child: Text(
        AppLocalizations.of(context).light_meter_instruction,
        textAlign: TextAlign.center,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildCameraCircle(BuildContext context, LightMeterViewModel viewModel, double screenWidth) {
    double circleSize = screenWidth * 0.5; // 50% of screen width

    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: viewModel.isMeasuring ? Colors.green : AppColors.white,
          width: 3,
        ),
      ),
      child: ClipOval(
        child: viewModel.cameraController != null
            ? CameraPreview(viewModel.cameraController!)
            : Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.white),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context).light_meter_starting,
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLightStatusCards(BuildContext context, LightMeterViewModel viewModel, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusCard(
              context,
              icon: Icons.eco,
              title: AppLocalizations.of(context).light_meter_optimal,
              value: AppLocalizations.of(context).light_meter_optimal_range,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: _buildStatusCard(
              context,
              icon: Icons.lightbulb,
              title: viewModel.isMeasuring
                  ? AppLocalizations.of(context).light_meter_measuring
                  : viewModel.getLightStatus(),
              value: '${viewModel.luxValue.round()} LUX',
              color: (viewModel.luxValue == 0.0 || viewModel.isMeasuring)
                  ? AppColors.white
                  : viewModel.getStatusColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
        color: Colors.black.withOpacity(0.3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, LightMeterViewModel viewModel,
      double screenHeight, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Column(
        children: [
          if (!viewModel.isMeasuring) ...[
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: viewModel.takeSingleMeasurement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context).light_meter_measure,
                  style: AppTypography.buttonText.copyWith(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                onPressed: viewModel.resetMeasurement,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context).light_meter_reset,
                  style: AppTypography.buttonText.copyWith(
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('💡 LightMeterScreen: Simple dispose');
    super.dispose(); // Cleanup handled by CameraManager
  }
}


/*  ------- Correct but unresponsive ------
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../l10n/app_localizations.dart';
import '../../view_models/light_meter_view_model.dart';
import '../../utils/responsive_helper.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../app/navigation/navigation_service.dart';
import '../../app/navigation/app_routes.dart';

class LightMeterScreen extends StatefulWidget {
  const LightMeterScreen({super.key});

  @override
  State<LightMeterScreen> createState() => _LightMeterScreenState();
}

class _LightMeterScreenState extends State<LightMeterScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('💣 ${runtimeType} INIT STATE');
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final viewModel = Provider.of<LightMeterViewModel>(context, listen: false);
    await viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
   debugPrint('💣 ${runtimeType} BUILD CALLED');

    return Consumer<LightMeterViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isInitialized && viewModel.errorMessage.isEmpty) {
          return _buildLoadingScreen(context);
        }

        if (viewModel.errorMessage.isNotEmpty) {
          return _buildErrorScreen(context, viewModel.errorMessage);
        }

        return _buildMainScreen(context, viewModel);
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryGreen),
            SizedBox(height: ResponsiveHelper.standardSpacing(context)),
            Text(
              'Initializing Camera...',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String error) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(20, context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.white, size: 48),
              SizedBox(height: ResponsiveHelper.standardSpacing(context)),
              Text(
              //  'Initialization Failed',
              AppLocalizations.of(context).light_meter_initializing,
                style: AppTypography.bodyLarge.copyWith(color: AppColors.white),
              ),
              SizedBox(height: ResponsiveHelper.smallSpacing(context)),
              Text(
                error,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
              ),
              SizedBox(height: ResponsiveHelper.largeSpacing(context)),
              ElevatedButton(
                onPressed: _initializeServices,
              //  child: Text('Retry'),
              child: Text(AppLocalizations.of(context).light_meter_retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainScreen(BuildContext context, LightMeterViewModel viewModel) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        // Blurred Camera Background
        if (viewModel.cameraController != null) // CHANGE
          _buildBlurredCameraBackground(context, viewModel)
        else
          Container(color: Colors.black),
        
        // UI Content
        SafeArea(
          child: Container(
            color: Colors.transparent, 
            child: Column(
              children: [
                _buildAppBar(context),
                SizedBox(height: ResponsiveHelper.responsiveHeight(20, context)),
                _buildInstructionText(context),
                SizedBox(height: ResponsiveHelper.responsiveHeight(40, context)),
                _buildCameraCircle(context, viewModel),
                SizedBox(height: ResponsiveHelper.responsiveHeight(60, context)),
                _buildLightStatusCards(context, viewModel),
                const Spacer(),
                _buildActionButtons(context, viewModel),
                SizedBox(height: ResponsiveHelper.responsiveHeight(34, context)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


Widget _buildBlurredCameraBackground(BuildContext context, LightMeterViewModel viewModel) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    child: ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), 
        child: Container(
          color: Colors.black.withOpacity(0.3), 
          child: CameraPreview(viewModel.cameraController!), // CHANGE
        ),
      ),
    ),
  );
}

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.responsiveWidth(16, context),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
           //   'Light Meter',
           AppLocalizations.of(context).light_meter_title,
              textAlign: TextAlign.center,
              style: AppTypography.languageItem.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: ResponsiveHelper.responsiveFontSize(20, context),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.white),
            onPressed: () {
              Provider.of<NavigationService>(context, listen: false)
                  .pushNamed(AppRoutes.lightMeterInfo);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.responsiveWidth(49, context),
      ),
      child: Text(
      //  'Position your phone at the intended plant placement location.',
       AppLocalizations.of(context).light_meter_instruction,
        textAlign: TextAlign.center,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
          fontSize: ResponsiveHelper.responsiveFontSize(16, context),
        ),
      ),
    );
  }

Widget _buildCameraCircle(BuildContext context, LightMeterViewModel viewModel) {
  return Container(
    width: ResponsiveHelper.responsiveWidth(200, context),
    height: ResponsiveHelper.responsiveWidth(200, context),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: viewModel.isMeasuring ? Colors.green : AppColors.white,
        width: 3,
      ),
    ),
    child: ClipOval(
      child: viewModel.cameraController != null // CHANGE
          ? CameraPreview(viewModel.cameraController!)
          : Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.white),
                    SizedBox(height: 10),
                    Text(
                    //  'Starting Camera...',
                    AppLocalizations.of(context).light_meter_starting,
                      style: TextStyle(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
    ),
  );
}

  Widget _buildLightStatusCards(BuildContext context, LightMeterViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.responsiveWidth(16, context),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusCard(
              context,
              icon: Icons.eco,
              title: 
              // 'Optimal',
              AppLocalizations.of(context).light_meter_optimal,
              value: 
              //'1000-10000 LUX',
              AppLocalizations.of(context).light_meter_optimal_range,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: ResponsiveHelper.responsiveWidth(15, context)),
          Expanded(
            child: _buildStatusCard(
              context,
              icon: Icons.lightbulb,
            //  title: viewModel.isMeasuring ? 'Measuring' : viewModel.getLightStatus(),
             title: viewModel.isMeasuring ? AppLocalizations.of(context).light_meter_measuring : viewModel.getLightStatus(),
              value: '${viewModel.luxValue.round()} LUX',
              color: (viewModel.luxValue == 0.0 || viewModel.isMeasuring) 
                  ? AppColors.white 
                  : viewModel.getStatusColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      height: ResponsiveHelper.responsiveHeight(92, context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
        color: Colors.black.withOpacity(0.3),
      ),
      child: Padding( 
        padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(8, context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: ResponsiveHelper.iconSize(context)),
            SizedBox(height: ResponsiveHelper.smallSpacing(context)),
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: ResponsiveHelper.responsiveFontSize(14, context), 
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: ResponsiveHelper.responsiveFontSize(12, context), 
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, LightMeterViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.responsiveWidth(16, context),
      ),
      child: Column(
        children: [
          if (!viewModel.isMeasuring) ...[
            SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.buttonHeight(context),
              child: ElevatedButton(
                onPressed: viewModel.takeSingleMeasurement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
               //   'Measure',
               AppLocalizations.of(context).light_meter_measure,
                  style: AppTypography.buttonText.copyWith(
                    fontSize: ResponsiveHelper.responsiveFontSize(16, context),
                  ),
                ),
              ),
            ),
            SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)), 
            SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.buttonHeight(context),
              child: OutlinedButton(
                onPressed: viewModel.resetMeasurement,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                 // 'Reset',
                 AppLocalizations.of(context).light_meter_reset,
                  style: AppTypography.buttonText.copyWith(
                    color: AppColors.white,
                    fontSize: ResponsiveHelper.responsiveFontSize(16, context),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

@override
void dispose() {
  debugPrint('💡 LightMeterScreen: Simple dispose');
  super.dispose(); // Cleanup handled by CameraManager
}
}*/