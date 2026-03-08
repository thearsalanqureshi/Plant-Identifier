


/*
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';


enum BottomNavItem { home, history, settings }

class BottomNavBar extends StatelessWidget {
  final BottomNavItem currentIndex;
  final Function(BottomNavItem) onItemSelected;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      height: 83,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.lightGray,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context,
            item: BottomNavItem.home,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: l10n.bottom_nav_home,
          ),
          _buildNavItem(
            context,
            item: BottomNavItem.history,
            icon: Icons.history_outlined,
            activeIcon: Icons.history,
            label: l10n.bottom_nav_history,
          ),
          _buildNavItem(
            context,
            item: BottomNavItem.settings,
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: l10n.bottom_nav_settings,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required BottomNavItem item,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = currentIndex == item;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onItemSelected(item),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Icon(
                isActive ? activeIcon : icon,
                size: 28,
                color: isActive ? AppColors.primaryGreen : AppColors.mediumGray,
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                label,
                style: AppTypography.bottomNavLabel.copyWith(
                  color: isActive ? AppColors.primaryGreen : AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
