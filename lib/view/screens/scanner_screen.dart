import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../view_models/scanner_view_model.dart';
import 'dart:developer' as developer;

import '../../l10n/app_localizations.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with TickerProviderStateMixin {
  bool _hasInitialized = false;
   bool _isCapturing = false; 
   bool _isMounted = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('💣 ${widget.runtimeType} INIT STATE CALLED');

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _preloadCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeArguments();
  }

 void _safeSetState(VoidCallback fn) {
    if (_isMounted) {
      setState(fn);
    }
  }


  void _initializeArguments() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      final viewModel = Provider.of<ScannerViewModel>(context, listen: false);
      viewModel.setMode(args['mode'] ?? 'identify');
    }
  }

  void _preloadCamera() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<ScannerViewModel>(context, listen: false);
      await viewModel.initializeCamera();
      _hasInitialized = true;
      
      
      _fadeController.forward();
      
      if (mounted)  _safeSetState(() {});
    });
  }

/*
  @override
  void dispose() {
    _fadeController.dispose();
    final viewModel = Provider.of<ScannerViewModel>(context, listen: false);
    viewModel.disposeCamera();
    super.dispose();
  }
  */

/*
@override
void dispose() {
  debugPrint('🔄 ScannerScreen DISPOSE STARTED');
  
  // Dispose animation FIRST
  _fadeController.dispose();
  
  // Get viewModel BEFORE super.dispose()
  final viewModel = Provider.of<ScannerViewModel>(context, listen: false);
  
  // Use post-frame to ensure widget is fully disposed
  WidgetsBinding.instance.addPostFrameCallback((_) {
    debugPrint('📸 Post-frame camera disposal');
    viewModel.disposeCamera();
  });
  
  debugPrint('✅ ScannerScreen dispose() completed');
  super.dispose();
}
*/

@override
void dispose() {
  _isMounted = false;
  developer.log('🔄 ScannerScreen DISPOSE SEQUENCE START', name: 'CAMERA');
  
  // 1. Stop animations first
  _fadeController.stop();
  _fadeController.dispose();
  developer.log('✅ Animations disposed', name: 'CAMERA');
  
  // 2. Get viewModel reference before context becomes invalid
  ScannerViewModel? viewModel;
  try {
    viewModel = Provider.of<ScannerViewModel>(context, listen: false);
    developer.log('📸 ViewModel acquired for disposal', name: 'CAMERA');
  } catch (e) {
    developer.log('⚠️ Could not get ViewModel: $e', name: 'CAMERA');
  }
  
  // 3. Call super.dispose() to clean up widget tree
  super.dispose();
  developer.log('✅ super.dispose() completed', name: 'CAMERA');
  
  // 4. Schedule camera cleanup for next frame (AFTER widget is fully disposed)
  if (viewModel != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      developer.log('📸 Post-frame camera cleanup scheduled', name: 'CAMERA');
      
      // Add small delay to ensure complete disposal
      Future.delayed(Duration(milliseconds: 100), () {
        developer.log('📸 Executing delayed camera disposal', name: 'CAMERA');
        viewModel!.disposeCamera();
      });
    });
  }
  
  developer.log('✅ ScannerScreen dispose() sequence complete', name: 'CAMERA');
}


/*
  @override
  Widget build(BuildContext context) {
   debugPrint('💣 ${runtimeType} BUILD CALLED');


     debugPrint('💣💣💣 SCANNER SCREEN: BUILD() CALLED');
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
      
        child: Stack(
          children: [
           
            Positioned.fill(
              child: _buildCameraPreview(),
            ),
            
            
            Positioned(
              top: 16,    //ResponsiveHelper.statusBarHeight(context),
              left: 16,   // 0,
              right: 16,  // 0,
              child: _buildTopControls(),
            ),
            
          
            Positioned(
              bottom: 30,    // ResponsiveHelper.bottomBarHeight(context),
              left: 0,
              right: 0,
              child: _buildBottomControls(),
            ),
          ],
        ),
      ),
    );
  }
  */


@override
Widget build(BuildContext context) {
  debugPrint('💣 ${runtimeType} BUILD CALLED');
  debugPrint('💣💣💣 SCANNER SCREEN: BUILD() CALLED');

  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallDevice = screenHeight < 700;
  
  return Scaffold(
    backgroundColor: AppColors.black,
    body: SafeArea(
      child: Stack(
         clipBehavior: Clip.none,
        children: [
          // Camera Preview - FILLS ENTIRE SCREEN
          Positioned.fill(
            child: _buildCameraPreview(),
          ),
          
          // Top Controls - SINGLE Positioned widget
    Positioned(
      top: 16,
      left: 16,
      right: 16,
      child:
      Consumer<ScannerViewModel>(
            builder: (context, viewModel, child) {
              return  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    _buildControlButton(
                      icon: Icons.close,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    
                    if (viewModel.isCameraInitialized)
                      _buildControlButton(
                        icon: viewModel.isFlashOn ? Icons.flash_on : Icons.flash_off,
                        onTap: () => viewModel.toggleFlash(),
                      )
                    else
                      const SizedBox(width: 44),
                ],
              );
            },
      ),
    ),
          
          // Bottom Controls - SINGLE Positioned widget
          Positioned(
            bottom: screenHeight * 0.05, // 5% from bottom
            left: 0,
            right: 0,
            child: _buildBottomControls(screenHeight, screenWidth, isSmallDevice),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildCameraPreview() {
  return Consumer<ScannerViewModel>(
    builder: (context, viewModel, child) {
      if (viewModel.isCameraInitialized && viewModel.cameraController != null) {
        final cameraController = viewModel.cameraController!;
        
        // Get camera aspect ratio from controller
        final aspectRatio = cameraController.value.aspectRatio;
        
        // Uses AspectRatio widget to prevent stretching
        return AspectRatio(
          aspectRatio: aspectRatio,
          child: CameraPreview(cameraController),
        );
      }
      return Container(color: AppColors.black);
    },
  );
}

 
  Widget _buildTopControls() {
    return Consumer<ScannerViewModel>(
      builder: (context, viewModel, child) {
        return Positioned(
          top: ResponsiveHelper.responsiveHeight(16, context),
          left: ResponsiveHelper.responsiveWidth(16, context),
          right: ResponsiveHelper.responsiveWidth(16, context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Close Button
              _buildControlButton(
                icon: Icons.close,
                onTap: () => Navigator.of(context).pop(),
              ),
              
              
              if (viewModel.isCameraInitialized)
                _buildControlButton(
                  icon: viewModel.isFlashOn ? Icons.flash_on : Icons.flash_off,
                  onTap: () => viewModel.toggleFlash(),
                )
              else
                const SizedBox(width: 44), 
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomControls(double screenHeight, double screenWidth,
      bool isSmallDevice) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer<ScannerViewModel>(
            builder: (context, viewModel, child) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getModeText(viewModel.currentMode),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),

          SizedBox(height: screenHeight * 0.03), // 3% spacing
          
          // Camera & Gallery Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1), // 10% horizontal padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Gallery Button
                _buildGalleryButton(),
                
                // Capture Button
                _buildCaptureButton(isSmallDevice),
                
                // Spacer for symmetry
                SizedBox(width: screenWidth * 0.1), // Spacer for symmetry
              ],
            ),
          ),
        ],
    );
  }

  

  Widget _buildControlButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.white, size: 24),
      ),
    );
  }

  Widget _buildCaptureButton(bool isSmallDevice) {
     debugPrint('🎯 CAPTURE BUTTON WIDGET BUILDING');

  return GestureDetector(
      onTap: () => _captureImage(context),

    child: Container(
      width: isSmallDevice ? 64 : 72,
      height: isSmallDevice ? 64 : 72,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 3),
      ),
      child: Center(
        child: Icon(Icons.camera_alt, color: AppColors.white, size: 32),
      ),
    ),
  );
}

  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: () => _pickFromGallery(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.photo_library, color: AppColors.white, size: 24),
      ),
    );
  }

  String _getModeText(String mode) {
    switch (mode) {

    //  case 'identify': return 'Identify Plant';
      case 'identify': return AppLocalizations.of(context).scanner_identify_plant;

    //  case 'diagnose': return 'Diagnose Plant';
      case 'diagnose': return AppLocalizations.of(context).scanner_diagnose_plant;

    //  case 'water': return 'Water Calculation';
      case 'water': return AppLocalizations.of(context).scanner_water_calculation;
      
    //  default: return 'Scan Mode';
      default: return AppLocalizations.of(context).scanner_scan_mode;
    }
  }

  Future<void> _captureImage(BuildContext context) async {
    
     // PREVENT DOUBLE TAP
  if (_isCapturing) return;

    _isCapturing = true; // LOCK
     debugPrint('🎯 [1/6] CAMERA CAPTURE STARTED');


    try {
      final viewModel = Provider.of<ScannerViewModel>(context, listen: false);
      final File? imageFile = await viewModel.captureImage();

       debugPrint('📸 [1/6] CAPTURE RESULT: ${imageFile?.path ?? "NULL"}');
      
      if (imageFile != null) {
        debugPrint('✅ [1/6] CAPTURE SUCCESS - Navigating to preview');
        _navigateToPreview(context, imageFile, viewModel.currentMode);

      } else {
         debugPrint('❌❌❌ CAPTURE FAILED: No image file or not mounted');

      }
    } catch (e) {
      debugPrint('❌ [1/6] CAPTURE ERROR: $e');
    //  _showError('Failed to capture image');
        _showError(AppLocalizations.of(context).scanner_capture_error);

    } finally {
      // RELEASE LOCK AFTER DELAY - SIMPLIFIED
      Future.delayed(Duration(milliseconds: 1000), () {
        _isCapturing = false;
      });
    }
  }
  

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final viewModel = Provider.of<ScannerViewModel>(context, listen: false);
      final File? imageFile = await viewModel.pickImageFromGallery();

      if (imageFile != null && mounted) {
        _navigateToPreview(context, imageFile, viewModel.currentMode);
      }
    } catch (e) {
    //  _showError('Failed to pick image');
        _showError(AppLocalizations.of(context).scanner_gallery_error);

    }
  }

  void _navigateToPreview(BuildContext context, File imageFile, String mode) {
   
  debugPrint('🎯 NAVIGATING TO PREVIEW with mode: $mode');
  debugPrint('📁 Image path: ${imageFile.path}');
   
    Navigator.pushNamed(
      context, 
      AppRoutes.scannerPreview,
      arguments: {'imageFile': imageFile, 'mode': mode},
       ).then((_) {
         debugPrint('✅ NAVIGATION COMPLETE');
           }).catchError((e) {
             debugPrint('❌ NAVIGATION ERROR: $e');
              }
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}


