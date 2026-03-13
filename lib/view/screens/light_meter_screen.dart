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
}
