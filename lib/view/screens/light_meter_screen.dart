//L2
/*import 'dart:math' as math;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/navigation/app_routes.dart';
import '../../app/navigation/navigation_service.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/responsive_helper.dart';
import '../../view_models/light_meter_view_model.dart';

class LightMeterScreen extends StatefulWidget {
  const LightMeterScreen({super.key});

  @override
  State<LightMeterScreen> createState() => _LightMeterScreenState();
}

class _LightMeterScreenState extends State<LightMeterScreen> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final viewModel = Provider.of<LightMeterViewModel>(context, listen: false);
    await viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primaryGreen),
              SizedBox(height: ResponsiveHelper.standardSpacing(context)),
              Text(
                l10n.light_meter_initializing,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String error) {
    final l10n = AppLocalizations.of(context);
    final isTablet = context.isTablet;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32.0 : 20.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.white, size: 48),
                  SizedBox(height: ResponsiveHelper.standardSpacing(context)),
                  Text(
                    l10n.light_meter_error_title,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.smallSpacing(context)),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                  ),
                  SizedBox(height: ResponsiveHelper.largeSpacing(context)),
                  SizedBox(
                    width: isTablet ? 240.0 : double.infinity,
                    height: isTablet ? 52.0 : 56.0,
                    child: ElevatedButton(
                      onPressed: _initializeServices,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        l10n.light_meter_retry,
                        style: AppTypography.buttonText.copyWith(
                          fontSize: _clampedFontSize(context, 16, min: 15, max: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainScreen(BuildContext context, LightMeterViewModel viewModel) {
    final isTablet = context.isTablet;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (viewModel.cameraController != null)
            _buildBlurredCameraBackground(viewModel)
          else
            const Positioned.fill(child: ColoredBox(color: Colors.black)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape = constraints.maxWidth > constraints.maxHeight;
                final horizontalPadding = isTablet ? 24.0 : 16.0;
                final maxContentWidth = math.min(
                  constraints.maxWidth,
                  isTablet ? 720.0 : constraints.maxWidth,
                );
                final contentWidth = math.max(
                  0.0,
                  maxContentWidth - (horizontalPadding * 2),
                );
                final circleSize = _resolveCircleSize(
                  width: contentWidth,
                  height: constraints.maxHeight,
                  isLandscape: isLandscape,
                  isTablet: isTablet,
                );

                final topGap = isLandscape ? 10.0 : (isTablet ? 18.0 : 20.0);
                final instructionGap = isLandscape ? 12.0 : (isTablet ? 14.0 : 16.0);
                final circleGap = isLandscape ? 18.0 : (isTablet ? 24.0 : 28.0);
                final cardsGap = isLandscape ? 14.0 : (isTablet ? 20.0 : 60.0);
                final cardsToButtonGap = isLandscape ? 14.0 : (isTablet ? 18.0 : 60.0);
                final bottomGap = isLandscape ? 12.0 : (isTablet ? 18.0 : 24.0);

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildAppBar(context, horizontalPadding),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: topGap)),
                        SliverToBoxAdapter(
                          child: _buildInstructionText(context, horizontalPadding),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: instructionGap)),
                        SliverToBoxAdapter(
                          child: Center(
                            child: _buildCameraCircle(context, viewModel, circleSize),
                          ),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: circleGap)),
                        SliverToBoxAdapter(
                          child: _buildLightStatusCards(
                            context,
                            viewModel,
                            horizontalPadding,
                          ),
                        ),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildActionButtons(context, viewModel, horizontalPadding),
                              SizedBox(height: bottomGap),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredCameraBackground(LightMeterViewModel viewModel) {
    return Positioned.fill(
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

  double _resolveCircleSize({
    required double width,
    required double height,
    required bool isLandscape,
    required bool isTablet,
  }) {
    final widthFactor = isTablet
        ? (isLandscape ? 0.38 : 0.50)
        : (isLandscape ? 0.44 : 0.56);
    final heightFactor = isLandscape ? 0.34 : 0.42;
    final widthBound = width * widthFactor;
    final heightBound = height * heightFactor;

    return math.min(widthBound, heightBound).clamp(150.0, 360.0).toDouble();
  }

  double _clampedFontSize(
      BuildContext context,
      double base, {
        required double min,
        required double max,
      }) {
    return ResponsiveHelper.responsiveFontSize(base, context)
        .clamp(min, max)
        .toDouble();
  }

  String _localizedLightStatus(AppLocalizations l10n, String status) {
    switch (status) {
      case 'Optimal':
        return l10n.light_meter_optimal;
      case 'Measuring':
        return l10n.light_meter_measuring;
      default:
        return status;
    }
  }

  Widget _buildAppBar(BuildContext context, double horizontalPadding) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              l10n.light_meter_title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.languageItem.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: _clampedFontSize(context, 20, min: 18, max: 22),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.white),
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            onPressed: () {
              Provider.of<NavigationService>(context, listen: false)
                  .pushNamed(AppRoutes.lightMeterInfo);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionText(BuildContext context, double horizontalPadding) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Text(
        l10n.light_meter_instruction,
        textAlign: TextAlign.center,
        maxLines: 3,
        softWrap: true,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
          fontSize: _clampedFontSize(context, 16, min: 15, max: 18),
          height: 1.25,
        ),
      ),
    );
  }

  Widget _buildCameraCircle(
      BuildContext context,
      LightMeterViewModel viewModel,
      double size,
      ) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
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
                  const CircularProgressIndicator(color: AppColors.white),
                  const SizedBox(height: 10),
                  Text(
                    l10n.light_meter_starting,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLightStatusCards(
      BuildContext context,
      LightMeterViewModel viewModel,
      double horizontalPadding,
      ) {
    final l10n = AppLocalizations.of(context);
    final isTablet = context.isTablet;
    final cardGap = isTablet ? 16.0 : 12.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusCard(
              context,
              icon: Icons.eco,
              title: l10n.light_meter_optimal,
              value: l10n.light_meter_optimal_range,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: cardGap),
          Expanded(
            child: _buildStatusCard(
              context,
              icon: Icons.lightbulb,
              title: viewModel.isMeasuring
                  ? l10n.light_meter_measuring
                  : _localizedLightStatus(l10n, viewModel.getLightStatus()),
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
    final isTablet = context.isTablet;
    final cardHeight = isTablet ? 104.0 : 92.0;
    final iconSize = isTablet ? 22.0 : 20.0;
    final titleFontSize = _clampedFontSize(context, 14, min: 13, max: 15);
    final valueFontSize = _clampedFontSize(context, 12, min: 11, max: 13);

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
        color: Colors.black.withOpacity(0.3),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 10.0 : 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: iconSize),
            SizedBox(height: isTablet ? 6.0 : 4.0),
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: titleFontSize,
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
                fontSize: valueFontSize,
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

  Widget _buildActionButtons(
      BuildContext context,
      LightMeterViewModel viewModel,
      double horizontalPadding,
      ) {
    final l10n = AppLocalizations.of(context);
    final isTablet = context.isTablet;
    final buttonHeight = isTablet ? 58.0 : 56.0;
    final buttonFontSize = _clampedFontSize(context, 16, min: 15, max: 18);

    if (viewModel.isMeasuring) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: viewModel.takeSingleMeasurement,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.light_meter_measure,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.buttonText.copyWith(
                    fontSize: buttonFontSize,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 14.0 : 12.0),
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: OutlinedButton(
              onPressed: viewModel.resetMeasurement,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.light_meter_reset,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.buttonText.copyWith(
                    color: AppColors.white,
                    fontSize: buttonFontSize,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}*/


//L1
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/light_meter_view_model.dart';
import '../../utils/responsive_helper.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../app/navigation/navigation_service.dart';
import '../../app/navigation/app_routes.dart';
import '../widgets/camera/camera_widgets.dart';

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
      backgroundColor: Colors.black,
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
                'Initialization Failed',
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
                child: Text('Retry'),
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
          child: CameraPreviewHost(
            controller: viewModel.cameraController,
            backgroundColor: Colors.black,
            isReady: viewModel.isInitialized && !viewModel.isInitializing,
          ),
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
              'Light Meter',
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
        'Position your phone at the intended plant placement location.',
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
      child: CameraPreviewHost(
        controller: viewModel.cameraController,
        backgroundColor: Colors.black,
        isReady: viewModel.isInitialized && !viewModel.isInitializing,
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.white),
                const SizedBox(height: 10),
                Text(
                  'Starting Camera...',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
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
              title: 'Optimal',
              value: '1000-10000 LUX',
              color: AppColors.white,
            ),
          ),
          SizedBox(width: ResponsiveHelper.responsiveWidth(15, context)),
          Expanded(
            child: _buildStatusCard(
              context,
              icon: Icons.lightbulb,
              title: viewModel.isMeasuring ? 'Measuring' : viewModel.getLightStatus(),
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
                  'Measure',
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
                  'Reset',
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
}


/*import 'dart:ui';
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
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final viewModel = Provider.of<LightMeterViewModel>(context, listen: false);
    await viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<LightMeterViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isInitialized && viewModel.errorMessage.isEmpty) {
          return _buildLoadingScreen(context, screenHeight);
        }

        if (viewModel.errorMessage.isNotEmpty) {
          return _buildErrorScreen(context, viewModel.errorMessage, screenHeight, screenWidth);
        }

        return _buildMainScreen(context, viewModel);
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context, double screenHeight) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryGreen),
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
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.white, size: 48),
              SizedBox(height: screenHeight * 0.02),
              Text(
                AppLocalizations.of(context).light_meter_initializing,
                textAlign: TextAlign.center,
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

  Widget _buildMainScreen(BuildContext context, LightMeterViewModel viewModel) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (viewModel.cameraController != null)
            _buildBlurredCameraBackground(viewModel)
          else
            Container(color: Colors.black),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final circleSize = _resolveCircleSize(constraints);

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      children: [
                        _buildAppBar(context),
                        const SizedBox(height: 12),
                        _buildInstructionText(context),
                        const SizedBox(height: 16),
                        _buildCameraCircle(context, viewModel, circleSize),
                        const SizedBox(height: 18),
                        _buildLightStatusCards(context, viewModel),
                        const Spacer(),
                        _buildActionButtons(context, viewModel),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _resolveCircleSize(BoxConstraints constraints) {
    final byWidth = constraints.maxWidth * 0.5;
    final byHeight = constraints.maxHeight * 0.34;
    final raw = byWidth < byHeight ? byWidth : byHeight;
    return raw.clamp(170.0, 340.0);
  }

  Widget _buildBlurredCameraBackground(LightMeterViewModel viewModel) {
    return SizedBox.expand(
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

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: Text(
            AppLocalizations.of(context).light_meter_title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildInstructionText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        AppLocalizations.of(context).light_meter_instruction,
        textAlign: TextAlign.center,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
          height: 1.25,
        ),
      ),
    );
  }

  Widget _buildCameraCircle(BuildContext context, LightMeterViewModel viewModel, double circleSize) {
    return SizedBox(
      width: circleSize,
      height: circleSize,
      child: DecoratedBox(
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
                        const CircularProgressIndicator(color: AppColors.white),
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
      ),
    );
  }

  Widget _buildLightStatusCards(BuildContext context, LightMeterViewModel viewModel) {
    return Row(
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
        const SizedBox(width: 12),
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
      height: 96,
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
            Icon(icon, color: color, size: 22),
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

  Widget _buildActionButtons(BuildContext context, LightMeterViewModel viewModel) {
    if (viewModel.isMeasuring) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
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
              style: AppTypography.buttonText.copyWith(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 56,
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
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}*/
