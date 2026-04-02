import 'package:flutter/material.dart';
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
}