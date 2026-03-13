import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plant_identifier_app/data/models/water_question_model.dart';
import 'package:provider/provider.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../view_models/water_calculation_view_model.dart';
import '../../l10n/app_localizations.dart';

class WaterQuestionsScreen extends StatefulWidget {
  const WaterQuestionsScreen({super.key});

  @override
  State<WaterQuestionsScreen> createState() => _WaterQuestionsScreenState();
}

class _WaterQuestionsScreenState extends State<WaterQuestionsScreen> {
  String? _selectedOption;
  bool _didInitialize = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitialize) return;
    _didInitialize = true;
    _initializeArguments();
  }

  void _initializeArguments() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final viewModel = context.read<WaterCalculationViewModel>();

    if (args == null) {
      _selectedOption = _getStoredAnswer(viewModel, viewModel.currentQuestion);
      return;
    }

    final imageFile = args['imageFile'] as File?;
    final currentQuestion = args['currentQuestion'] as int? ?? 1;
    final location = args['location'] as String?;
    final temperature = args['temperature'] as String?;
    final wateringFrequency = args['wateringFrequency'] as String?;

    if (imageFile != null) {
      viewModel.setImageFile(imageFile);
    }

    viewModel.setCurrentQuestion(currentQuestion);

    if (location != null && location.isNotEmpty) {
      viewModel.setLocation(location);
    }
    if (temperature != null && temperature.isNotEmpty) {
      viewModel.setTemperature(temperature);
    }
    if (wateringFrequency != null && wateringFrequency.isNotEmpty) {
      viewModel.setWateringFrequency(wateringFrequency);
    }

    _selectedOption = _getStoredAnswer(viewModel, currentQuestion);
  }

  String? _getStoredAnswer(WaterCalculationViewModel viewModel, int question) {
    switch (question) {
      case 1:
        return viewModel.location.isEmpty ? null : viewModel.location;
      case 2:
        return viewModel.temperature.isEmpty ? null : viewModel.temperature;
      case 3:
        return viewModel.wateringFrequency.isEmpty ? null : viewModel.wateringFrequency;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WaterCalculationViewModel>();
    final currentQuestion = viewModel.currentQuestion;
    final questionData = _getCurrentQuestion(context, currentQuestion);
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              isTablet ? 8 : 4,
              horizontalPadding,
              bottomInset > 0 ? bottomInset + 8 : 16,
            ),
            child: Column(
              children: [
                _buildProgressIndicator(viewModel.currentQuestion, isTablet),
                const SizedBox(height: 18),
                _buildPlantImage(viewModel, isTablet),
                const SizedBox(height: 18),
                _buildQuestion(questionData.question, isTablet),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: questionData.options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final option = questionData.options[index];
                      return _buildOptionCard(
                        option: option,
                        isSelected: _selectedOption == option,
                        isTablet: isTablet,
                        onTap: () {
                          setState(() {
                            _selectedOption = option;
                          });
                          _saveAnswer(option, viewModel);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildContinueButton(
                  context,
                  viewModel,
                  isTablet,
                  enabled: _selectedOption != null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int currentQuestion, bool isTablet) {
    final width = isTablet ? 280.0 : 220.0;
    final progress = (currentQuestion - 1) / 2;

    return SizedBox(
      width: width,
      height: 30,
      child: Stack(
        children: [
          Positioned(
            left: 15,
            right: 15,
            top: 14,
            child: Container(
              height: 2,
              color: AppColors.lightGray,
            ),
          ),
          Positioned(
            left: 15,
            top: 14,
            child: Container(
              height: 2,
              width: (width - 30) * progress,
              color: AppColors.primaryGreen,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              final number = index + 1;
              final active = number <= currentQuestion;

              return Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryGreen : AppColors.lightGray,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: active ? AppColors.white : AppColors.darkGray,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 15 : 14,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantImage(
    WaterCalculationViewModel viewModel,
    bool isTablet,
  ) {
    final size = isTablet ? 112.0 : 96.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightGreenBg,
        image: viewModel.imageFile != null
            ? DecorationImage(
                image: FileImage(viewModel.imageFile!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: viewModel.imageFile == null
          ? Icon(
              Icons.photo,
              color: AppColors.primaryGreen,
              size: isTablet ? 42 : 36,
            )
          : null,
    );
  }

  Widget _buildQuestion(String question, bool isTablet) {
    return Text(
      question,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'DMSans',
        fontWeight: FontWeight.w700,
        fontSize: isTablet ? 22 : 16,
        height: 1.3,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildOptionCard({
    required String option,
    required bool isSelected,
    required bool isTablet,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryGreen
                  : AppColors.primaryGreen.withOpacity(0.5),
              width: isSelected ? 2 : 0.7,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w500,
                    fontSize: isTablet ? 16 : 14,
                    color: AppColors.black,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SvgPicture.asset(
                isSelected
                    ? 'assets/icons/ic_checked.svg'
                    : 'assets/icons/ic_unchecked.svg',
                width: 22,
                height: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(
    BuildContext context,
    WaterCalculationViewModel viewModel,
    bool isTablet, {
    required bool enabled,
  }) {
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 58 : 54,
      child: ElevatedButton(
        onPressed: enabled ? () => _navigateToNext(context, viewModel) : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              enabled ? AppColors.primaryGreen : AppColors.mediumGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Text(
          AppLocalizations.of(context).water_continue,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w700,
            fontSize: isTablet ? 18 : 16,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  void _saveAnswer(String answer, WaterCalculationViewModel viewModel) {
    switch (viewModel.currentQuestion) {
      case 1:
        viewModel.setLocation(answer);
        break;
      case 2:
        viewModel.setTemperature(answer);
        break;
      case 3:
        viewModel.setWateringFrequency(answer);
        break;
    }
  }

  void _navigateToNext(
    BuildContext context,
    WaterCalculationViewModel viewModel,
  ) {
    final nextQuestion = viewModel.currentQuestion + 1;

    if (nextQuestion <= 3) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.waterQuestions,
        arguments: {
          'imageFile': viewModel.imageFile,
          'currentQuestion': nextQuestion,
          'location': viewModel.location,
          'temperature': viewModel.temperature,
          'wateringFrequency': viewModel.wateringFrequency,
        },
      );
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.processing,
      arguments: {
        'imageFile': viewModel.imageFile,
        'mode': 'water',
        'location': viewModel.location,
        'temperature': viewModel.temperature,
        'wateringFrequency': viewModel.wateringFrequency,
      },
    );
  }

  WaterQuestion _getCurrentQuestion(BuildContext context, int currentQuestion) {
    final l10n = AppLocalizations.of(context);

    switch (currentQuestion) {
      case 1:
        return WaterQuestion(
          questionNumber: 1,
          question: l10n.water_question_location,
          options: [
            l10n.water_location_indoor_window,
            l10n.water_location_indoor_shaded,
            l10n.water_location_outdoor_sun,
            l10n.water_location_outdoor_shade,
          ],
        );
      case 2:
        return WaterQuestion(
          questionNumber: 2,
          question: l10n.water_question_temperature,
          options: [
            l10n.water_temperature_very_cold,
            l10n.water_temperature_cold,
            l10n.water_temperature_moderate,
            l10n.water_temperature_warm,
            l10n.water_temperature_hot,
          ],
        );
      case 3:
        return WaterQuestion(
          questionNumber: 3,
          question: l10n.water_question_frequency,
          options: [
            l10n.water_frequency_daily,
            l10n.water_frequency_2_3_days,
            l10n.water_frequency_weekly,
            l10n.water_frequency_biweekly,
            l10n.water_frequency_rarely,
          ],
        );
      default:
        return WaterQuestion(
          questionNumber: 1,
          question: l10n.water_question_location,
          options: [
            l10n.water_location_indoor_window,
            l10n.water_location_indoor_shaded,
            l10n.water_location_outdoor_sun,
            l10n.water_location_outdoor_shade,
          ],
        );
    }
  }
}



// Still no Problem - Commenting out for Enhanced Responsiveness 13/03/26 - 07:58am
/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_identifier_app/data/models/water_question_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../view_models/water_calculation_view_model.dart';
import '../../l10n/app_localizations.dart';

class WaterQuestionsScreen extends StatefulWidget {
  const WaterQuestionsScreen({super.key});

  @override
  State<WaterQuestionsScreen> createState() => _WaterQuestionsScreenState();
}

class _WaterQuestionsScreenState extends State<WaterQuestionsScreen> {
  String? _selectedOption;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint('💣 ${runtimeType} INIT STATE');
    print('🔄 WaterQuestionsScreen initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🔄 WaterQuestionsScreen didChangeDependencies');
    if (!_isInitialized) {
      _initializeArguments();
      _isInitialized = true;
    }
  }

  void _initializeArguments() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    print('🔄 INITIALIZING WATER QUESTIONS SCREEN WITH ARGS: ${args != null}');

    if (args != null) {
      final viewModel = Provider.of<WaterCalculationViewModel>(context, listen: false);
      final imageFile = args['imageFile'] as File?;
      final currentQuestion = args['currentQuestion'] as int? ?? 1;
      final location = args['location'] as String?;
      final temperature = args['temperature'] as String?;
      final wateringFrequency = args['wateringFrequency'] as String?;

      print(' RECEIVED ARGUMENTS:');
      print('   Current Question: $currentQuestion');
      print('   Location: $location');
      print('   Temperature: $temperature');
      print('   Watering Frequency: $wateringFrequency');
      print('   Image: ${imageFile != null ? "Provided" : "Missing"}');

      // Use WidgetsBinding to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processInitialization(
          viewModel: viewModel,
          imageFile: imageFile,
          currentQuestion: currentQuestion,
          location: location,
          temperature: temperature,
          wateringFrequency: wateringFrequency,
        );
      });
    } else {
      print('NO ARGUMENTS PROVIDED - Starting fresh');
    }
  }

  void _processInitialization({
    required WaterCalculationViewModel viewModel,
    required File? imageFile,
    required int currentQuestion,
    required String? location,
    required String? temperature,
    required String? wateringFrequency,
  }) {
    print('PROCESSING INITIALIZATION...');

    if (imageFile != null) {
      viewModel.setImageFile(imageFile);
    }

    viewModel.setCurrentQuestion(currentQuestion);

    // CRITICAL: Restore previous answers to ViewModel
    if (location != null && location.isNotEmpty) {
      viewModel.setLocation(location);
      print(' Restored Location to ViewModel: $location');
    }
    if (temperature != null && temperature.isNotEmpty) {
      viewModel.setTemperature(temperature);
      print(' Restored Temperature to ViewModel: $temperature');
    }
    if (wateringFrequency != null && wateringFrequency.isNotEmpty) {
      viewModel.setWateringFrequency(wateringFrequency);
      print(' Restored Watering Frequency to ViewModel: $wateringFrequency');
    }

    // Auto-select current question's answer in UI
    _autoSelectCurrentAnswer(viewModel, currentQuestion);
  }

  void _autoSelectCurrentAnswer(WaterCalculationViewModel viewModel, int currentQuestion) {
    String? currentAnswer;
    switch (currentQuestion) {
      case 1:
        currentAnswer = viewModel.location;
        break;
      case 2:
        currentAnswer = viewModel.temperature;
        break;
      case 3:
        currentAnswer = viewModel.wateringFrequency;
        break;
    }

    print('AUTO-SELECTING FOR Q$currentQuestion: "$currentAnswer"');

    if (currentAnswer != null && currentAnswer.isNotEmpty) {
      setState(() {
        _selectedOption = currentAnswer;
      });
      print('UI Auto-selected: $currentAnswer');
    } else {
      print('No previous answer to auto-select');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('💣 ${runtimeType} BUILD CALLED');

    final viewModel = Provider.of<WaterCalculationViewModel>(context);
    final currentQuestion = viewModel.currentQuestion;
    final questionData = _getCurrentQuestion(currentQuestion, viewModel);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    print('BUILDING SCREEN - Q$currentQuestion, Selected: "$_selectedOption"');

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                 SizedBox(height: screenHeight * 0.01),

                // Progress Indicator
                _buildProgressIndicator(context, viewModel, screenWidth, screenHeight),

                // Plant Image
                _buildPlantImage(context, viewModel, screenWidth),

                // Question
                _buildQuestion(context, questionData.question, screenWidth),

                // Options
                _buildOptions(context, questionData.options, viewModel, screenHeight, screenWidth),

                // Continue Button
                _buildContinueButton(context, viewModel, screenHeight, screenWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, WaterCalculationViewModel viewModel, 
      double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.55, // 55% of screen width
      height: 30,
      margin: EdgeInsets.only(top: screenHeight * 0.02),
      child: Stack(
        children: [
          // Background connecting line (full gray)
          Positioned(
            left: 15,
            right: 15,
            top: 14,
            child: Container(
              height: 2,
              color: AppColors.lightGray,
            ),
          ),
          // Progress connecting line (green for completed sections)
          if (viewModel.currentQuestion > 1)
            Positioned(
              left: 15,
              top: 14,
              child: Container(
                height: 2,
                width: _calculateProgressWidth(screenWidth, viewModel.currentQuestion),
                color: AppColors.primaryGreen,
              ),
            ),
          // Progress dots with numbers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              final questionNumber = index + 1;
              final isCompleted = questionNumber < viewModel.currentQuestion;
              final isCurrent = questionNumber == viewModel.currentQuestion;

              return Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent
                      ? AppColors.primaryGreen
                      : AppColors.lightGray,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$questionNumber',
                    style: TextStyle(
                      color: isCompleted || isCurrent
                          ? AppColors.white
                          : AppColors.darkGray,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  double _calculateProgressWidth(double screenWidth, int currentQuestion) {
    final totalWidth = screenWidth * 0.55 - 30;

    if (currentQuestion == 2) {
      return totalWidth / 2;
    } else if (currentQuestion == 3) {
      return totalWidth;
    } else {
      return 0;
    }
  }

  Widget _buildPlantImage(BuildContext context, WaterCalculationViewModel viewModel, 
      double screenWidth) {
    return Container(
      width: screenWidth * 0.25, // 25% of screen width
      height: screenWidth * 0.25,
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightGreenBg,
        image: viewModel.imageFile != null
            ? DecorationImage(
                image: FileImage(viewModel.imageFile!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: viewModel.imageFile == null
          ? Icon(
              Icons.photo,
              color: AppColors.primaryGreen,
              size: screenWidth * 0.1,
            )
          : null,
    );
  }

  Widget _buildQuestion(BuildContext context, String question, double screenWidth) {
    return Container(
      width: screenWidth * 0.75, // 75% of screen width
      margin: const EdgeInsets.only(top: 16),
      child: Text(
        question,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'DMSans',
          fontWeight: FontWeight.w700,
          fontSize: 15,
          height: 1.2,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildOptions(BuildContext context, List<String> options, 
      WaterCalculationViewModel viewModel, double screenHeight, double screenWidth) {
    final l10n = AppLocalizations.of(context);

    print('🔄 BUILDING OPTIONS - Current selection: "$_selectedOption"');

    // Get localized options based on current question
    final localizedOptions = _getLocalizedOptions(viewModel.currentQuestion, l10n);

    return Container(
      width: screenWidth * 0.9, // 90% of screen width
      margin: EdgeInsets.only(top: screenHeight * 0.04),
      child: Column(
        children: localizedOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final localizedOption = entry.value;

          // Use original option from ViewModel for storage/comparison
          final originalOption = options[index];

          return _buildOptionCard(context, localizedOption, originalOption, 
              viewModel, screenHeight, screenWidth);
        }).toList(),
      ),
    );
  }

  // Helper method to get localized options
  List<String> _getLocalizedOptions(int questionNumber, AppLocalizations l10n) {
    switch (questionNumber) {
      case 1:
        return [
          l10n.water_location_indoor_window,
          l10n.water_location_indoor_shaded,
          l10n.water_location_outdoor_sun,
          l10n.water_location_outdoor_shade,
        ];
      case 2:
        return [
          l10n.water_temperature_very_cold,
          l10n.water_temperature_cold,
          l10n.water_temperature_moderate,
          l10n.water_temperature_warm,
          l10n.water_temperature_hot,
        ];
      case 3:
        return [
          l10n.water_frequency_daily,
          l10n.water_frequency_2_3_days,
          l10n.water_frequency_weekly,
          l10n.water_frequency_biweekly,
          l10n.water_frequency_rarely,
        ];
      default:
        return [];
    }
  }

  Widget _buildOptionCard(BuildContext context, String localizedOption, 
      String originalOption, WaterCalculationViewModel viewModel, 
      double screenHeight, double screenWidth) {
    final isSelected = _selectedOption == originalOption; // Compare with original

    print('   🔘 Option: "$originalOption" - Selected: $isSelected');

    return Container(
      width: double.infinity,
      height: 56,
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppColors.primaryGreen : AppColors.primaryGreen.withOpacity(0.5),
          width: isSelected ? 2 : 0.5,
        ),
      ),
      child: Center(
        child: ListTile(
          title: Text(
            localizedOption,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.black,
            ),
          ),
          trailing: SvgPicture.asset(
            isSelected ? 'assets/icons/ic_checked.svg' : 'assets/icons/ic_unchecked.svg',
            width: 22,
            height: 22,
          ),
          onTap: () {
            print('👆 TAPPED OPTION: "$originalOption"');
            setState(() {
              _selectedOption = originalOption; // Store original for comparison
            });
            _saveAnswer(originalOption, viewModel); // Save original
          },
        ),
      ),
    );
  }

  /*Widget _buildContinueButton(BuildContext context, WaterCalculationViewModel viewModel, 
      double screenHeight, double screenWidth) {
    final canContinue = _selectedOption != null;

    print('CONTINUE BUTTON - Can continue: $canContinue');

    return Container(
      width: screenWidth * 0.9, // 90% of screen width
      height: 60,
      margin: EdgeInsets.only(
      //  top: screenHeight * 0.04,
      //  bottom: screenHeight * 0.06,
      top: screenHeight * 0.14,   
      bottom: 50,

      ),
      child: ElevatedButton(
        onPressed: canContinue ? () => _navigateToNext(context, viewModel) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canContinue ? AppColors.primaryGreen : AppColors.mediumGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Text(
          AppLocalizations.of(context).water_continue,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }*/

  Widget _buildContinueButton(BuildContext context, WaterCalculationViewModel viewModel, 
    double screenHeight, double screenWidth) {
  final canContinue = _selectedOption != null;
  final currentQuestion = viewModel.currentQuestion;

  print('CONTINUE BUTTON - Can continue: $canContinue');

  // Calculate top margin based on question number
  double topMargin;
  switch (currentQuestion) {
    case 1:
      topMargin = screenHeight * 0.14; // Question 1 (4 options)
      break;
    case 2:
      topMargin = screenHeight * 0.06; // Question 2 (5 options) - less space needed
      break;
    case 3:
      topMargin = screenHeight * 0.06; // Question 3 (5 options) - less space needed
      break;
    default:
      topMargin = screenHeight * 0.12;
  }

  return Container(
    width: screenWidth * 0.9,
    height: 60,
    margin: EdgeInsets.only(
      top: topMargin,      // Dynamic based on question
      bottom: 50,          // Fixed 50px from bottom
    ),
    child: ElevatedButton(
      onPressed: canContinue ? () => _navigateToNext(context, viewModel) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canContinue ? AppColors.primaryGreen : AppColors.mediumGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: Text(
        AppLocalizations.of(context).water_continue,
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

  void _saveAnswer(String answer, WaterCalculationViewModel viewModel) {
    final currentQuestion = viewModel.currentQuestion;

    print('SAVING ANSWER: Q$currentQuestion = "$answer"');

    switch (currentQuestion) {
      case 1:
        viewModel.setLocation(answer);
        print('   Saved Location to ViewModel: $answer');
        break;
      case 2:
        viewModel.setTemperature(answer);
        print('Saved Temperature to ViewModel: $answer');
        break;
      case 3:
        viewModel.setWateringFrequency(answer);
        print(' Saved Watering Frequency to ViewModel: $answer');
        break;
    }

    // Print current state for verification
    print(' CURRENT VIEWMODEL STATE:');
    print('   Location: ${viewModel.location}');
    print('   Temperature: ${viewModel.temperature}');
    print('   Watering Frequency: ${viewModel.wateringFrequency}');
  }

  void _navigateToNext(BuildContext context, WaterCalculationViewModel viewModel) {
    final nextQuestion = viewModel.currentQuestion + 1;

    print(' NAVIGATING FROM QUESTION ${viewModel.currentQuestion} TO $nextQuestion');
    print(' CURRENT DATA FOR NAVIGATION:');
    print('   Location: ${viewModel.location}');
    print('   Temperature: ${viewModel.temperature}');
    print('   Watering Frequency: ${viewModel.wateringFrequency}');
    print('   Image: ${viewModel.imageFile != null ? "Provided" : "Missing"}');

    if (nextQuestion <= 3) {
      // Navigate to next question with ALL preserved data
      print(' NAVIGATING TO QUESTION $nextQuestion');
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.waterQuestions,
        arguments: {
          'imageFile': viewModel.imageFile,
          'currentQuestion': nextQuestion,
          'location': viewModel.location,
          'temperature': viewModel.temperature,
          'wateringFrequency': viewModel.wateringFrequency,
        },
      );
    } else {
      // All questions completed
      print(' ALL QUESTIONS COMPLETED - Proceeding to Processing');
      print(' FINAL DATA:');
      print('   Location: ${viewModel.location}');
      print('   Temperature: ${viewModel.temperature}');
      print('   Watering Frequency: ${viewModel.wateringFrequency}');

      _navigateToProcessing(context, viewModel);
    }
  }

  void _navigateToProcessing(BuildContext context, WaterCalculationViewModel viewModel) {
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.processing,
        arguments: {
          'imageFile': viewModel.imageFile,
          'mode': 'water',
          'location': viewModel.location,
          'temperature': viewModel.temperature,
          'wateringFrequency': viewModel.wateringFrequency,
        },
      );
    }
  }

  WaterQuestion _getCurrentQuestion(int currentQuestion, WaterCalculationViewModel viewModel) {
    final l10n = AppLocalizations.of(context);

    // Create questions on the fly with localized strings
    switch (currentQuestion) {
      case 1:
        return WaterQuestion(
          questionNumber: 1,
          question: l10n.water_question_location,
          options: [
            l10n.water_location_indoor_window,
            l10n.water_location_indoor_shaded,
            l10n.water_location_outdoor_sun,
            l10n.water_location_outdoor_shade,
          ],
        );
      case 2:
        return WaterQuestion(
          questionNumber: 2,
          question: l10n.water_question_temperature,
          options: [
            l10n.water_temperature_very_cold,
            l10n.water_temperature_cold,
            l10n.water_temperature_moderate,
            l10n.water_temperature_warm,
            l10n.water_temperature_hot,
          ],
        );
      case 3:
        return WaterQuestion(
          questionNumber: 3,
          question: l10n.water_question_frequency,
          options: [
            l10n.water_frequency_daily,
            l10n.water_frequency_2_3_days,
            l10n.water_frequency_weekly,
            l10n.water_frequency_biweekly,
            l10n.water_frequency_rarely,
          ],
        );
      default:
        return WaterQuestion(
          questionNumber: 1,
          question: l10n.water_question_location,
          options: [
            l10n.water_location_indoor_window,
            l10n.water_location_indoor_shaded,
            l10n.water_location_outdoor_sun,
            l10n.water_location_outdoor_shade,
          ],
        );
    }
  }
}*/




/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_identifier_app/data/models/water_question_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../view_models/water_calculation_view_model.dart';
import '../../l10n/app_localizations.dart';



class WaterQuestionsScreen extends StatefulWidget {
  const WaterQuestionsScreen({super.key});

  @override
  State<WaterQuestionsScreen> createState() => _WaterQuestionsScreenState();
}

class _WaterQuestionsScreenState extends State<WaterQuestionsScreen> {
  String? _selectedOption;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
     debugPrint('💣 ${runtimeType} INIT STATE');

    print('🔄 WaterQuestionsScreen initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🔄 WaterQuestionsScreen didChangeDependencies');
    if (!_isInitialized) {
      _initializeArguments();
      _isInitialized = true;
    }
  }

  void _initializeArguments() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    print('🔄 INITIALIZING WATER QUESTIONS SCREEN WITH ARGS: ${args != null}');
    
    if (args != null) {
      final viewModel = Provider.of<WaterCalculationViewModel>(context, listen: false);
      final imageFile = args['imageFile'] as File?;
      final currentQuestion = args['currentQuestion'] as int? ?? 1;
      final location = args['location'] as String?;
      final temperature = args['temperature'] as String?;
      final wateringFrequency = args['wateringFrequency'] as String?;
      
      print(' RECEIVED ARGUMENTS:');
      print('   Current Question: $currentQuestion');
      print('   Location: $location');
      print('   Temperature: $temperature');
      print('   Watering Frequency: $wateringFrequency');
      print('   Image: ${imageFile != null ? "Provided" : "Missing"}');
      
      // Use WidgetsBinding to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processInitialization(
          viewModel: viewModel,
          imageFile: imageFile,
          currentQuestion: currentQuestion,
          location: location,
          temperature: temperature,
          wateringFrequency: wateringFrequency,
        );
      });
    } else {
      print('NO ARGUMENTS PROVIDED - Starting fresh');
    }
  }

  void _processInitialization({
    required WaterCalculationViewModel viewModel,
    required File? imageFile,
    required int currentQuestion,
    required String? location,
    required String? temperature,
    required String? wateringFrequency,
  }) {
    print('PROCESSING INITIALIZATION...');
    
    if (imageFile != null) {
      viewModel.setImageFile(imageFile);
    }
    
    viewModel.setCurrentQuestion(currentQuestion);
    
    // CRITICAL: Restore previous answers to ViewModel
    if (location != null && location.isNotEmpty) {
      viewModel.setLocation(location);
      print(' Restored Location to ViewModel: $location');
    }
    if (temperature != null && temperature.isNotEmpty) {
      viewModel.setTemperature(temperature);
      print(' Restored Temperature to ViewModel: $temperature');
    }
    if (wateringFrequency != null && wateringFrequency.isNotEmpty) {
      viewModel.setWateringFrequency(wateringFrequency);
      print(' Restored Watering Frequency to ViewModel: $wateringFrequency');
    }
    
    // Auto-select current question's answer in UI
    _autoSelectCurrentAnswer(viewModel, currentQuestion);
  }

  void _autoSelectCurrentAnswer(WaterCalculationViewModel viewModel, int currentQuestion) {
    String? currentAnswer;
    switch (currentQuestion) {
      case 1:
        currentAnswer = viewModel.location;
        break;
      case 2:
        currentAnswer = viewModel.temperature;
        break;
      case 3:
        currentAnswer = viewModel.wateringFrequency;
        break;
    }
    
    print('AUTO-SELECTING FOR Q$currentQuestion: "$currentAnswer"');
    
    if (currentAnswer != null && currentAnswer.isNotEmpty) {
      setState(() {
        _selectedOption = currentAnswer;
      });
      print('UI Auto-selected: $currentAnswer');
    } else {
      print('No previous answer to auto-select');
    }
  }

  @override
Widget build(BuildContext context) {
 debugPrint('💣 ${runtimeType} BUILD CALLED');

  final viewModel = Provider.of<WaterCalculationViewModel>(context);
  final currentQuestion = viewModel.currentQuestion;
  final questionData = _getCurrentQuestion(currentQuestion, viewModel);

  print('BUILDING SCREEN - Q$currentQuestion, Selected: "$_selectedOption"');

  return Scaffold(
    backgroundColor: AppColors.white,
    appBar: AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.black),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: SafeArea(
      
      child: _buildContent(context, viewModel, questionData),
    ),
  );
}
  Widget _buildContent(BuildContext context, WaterCalculationViewModel viewModel, WaterQuestion questionData) {
    return 
       SingleChildScrollView(
        child: Center(
      child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Progress Indicator
            _buildProgressIndicator(context, viewModel),
            
            // Plant Image
            _buildPlantImage(context, viewModel),
            
            // Question
            _buildQuestion(context, questionData.question),
            
            // Options
            _buildOptions(context, questionData.options, viewModel),
            
            // Continue Button
            _buildContinueButton(context, viewModel),
          ],
        ),
       ),
       );
  }

  Widget _buildProgressIndicator(BuildContext context, WaterCalculationViewModel viewModel) {
    return Container(
      width: ResponsiveHelper.responsiveWidth(205, context),
      height: ResponsiveHelper.responsiveHeight(30, context),
      margin: EdgeInsets.only(
     //  top: ResponsiveHelper.responsiveHeight(83, context),
      ),
      child: Stack(
        children: [
          // Background connecting line (full gray)
          Positioned(
            left: ResponsiveHelper.responsiveWidth(15, context),
            right: ResponsiveHelper.responsiveWidth(15, context),
            top: ResponsiveHelper.responsiveHeight(14, context),
            child: Container(
              height: 2,
              color: AppColors.lightGray,
            ),
          ),
          // Progress connecting line (green for completed sections)
          if (viewModel.currentQuestion > 1)
            Positioned(
              left: ResponsiveHelper.responsiveWidth(15, context),
              top: ResponsiveHelper.responsiveHeight(14, context),
              child: Container(
                height: 2,
                width: _calculateProgressWidth(context, viewModel.currentQuestion),
                color: AppColors.primaryGreen,
              ),
            ),
          // Progress dots with numbers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              final questionNumber = index + 1;
              final isCompleted = questionNumber < viewModel.currentQuestion;
              final isCurrent = questionNumber == viewModel.currentQuestion;
              
              return Container(
                width: ResponsiveHelper.responsiveWidth(30, context),
                height: ResponsiveHelper.responsiveWidth(30, context),
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent 
                      ? AppColors.primaryGreen 
                      : AppColors.lightGray,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$questionNumber',
                    style: TextStyle(
                      color: isCompleted || isCurrent 
                          ? AppColors.white 
                          : AppColors.darkGray,
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveHelper.responsiveFontSize(14, context),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  double _calculateProgressWidth(BuildContext context, int currentQuestion) {
    final totalWidth = ResponsiveHelper.responsiveWidth(205, context) - 
                      ResponsiveHelper.responsiveWidth(30, context);
    
    if (currentQuestion == 2) {
      return totalWidth / 2;
    } else if (currentQuestion == 3) {
      return totalWidth;
    } else {
      return 0;
    }
  }

  Widget _buildPlantImage(BuildContext context, WaterCalculationViewModel viewModel) {
    return Container(
      width: ResponsiveHelper.responsiveWidth(100, context),
      height: ResponsiveHelper.responsiveWidth(100, context),
      margin: EdgeInsets.only(
        top: ResponsiveHelper.responsiveHeight(16, context),
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightGreenBg,
        image: viewModel.imageFile != null
            ? DecorationImage(
                image: FileImage(viewModel.imageFile!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: viewModel.imageFile == null
          ? Icon(
              Icons.photo,
              color: AppColors.primaryGreen,
              size: ResponsiveHelper.responsiveWidth(40, context),
            )
          : null,
    );
  }

  Widget _buildQuestion(BuildContext context, String question) {
    return Container(
      width: ResponsiveHelper.responsiveWidth(284, context),
      margin: EdgeInsets.only(
        top: ResponsiveHelper.responsiveHeight(16, context),
      ),
      child: Text(
        question,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontWeight: FontWeight.w700,
          fontSize: ResponsiveHelper.responsiveFontSize(15, context),
          height: 1.0,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildOptions(BuildContext context, List<String> options, WaterCalculationViewModel viewModel) {
    final l10n = AppLocalizations.of(context);
   
    print('🔄 BUILDING OPTIONS - Current selection: "$_selectedOption"');
    
     // Get localized options based on current question
  final localizedOptions = _getLocalizedOptions(viewModel.currentQuestion, l10n);

    return Container(
      width: ResponsiveHelper.responsiveWidth(343, context),
      margin: EdgeInsets.only(
        top: ResponsiveHelper.responsiveHeight(32, context),
      ),
      child: Column(
      //  children: options.map((option) {
       children: localizedOptions.asMap().entries.map((entry) {
         final index = entry.key;
        final localizedOption = entry.value;

         // Use original option from ViewModel for storage/comparison
        final originalOption = options[index];

        //  return _buildOptionCard(context, option, viewModel);
       // }).toList(),
       return _buildOptionCard(context, localizedOption, originalOption, viewModel);
      }).toList(),
      ),
    );
  }

  
   // Helper method to get localized options
List<String> _getLocalizedOptions(int questionNumber, AppLocalizations l10n) {
  switch (questionNumber) {
    case 1:
      return [
        l10n.water_location_indoor_window,
        l10n.water_location_indoor_shaded,
        l10n.water_location_outdoor_sun,
        l10n.water_location_outdoor_shade,
      ];
    case 2:
      return [
        l10n.water_temperature_very_cold,
        l10n.water_temperature_cold,
        l10n.water_temperature_moderate,
        l10n.water_temperature_warm,
        l10n.water_temperature_hot,
      ];
    case 3:
      return [
        l10n.water_frequency_daily,
        l10n.water_frequency_2_3_days,
        l10n.water_frequency_weekly,
        l10n.water_frequency_biweekly,
        l10n.water_frequency_rarely,
      ];
    default:
      return [];
  }
}


//  Widget _buildOptionCard(BuildContext context, String localizedOption, WaterCalculationViewModel viewModel) {
Widget _buildOptionCard(BuildContext context, String localizedOption, 
String originalOption, WaterCalculationViewModel viewModel) {

 final isSelected = _selectedOption == originalOption; // Compare with original
    
     print('   🔘 Option: "$originalOption" - Selected: $isSelected');
    
    return Container(
      width: double.infinity,
      height: ResponsiveHelper.responsiveHeight(60, context),
      margin: EdgeInsets.only(bottom: ResponsiveHelper.responsiveHeight(12, context)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppColors.primaryGreen : AppColors.primaryGreen.withOpacity(0.5),
          width: isSelected ? 2 : 0.5,
        ),
      ),
      child: Center(
        child: ListTile(
          title: Text(
          //  option,
           localizedOption,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w500,
              fontSize: ResponsiveHelper.responsiveFontSize(14, context),
              color: AppColors.black,
            ),
          ),
          trailing: SvgPicture.asset(
            isSelected ? 'assets/icons/ic_checked.svg' : 'assets/icons/ic_unchecked.svg',
            width: ResponsiveHelper.responsiveWidth(22, context),
            height: ResponsiveHelper.responsiveWidth(22, context),
          ),
          onTap: () {
             print('👆 TAPPED OPTION: "$originalOption"');
            setState(() {
            //  _selectedOption = option;
             _selectedOption = originalOption; // ← Store original for comparison
            });
          //  _saveAnswer(option, viewModel);
           _saveAnswer(originalOption, viewModel); // ← Save original
          },
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context, WaterCalculationViewModel viewModel) {
    final canContinue = _selectedOption != null;
    
    print('CONTINUE BUTTON - Can continue: $canContinue');
    
    return Container(
      width: ResponsiveHelper.responsiveWidth(343, context),
      height: ResponsiveHelper.responsiveHeight(60, context),
      margin: EdgeInsets.only(
        top: ResponsiveHelper.responsiveHeight(32, context),
        bottom: ResponsiveHelper.responsiveHeight(50, context),
      ),
      child: ElevatedButton(
        onPressed: canContinue ? () => _navigateToNext(context, viewModel) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canContinue ? AppColors.primaryGreen : AppColors.mediumGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Text(
        //  'Continue',
         AppLocalizations.of(context).water_continue,
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

  void _saveAnswer(String answer, WaterCalculationViewModel viewModel) {
    final currentQuestion = viewModel.currentQuestion;
    
    print('SAVING ANSWER: Q$currentQuestion = "$answer"');
    
    switch (currentQuestion) {
      case 1:
        viewModel.setLocation(answer);
        print('   Saved Location to ViewModel: $answer');
        break;
      case 2:
        viewModel.setTemperature(answer);
        print('Saved Temperature to ViewModel: $answer');
        break;
      case 3:
        viewModel.setWateringFrequency(answer);
        print(' Saved Watering Frequency to ViewModel: $answer');
        break;
    }
    
    // Print current state for verification
    print(' CURRENT VIEWMODEL STATE:');
    print('   Location: ${viewModel.location}');
    print('   Temperature: ${viewModel.temperature}');
    print('   Watering Frequency: ${viewModel.wateringFrequency}');
  }

  void _navigateToNext(BuildContext context, WaterCalculationViewModel viewModel) {
    final nextQuestion = viewModel.currentQuestion + 1;
    
    print(' NAVIGATING FROM QUESTION ${viewModel.currentQuestion} TO $nextQuestion');
    print(' CURRENT DATA FOR NAVIGATION:');
    print('   Location: ${viewModel.location}');
    print('   Temperature: ${viewModel.temperature}');
    print('   Watering Frequency: ${viewModel.wateringFrequency}');
    print('   Image: ${viewModel.imageFile != null ? "Provided" : "Missing"}');
    
    if (nextQuestion <= 3) {
      // Navigate to next question with ALL preserved data
      print(' NAVIGATING TO QUESTION $nextQuestion');
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.waterQuestions,
        arguments: {
          'imageFile': viewModel.imageFile,
          'currentQuestion': nextQuestion,
          'location': viewModel.location,
          'temperature': viewModel.temperature,
          'wateringFrequency': viewModel.wateringFrequency,
        },
      );
    } else {
      // All questions completed
      print(' ALL QUESTIONS COMPLETED - Proceeding to Processing');
      print(' FINAL DATA:');
      print('   Location: ${viewModel.location}');
      print('   Temperature: ${viewModel.temperature}');
      print('   Watering Frequency: ${viewModel.wateringFrequency}');
      
      _navigateToProcessing(context, viewModel);
    }
  }

  void _navigateToProcessing(BuildContext context, WaterCalculationViewModel viewModel) {
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.processing,
        arguments: {
          'imageFile': viewModel.imageFile,
          'mode': 'water',
          'location': viewModel.location,
          'temperature': viewModel.temperature,
          'wateringFrequency': viewModel.wateringFrequency,
        },
      );
    }
  }

 WaterQuestion _getCurrentQuestion(int currentQuestion, WaterCalculationViewModel viewModel) {
  final l10n = AppLocalizations.of(context);
  
  // Create questions on the fly with localized strings
  switch (currentQuestion) {
    case 1:
      return WaterQuestion(
        questionNumber: 1,
        question: l10n.water_question_location,
        options: [
          l10n.water_location_indoor_window,
          l10n.water_location_indoor_shaded,
          l10n.water_location_outdoor_sun,
          l10n.water_location_outdoor_shade,
        ],
      );
    case 2:
      return WaterQuestion(
        questionNumber: 2,
        question: l10n.water_question_temperature,
        options: [
          l10n.water_temperature_very_cold,
          l10n.water_temperature_cold,
          l10n.water_temperature_moderate,
          l10n.water_temperature_warm,
          l10n.water_temperature_hot,
        ],
      );
    case 3:
      return WaterQuestion(
        questionNumber: 3,
        question: l10n.water_question_frequency,
        options: [
          l10n.water_frequency_daily,
          l10n.water_frequency_2_3_days,
          l10n.water_frequency_weekly,
          l10n.water_frequency_biweekly,
          l10n.water_frequency_rarely,
        ],
      );
    default:
      return WaterQuestion(
        questionNumber: 1,
        question: l10n.water_question_location,
        options: [
          l10n.water_location_indoor_window,
          l10n.water_location_indoor_shaded,
          l10n.water_location_outdoor_sun,
          l10n.water_location_outdoor_shade,
        ],
      );
  }
}*/

  
/* final List<WaterQuestion> _waterQuestions = [
    WaterQuestion(
      questionNumber: 1,
    //  question: 'Where do you intend to keep the plant?',
     question: AppLocalizations.of(context).water_question_location,
      options: [
      /*'Indoor, Close To Window',
        'Indoor, In A Shaded Corner',
        'Outdoor, Full Sun',
        'Outdoor, Partial Shade',*/

      AppLocalizations.of(context).water_location_indoor_window,
      AppLocalizations.of(context).water_location_indoor_shaded,
      AppLocalizations.of(context).water_location_outdoor_sun,
      AppLocalizations.of(context).water_location_outdoor_shade,
      ],
    ),
    WaterQuestion(
       questionNumber: 2,
    //  question: 'What\'s the current temperature?',
     question: AppLocalizations.of(context).water_question_temperature,
      options: [
      /*'Very Cold (Below 5°C / 41°F)',
        'Cold (Below 15°C / 59°F)',
        'Moderate (15°C - 25°C / 59°F - 77°F)',
        'Warm (25°C - 30°C / 77°F - 86°F)',
        'Hot (Above 30°C / 86°F)',*/

      AppLocalizations.of(context).water_temperature_very_cold,
      AppLocalizations.of(context).water_temperature_cold,
      AppLocalizations.of(context).water_temperature_moderate,
      AppLocalizations.of(context).water_temperature_warm,
      AppLocalizations.of(context).water_temperature_hot,
      ],
    ),
    WaterQuestion(
      questionNumber: 3,
    //  question: 'How often do you water?',
     question: AppLocalizations.of(context).water_question_frequency, 
      options: [
      /*  'Daily',
        'Every 2-3 Days',
        'Once A Week',
        'Every two Weeks',
        'Rarely / When Dry',*/

         AppLocalizations.of(context).water_frequency_daily,
      AppLocalizations.of(context).water_frequency_2_3_days,
      AppLocalizations.of(context).water_frequency_weekly,
      AppLocalizations.of(context).water_frequency_biweekly,
      AppLocalizations.of(context).water_frequency_rarely,
      ],
    ),
  ];*/
//}

