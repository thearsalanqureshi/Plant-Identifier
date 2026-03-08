import 'package:flutter/material.dart';
import '../../../../utils/responsive_helper.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';

class HistoryTabs extends StatefulWidget {
  final bool showMyPlants;
  final int myPlantsCount;
  final int historyCount;
  final Function(bool) onTabChanged;
  
  const HistoryTabs({
    super.key,
    required this.showMyPlants,
    required this.myPlantsCount,
    required this.historyCount,
    required this.onTabChanged,
  });

  @override
  State<HistoryTabs> createState() => _HistoryTabsState();
}

class _HistoryTabsState extends State<HistoryTabs> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<Color?> _colorAnimation;
  late double _tabWidth;
  late double _tabSpacing;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    
    // Initialize with default values, will be updated in build
    _tabWidth = 0;
    _tabSpacing = 4;
    
    // Smooth cubic curve for natural movement
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastEaseInToSlowEaseOut,
    );
    
    // Color animation for active tab glow effect
    _colorAnimation = ColorTween(
      begin: AppColors.primaryGreen.withOpacity(0.8),
      end: AppColors.primaryGreen,
    ).animate(curvedAnimation);
    
    // Position animation will be set in build based on calculated width
  }
  
  void _setupAnimations(BuildContext context) {
    // Calculate responsive dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - ResponsiveHelper.responsiveWidth(32, context); // 16px padding on each side
    
    // Calculate tab width (half of container minus spacing)
    _tabWidth = (containerWidth - (_tabSpacing * 3)) / 2;
    
    // Calculate positions
    final firstTabPosition = _tabSpacing;
    final secondTabPosition = _tabWidth + (_tabSpacing * 2);
    
    // Set up position animation
    _positionAnimation = Tween<double>(
      begin: widget.showMyPlants ? firstTabPosition : secondTabPosition,
      end: widget.showMyPlants ? firstTabPosition : secondTabPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastEaseInToSlowEaseOut,
    ));
  }
  
  @override
  void didUpdateWidget(HistoryTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.showMyPlants != oldWidget.showMyPlants && context.mounted) {
      // Recalculate positions
      _setupAnimations(context);
      
      // Reset and play animation when tab changes
      _controller.reset();
      _controller.forward();
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tabWidth == 0) {
      _setupAnimations(context);
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure animations are set up with current context
    if (_tabWidth == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _setupAnimations(context);
          if (!widget.showMyPlants) {
            _controller.forward();
          }
          setState(() {});
        }
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final containerHeight = ResponsiveHelper.responsiveHeight(48, context);
        
        return Container(
          width: containerWidth,
          height: containerHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFDEEADD),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated tab background with glow effect
              if (_tabWidth > 0)
                AnimatedBuilder(
                  animation: _positionAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: _positionAnimation.value,
                      top: _tabSpacing,
                      child: Container(
                        width: _tabWidth,
                        height: containerHeight - (_tabSpacing * 2),
                        decoration: BoxDecoration(
                          color: _colorAnimation.value,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primaryGreen.withOpacity(0.95),
                              AppColors.primaryGreen.withOpacity(0.85),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              
              // Tab buttons with scale animation on tap
              if (_tabWidth > 0)
                Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        context: context,
                      //  title: 'My Plants',
                      title: AppLocalizations.of(context).widget_history_tab_my_plants,

                        count: widget.myPlantsCount,
                        isActive: widget.showMyPlants,
                        onTap: () {
                          if (!widget.showMyPlants) {
                            widget.onTabChanged(true);
                          }
                        },
                      ),
                    ),
                    
                    Expanded(
                      child: _buildTabButton(
                        context: context,
                      //  title: 'History',
                      title: AppLocalizations.of(context).widget_history_tab_history,
                        count: widget.historyCount,
                        isActive: !widget.showMyPlants,
                        onTap: () {
                          if (widget.showMyPlants) {
                            widget.onTabChanged(false);
                          }
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required String title,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTapDown: (_) {
        if (!isActive) onTap();
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.responsiveWidth(8, context)),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$title ',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveHelper.responsiveFontSize(14, context),
                          color: isActive ? Colors.white : const Color(0xFF1F2937),
                          letterSpacing: -0.1,
                          height: 1.0,
                        ),
                      ),
                      TextSpan(
                        text: '($count)',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: ResponsiveHelper.responsiveFontSize(13, context),
                          color: isActive 
                              ? Colors.white.withOpacity(0.95)
                              : const Color(0xFF6B7280),
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}