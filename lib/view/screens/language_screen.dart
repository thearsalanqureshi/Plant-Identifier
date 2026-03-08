import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/language_view_model.dart';
import '../../../app/theme/app_colors.dart';
import '../../view/widgets/common/language_app_bar.dart';
import '../../view/widgets/common/language_item.dart';
import '../../../app/navigation/navigation_service.dart';

class LanguageScreen extends StatefulWidget {
  final bool showBackButton;

  const LanguageScreen({super.key, this.showBackButton = true});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('💣 ${widget.runtimeType} INIT STATE CALLED');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('💣 ${runtimeType} BUILD CALLED');

    final navigationService = Provider.of<NavigationService>(context, listen: false);
    final viewModel = Provider.of<LanguageViewModel>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // DEBUG: Check what value we're passing
    final backButtonCallback = widget.showBackButton
        ? () => _handleBackPressed(navigationService)
        : null;

    print(' LanguageScreen - showBackButton: ${widget.showBackButton}');
    print(' LanguageScreen - backButtonCallback: $backButtonCallback');

    return Scaffold(
      backgroundColor: AppColors.languageScreenBg,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            LanguageAppBar(
              onBackPressed: backButtonCallback,
              onSavePressed: () => _handleSavePressed(viewModel, navigationService),
              canSave: true,
            ),

            // Language List
            Expanded(
              child: _buildLanguageList(viewModel, screenHeight, screenWidth),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageList(LanguageViewModel viewModel, double screenHeight, double screenWidth) {
    return ListView.separated(
      padding: EdgeInsets.only(
        top: screenHeight * 0.015, // 1.5% of screen height
        bottom: screenHeight * 0.025, // 2.5% of screen height
        left: screenWidth * 0.04, // 4% of screen width
        right: screenWidth * 0.04, // 4% of screen width
      ),
      itemCount: viewModel.supportedLanguages.length,
      separatorBuilder: (context, index) => SizedBox(height: screenHeight * 0.015), // 1.5% spacing
      itemBuilder: (context, index) {
        final language = viewModel.supportedLanguages[index];
        return LanguageItem(
          language: language,
          isSelected: viewModel.isSelected(language),
          onTap: () => viewModel.selectLanguage(language),
        );
      },
    );
  }

  void _handleBackPressed(NavigationService navigationService) {
    navigationService.pop();
  }

  Future<void> _handleSavePressed(
    LanguageViewModel viewModel,
    NavigationService navigationService,
  ) async {
    await viewModel.saveLanguageSelection();

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      navigationService.pushReplacementNamed('/home');
    }
  }
}


/* ----- Correct but unresponsive ------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/language_view_model.dart';
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';
import '../../view/widgets/common/language_app_bar.dart';
import '../../view/widgets/common/language_item.dart';
import '../../../app/navigation/navigation_service.dart';

class LanguageScreen extends StatefulWidget {
  final bool showBackButton;
  
  const LanguageScreen({ super.key, 
    this.showBackButton = true
  });

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
   void initState() {
    super.initState();
    debugPrint('💣 ${widget.runtimeType} INIT STATE CALLED');
  }

  Widget build(BuildContext context) {
  debugPrint('💣 ${runtimeType} BUILD CALLED');

    final navigationService = Provider.of<NavigationService>(context, listen: false);
    final viewModel = Provider.of<LanguageViewModel>(context);

    // DEBUG: Check what value we're passing
    final backButtonCallback = widget.showBackButton 
        ? () => _handleBackPressed(navigationService) 
        : null;
    
    print(' LanguageScreen - showBackButton: ${widget.showBackButton}');
    print(' LanguageScreen - backButtonCallback: $backButtonCallback');

    return Scaffold(
      backgroundColor: AppColors.languageScreenBg,
      body: SafeArea(
       
        child: Column(
          children: [
            // App Bar
            LanguageAppBar(
              onBackPressed: backButtonCallback,
              onSavePressed: () => _handleSavePressed(viewModel, navigationService),
              canSave: true,
            ),
            
            // Language List
            Expanded(
              child: _buildLanguageList(viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageList(LanguageViewModel viewModel) {
    return ListView.separated(
      padding: EdgeInsets.only(
        top: ResponsiveHelper.responsiveHeight(12, context),
        bottom: ResponsiveHelper.responsiveHeight(20, context),
        left: ResponsiveHelper.responsiveWidth(16, context),
        right: ResponsiveHelper.responsiveWidth(16, context),
      ),
      itemCount: viewModel.supportedLanguages.length,
      separatorBuilder: (context, index) => 
          SizedBox(height: ResponsiveHelper.responsiveHeight(12, context)),
      itemBuilder: (context, index) {
        final language = viewModel.supportedLanguages[index];
        return LanguageItem(
          language: language,
          isSelected: viewModel.isSelected(language),
          onTap: () => viewModel.selectLanguage(language),
        );
      },
    );
  }

  void _handleBackPressed(NavigationService navigationService) {
    navigationService.pop(); 
  }

  Future<void> _handleSavePressed(
    LanguageViewModel viewModel, 
    NavigationService navigationService
  ) async {
    await viewModel.saveLanguageSelection();

    // Show success message
  /*
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Language updated to ${viewModel.selectedLanguage.name}'),
      duration: Duration(seconds: 2),
    ),
  );
  */

   if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {


    navigationService.pushReplacementNamed('/home'); 
    
  }

/*
   ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language updated to ${viewModel.selectedLanguage.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
    */
  }
}*/

