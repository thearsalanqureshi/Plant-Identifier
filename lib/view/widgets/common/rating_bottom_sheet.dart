import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants.dart';

class RatingBottomSheet extends StatefulWidget {
  final VoidCallback onRateNow;

  const RatingBottomSheet({
    super.key,
    required this.onRateNow,
  });

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  int _selectedRating = 0;

  void _submitRating() {
    if (_selectedRating <= 0) return;

    Navigator.pop(context);
    widget.onRateNow();
  }

  double _scaleForWidth(double width) {
    return (width / 375.0).clamp(0.92, 1.15).toDouble();
  }

  double _valueForWidth(
      double base,
      double width, {
        double min = 0,
        double max = double.infinity,
      }) {
    final scaled = base * _scaleForWidth(width);
    return scaled.clamp(min, max).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : mediaQuery.size.width;
        final isTablet = width >= 600;
        final maxContentWidth = isTablet ? 560.0 : width;

        final horizontalPadding = _valueForWidth(16, width, min: 16, max: 24);
        final topPadding = _valueForWidth(18, width, min: 16, max: 24);
        final bottomPadding = _valueForWidth(18, width, min: 16, max: 24);
        final titleFontSize = _valueForWidth(20, width, min: 18, max: 24);
        final descriptionFontSize = _valueForWidth(16, width, min: 14, max: 18);
        final starSize = _valueForWidth(40, width, min: 32, max: 44);
        final starGap = _valueForWidth(8, width, min: 6, max: 10);
        final titleSpacing = _valueForWidth(12, width, min: 10, max: 16);
        final descriptionSpacing = _valueForWidth(10, width, min: 8, max: 14);
        final starsSpacing = _valueForWidth(22, width, min: 18, max: 28);
        final buttonHeight = _valueForWidth(56, width, min: 52, max: 60);
        final buttonFontSize = _valueForWidth(16, width, min: 15, max: 18);
        final bottomInset = mediaQuery.viewPadding.bottom;

        return Material(
          color: Colors.white,
          elevation: 18,
          shadowColor: Colors.black26,
        //  borderRadius: BorderRadius.circular(15),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                bottomPadding + bottomInset,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  SizedBox(height: titleSpacing),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Text(
                      l10n.widget_rating_title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.w700,
                        fontSize: titleFontSize,
                        color: const Color(0xFF1E1F24),
                        height: 1.15,
                      ),
                    ),
                  ),
                  SizedBox(height: descriptionSpacing),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 470),
                    child: Text(
                      l10n.widget_rating_description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.w500,
                        fontSize: descriptionFontSize,
                        color: const Color(0xFF80828D),
                        height: 1.25,
                      ),
                    ),
                  ),
                  SizedBox(height: starsSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final isSelected = index < _selectedRating;
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: starGap / 2),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              _selectedRating = index + 1;
                            });
                          },
                          child: SizedBox(
                            width: starSize,
                            height: starSize,
                            child: _buildStarWidget(isSelected, starSize),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: _valueForWidth(24, width, min: 20, max: 28)),
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: _selectedRating > 0 ? _submitRating : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedRating > 0
                            ? AppColors.primaryGreen
                            : const Color(0xFFD9D9D9),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          l10n.widget_rating_submit,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.w700,
                            fontSize: buttonFontSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStarWidget(bool isFilled, double size) {
    final assetPath = isFilled ? AppConstants.starFilled : AppConstants.starOutline;

    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          isFilled ? Icons.star_rounded : Icons.star_border_rounded,
          size: size,
          color: isFilled ? const Color(0xFFFFD700) : const Color(0xFFC4C4C4),
        );
      },
    );
  }
}


/*import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';
import '../../../utils/constants.dart';

class RatingBottomSheet extends StatefulWidget {
   final VoidCallback onRateNow;  // Add callback parameter

  const RatingBottomSheet({
    Key? key,
     required this.onRateNow,  // Make it required
  
  }) : super(key: key);

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  int _selectedRating = 0;

  void _submitRating() {
    if (_selectedRating > 0) {
      // Handle rating submission logic here
      print('User rated: $_selectedRating stars');
      
      // You can add your API call or storage logic here
      // For example: save to Hive, send to backend, etc.
      
      Navigator.pop(context);
      

      
      // Optional: Show thank you message
      /*
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thank you for your $_selectedRating star rating!'),
          duration: const Duration(seconds: 2),
        ),
      );
       */


       widget.onRateNow();
    }
  }
  


  @override
  Widget build(BuildContext context) {
     final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(16, context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
          //  'Rate Your Experience With\nOur App',
          l10n.widget_rating_title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: ResponsiveHelper.responsiveFontSize(20, context),
              color: const Color(0xFF1E1F24),
              height: 1.2,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.responsiveHeight(16, context)),
          
          // Description
          Text(
          //  'Please rate your experience and help us\nimprove. Thank You',
            l10n.widget_rating_description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w500,
              fontSize: ResponsiveHelper.responsiveFontSize(16, context),
              color: const Color(0xFF80828D),
              height: 1.2,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.responsiveHeight(24, context)),
          
          // Stars Row - IMPROVED WITH BETTER ERROR HANDLING
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final isSelected = index < _selectedRating;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = index + 1;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.responsiveWidth(6, context),
                  ),
                  child: Container(
                    width: ResponsiveHelper.responsiveWidth(44, context),
                    height: ResponsiveHelper.responsiveHeight(44, context),
                    child: _buildStarWidget(isSelected),
                  ),
                ),
              );
            }),
          ),
          
          SizedBox(height: ResponsiveHelper.responsiveHeight(32, context)),
          
          // Submit Button - IMPROVED WITH BETTER STYLING
          SizedBox(
            width: double.infinity,
            height: ResponsiveHelper.responsiveHeight(60, context),
            child: ElevatedButton(
              onPressed: _selectedRating > 0 ? _submitRating : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedRating > 0 
                    ? AppColors.primaryGreen 
                    : Colors.grey[300],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.responsiveWidth(100, context),
                ),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text(
              //  'Submit',
                 AppLocalizations.of(context).widget_rating_submit,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveHelper.responsiveFontSize(16, context),
                ),
              ),
            ),
          ),
          
          // Add some bottom padding for better appearance
          SizedBox(height: ResponsiveHelper.responsiveHeight(8, context)),
        ],
      ),
    );
  }

  Widget _buildStarWidget(bool isFilled) {
    final assetPath = isFilled ? AppConstants.starFilled : AppConstants.starOutline;
    
    return Image.asset(
      assetPath,
      width: ResponsiveHelper.responsiveWidth(40, context),
      height: ResponsiveHelper.responsiveHeight(40, context),
      errorBuilder: (context, error, stackTrace) {
        // Fallback to icons if images are not found
        return Icon(
          isFilled ? Icons.star_rounded : Icons.star_border_rounded,
          size: ResponsiveHelper.responsiveWidth(40, context),
          color: isFilled ? const Color(0xFFFFD700) : const Color(0xFFC4C4C4),
        );
      },
      fit: BoxFit.contain,
    );
  }
}*/