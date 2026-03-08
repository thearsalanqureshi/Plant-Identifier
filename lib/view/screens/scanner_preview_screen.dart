import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../utils/constants.dart';
import '../../l10n/app_localizations.dart';

class ScannerPreviewScreen extends StatefulWidget {
  const ScannerPreviewScreen({super.key});

  @override
  State<ScannerPreviewScreen> createState() => _ScannerPreviewScreenState();
}

class _ScannerPreviewScreenState extends State<ScannerPreviewScreen> {
   @override
  void initState() {
    super.initState();
    debugPrint('💣 ${widget.runtimeType} INIT STATE CALLED');
  }
  final ImagePicker _imagePicker = ImagePicker();
  File? _imageFile;
  String _mode = 'identify';


  @override
Widget build(BuildContext context) {
debugPrint('💣 ${runtimeType} BUILD CALLED');

  _initializeArguments(context);

final screenHeight = MediaQuery.of(context).size.height;
final screenWidth = MediaQuery.of(context).size.width;
final isSmallDevice = screenHeight < 700;
  
  return Scaffold(
    backgroundColor: Color(0xFF1E1F24),
    body: SafeArea(
      
      child: Stack(
        children: [ // Image Preview
          Positioned(
            top: screenHeight * 0.08, // 8% from top
            left: screenWidth * 0.04, // 4% from left
            right: screenWidth * 0.04, // 4% from right
            child: Container(
              height: screenHeight * 0.65, // 65% of screen height
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.black,
              ),
              child: _imageFile != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _imageFile!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo,
                      color: AppColors.white.withOpacity(0.5),
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).preview_no_image,
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top Controls
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 44), // Empty for balance
              ],
            ),
          ),

          // Gallery Button (Bottom Left)
          Positioned(
            bottom: screenHeight * 0.05, // 5% from bottom
            left: screenWidth * 0.1, // 10% from left
            child: GestureDetector(
              onTap: _pickDifferentImage,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppConstants.galleryIcon,
                    width: 24,
                    height: 26,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).preview_gallery,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confirm Button (Bottom Center)
          Positioned(
            bottom: screenHeight * 0.04, // 4% from bottom
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _confirmImage,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    border: Border.all(
                      color: AppColors.white,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }


   /* Widget _buildImagePreview() {

    return Positioned(
      top: ResponsiveHelper.responsiveHeight(99, context),
      left: ResponsiveHelper.responsiveWidth(16, context),
      child: Container(
        width: ResponsiveHelper.responsiveWidth(344, context),
        height: ResponsiveHelper.responsiveHeight(569, context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.black,
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _imageFile!,
                  width: ResponsiveHelper.responsiveWidth(344, context),
                  height: ResponsiveHelper.responsiveHeight(569, context),
                  fit: BoxFit.cover,
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo,
                      color: AppColors.white.withOpacity(0.5),
                      size: ResponsiveHelper.responsiveWidth(48, context),
                    ),
                    SizedBox(height: ResponsiveHelper.responsiveHeight(16, context)),
                    Text(
                    //  'No Image',
                      AppLocalizations.of(context).preview_no_image,
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.7),
                        fontSize: ResponsiveHelper.responsiveFontSize(16, context),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }*/

 /* Widget _buildTopControls() {
    return Positioned(
      top: ResponsiveHelper.responsiveHeight(46, context),
      left: ResponsiveHelper.responsiveWidth(16, context),
      right: ResponsiveHelper.responsiveWidth(16, context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Cancel Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: ResponsiveHelper.responsiveWidth(24, context),
              height: ResponsiveHelper.responsiveWidth(24, context),
              child: Icon(
                Icons.close,
                color: AppColors.white,
                size: ResponsiveHelper.responsiveWidth(24, context),
              ),
            ),
          ),

          // Empty container to maintain layout balance (flash button removed)
          Container(
            width: ResponsiveHelper.responsiveWidth(24, context),
            height: ResponsiveHelper.responsiveWidth(24, context),
          ),
        ],
      ),
    );
  }*/

  /*Widget _buildConfirmButton() {
    return Positioned(
      bottom: ResponsiveHelper.responsiveHeight(34, context), // Adjusted for home indicator
      left: ResponsiveHelper.responsiveWidth(159, context),
      child: GestureDetector(
        onTap: _confirmImage,
        child: Container(
          width: ResponsiveHelper.responsiveWidth(58, context),
          height: ResponsiveHelper.responsiveWidth(58, context), 
          padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(4, context)),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            border: Border.all(
              color: AppColors.white,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Icon(
              Icons.check,
              color: AppColors.white,
              size: ResponsiveHelper.responsiveWidth(28, context),
              weight: 600, 
            ),
          ),
        ),
      ),
    );
  }*/

 /* Widget _buildGalleryButton() {
    return Positioned(
      bottom: ResponsiveHelper.responsiveHeight(38, context), 
      left: ResponsiveHelper.responsiveWidth(48, context),
      child: GestureDetector(
        onTap: _pickDifferentImage,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppConstants.galleryIcon,
              width: ResponsiveHelper.responsiveWidth(24, context),
              height: ResponsiveHelper.responsiveWidth(26, context),
              color: AppColors.white,
            ),
            SizedBox(height: ResponsiveHelper.responsiveHeight(4, context)),
            Text(
            //  'Gallery',
               AppLocalizations.of(context).preview_gallery,
              style: TextStyle(
                color: AppColors.white,
                fontSize: ResponsiveHelper.responsiveFontSize(12, context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }*/

  void _initializeArguments(BuildContext context) {
      debugPrint('🎯 [2/6] PREVIEW SCREEN INITIALIZING');
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      debugPrint('✅ [2/6] PREVIEW ARGS RECEIVED:');
    debugPrint('   Image: ${args['imageFile'] != null ? "YES" : "NO"}');
    debugPrint('   Mode: ${args['mode']}');
     
      setState(() {
        _imageFile = args['imageFile'];
        _mode = args['mode'] ?? 'identify';
      });
       } else {
         debugPrint('❌ [2/6] NO ARGUMENTS RECEIVED');
    }
  }

 // void _toggleFlash() {
 //   setState(() {
 //     _isFlashOn = !_isFlashOn;
 //   });
 // }

  Future<void> _pickDifferentImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      _showError('Gallery error: $e');
    }
  }
void _confirmImage() {

  debugPrint('💣💣💣 PREVIEW SCREEN: _confirmImage() STARTED');
  debugPrint('💣 Mode: $_mode');
  debugPrint('💣 Image: ${_imageFile?.path}');

  if (_imageFile != null) {
    debugPrint('✅✅✅ NAVIGATING TO PROCESSING with mode: $_mode');
     print('PreviewScreen: Confirming image for mode $_mode');

    if (_mode == 'water') {
       debugPrint('🌊 Water calculation flow selected');

      Navigator.pushNamed(
        context, 
        AppRoutes.waterQuestions,
        arguments: {
          'imageFile': _imageFile,
          'mode': _mode,
        },
      );
    } else {
         debugPrint('🌿 Plant identification flow selected');
      debugPrint('🔄 Navigating to ProcessingScreen...');
      Navigator.pushNamed(
        context, 
        AppRoutes.processing,
        arguments: {
          'imageFile': _imageFile,
          'mode': _mode
        },
           ).then((_) {
      debugPrint('✅✅✅ NAVIGATION COMPLETE');
    }).catchError((e) {
      debugPrint('❌❌❌ NAVIGATION ERROR: $e');
      });
    }
  } else {
    
      debugPrint('❌❌❌ NO IMAGE FILE');
  //  _showError('Please select an image first');
  _showError(AppLocalizations.of(context).preview_select_image_error);
  }
}

//  Fix the _showError method to accept context
void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    ),
  );
}
  
}