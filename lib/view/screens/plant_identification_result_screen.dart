import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/plant_model.dart';
import '../../../utils/constants.dart';
import '../../../view_models/plant_result_view_model.dart';
import '../../l10n/app_localizations.dart';

class PlantIdentificationResultScreen extends StatefulWidget {
  const PlantIdentificationResultScreen({super.key});

  @override
  State<PlantIdentificationResultScreen> createState() =>
      _PlantIdentificationResultScreenState();
}

class _PlantIdentificationResultScreenState
    extends State<PlantIdentificationResultScreen> {
  bool _didInitialize = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitialize) return;
    _didInitialize = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeScreen());
  }

  Future<void> _initializeScreen() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final viewModel = context.read<PlantResultViewModel>();

    if (args == null) return;

    if (args['fromProcessing'] == true && args['imageFile'] is File) {
      await viewModel.identifyPlant(args['imageFile'] as File);
      return;
    }

    if (args['imageFile'] is File) {
      final imageFile = args['imageFile'] as File;
      if (viewModel.plant == null) {
        await viewModel.identifyPlant(imageFile);
      }
      return;
    }

    if (args['scanData'] is Map<String, dynamic>) {
      await viewModel.loadFromHistory(
        args['scanData'] as Map<String, dynamic>,
        args['imagePath'] as String?,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    return Consumer<PlantResultViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: _buildBody(context, viewModel, isTablet),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    PlantResultViewModel viewModel,
    bool isTablet,
  ) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    if (viewModel.error.isNotEmpty) {
      return _buildErrorState(context, viewModel.error, isTablet);
    }

    if (viewModel.plant == null) {
      return _buildEmptyState(context, isTablet);
    }

    return _buildSuccessState(context, viewModel, viewModel.plant!, isTablet);
  }

  Widget _buildSuccessState(
    BuildContext context,
    PlantResultViewModel viewModel,
    Plant plant,
    bool isTablet,
  ) {
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              isTablet ? 18 : 12,
              horizontalPadding,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, isTablet),
                SizedBox(height: isTablet ? 18 : 12),
                _buildPlantImage(viewModel, isTablet),
                const SizedBox(height: 12),
                _buildPlantDetailsCard(context, plant, isTablet),
                const SizedBox(height: 12),
                _buildClimateCard(context, plant, isTablet),
                const SizedBox(height: 12),
                _buildCareScheduleCard(context, plant, isTablet),
                const SizedBox(height: 12),
                _buildSafetyWarningCard(context, plant, isTablet),
                const SizedBox(height: 12),
                _buildActionButtons(context, viewModel, isTablet),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.black,
            size: isTablet ? 28 : 24,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        Expanded(
          child: Text(
            AppLocalizations.of(context).result_plant_identified,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 28 : 20,
              color: AppColors.black,
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildPlantImage(PlantResultViewModel viewModel, bool isTablet) {
    final imageHeight = isTablet ? 260.0 : 180.0;

    return Container(
      width: double.infinity,
      height: imageHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.lightGreenBg,
        image: viewModel.imageFile != null
            ? DecorationImage(
                image: FileImage(viewModel.imageFile!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: viewModel.imageFile == null
          ? Center(
              child: Icon(
                Icons.photo,
                color: AppColors.mediumGray,
                size: isTablet ? 56 : 48,
              ),
            )
          : null,
    );
  }

  Widget _buildPlantDetailsCard(
    BuildContext context,
    Plant plant,
    bool isTablet,
  ) {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plant.plantName,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 24 : 18,
              color: AppColors.black,
            ),
          ),
          if (plant.scientificName.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              plant.scientificName,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w500,
                fontSize: isTablet ? 16 : 13,
                fontStyle: FontStyle.italic,
                color: AppColors.mediumGray,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context).result_about_plant,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 20 : 16,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plant.description,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w500,
              fontSize: isTablet ? 16 : 14,
              color: AppColors.darkGray,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClimateCard(BuildContext context, Plant plant, bool isTablet) {
    final items = [
      (
        AppConstants.temperatureIcon,
        AppLocalizations.of(context).result_temperature,
        plant.temperature,
      ),
      (
        AppConstants.lightIcon,
        AppLocalizations.of(context).result_light,
        plant.light,
      ),
      (
        AppConstants.soilIcon,
        AppLocalizations.of(context).result_soil,
        plant.soil,
      ),
      (
        AppConstants.humidityIcon,
        AppLocalizations.of(context).result_humidity,
        plant.humidity,
      ),
    ];

    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).result_climate_requirements,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 20 : 18,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: items.map((item) {
                  return SizedBox(
                    width: itemWidth,
                    child: _buildClimateItem(
                      icon: item.$1,
                      title: item.$2,
                      value: item.$3,
                      isTablet: isTablet,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClimateItem({
    required String icon,
    required String title,
    required String value,
    required bool isTablet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(icon, width: 16, height: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w500,
                  fontSize: isTablet ? 15 : 14,
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w400,
            fontSize: isTablet ? 14 : 12,
            color: AppColors.darkGray,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildCareScheduleCard(
    BuildContext context,
    Plant plant,
    bool isTablet,
  ) {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).result_care_schedule,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 20 : 18,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 14),
          _buildCareItem(
            icon: AppConstants.wateringIcon,
            title: AppLocalizations.of(context).result_watering,
            description: plant.watering,
            isTablet: isTablet,
          ),
          const SizedBox(height: 12),
          _buildCareItem(
            icon: AppConstants.fertilizingIcon,
            title: AppLocalizations.of(context).result_fertilizing,
            description: plant.fertilizing,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildCareItem({
    required String icon,
    required String title,
    required String description,
    required bool isTablet,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(icon, width: 20, height: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 15 : 14,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w400,
                  fontSize: isTablet ? 14 : 12,
                  color: AppColors.darkGray,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyWarningCard(
    BuildContext context,
    Plant plant,
    bool isTablet,
  ) {
    return _buildCardContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(AppConstants.warningIcon, width: 20, height: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).result_safety_warning,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 15 : 14,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plant.toxicity,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w400,
                    fontSize: isTablet ? 14 : 12,
                    color: AppColors.darkGray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    PlantResultViewModel viewModel,
    bool isTablet,
  ) {
    final buttonHeight = isTablet ? 58.0 : 54.0;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: () async {
              await viewModel.toggleSaveStatus();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    viewModel.isSaved
                        ? AppLocalizations.of(context).result_saved_success
                        : AppLocalizations.of(context).result_removed_success,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: viewModel.isSaved
                  ? AppColors.mediumGray
                  : AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              viewModel.isSaved
                  ? AppLocalizations.of(context).result_saved_button
                  : AppLocalizations.of(context).result_save_button,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w700,
                fontSize: isTablet ? 18 : 16,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.scanner,
              (route) => route.isFirst,
              arguments: {'mode': 'identify'},
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryGreen, width: 0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).result_identify_another,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w700,
                fontSize: isTablet ? 18 : 16,
                color: AppColors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isTablet) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco,
              color: AppColors.mediumGray,
              size: isTablet ? 60 : 48,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).result_no_data,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: isTablet ? 18 : 16,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String error,
    bool isTablet,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.mediumGray,
                size: isTablet ? 60 : 48,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).result_error,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: isTablet ? 16 : 14,
                  color: AppColors.darkGray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context).result_try_again,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}



// Still no Problem - Commenting out for Enhanced Responsiveness 13/03/26 - 07:51am
/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../view_models/plant_result_view_model.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../utils/constants.dart';
import '../../../data/models/plant_model.dart';
import '../../data/models/history_model.dart';
import '../../data/services/history_service.dart';
import '../../l10n/app_localizations.dart';

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class PlantIdentificationResultScreen extends StatefulWidget {
  const PlantIdentificationResultScreen({super.key});

  @override
  State<PlantIdentificationResultScreen> createState() => _PlantIdentificationResultScreenState();
}

class _PlantIdentificationResultScreenState extends State<PlantIdentificationResultScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint('💣 ${runtimeType} INIT STATE');
  }

  Future<void> _initializeScreen() async {
    debugPrint('🎯 _initializeScreen() - SIMPLIFIED');

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final viewModel = Provider.of<PlantResultViewModel>(context, listen: false);

    debugPrint('📋 Args: $args');

    // FLOW 1: Coming from ProcessingScreen with ALREADY saved data
    if (args != null && args['fromProcessing'] == true) {
      debugPrint('✅✅✅ FROM PROCESSING FLOW - Starting identification');

      // Get the image file from arguments
      if (args['imageFile'] != null && args['imageFile'] is File) {
        final imageFile = args['imageFile'] as File;

        // ALWAYS call identifyPlant for new scans
        await viewModel.identifyPlant(imageFile);
      } else {
        debugPrint('❌ No image file in processing flow arguments');
      }
      return;
    }

    // FLOW 2: Traditional image file flow
    if (args != null && args['imageFile'] != null && args['imageFile'] is File) {
      debugPrint('🔄 TRADITIONAL IMAGE FLOW');
      final imageFile = args['imageFile'] as File;

      if (viewModel.plant == null) {
        debugPrint('🎯 Calling identifyPlant() from traditional flow');
        await viewModel.identifyPlant(imageFile);
      } else {
        debugPrint('✅ Plant already identified');
      }
      return;
    }

    // FLOW 3: History flow
    if (args != null && args['scanData'] != null) {
      debugPrint('📚 HISTORY FLOW');
      final scanData = args['scanData'] as Map<String, dynamic>;
      final imagePath = args['imagePath'] as String?;
      await viewModel.loadFromHistory(scanData, imagePath);
      return;
    }

    debugPrint('❌ NO VALID FLOW DETECTED');
  }

  // Add this helper method
  Future<void> _loadMostRecentScan(PlantResultViewModel viewModel) async {
    try {
      debugPrint('🔍 Loading most recent scan from history');
      final historyService = HistoryService();
      final allScans = await historyService.getScanHistory();

      if (allScans.isNotEmpty) {
        final latestScan = allScans.first;
        debugPrint('✅ Found latest scan: ${latestScan.plantName}');

        // Load it into viewModel
        await viewModel.loadFromHistory(
          latestScan.resultData ?? {},
          latestScan.imagePath,
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading recent scan: $e');
    }
  }

  // Helper method for new scan processing
  Future<void> _processNewScan(PlantResultViewModel viewModel, File imageFile) async {
    debugPrint('🔥🔥🔥 PROCESSING NEW SCAN');
    debugPrint('📁 Image path: ${imageFile.path}');
    debugPrint('📁 Image exists: ${await imageFile.exists()}');

    try {
      // CRITICAL: Reset viewModel
      debugPrint('🔄 Resetting viewModel...');
      viewModel.reset();

      // Set image file
      viewModel.setImageFile(imageFile);

      // CALL identifyPlant - THIS IS WHAT SAVES TO HISTORY
      debugPrint('🎯🎯🎯 CALLING identifyPlant() - THIS SAVES TO HIVE');
      await viewModel.identifyPlant(imageFile);
      debugPrint('✅✅✅ identifyPlant() COMPLETED - SCAN SHOULD BE SAVED');

      // Immediate verification
      debugPrint('🔍 Verifying save immediately...');
      await _verifyImmediateSave(viewModel);
    } catch (e) {
      debugPrint('💥💥💥 SCAN PROCESSING ERROR: $e');
      debugPrint('💥 Stack trace: ${e.toString()}');
      _showError('Failed to identify plant: $e');
    }
  }

  // Immediate verification helper
  Future<void> _verifyImmediateSave(PlantResultViewModel viewModel) async {
    try {
      debugPrint('🔍🔍🔍 IMMEDIATE SAVE VERIFICATION');

      // Wait a moment for async operations
      await Future.delayed(const Duration(milliseconds: 500));

      // Check Hive directly
      final box = await Hive.openBox<ScanHistory>('scanHistory');
      debugPrint('📦 Box keys after scan: ${box.keys.length}');

      // Look for our scan (most recent)
      final allScans = box.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (allScans.isNotEmpty) {
        final latestScan = allScans.first;
        debugPrint('✅✅✅ LATEST SCAN IN HIVE:');
        debugPrint('   Plant: ${latestScan.plantName}');
        debugPrint('   Time: ${latestScan.timestamp}');
        debugPrint('   ID: ${latestScan.id}');
        debugPrint('   Type: ${latestScan.type}');
      } else {
        debugPrint('❌❌❌ NO SCANS FOUND IN HIVE!');
      }
    } catch (e) {
      debugPrint('❌ Verification error: $e');
    }
  }

  // Error display helper
  void _showError(String message) {
    debugPrint('💥 UI Error: $message');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('💣 ${runtimeType} BUILD CALLED');

    final screenHeight = MediaQuery.of(context).size.height;

    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
          _initializeScreen();
        }
      });
    }

    return Consumer<PlantResultViewModel>(
      builder: (context, viewModel, child) {
        debugPrint('Result Screen - Plant: ${viewModel.plant?.plantName}');
        debugPrint('Result Screen - Loading: ${viewModel.isLoading}');
        debugPrint('Result Screen - Error: ${viewModel.error}');

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: _buildBody(viewModel, screenHeight),
        );
      },
    );
  }

  Widget _buildBody(PlantResultViewModel viewModel, double screenHeight) {
    if (viewModel.isLoading) {
      return _buildLoadingState();
    }

    if (viewModel.error.isNotEmpty) {
      return _buildErrorState(viewModel.error);
    }

    if (viewModel.plant == null) {
      return _buildEmptyState();
    }

    return _buildPlantInfo(viewModel.plant!, screenHeight);
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryGreen,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco,
            color: AppColors.mediumGray,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).result_no_data,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 16,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantInfo(Plant plant, double screenHeight) {
    return Consumer<PlantResultViewModel>(
      builder: (context, viewModel, child) {
        return _buildSuccessState(viewModel, screenHeight);
      },
    );
  }

  Widget _buildSuccessState(PlantResultViewModel viewModel, double screenHeight) {
    final plant = viewModel.plant!;

    return SingleChildScrollView(
      child: Column(
        children: [
          // App Bar
          _buildAppBar(),

          // Plant Image
          _buildPlantImage(viewModel, screenHeight),

          const SizedBox(height: 12),

          // Plant Details Card
          _buildPlantDetailsCard(plant),

          const SizedBox(height: 12),

          // Climate Card
          _buildClimateCard(plant),

          const SizedBox(height: 12),

          // Care Schedule Card
          _buildCareScheduleCard(plant),

          const SizedBox(height: 12),

          // Safety Warning Card
          _buildSafetyWarningCard(plant),

          const SizedBox(height: 12),

          // Action Buttons
          _buildActionButtons(viewModel),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.black,
              size: 24,
            ),
          ),

          // Title
          Expanded(
            child: Center(
              child: Text(
                AppLocalizations.of(context).result_plant_identified,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.black,
                ),
              ),
            ),
          ),

          // Empty space for balance
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildPlantImage(PlantResultViewModel viewModel, double screenHeight) {
    return Container(
      width: double.infinity,
      height: screenHeight * 0.22,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: viewModel.imageFile != null
            ? DecorationImage(
          image: FileImage(viewModel.imageFile!),
          fit: BoxFit.cover,
        )
            : null,
        color: AppColors.lightGreenBg,
      ),
      child: viewModel.imageFile == null
          ? Center(
        child: Icon(
          Icons.photo,
          color: AppColors.mediumGray,
          size: 48,
        ),
      )
          : null,
    );
  }

  Widget _buildPlantDetailsCard(Plant plant) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plant.plantName,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).result_about_plant,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plant.description,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.darkGray,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClimateCard(Plant plant) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).result_climate_requirements,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.black,
            ),
          ),

          const SizedBox(height: 16),

          // Climate Details Grid
          _buildClimateDetails(plant),
        ],
      ),
    );
  }

  Widget _buildClimateDetails(Plant plant) {
    return Column(
      children: [
        // First Row - Temperature & Light
        Row(
          children: [
            Expanded(
              child: _buildClimateItem(
                icon: AppConstants.temperatureIcon,
                title: AppLocalizations.of(context).result_temperature,
                value: plant.temperature,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildClimateItem(
                icon: AppConstants.lightIcon,
                title: AppLocalizations.of(context).result_light,
                value: plant.light,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Second Row - Soil & Humidity
        Row(
          children: [
            Expanded(
              child: _buildClimateItem(
                icon: AppConstants.soilIcon,
                title: AppLocalizations.of(context).result_soil,
                value: plant.soil,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildClimateItem(
                icon: AppConstants.humidityIcon,
                title: AppLocalizations.of(context).result_humidity,
                value: plant.humidity,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClimateItem({
    required String icon,
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: AppColors.darkGray,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildCareScheduleCard(Plant plant) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).result_care_schedule,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.black,
            ),
          ),

          const SizedBox(height: 16),

          // Watering Schedule
          _buildCareItem(
            icon: AppConstants.wateringIcon,
            title: AppLocalizations.of(context).result_watering,
            description: plant.watering,
          ),

          const SizedBox(height: 12),

          // Fertilizing Schedule
          _buildCareItem(
            icon: AppConstants.fertilizingIcon,
            title: AppLocalizations.of(context).result_fertilizing,
            description: plant.fertilizing,
          ),
        ],
      ),
    );
  }

  Widget _buildCareItem({
    required String icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          icon,
          width: 20,
          height: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: AppColors.darkGray,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyWarningCard(Plant plant) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            AppConstants.warningIcon,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).result_safety_warning,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plant.toxicity,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.darkGray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PlantResultViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                await viewModel.toggleSaveStatus();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        viewModel.isSaved
                            ? AppLocalizations.of(context).result_saved_success
                            : AppLocalizations.of(context).result_removed_success,
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                debugPrint('Save action error: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: viewModel.isSaved
                  ? AppColors.mediumGray
                  : AppColors.primaryGreen,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              viewModel.isSaved
                  ? AppLocalizations.of(context).result_saved_button
                  : AppLocalizations.of(context).result_save_button,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.white,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Identify Another Plant Button
          OutlinedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.scanner,
                  (route) => route.isFirst,
              arguments: {'mode': 'identify'},
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: AppColors.primaryGreen,
                width: 0.5,
              ),
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).result_identify_another,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.mediumGray,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).result_error,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).result_try_again,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/


/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../view_models/plant_result_view_model.dart';
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../utils/constants.dart';
import '../../../data/models/plant_model.dart';
import '../../data/models/history_model.dart';
import '../../data/services/history_service.dart';
import '../../l10n/app_localizations.dart';

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class PlantIdentificationResultScreen extends StatefulWidget {
  const PlantIdentificationResultScreen({super.key});

  @override
  State<PlantIdentificationResultScreen> createState() => _PlantIdentificationResultScreenState();
}

class _PlantIdentificationResultScreenState extends State<PlantIdentificationResultScreen> {
 
  bool _initialized = false; 
 
  @override
  void initState() {
    super.initState();
     debugPrint('💣 ${runtimeType} INIT STATE');

   /*
   WidgetsBinding.instance.addPostFrameCallback((_) async {
   await  _initializeScreen();
   });
   */

  }

Future<void> _initializeScreen() async {
  debugPrint('🎯 _initializeScreen() - SIMPLIFIED');
  
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  final viewModel = Provider.of<PlantResultViewModel>(context, listen: false);
  
  debugPrint('📋 Args: $args');
  
  
  /*
  // FLOW 1: Coming from ProcessingScreen with ALREADY saved data
  if (args != null && args['fromProcessing'] == true) {
    debugPrint('✅✅✅ FROM PROCESSING FLOW - Data already saved');
    debugPrint('   Plant: ${args['plantName']}');
    debugPrint('   Scan saved: ${args['scanSaved']}');
    
    // Just verify the viewModel already has data
    if (viewModel.plant != null) {
      debugPrint('✅ ViewModel already has plant data: ${viewModel.plant!.plantName}');
    } else {
      debugPrint('⚠️ ViewModel has no plant data - loading from history');
      // Try to load most recent scan
      await _loadMostRecentScan(viewModel);
    }
    return;
  }
  */


// FLOW 1: Coming from ProcessingScreen with ALREADY saved data
if (args != null && args['fromProcessing'] == true) {
  debugPrint('✅✅✅ FROM PROCESSING FLOW - Starting identification');
  
  // Get the image file from arguments
  if (args['imageFile'] != null && args['imageFile'] is File) {
    final imageFile = args['imageFile'] as File; // DECLARE VARIABLE HERE
    
    // ALWAYS call identifyPlant for new scans
    await viewModel.identifyPlant(imageFile);
  } else {
    debugPrint('❌ No image file in processing flow arguments');
  }
  return;
}



  
  // FLOW 2: Traditional image file flow
  if (args != null && args['imageFile'] != null && args['imageFile'] is File) {
    debugPrint('🔄 TRADITIONAL IMAGE FLOW');
    final imageFile = args['imageFile'] as File;
    
    if (viewModel.plant == null) {
      debugPrint('🎯 Calling identifyPlant() from traditional flow');
      await viewModel.identifyPlant(imageFile);
    } else {
      debugPrint('✅ Plant already identified');
    }
    return;
  }
  
  // FLOW 3: History flow
  if (args != null && args['scanData'] != null) {
    debugPrint('📚 HISTORY FLOW');
    final scanData = args['scanData'] as Map<String, dynamic>;
    final imagePath = args['imagePath'] as String?;
    await viewModel.loadFromHistory(scanData, imagePath);
    return;
  }
  
  debugPrint('❌ NO VALID FLOW DETECTED');
}

// Add this helper method
Future<void> _loadMostRecentScan(PlantResultViewModel viewModel) async {
  try {
    debugPrint('🔍 Loading most recent scan from history');
    final historyService = HistoryService();
    final allScans = await historyService.getScanHistory();
    
    if (allScans.isNotEmpty) {
      final latestScan = allScans.first;
      debugPrint('✅ Found latest scan: ${latestScan.plantName}');
      
      // Load it into viewModel
      await viewModel.loadFromHistory(
        latestScan.resultData ?? {},
        latestScan.imagePath,
      );
    }
  } catch (e) {
    debugPrint('❌ Error loading recent scan: $e');
  }
}

// Helper method for new scan processing
Future<void> _processNewScan(PlantResultViewModel viewModel, File imageFile) async {
  debugPrint('🔥🔥🔥 PROCESSING NEW SCAN');
  debugPrint('📁 Image path: ${imageFile.path}');
  debugPrint('📁 Image exists: ${await imageFile.exists()}');
  
  try {
    // CRITICAL: Reset viewModel
    debugPrint('🔄 Resetting viewModel...');
    viewModel.reset();
    
    // Set image file
    viewModel.setImageFile(imageFile);
    
    // CALL identifyPlant - THIS IS WHAT SAVES TO HISTORY
    debugPrint('🎯🎯🎯 CALLING identifyPlant() - THIS SAVES TO HIVE');
    await viewModel.identifyPlant(imageFile);
    debugPrint('✅✅✅ identifyPlant() COMPLETED - SCAN SHOULD BE SAVED');
    
    // Immediate verification
    debugPrint('🔍 Verifying save immediately...');
    await _verifyImmediateSave(viewModel);
    
  } catch (e) {
    debugPrint('💥💥💥 SCAN PROCESSING ERROR: $e');
    debugPrint('💥 Stack trace: ${e.toString()}');
    _showError('Failed to identify plant: $e');
  }
}

// Immediate verification helper
Future<void> _verifyImmediateSave(PlantResultViewModel viewModel) async {
  try {
    debugPrint('🔍🔍🔍 IMMEDIATE SAVE VERIFICATION');
    
    // Wait a moment for async operations
    await Future.delayed(Duration(milliseconds: 500));
    
    // Check Hive directly
    final box = await Hive.openBox<ScanHistory>('scanHistory');
    debugPrint('📦 Box keys after scan: ${box.keys.length}');
    
    // Look for our scan (most recent)
    final allScans = box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    if (allScans.isNotEmpty) {
      final latestScan = allScans.first;
      debugPrint('✅✅✅ LATEST SCAN IN HIVE:');
      debugPrint('   Plant: ${latestScan.plantName}');
      debugPrint('   Time: ${latestScan.timestamp}');
      debugPrint('   ID: ${latestScan.id}');
      debugPrint('   Type: ${latestScan.type}');
    } else {
      debugPrint('❌❌❌ NO SCANS FOUND IN HIVE!');
    }
  } catch (e) {
    debugPrint('❌ Verification error: $e');
  }
}

// Error display helper
void _showError(String message) {
  debugPrint('💥 UI Error: $message');
  // You can show a dialog or snackbar here if needed
}


  @override
  Widget build(BuildContext context) {
    debugPrint('💣 ${runtimeType} BUILD CALLED');

     if (!_initialized) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
          setState(() {
     
      _initialized = true;
      });
      _initializeScreen();
  }
      });
    }
   

    return Consumer<PlantResultViewModel>(
      builder: (context, viewModel, child) {
       
        debugPrint('Result Screen - Plant: ${viewModel.plant?.plantName}');
        debugPrint('Result Screen - Loading: ${viewModel.isLoading}');
        debugPrint('Result Screen - Error: ${viewModel.error}');
        
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body:  _buildBody(viewModel),
          );
        
      },
    ); 
  }

  Widget _buildBody(PlantResultViewModel viewModel) {
    if (viewModel.isLoading) {
      return _buildLoadingState();
    }
    
    if (viewModel.error.isNotEmpty) {
      return _buildErrorState(viewModel.error);
    }
    
    if (viewModel.plant == null) {
      return _buildEmptyState();
    }
    
    return _buildPlantInfo(viewModel.plant!);
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryGreen,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco,
            color: AppColors.mediumGray,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
          //  'No plant data available',
          AppLocalizations.of(context).result_no_data,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 16,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantInfo(Plant plant) {
    return Consumer<PlantResultViewModel>(
      builder: (context, viewModel, child) {
        return _buildSuccessState(viewModel);
      },
    );
  }

  Widget _buildSuccessState(PlantResultViewModel viewModel) {
    final plant = viewModel.plant!;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // App Bar
          _buildAppBar(),
          
          // Plant Image
          _buildPlantImage(viewModel),
          
          SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
          
          // Plant Details Card
          _buildPlantDetailsCard(plant),
          
          SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
          
          // Climate Card
          _buildClimateCard(plant),
          
          SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
          
          // Care Schedule Card
          _buildCareScheduleCard(plant),
          
          SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
          
          // Safety Warning Card
          _buildSafetyWarningCard(plant),
          
          SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
          
          // Action Buttons
          _buildActionButtons(viewModel),
          
          SizedBox(height: ResponsiveHelper.responsiveHeight(20, context)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(16, context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.mediumGray,
              size: ResponsiveHelper.responsiveWidth(48, context),
            ),
            SizedBox(height: ResponsiveHelper.responsiveHeight(16, context)),
            Text(
            //  'Error',
            AppLocalizations.of(context).result_error,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: ResponsiveHelper.responsiveFontSize(18, context),
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: ResponsiveHelper.responsiveHeight(8, context)),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: ResponsiveHelper.responsiveFontSize(14, context),
                color: AppColors.darkGray,
              ),
            ),
            SizedBox(height: ResponsiveHelper.responsiveHeight(24, context)),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
              //  'Try Again',
              AppLocalizations.of(context).result_try_again,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveHelper.responsiveFontSize(16, context),
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16, // Safe area + fixed
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.black,
              size: ResponsiveHelper.responsiveWidth(24, context),
            ),
          ),
          
          // Title
          Expanded(
            child: Center(
              child: Text(
              //  'Plant Identified',
              AppLocalizations.of(context).result_plant_identified,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveHelper.responsiveFontSize(20, context),
                  color: AppColors.black,
                ),
              ),
            ),
          ),
          
         
         /*
          // Share Button
          GestureDetector(
            onTap: _sharePlantInfo,
            child: SvgPicture.asset(
              AppConstants.shareIcon,
              width: ResponsiveHelper.responsiveWidth(24, context),
              height: ResponsiveHelper.responsiveWidth(24, context),
            ),
          ),
         */

        ],
      ),
    );
  }

  Widget _buildPlantImage(PlantResultViewModel viewModel) {
    return Container(
      width: double.infinity, // Full width
      height: MediaQuery.of(context).size.height * 0.22, // 22% of screen height
      margin: const EdgeInsets.symmetric(horizontal: 16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: viewModel.imageFile != null
            ? DecorationImage(
                image: FileImage(viewModel.imageFile!),
                fit: BoxFit.cover,
              )
            : null,
        color: AppColors.lightGreenBg,
      ),
      child: viewModel.imageFile == null
          ? Center(
              child: Icon(
                Icons.photo,
                color: AppColors.mediumGray,
                size: ResponsiveHelper.responsiveWidth(48, context),
              ),
            )
          : null,
    );
  }

  Widget _buildPlantDetailsCard(Plant plant) {
    return Container(
      width: double.infinity, // Full width
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(16, context)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plant.plantName,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: ResponsiveHelper.responsiveFontSize(18, context),
              color: AppColors.black,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveHeight(8, context)),
          Text(
          //  'About the Plant',
           AppLocalizations.of(context).result_about_plant,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: ResponsiveHelper.responsiveFontSize(16, context),
              color: AppColors.black,
            ),
          ),
          SizedBox(height: ResponsiveHelper.responsiveHeight(8, context)),
          Text(
            plant.description,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w500,
              fontSize: ResponsiveHelper.responsiveFontSize(14, context),
              color: AppColors.darkGray,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClimateCard(Plant plant) {
    return Container(
      width: double.infinity, // Full width
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(16, context)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
          //  'Climate Requirements',
          AppLocalizations.of(context).result_climate_requirements,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: ResponsiveHelper.responsiveFontSize(18, context),
              color: AppColors.black,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.responsiveHeight(16, context)),
          
          // Climate Details Grid
          _buildClimateDetails(plant),
        ],
      ),
    );
  }

  Widget _buildClimateDetails(Plant plant) {
    return Column(
      children: [
        // First Row - Temperature & Light
        Row(
          children: [
            Expanded(
              child: _buildClimateItem(
                icon: AppConstants.temperatureIcon,
              //  title: 'Temperature',
              title: AppLocalizations.of(context).result_temperature,
                value: plant.temperature,
              ),
            ),
            SizedBox(width: ResponsiveHelper.responsiveWidth(16, context)),
            Expanded(
              child: _buildClimateItem(
                icon: AppConstants.lightIcon,
              //  title: 'Light',
              title: AppLocalizations.of(context).result_light,
                value: plant.light,
              ),
            ),
          ],
        ),
        
        SizedBox(height: ResponsiveHelper.responsiveHeight(16, context)),
        
        // Second Row - Soil & Humidity
        Row(
          children: [
            Expanded(
              child: _buildClimateItem(
                icon: AppConstants.soilIcon,
              //  title: 'Soil',
              title: AppLocalizations.of(context).result_soil,
                value: plant.soil,
              ),
            ),
            SizedBox(width: ResponsiveHelper.responsiveWidth(16, context)),
            Expanded(
              child: _buildClimateItem(
                icon: AppConstants.humidityIcon,
              //  title: 'Humidity',
              title: AppLocalizations.of(context).result_humidity,
                value: plant.humidity,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClimateItem({
    required String icon,
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              icon,
              width: ResponsiveHelper.responsiveWidth(16, context),
              height: ResponsiveHelper.responsiveWidth(16, context),
            ),
            SizedBox(width: ResponsiveHelper.responsiveWidth(8, context)),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w500,
                fontSize: ResponsiveHelper.responsiveFontSize(14, context),
                color: AppColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveHelper.responsiveHeight(4, context)),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w400,
            fontSize: ResponsiveHelper.responsiveFontSize(12, context),
            color: AppColors.darkGray,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildCareScheduleCard(Plant plant) {
    return Container(
      width: ResponsiveHelper.responsiveWidth(343, context),
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.responsiveWidth(16, context)),
      padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(16, context)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
          //  'Care Schedule',
          AppLocalizations.of(context).result_care_schedule,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: ResponsiveHelper.responsiveFontSize(18, context),
              color: AppColors.black,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.responsiveHeight(16, context)),
          
          // Watering Schedule
          _buildCareItem(
            icon: AppConstants.wateringIcon,
          //  title: 'Watering',
          title: AppLocalizations.of(context).result_watering,
            description: plant.watering,
          ),
          
          SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
          
          // Fertilizing Schedule
          _buildCareItem(
            icon: AppConstants.fertilizingIcon,
          //  title: 'Fertilizing',
          title: AppLocalizations.of(context).result_fertilizing,

            description: plant.fertilizing,
          ),
        ],
      ),
    );
  }

  Widget _buildCareItem({
    required String icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          icon,
          width: ResponsiveHelper.responsiveWidth(20, context),
          height: ResponsiveHelper.responsiveWidth(20, context),
        ),
        SizedBox(width: ResponsiveHelper.responsiveWidth(12, context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveHelper.responsiveFontSize(14, context),
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: ResponsiveHelper.responsiveHeight(4, context)),
              Text(
                description,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w400,
                  fontSize: ResponsiveHelper.responsiveFontSize(12, context),
                  color: AppColors.darkGray,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyWarningCard(Plant plant) {
    return Container(
      width: ResponsiveHelper.responsiveWidth(343, context),
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.responsiveWidth(16, context)),
      padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(16, context)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            AppConstants.warningIcon,
            width: ResponsiveHelper.responsiveWidth(20, context),
            height: ResponsiveHelper.responsiveWidth(20, context),
          ),
          SizedBox(width: ResponsiveHelper.responsiveWidth(12, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                //  'Safety Warning',
                AppLocalizations.of(context).result_safety_warning,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveHelper.responsiveFontSize(14, context),
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.responsiveHeight(4, context)),
                Text(
                  plant.toxicity,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w400,
                    fontSize: ResponsiveHelper.responsiveFontSize(12, context),
                    color: AppColors.darkGray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PlantResultViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.responsiveWidth(16, context)),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async { 
              try {
                await viewModel.toggleSaveStatus();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        viewModel.isSaved 
                        //  ? 'Saved to My Plants!' 
                        //  : 'Removed from My Plants',

                         ? AppLocalizations.of(context).result_saved_success 
                         : AppLocalizations.of(context).result_removed_success
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                debugPrint('Save action error: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: viewModel.isSaved 
                ? AppColors.mediumGray 
                : AppColors.primaryGreen,
              minimumSize: Size(
                ResponsiveHelper.responsiveWidth(343, context),
                ResponsiveHelper.responsiveHeight(60, context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              viewModel.isSaved 
            //  ? 'Saved to My Plants' 
            //  : 'Save To My Plants',

            ? AppLocalizations.of(context).result_saved_button 
            : AppLocalizations.of(context).result_save_button,

              style: TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w700,
                fontSize: ResponsiveHelper.responsiveFontSize(16, context),
                color: AppColors.white,
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
          
          // Identify Another Plant Button
          OutlinedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.scanner,
              (route) => route.isFirst,
              arguments: {'mode': 'identify'},
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppColors.primaryGreen,
                width: 0.5,
              ),
              minimumSize: Size(
                ResponsiveHelper.responsiveWidth(343, context),
                ResponsiveHelper.responsiveHeight(60, context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
            //  'Identify Another Plant',
            AppLocalizations.of(context).result_identify_another,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w700,
                fontSize: ResponsiveHelper.responsiveFontSize(16, context),
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sharePlantInfo() {
    // Implement share functionality
    debugPrint('Share plant information');
  }
}*/