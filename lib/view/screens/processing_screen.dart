import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../view_models/diagnosis_view_model.dart';
import '../../../view_models/history_view_model.dart';
import '../../../view_models/plant_result_view_model.dart';
import '../../../view_models/water_calculation_view_model.dart';
import '../../data/services/analytics_service.dart';
import '../../l10n/app_localizations.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  File? _imageFile;
  String _mode = 'identify';
  String _location = '';
  String _temperature = '';
  String _wateringFrequency = '';

  bool _didInitialize = false;
  bool _didStartProcessing = false;
  bool _hasLoggedProcessing = false;
  late final DateTime _processingStartTime;

  @override
  void initState() {
    super.initState();
    _processingStartTime = DateTime.now();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitialize) return;
    _didInitialize = true;
    _initializeArguments();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startProcessing());
  }

  @override
  void dispose() {
    _animationController.dispose();

    if (!_hasLoggedProcessing && _mode.isNotEmpty) {
      _logProcessingEvent(
        success: false,
        error: 'Processing screen disposed before completion',
      );
    }

    super.dispose();
  }

  void _initializeArguments() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) return;

    _imageFile = args['imageFile'] as File?;
    _mode = (args['mode'] ?? 'identify') as String;
    _location = (args['location'] ?? '') as String;
    _temperature = (args['temperature'] ?? '') as String;
    _wateringFrequency = (args['wateringFrequency'] ?? '') as String;
  }

  Future<void> _startProcessing() async {
    if (_didStartProcessing || !mounted) return;
    _didStartProcessing = true;

    if (_imageFile == null) {
      _logProcessingEvent(success: false, error: 'Missing image file');
      if (mounted) {
        Navigator.pushReplacementNamed(context, _getFallbackRoute());
      }
      return;
    }

    try {
      switch (_mode) {
        case 'identify':
          await _processPlantIdentification();
          break;
        case 'diagnose':
          await _processPlantDiagnosis();
          break;
        case 'water':
          await _processWaterCalculation();
          break;
        default:
          _logProcessingEvent(success: false, error: 'Unsupported mode: $_mode');
          if (mounted) {
            Navigator.pushReplacementNamed(context, _getFallbackRoute());
          }
      }
    } catch (e) {
      _logProcessingEvent(success: false, error: e.toString());
      if (mounted) {
        Navigator.pushReplacementNamed(context, _getFallbackRoute());
      }
    }
  }

  Future<void> _processPlantIdentification() async {
    final viewModel = context.read<PlantResultViewModel>();
    await viewModel.identifyPlant(_imageFile!);

    _logProcessingEvent(success: true);

    if (!mounted) return;

    try {
      context.read<HistoryViewModel>().loadHistory(forceRefresh: true);
    } catch (_) {}

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.plantIdentificationResult,
      arguments: {'imageFile': _imageFile},
    );
  }

  Future<void> _processPlantDiagnosis() async {
    final diagnosisViewModel = context.read<DiagnosisViewModel>();
    diagnosisViewModel.reset();
    diagnosisViewModel.setImageFile(_imageFile!);
    await diagnosisViewModel.diagnosePlant(_imageFile!);

    _logProcessingEvent(success: true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.plantDiagnosisResult,
      arguments: {'imageFile': _imageFile},
    );
  }

  Future<void> _processWaterCalculation() async {
    final waterViewModel = context.read<WaterCalculationViewModel>();
    waterViewModel.reset();

    await waterViewModel.calculateWaterNeedsWithGemini(
      plantImage: _imageFile!,
      location: _location,
      temperature: _temperature,
      wateringFrequency: _wateringFrequency,
    );

    _logProcessingEvent(success: true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.waterResult);
  }

  void _logProcessingEvent({required bool success, String? error}) {
    if (_hasLoggedProcessing) return;

    final processingTime =
        DateTime.now().difference(_processingStartTime).inMilliseconds;

    AnalyticsService.logProcessingComplete(
      mode: _mode,
      success: success,
      error: error,
      processingTime: processingTime,
    );

    _hasLoggedProcessing = true;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RotationTransition(
                    turns: _animationController,
                    child: Icon(
                      Icons.autorenew,
                      color: AppColors.primaryGreen,
                      size: isTablet ? 52 : 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getProcessingTitle(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 20 : 16,
                      height: 1.2,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getProcessingSubtitle(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontWeight: FontWeight.w500,
                      fontSize: isTablet ? 16 : 14,
                      height: 1.35,
                      color: AppColors.darkGray,
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

  String _getProcessingTitle(BuildContext context) {
    switch (_mode) {
      case 'identify':
        return AppLocalizations.of(context).processing_title_identify;
      case 'diagnose':
        return AppLocalizations.of(context).processing_title_diagnose;
      case 'water':
        return AppLocalizations.of(context).processing_title_water;
      default:
        return AppLocalizations.of(context).processing_title_default;
    }
  }

  String _getProcessingSubtitle(BuildContext context) {
    switch (_mode) {
      case 'identify':
        return AppLocalizations.of(context).processing_subtitle_identify;
      case 'diagnose':
        return AppLocalizations.of(context).processing_subtitle_diagnose;
      case 'water':
        return AppLocalizations.of(context).processing_subtitle_water;
      default:
        return AppLocalizations.of(context).processing_subtitle_default;
    }
  }

  String _getFallbackRoute() {
    switch (_mode) {
      case 'identify':
        return AppRoutes.plantIdentificationResult;
      case 'diagnose':
        return AppRoutes.plantDiagnosisResult;
      case 'water':
        return AppRoutes.waterResult;
      default:
        return AppRoutes.home;
    }
  }
}



// Still no Problem - Commenting out for Enhanced Responsiveness 13/03/26 - 08:11am
/*import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../view_models/plant_result_view_model.dart';
import '../../../view_models/diagnosis_view_model.dart';
import '../../../view_models/water_calculation_view_model.dart';
import '../../data/models/history_model.dart';
import '../../data/services/analytics_service.dart';
import '../../l10n/app_localizations.dart';
import '../../view_models/history_view_model.dart';
// import '../../data/services/history_service.dart';
// import '../../data/models/history_model.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  File? _imageFile;
  String _mode = 'identify';
  
  String _location = '';
  String _temperature = '';
  String _wateringFrequency = '';

  late DateTime _processingStartTime;
  bool _hasLoggedProcessing = false; // Prevent double logging


  @override
  void initState() {
    super.initState();
     debugPrint('💣 ${runtimeType} INIT STATE');
     _processingStartTime = DateTime.now(); // Start tracking

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startProcessing();
    });
  }


  @override
  void dispose() {
    _animationController.dispose();

      // SAFETY NET: Ensure processing is logged even if screen disposes early
    if (!_hasLoggedProcessing && _mode.isNotEmpty) {
      _logProcessingEvent(success: false, error: 'Screen disposed before completion');
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  debugPrint('💣 ${runtimeType} BUILD CALLED');

  _initializeArguments();

  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
  child: Center(
      child: Container(
        width: screenWidth * 0.7, // 70% of screen width
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Loading Spinner
          RotationTransition(
            turns: _animationController,
            child: Icon(
              Icons.autorenew,
              color: AppColors.primaryGreen,
              size:  screenWidth * 0.08, // 8% of screen width
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
          
          // Title
          Text(
            _getProcessingTitle(),
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 1.0,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.01), // 1% spacing
          
          // Subtitle
          Text(
            _getProcessingSubtitle(),
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              height: 1.0,
              color: AppColors.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      ),
    ),
  ),
      );
    }

  
  void _logProcessingEvent({required bool success, String? error}) {
    if (_hasLoggedProcessing) return; // Prevent double logging
    
    final processingTime = DateTime.now().difference(_processingStartTime).inMilliseconds;
    
    AnalyticsService.logProcessingComplete(
      mode: _mode,
      success: success,
      error: error,
      processingTime: processingTime,
    );
    
    debugPrint('📊 PROCESSING ANALYTICS LOGGED:');
    debugPrint('   Mode: $_mode');
    debugPrint('   Success: $success');
    debugPrint('   Time: ${processingTime}ms');
    if (error != null) debugPrint('   Error: $error');
    
    _hasLoggedProcessing = true;
  }

  void _initializeArguments() {
     debugPrint('🔄🔄🔄 PROCESSING SCREEN INITIALIZING');
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
 
  print(' PROCESSING SCREEN: INITIALIZING ARGUMENTS');
  
  if (args != null) {

   debugPrint('✅ ARGUMENTS RECEIVED');
    debugPrint('   Mode: ${args['mode']}');
    debugPrint('   Image: ${args['imageFile'] != null ? "PRESENT" : "MISSING"}');

    setState(() {
      _imageFile = args['imageFile'];
      _mode = args['mode'] ?? 'identify';

    debugPrint('📋 SET STATE COMPLETE');
    debugPrint('   _imageFile: ${_imageFile?.path}');
    debugPrint('   _mode: $_mode');

      _location = args['location'] ?? '';
      _temperature = args['temperature'] ?? '';
      _wateringFrequency = args['wateringFrequency'] ?? '';
    });
    
    print(' PROCESSING SCREEN ARGUMENTS RECEIVED:');
    print(' Mode: $_mode');
    print(' Image: ${_imageFile != null ? "Provided (${_imageFile!.path})" : "MISSING"}');
    print(' Location: $_location');
    print(' Temperature: $_temperature');
    print(' Watering Frequency: $_wateringFrequency');
    
    
    if (_mode == 'water') {
      if (_location.isEmpty) print(' CRITICAL: Location is EMPTY');
      if (_temperature.isEmpty) print(' CRITICAL: Temperature is EMPTY'); 
      if (_wateringFrequency.isEmpty) print(' CRITICAL: Watering Frequency is EMPTY');
      if (_imageFile == null) print(' CRITICAL: Image file is NULL');
    }
  } else {
    debugPrint('❌❌❌ NO ARGUMENTS PROVIDED TO PROCESSING SCREEN');
    print(' PROCESSING SCREEN: NO ARGUMENTS PROVIDED');
  }
}


Future<void> _startProcessing() async {
  debugPrint('💣💣💣 NUCLEAR LOGGING - _startProcessing() CALLED');
  debugPrint('💣 Current time: ${DateTime.now()}');
   
  _initializeArguments();

  debugPrint('💣 After initialization:');
  debugPrint('💣   _mode = "$_mode"');
  debugPrint('💣   _imageFile = ${_imageFile?.path}');
  debugPrint('💣   _imageFile exists = ${_imageFile?.existsSync()}');

  try {
    if (_imageFile != null) {
      debugPrint('✅ Image available - Starting processing');
      
      if (_mode == 'identify') {
        debugPrint('💣💣💣 MODE IS "identify" - SHOULD PROCESS PLANT');
        await _processPlantIdentification();
      } else if (_mode == 'diagnose') {
        debugPrint('💣💣💣 MODE IS "diagnose"');
        await _processPlantDiagnosis();
      } else if (_mode == 'water') {
        debugPrint('💣💣💣 MODE IS "water"');
        await _processWaterCalculation();
      } else {
        debugPrint('💣💣💣 UNKNOWN MODE: "$_mode" - THIS IS THE PROBLEM!');
        // Handle unknown mode
        Navigator.pushReplacementNamed(
          context,
          _getFallbackRoute(),
        );
      }
    } else {
      debugPrint('💣💣💣 NO IMAGE FILE - CANNOT PROCESS');
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          _getFallbackRoute(),
        );
      }
    }
  } catch (e) {
    debugPrint('💣💣💣 PROCESSING ERROR: $e');
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        _getFallbackRoute(),
      );
    }
  }
}

/*
Future<void> _processPlantIdentification() async {
   debugPrint('🎯 [4/6] PROCESSING PLANT IDENTIFICATION');
  
  // GUARANTEE: Save scan NO MATTER WHAT
  final scanId = 'plant_scan_${DateTime.now().millisecondsSinceEpoch}';
   debugPrint('📝 [4/6] Generated Scan ID: $scanId');
  
  try {
    // STEP 1: SAVE SCAN IMMEDIATELY (GUARANTEED)
    final box = await Hive.openBox<ScanHistory>('scanHistory');
      debugPrint('📦 [4/6] Hive box opened, keys: ${box.keys.length}');
    
    final scan = ScanHistory(
      id: scanId,
      type: 'identify',
      plantName: 'Scanning Plant...',  // Placeholder
      timestamp: DateTime.now(),
      imagePath: _imageFile?.path ?? '',
      isSaved: false,
      hasAbnormality: false,
      resultData: {
        'status': 'scanning',
        'timestamp': DateTime.now().toIso8601String(),
        'imagePath': _imageFile?.path ?? '',
      },
    );
    
    await box.put(scanId, scan);
    await box.flush();
    debugPrint('💾 [4/6] GUARANTEED SAVE COMPLETE: $scanId');
    debugPrint('💣 Box keys after save: ${box.keys.length}');
    
    // STEP 2: Try identification (but SAVE is already done)
    final viewModel = Provider.of<PlantResultViewModel>(context, listen: false);
    
    try {
      viewModel.reset();
      viewModel.setImageFile(_imageFile!);
   //   await viewModel.identifyPlant(_imageFile!);
   await viewModel.identifyPlant(_imageFile!, scanId: scanId);
      
      debugPrint('💣 Plant identification completed');
    } catch (e) {
      debugPrint('❌ [4/6] SAVE ERROR: $e');
      // We already saved the scan, so continue anyway
    }
    
    // STEP 3: Navigate
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.plantIdentificationResult,
      arguments: {
        'imageFile': _imageFile,
        'scanId': scanId,  // Pass the scan ID
      },
    );
    
  } catch (e) {
    debugPrint('💣💣💣 CRITICAL ERROR in _processPlantIdentification: $e');
    // Even if everything fails, try to navigate
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.plantIdentificationResult,
      arguments: {'imageFile': _imageFile},
    );
  }
}
*/

Future<void> _processPlantIdentification() async {
  
   developer.log('🎯 PROCESSING SCREEN CALLED', name: 'PERSISTENCE');
  print('🔴 FORCED PRINT: _processPlantIdentification START');
  debugPrint('🎯 [4/6] PROCESSING PLANT IDENTIFICATION');

   try {
  
  // GUARANTEE: Save scan NO MATTER WHAT
  final scanId = 'plant_scan_${DateTime.now().millisecondsSinceEpoch}';
  debugPrint('📝 [4/6] Generated Scan ID: $scanId');
  

    // STEP 1: SAVE SCAN IMMEDIATELY (GUARANTEED)
    final box = await Hive.openBox<ScanHistory>('scanHistory');
    debugPrint('📦 [4/6] Hive box opened, keys: ${box.keys.length}');
    
    // ✅ ADDED: Check if scanId already exists (shouldn't, but verify)
    if (box.containsKey(scanId)) {
      debugPrint('⚠️ WARNING: scanId $scanId ALREADY EXISTS in Hive!');
    }
    
    final scan = ScanHistory( 
      id: scanId, 
      type: 'identify', 
      plantName: 'Scanning Plant...',  
      timestamp: DateTime.now(),
      imagePath: _imageFile?.path ?? '',
      isSaved: false,
      hasAbnormality: false,
      resultData: { 
        'status': 'scanning', 
        'timestamp': DateTime.now().toIso8601String(),
        'imagePath': _imageFile?.path ?? '',
      },
    );
    
    await box.put(scanId, scan);
    await box.flush();
    debugPrint('💾 [4/6] GUARANTEED SAVE COMPLETE: $scanId');
    debugPrint('💣 Box keys after save: ${box.keys.length}');
    
    // ✅ ADDED: VERIFY the scan was saved
    final savedScan = box.get(scanId);
    if (savedScan != null) {
      debugPrint(' VERIFICATION: Scan saved successfully');
      debugPrint('  Saved plantName: "${savedScan.plantName}"');
      debugPrint('   Should be "Scanning Plant...": ${savedScan.plantName == "Scanning Plant..."}');
    } else {
      debugPrint('❌❌❌ CRITICAL: Scan NOT FOUND after save!'); 
    }
    
    // STEP 2: Try identification (but SAVE is already done)
    final viewModel = Provider.of<PlantResultViewModel>(context, listen: false);
    
    try {
      viewModel.reset();
      viewModel.setImageFile(_imageFile!);
      
      
      // ✅ ADDED: VERIFY scanId is being passed
      debugPrint('📤 PASSING scanId to identifyPlant(): $scanId');
      debugPrint('   scanId is null? false');
      debugPrint('   scanId length: ${scanId.length}');
      
      await viewModel.identifyPlant(_imageFile!, scanId: scanId);
      
      debugPrint('💣 Plant identification completed');

        // Log success - Note: ViewModel also logs this, but we log it here too for safety
       _logProcessingEvent(success: true);

    } catch (e) {

      // Even if identification fails, we log processing as failed
       _logProcessingEvent(success: false, error: e.toString());

      debugPrint('❌ [4/6] IDENTIFY ERROR: $e');
      debugPrint('   Stack trace: ${e.toString()}');
      // We already saved the scan, so continue anyway
    }
    
    // STEP 3: Navigate
    debugPrint('🔄 NAVIGATING to PlantIdentificationResultScreen');
    debugPrint('   Passing arguments:');
    debugPrint('     - imageFile: ${_imageFile != null ? "PRESENT" : "MISSING"}');
    debugPrint('     - scanId: $scanId');
    

   // IMPORTANT: Refresh the history screen to show the new scan
try {
  final BuildContext rootContext = context;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      // Get the history view model and force refresh
      final historyViewModel = Provider.of<HistoryViewModel>(
        rootContext, 
        listen: false
      );
      historyViewModel.loadHistory(forceRefresh: true);
      debugPrint('✅ History refresh triggered after plant scan');
    } catch (e) {
      debugPrint('⚠️ History refresh failed: $e');
    }
  });
} catch (e) {
  debugPrint('⚠️ Could not trigger history refresh: $e');
}


    Navigator.pushReplacementNamed(
      context,
      AppRoutes.plantIdentificationResult,
      arguments: {
        'imageFile': _imageFile,
        'scanId': scanId,  // Pass the scan ID
      },
    );
    
    debugPrint('✅ NAVIGATION TRIGGERED with scanId: $scanId');
    
  } catch (e) {
       _logProcessingEvent(success: false, error: e.toString());


    debugPrint('💣💣💣 CRITICAL ERROR in _processPlantIdentification: $e');
    debugPrint('   Error type: ${e.runtimeType}');
    debugPrint('   Full error: $e');
    
    // Even if everything fails, try to navigate
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.plantIdentificationResult,
      arguments: {'imageFile': _imageFile},
    );
  }
}


// Future<void> _verifySaveImmediately() async {
  /*try {
    debugPrint('🔍 IMMEDIATE SAVE VERIFICATION IN PROCESSING');
    await Future.delayed(Duration(milliseconds: 300));
    
    final box = await Hive.openBox<ScanHistory>('scanHistory');
    debugPrint('📦 Box keys after processing save: ${box.keys.length}');
    
    final allScans = box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    if (allScans.isNotEmpty) {
      final latest = allScans.first;
      debugPrint('✅✅✅ LATEST SAVE VERIFIED IN PROCESSING:');
      debugPrint('   Plant: ${latest.plantName}');
      debugPrint('   Time: ${latest.timestamp}');
      debugPrint('   ID: ${latest.id}');
    } else {
      debugPrint('❌❌❌ NO SAVE FOUND IN PROCESSING!');
    }
  } catch (e) {
    debugPrint('❌ Verification error: $e');
  }
}*/

  Future<void> _processPlantDiagnosis() async {
    final diagnosisViewModel = Provider.of<DiagnosisViewModel>(context, listen: false);
    try {
   
    await diagnosisViewModel.diagnosePlant(_imageFile!);

     // Log success - ViewModel will also log, but we log here for safety
      _logProcessingEvent(success: true);

    
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.plantDiagnosisResult,
       arguments:{'imageFile': _imageFile,
       },
      );
    
}
    } catch (e) {
      _logProcessingEvent(success: false, error: e.toString());
      rethrow;

    }
  }

  Future<void> _processWaterCalculation() async {
  final waterViewModel = Provider.of<WaterCalculationViewModel>(context, listen: false);
  
  print(' Water Calculation Parameters:');
  print('   Location: $_location');
  print('   Temperature: $_temperature');
  print('   Watering Frequency: $_wateringFrequency');


    try {
       // Reset ViewModel to clear any previous state
    waterViewModel.reset();


  // Calling Gemini API for water calculation
  await waterViewModel.calculateWaterNeedsWithGemini(
    plantImage: _imageFile!,
    location: _location,
    temperature: _temperature,
    wateringFrequency: _wateringFrequency,
  );
  
 // Log success - ViewModel will also log, but we log here for safety
      _logProcessingEvent(success: true);


  if (waterViewModel.waterCalculation != null) {
    print(' Water Calculation SUCCESS:');
    print('   Plant: ${waterViewModel.waterCalculation!.plantName}');
    print('   Amount: ${waterViewModel.waterCalculation!.waterAmount}');
    print('   Explanation: ${waterViewModel.waterCalculation!.explanation}');
    print('   Frequency: ${waterViewModel.waterCalculation!.frequency}');
    print('   Best Time: ${waterViewModel.waterCalculation!.bestTime}');
    print('   Tips: ${waterViewModel.waterCalculation!.tips}');
  } else {
    print(' Water Calculation FAILED - No data received');
  }
  
 
  if (mounted) {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.waterResult,
       // NO arguments needed - ViewModel already has data
    );
  }
} catch (e) {
      _logProcessingEvent(success: false, error: e.toString());
      rethrow;
    }
  }
  
  
  String _getProcessingTitle() {
    switch (_mode) {
      case 'identify':
     //   return 'Identifying Plant';
     return AppLocalizations.of(context).processing_title_identify;
      case 'diagnose':
     //   return 'Diagnosing Plant';
      return AppLocalizations.of(context).processing_title_diagnose;


      case 'water':
     //   return 'Calculating Water Needs';
     return AppLocalizations.of(context).processing_title_water;


      default:
      //  return 'Processing';
    return AppLocalizations.of(context).processing_title_default;


    }
  }

  String _getProcessingSubtitle() {
      final l10n = AppLocalizations.of(context);

    switch (_mode) {
      case 'identify':
      //  return 'Smart, fast, and accurate plant ID';
       return l10n.processing_subtitle_identify; 

      case 'diagnose':
      //  return 'Spotting possible diseases and issues';
       return l10n.processing_subtitle_diagnose;

      case 'water':
      //  return 'Analyzing plant and environment...';
       return l10n.processing_subtitle_water; 

      default:
      //  return 'Please wait...';
      return l10n.processing_subtitle_default;
    }
  }

  String _getFallbackRoute() {
    switch (_mode) {
      case 'identify':
        return AppRoutes.plantIdentificationResult;
      case 'diagnose':
        return AppRoutes.plantDiagnosisResult;
      case 'water':
        return AppRoutes.waterResult;
      default:
        return AppRoutes.home;
    }
  }
}*/