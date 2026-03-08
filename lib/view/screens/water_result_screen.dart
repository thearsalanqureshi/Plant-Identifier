import 'package:flutter/material.dart';
import 'package:plant_identifier_app/data/models/water_calculation_model.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../view_models/water_calculation_view_model.dart';
import '../../l10n/app_localizations.dart';
import '../../data/services/translation_service.dart';

class WaterResultScreen extends StatefulWidget {
  const WaterResultScreen({super.key});

  @override
  State<WaterResultScreen> createState() => _WaterResultScreen();
}

class _WaterResultScreen extends State<WaterResultScreen> {
  Map<String, String>? _translatedTexts;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    debugPrint('💣 ${widget.runtimeType} INIT STATE CALLED');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  void _initializeScreen() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final viewModel = Provider.of<WaterCalculationViewModel>(context, listen: false);

    print('🔄 WATER RESULT SCREEN INITIALIZING');

    // TWO DISTINCT FLOWS:

    // FLOW 1: Coming directly from processing (new calculation)
    if (args == null || args['scanData'] == null) {
      print('✅ [WATER] New calculation flow - data already in ViewModel');
      // The ViewModel should already have data from processing
      return;
    }

    // FLOW 2: Loading from history
    if (args['scanData'] != null) {
      print('📚 [WATER] History flow detected');
      final scanData = args['scanData'] as Map<String, dynamic>;
      final imagePath = args['imagePath'] as String?;

      // Load from history instead of reprocessing
      viewModel.loadFromHistory(scanData, imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('💣 ${runtimeType} BUILD CALLED');
    
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    print('WATER RESULT SCREEN: BUILDING');

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Consumer<WaterCalculationViewModel>(
            builder: (context, viewModel, child) {
              print('WATER RESULT CONSUMER UPDATED:');
              print('   isLoading: ${viewModel.isLoading}');
              print('   error: ${viewModel.error}');
              print('   waterCalculation: ${viewModel.waterCalculation != null ? "EXISTS" : "NULL"}');

              if (viewModel.waterCalculation != null) {
                print(' FINAL WATER CALCULATION DATA:');
                print('   Plant: ${viewModel.waterCalculation!.plantName}');
                print('   Water: ${viewModel.waterCalculation!.waterAmount}');
                print('   Explanation: ${viewModel.waterCalculation!.explanation}');
                print('   Frequency: ${viewModel.waterCalculation!.frequency}');
                print('   Best Time: ${viewModel.waterCalculation!.bestTime}');
                print('   Tips: ${viewModel.waterCalculation!.tips}');
              }

              // Show loading state when loading from history
              if (viewModel.isLoading) {
                return _buildLoadingState(context);
              }

              if (viewModel.error.isNotEmpty) {
                return _buildErrorState(context, viewModel.error);
              }

              if (viewModel.waterCalculation == null) {
                return _buildErrorState(context, AppLocalizations.of(context).water_no_data);
              }

              // 🔥 Trigger translation if needed
              if (_translatedTexts == null && !_isTranslating) {
                _translateAllText(viewModel.waterCalculation!);
              }

              return _buildSuccessState(context, viewModel, screenHeight, screenWidth);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryGreen),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).water_calculating,
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

  Widget _buildErrorState(BuildContext context, String error) {
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
              AppLocalizations.of(context).water_error_title,
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
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => route.isFirst,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).water_back_home,
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

  Widget _buildSuccessState(BuildContext context, WaterCalculationViewModel viewModel, 
      double screenHeight, double screenWidth) {
    final calculation = viewModel.waterCalculation!;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Result Card
          _buildResultCard(context, calculation, screenHeight, screenWidth),

          // Additional Information
          _buildAdditionalInfo(context, calculation, screenWidth),

          // Thank You Button
          _buildThankYouButton(context, screenHeight, screenWidth),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, WaterCalculation calculation, 
      double screenHeight, double screenWidth) {
    return Container(
      width: screenWidth * 0.8, // 80% of screen width
      margin: EdgeInsets.only(top: screenHeight * 0.08), // 8% from top
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // WATER-THEMED ICON
          Container(
            width: screenWidth * 0.2, // 20% of screen width
            height: screenWidth * 0.2,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.water_drop,
                color: AppColors.primaryGreen,
                size: screenWidth * 0.12, // 12% of screen width
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Water Amount (Highlighted)
          Center(
            child: Text(
              calculation.waterAmount,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w700,
                fontSize: screenWidth * 0.07, // 7% of screen width
                color: AppColors.primaryGreen,
              ),
              textAlign: TextAlign.center, 
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Center(
            child: Text(
              AppLocalizations.of(context).water_plant_water_need,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppColors.darkGray,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Explanation
          Center(
            child: Container(
              width: screenWidth * 0.7, // 70% of screen width
              child: Text(
                _translatedTexts?['explanation'] ?? calculation.explanation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  color: AppColors.darkGray,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context, WaterCalculation calculation, 
      double screenWidth) {
    return Container(
      width: screenWidth * 0.8, // 80% of screen width
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGreenBg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Schedule Section
          _buildScheduleSection(context, calculation),

          const SizedBox(height: 12),

          // Tips Section
          _buildTipsSection(context, calculation),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(BuildContext context, WaterCalculation calculation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              color: AppColors.primaryGreen,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).water_schedule,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildInfoRow(
          AppLocalizations.of(context).water_frequency,
          _translatedTexts?['frequency'] ?? calculation.frequency,
          Icons.calendar_today,
        ),

        _buildInfoRow(
          AppLocalizations.of(context).water_best_time,
          _translatedTexts?['bestTime'] ?? calculation.bestTime,
          Icons.access_time,
        ),
      ],
    );
  }

  Widget _buildTipsSection(BuildContext context, WaterCalculation calculation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: AppColors.primaryGreen,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).water_care_tips,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...calculation.tips.asMap().entries.map((entry) {
          final index = entry.key;
          final tip = entry.value;
          final translatedTip = _translatedTexts?['tip_$index'] ?? tip;
          return _buildTipItem(translatedTip, context);
        }).toList(),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: AppColors.darkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThankYouButton(BuildContext context, double screenHeight, double screenWidth) {
    return Container(
      width: screenWidth * 0.9, // 90% of screen width
      height: 60,
      margin: EdgeInsets.only(
        top: screenHeight * 0.05, // 5% from bottom
        bottom: 50,
    ),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => route.isFirst,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Text(
          AppLocalizations.of(context).water_thank_you,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _translateAllText(WaterCalculation calculation) async {
    if (_isTranslating) return;

    setState(() => _isTranslating = true);

    try {
      final locale = Localizations.localeOf(context).languageCode;
      if (locale == 'en') {
        setState(() => _isTranslating = false);
        return;
      }

      final textsToTranslate = {
        'plantName': calculation.plantName,
        'explanation': calculation.explanation,
        'frequency': calculation.frequency,
        'bestTime': calculation.bestTime,
      };

      // Add tips as separate entries
      for (int i = 0; i < calculation.tips.length; i++) {
        textsToTranslate['tip_$i'] = calculation.tips[i];
      }

      final results = <String, String>{};
      final futures = textsToTranslate.entries.map((entry) async {
        final translated = await TranslationService.translateText(entry.value, locale);
        results[entry.key] = translated;
      }).toList();

      await Future.wait(futures);

      setState(() {
        _translatedTexts = results;
        _isTranslating = false;
      });
    } catch (e) {
      debugPrint('Translation error: $e');
      setState(() => _isTranslating = false);
    }
  }
}


/*import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:plant_identifier_app/data/models/water_calculation_model.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Commented out for now
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../view_models/water_calculation_view_model.dart';
import '../../l10n/app_localizations.dart';
import '../../data/services/translation_service.dart';


class WaterResultScreen extends StatefulWidget {
  const WaterResultScreen({super.key});

 @override
  State<WaterResultScreen> createState() => _WaterResultScreen();
}

class _WaterResultScreen extends State<WaterResultScreen> {
 Map<String, String>? _translatedTexts;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    debugPrint('💣 ${widget.runtimeType} INIT STATE CALLED');

     
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeScreen();
  });
  }


  void _initializeScreen() {
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  final viewModel = Provider.of<WaterCalculationViewModel>(context, listen: false);
  
  print('🔄 WATER RESULT SCREEN INITIALIZING');
  
  // TWO DISTINCT FLOWS:
  
  // FLOW 1: Coming directly from processing (new calculation)
  if (args == null || args['scanData'] == null) {
    print('✅ [WATER] New calculation flow - data already in ViewModel');
    // The ViewModel should already have data from processing
    return;
  }
  
  // FLOW 2: Loading from history
  if (args['scanData'] != null) {
    print('📚 [WATER] History flow detected');
    final scanData = args['scanData'] as Map<String, dynamic>;
    final imagePath = args['imagePath'] as String?;
    
    // Load from history instead of reprocessing
    viewModel.loadFromHistory(scanData, imagePath);
  }
}

  @override
Widget build(BuildContext context) {
 debugPrint('💣 ${runtimeType} BUILD CALLED');

  print('WATER RESULT SCREEN: BUILDING');
 
  return Scaffold(
    backgroundColor: AppColors.white,
    body: SafeArea(
        child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.responsiveWidth(16, context),
        ),

      child: Consumer<WaterCalculationViewModel>(
        builder: (context, viewModel, child) {
          print('WATER RESULT CONSUMER UPDATED:');
          print('   isLoading: ${viewModel.isLoading}');
          print('   error: ${viewModel.error}');
          print('   waterCalculation: ${viewModel.waterCalculation != null ? "EXISTS" : "NULL"}');
         
          if (viewModel.waterCalculation != null) {
            print(' FINAL WATER CALCULATION DATA:');
            print('   Plant: ${viewModel.waterCalculation!.plantName}');
            print('   Water: ${viewModel.waterCalculation!.waterAmount}');
            print('   Explanation: ${viewModel.waterCalculation!.explanation}');
            print('   Frequency: ${viewModel.waterCalculation!.frequency}');
            print('   Best Time: ${viewModel.waterCalculation!.bestTime}');
            print('   Tips: ${viewModel.waterCalculation!.tips}');
          }
          
          // Show loading state when loading from history
          if (viewModel.isLoading) {
            return _buildLoadingState(context);
          }

          if (viewModel.error.isNotEmpty) {
            return _buildErrorState(context, viewModel.error);
          }

          if (viewModel.waterCalculation == null) {
          //  return _buildErrorState(context, 'No water calculation data available');
              return _buildErrorState(context, AppLocalizations.of(context).water_no_data);
          }

           // 🔥 ADD THIS - Trigger translation if needed
    if (_translatedTexts == null && !_isTranslating) {
      _translateAllText(viewModel.waterCalculation!);
    }

          return _buildSuccessState(context, viewModel);
        },
      ),
    ),
    ),
  );
}

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryGreen),
          SizedBox(height: ResponsiveHelper.responsiveHeight(16, context)),
          Text(
          //  'Calculating water needs...',
            AppLocalizations.of(context).water_calculating,

            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: ResponsiveHelper.responsiveFontSize(16, context),
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
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
            //  'Calculation Error',
              AppLocalizations.of(context).water_error_title,
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
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => route.isFirst,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
              //  'Back to Home',
                AppLocalizations.of(context).water_back_home,
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

  Widget _buildSuccessState(BuildContext context, WaterCalculationViewModel viewModel) {
    final calculation = viewModel.waterCalculation!;
   
    return   SingleChildScrollView(
    
     child: Column(
         
          children: [
            // Result Card (Centered)
            _buildResultCard(context, calculation),
           
            // Additional Information
            _buildAdditionalInfo(context, calculation),
           
            // Thank You Button
            _buildThankYouButton(context),
          ],
     ),
        );
  }

  Widget _buildResultCard(BuildContext context, WaterCalculation calculation) {
    // return Center( // ← ADD THIS
    return Container(
      width: ResponsiveHelper.responsiveWidth(307, context),
      margin: EdgeInsets.only(
        top: ResponsiveHelper.responsiveHeight(60, context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // WATER-THEMED ICON (Commented out SVG, using Material Icons)
          Container(
            width: ResponsiveHelper.responsiveWidth(90, context),
            height: ResponsiveHelper.responsiveWidth(90, context),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
           
           
            child: Center( // ← ADD THIS
            child: Icon(
              Icons.water_drop, // Most relevant water calculation icon
              color: AppColors.primaryGreen,
              size: ResponsiveHelper.responsiveWidth(60, context),
            ),
          ),
        ),

          SizedBox(height: ResponsiveHelper.responsiveHeight(16, context)),
         
          // Water Amount (Highlighted)
         
        Center( // ← ADD THIS
        child:  Text(
            calculation.waterAmount,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: ResponsiveHelper.responsiveFontSize(28, context),
              color: AppColors.primaryGreen,
            ),
          ),
        ),
         
          SizedBox(height: ResponsiveHelper.responsiveHeight(16, context)),
         
          // Title
          Center( // ← ADD THIS
          child: Text(

          //  'Plant Water Need',
            AppLocalizations.of(context).water_plant_water_need,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveHelper.responsiveFontSize(18, context),
              color: AppColors.darkGray,
            ),
          ),
          ),
         
          SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
         
          // Explanation
           Center( // ← ADD THIS
         child: Container(
            width: ResponsiveHelper.responsiveWidth(280, context),
            child: Text(
              calculation.explanation,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: ResponsiveHelper.responsiveFontSize(14, context),
                color: AppColors.darkGray,
                height: 1.4,
              ),
              ),
            ),
          ),
        ],
      ),
    );
}

  Widget _buildAdditionalInfo(BuildContext context, WaterCalculation calculation) {
    return Container(
      width: ResponsiveHelper.responsiveWidth(307, context),
      margin: EdgeInsets.only(
        top: ResponsiveHelper.responsiveHeight(20, context),
      ),
      padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(16, context)),
      decoration: BoxDecoration(
        color: AppColors.lightGreenBg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Schedule Section
          _buildScheduleSection(context, calculation),
         
          SizedBox(height: ResponsiveHelper.responsiveHeight(14, context)),
         
          // Tips Section
          _buildTipsSection(context, calculation),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(BuildContext context, WaterCalculation calculation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              color: AppColors.primaryGreen,
              size: ResponsiveHelper.responsiveWidth(18, context),
            ),
            SizedBox(width: ResponsiveHelper.responsiveWidth(8, context)),
            Text(
            //  'Watering Schedule',
              AppLocalizations.of(context).water_schedule,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveHelper.responsiveFontSize(14, context),
                color: AppColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
     
      //  _buildInfoRow('Frequency:', calculation.frequency, Icons.calendar_today),
          _buildInfoRow(
            AppLocalizations.of(context).water_frequency, 
            // calculation.frequency, 
             _translatedTexts?['frequency'] ?? calculation.frequency, 
             Icons.calendar_today),
      
      //  _buildInfoRow('Best Time:', calculation.bestTime, Icons.access_time),
          _buildInfoRow(
            AppLocalizations.of(context).water_best_time, 
           // calculation.bestTime, 
            _translatedTexts?['bestTime'] ?? calculation.bestTime, 
            Icons.access_time),
      ],
    );
  }

  Widget _buildTipsSection(BuildContext context, WaterCalculation calculation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: AppColors.primaryGreen,
              size: ResponsiveHelper.responsiveWidth(18, context),
            ),
            SizedBox(width: ResponsiveHelper.responsiveWidth(8, context)),
            Text(
            //  'Care Tips',
              AppLocalizations.of(context).water_care_tips,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveHelper.responsiveFontSize(14, context),
                color: AppColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
         ...calculation.tips.asMap().entries.map((entry) {
          final index = entry.key;
        final tip = entry.value;
        final translatedTip = _translatedTexts?['tip_$index'] ?? tip;
        return _buildTipItem(translatedTip, context);
      }).toList(),
     
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primaryGreen,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.darkGray,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.primaryGreen,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w400,
                fontSize: ResponsiveHelper.responsiveFontSize(13, context),
                color: AppColors.darkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThankYouButton(BuildContext context) {
    return Container(
      width: ResponsiveHelper.responsiveWidth(343, context),
      height: ResponsiveHelper.responsiveHeight(60, context),
      margin: EdgeInsets.only(
        top: ResponsiveHelper.responsiveHeight(40, context),
   //     bottom: ResponsiveHelper.responsiveHeight(50, context),
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => route.isFirst,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Text(
        //  'Thank You',
          AppLocalizations.of(context).water_thank_you,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w700,
            fontSize: ResponsiveHelper.responsiveFontSize(16, context),
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _translateAllText(WaterCalculation calculation) async {
  if (_isTranslating) return;
  
  setState(() => _isTranslating = true);
  
  try {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'en') {
      setState(() => _isTranslating = false);
      return;
    }
    
    final textsToTranslate = {
      'plantName': calculation.plantName,
      'explanation': calculation.explanation,
      'frequency': calculation.frequency,
      'bestTime': calculation.bestTime,
    };
    
    // Add tips as separate entries
    for (int i = 0; i < calculation.tips.length; i++) {
      textsToTranslate['tip_$i'] = calculation.tips[i];
    }
    
    final results = <String, String>{};
    final futures = textsToTranslate.entries.map((entry) async {
      final translated = await TranslationService.translateText(entry.value, locale);
      results[entry.key] = translated;
    }).toList();
    
    await Future.wait(futures);
    
    setState(() {
      _translatedTexts = results;
      _isTranslating = false;
    });
    
  } catch (e) {
    debugPrint('Translation error: $e');
    setState(() => _isTranslating = false);
  }
}
}*/