import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/scanner_preview_payload.dart';
import '../../../data/services/scanner_service.dart';
import '../widgets/camera/camera_widgets.dart';
import '../../l10n/app_localizations.dart';

class ScannerPreviewScreen extends StatefulWidget {
  const ScannerPreviewScreen({
    super.key,
    this.initialPayload,
    this.initialImageFile,
    this.initialMode,
    this.onFirstFrame,
  });

  final ScannerPreviewPayload? initialPayload;
  final File? initialImageFile;
  final String? initialMode;
  final VoidCallback? onFirstFrame;

  @override
  State<ScannerPreviewScreen> createState() => _ScannerPreviewScreenState();
}

class _ScannerPreviewScreenState extends State<ScannerPreviewScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final ScannerService _scannerService = ScannerService();

  ScannerPreviewPayload? _previewPayload;
  File? _imageFile;
  String _mode = 'identify';
  bool _argsInitialized = false;
  bool _isPreparingPayload = false;
  bool _hasNotifiedFirstFrame = false;

  @override
  void initState() {
    super.initState();
    _bootstrapInitialSource();
    debugPrint('ScannerPreviewScreen initState');
  }

  @override
  void dispose() {
    _notifyFirstFrameIfNeeded();
    _previewPayload?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsInitialized) return;
    _argsInitialized = true;
    if (_previewPayload != null || _imageFile != null) {
      return;
    }
    _initializeArguments();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ScannerPreviewScreen build');

    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.04,
                screenHeight * 0.01,
                screenWidth * 0.04,
                screenHeight * 0.01,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.close,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44, height: 44),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.04,
                screenHeight * 0.01,
                screenWidth * 0.04,
                screenHeight * 0.015,
              ),
              child: Transform.translate(
                offset: const Offset(0, -7.5),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.zero,
                    color: AppColors.black,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: _previewPayload != null
                        ? RawImage(
                            image: _previewPayload!.thumbnailImage,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          )
                        : const ColoredBox(
                            color: AppColors.black,
                          ),
                  ),
                ),
              ),
            ),
          ),
          _buildBottomDock(context, screenWidth, screenHeight),
        ],
      ),
    );
  }

  Widget _buildBottomDock(
    BuildContext context,
    double screenWidth,
    double screenHeight,
  ) {
    final isLandscape = screenWidth > screenHeight;
    final dockHeight = isLandscape
        ? (screenHeight * 0.20).clamp(88.0, 110.0).toDouble()
        : (screenWidth * 0.307).clamp(92.0, 115.0).toDouble();
    final confirmButtonSize =
        (screenWidth * 0.16).clamp(56.0, 60.0).toDouble();

    return Container(
      width: double.infinity,
      color: Colors.black,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: dockHeight,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 375),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CameraRoundActionButton(
                      icon: Icons.photo_library,
                      size: 48,
                      iconSize: 24,
                      backgroundColor: AppColors.black.withOpacity(0.0),
                      onTap: _pickDifferentImage,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _confirmImage,
                      child: Container(
                        width: confirmButtonSize,
                        height: confirmButtonSize,
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
                    SizedBox(width: screenWidth * 0.1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _initializeArguments() {
    debugPrint('ScannerPreviewScreen initializing arguments');

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ScannerPreviewPayload) {
      _setPreviewPayload(args);
      return;
    }

    if (args is Map<String, dynamic>) {
      debugPrint('ScannerPreviewScreen args received');
      _mode = (args['mode'] ?? 'identify') as String;
      final previewPayload = args['previewPayload'];
      if (previewPayload is ScannerPreviewPayload) {
        _setPreviewPayload(previewPayload);
        return;
      }

      final initialFile = args['imageFile'] as File?;
      if (initialFile != null) {
        _setInitialImageSource(
          initialFile,
          (args['mode'] ?? _mode) as String,
        );
      }
    } else {
      debugPrint('ScannerPreviewScreen received no arguments');
    }
  }

  void _bootstrapInitialSource() {
    final initialPayload = widget.initialPayload;
    if (initialPayload != null) {
      _previewPayload = initialPayload;
      _imageFile = initialPayload.sourceFile;
      _mode = initialPayload.mode;
      _argsInitialized = true;
      _scheduleFirstFrameCallback();
      return;
    }

    final initialFile = widget.initialImageFile;
    if (initialFile != null) {
      _setInitialImageSource(
        initialFile,
        widget.initialMode ?? _mode,
      );
      _argsInitialized = true;
      return;
    }
  }

  void _setInitialImageSource(File imageFile, String mode) {
    _imageFile = imageFile;
    _mode = mode;
    _scheduleFirstFrameCallback();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _previewPayload != null || _imageFile == null) {
        return;
      }

      _notifyFirstFrameIfNeeded();
      unawaited(_warmPreviewPayload(_imageFile!, _mode));
    });
  }

  void _setPreviewPayload(ScannerPreviewPayload payload) {
    final previousPayload = _previewPayload;
    setState(() {
      _previewPayload = payload;
      _imageFile = payload.sourceFile;
      _mode = payload.mode;
      _isPreparingPayload = false;
    });
    _scheduleFirstFrameCallback();
    if (previousPayload != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        previousPayload.dispose();
      });
    }
  }

  Future<void> _warmPreviewPayload(File imageFile, String mode) async {
    try {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPreparingPayload = true;
      });

      final previewPayload = await prepareScannerPreviewPayload(
        sourceFile: imageFile,
        mode: mode,
        previewSize: Size(
          MediaQuery.of(context).size.width * 0.92,
          MediaQuery.of(context).size.height * 0.65,
        ),
        devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      );

      if (!mounted) {
        previewPayload?.dispose();
        return;
      }

      if (previewPayload == null) {
        _showError('Selected image is no longer available.');
        return;
      }

      _setPreviewPayload(previewPayload);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPreparingPayload = false;
      });
      _showError('Unable to prepare preview image: $e');
    }
  }

  void _scheduleFirstFrameCallback() {
    if (_hasNotifiedFirstFrame || widget.onFirstFrame == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyFirstFrameIfNeeded();
    });
  }

  void _notifyFirstFrameIfNeeded() {
    if (_hasNotifiedFirstFrame || widget.onFirstFrame == null) {
      return;
    }

    _hasNotifiedFirstFrame = true;
    widget.onFirstFrame?.call();
  }

  Future<void> _pickDifferentImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null || !mounted) {
        return;
      }

      final File candidateFile = File(image.path);
      if (!await candidateFile.exists()) {
        _showError('Selected image is no longer available.');
        return;
      }

      if (!mounted) {
        return;
      }

      await _warmPreviewPayload(candidateFile, _mode);
    } catch (e) {
      _showError('Gallery error: $e');
    }
  }

  Future<void> _confirmImage() async {
    final imageFile = _imageFile;
    if (imageFile == null || _isPreparingPayload) {
      _showError(AppLocalizations.of(context).preview_select_image_error);
      return;
    }

    final File? preparedFile =
        await _scannerService.prepareFileForProcessing(imageFile);
    if (!mounted || preparedFile == null) {
      _showError('Unable to prepare selected image.');
      return;
    }

    if (_mode == 'water') {
      Navigator.pushNamed(
        context,
        AppRoutes.waterQuestions,
        arguments: {
          'imageFile': preparedFile,
          'mode': _mode,
        },
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.processing,
      arguments: {
        'imageFile': preparedFile,
        'mode': _mode,
      },
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
