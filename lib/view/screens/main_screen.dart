import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../l10n/app_localizations.dart';
import '../../app/theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/responsive_helper.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

enum NavItem { home, history, settings }

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  NavItem _selectedIndex = NavItem.home;

  final Map<NavItem, Widget> _pages = {
    NavItem.home: const HomeScreen(),
    NavItem.history: const HistoryScreen(),
    NavItem.settings: const SettingsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex.index,
        children: _pages.values.toList(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final navHeight = ResponsiveHelper.responsiveHeight(64, context);

    return Container(
      height: navHeight + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.lightGray,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: NavItem.values.map(_buildNavItem).toList(),
      ),
    );
  }

  Widget _buildNavItem(NavItem item) {
    final bool isActive = _selectedIndex == item;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = item),
        child: Center(
          child: _buildAnimatedIcon(item, isActive),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(NavItem item, bool isActive) {
    final iconPaths = _getIconPaths(item);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: Tween(begin: 0.95, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: isActive
          ? _buildActiveItem(item, iconPaths.active)
          : SvgPicture.asset(
              iconPaths.inactive,
              key: ValueKey('${item.name}_inactive'),
              width: 24,
              height: 24,
            ),
    );
  }

  Widget _buildActiveItem(NavItem item, String iconPath) {
    return Container(
      key: ValueKey('${item.name}_active'),
      constraints: const BoxConstraints(minWidth: 92),
      height: ResponsiveHelper.responsiveHeight(42, context),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _getNavLabel(context, item),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.0,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNavLabel(BuildContext context, NavItem item) {
    final l10n = AppLocalizations.of(context)!;

    switch (item) {
      case NavItem.home:
        return l10n.bottom_nav_home;
      case NavItem.history:
        return l10n.bottom_nav_history;
      case NavItem.settings:
        return l10n.bottom_nav_settings;
    }
  }

  _IconPaths _getIconPaths(NavItem item) {
    switch (item) {
      case NavItem.home:
        return _IconPaths(
          active: AppConstants.homeActiveIcon,
          inactive: AppConstants.homeIcon,
        );
      case NavItem.history:
        return _IconPaths(
          active: AppConstants.recordActiveIcon,
          inactive: AppConstants.recordIcon,
        );
      case NavItem.settings:
        return _IconPaths(
          active: AppConstants.settingsActiveIcon,
          inactive: AppConstants.settingsIcon,
        );
    }
  }
}

class _IconPaths {
  final String active;
  final String inactive;

  const _IconPaths({
    required this.active,
    required this.inactive,
  });
}



// Correct but unresponsive
/*import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../l10n/app_localizations.dart';
import '../../app/theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/responsive_helper.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

enum NavItem { home, history, settings }

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  NavItem _selectedIndex = NavItem.home;

  final Map<NavItem, Widget> _pages = {
    NavItem.home: const HomeScreen(),
    NavItem.history: const HistoryScreen(),
    NavItem.settings: const SettingsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex.index,
        children: _pages.values.toList(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final navHeight = ResponsiveHelper.responsiveHeight(64, context);

    return Container(
      height: navHeight + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.lightGray,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: NavItem.values.map(_buildNavItem).toList(),
      ),
    );
  }

  Widget _buildNavItem(NavItem item) {
    final bool isActive = _selectedIndex == item;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedIndex = item);
        },
        child: Center(
          child: _buildAnimatedIcon(item, isActive),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(NavItem item, bool isActive) {
    final iconPaths = _getIconPaths(item);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: Tween(begin: 0.95, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: isActive
          ? _buildActiveItem(item, iconPaths.active)
          : SvgPicture.asset(
              iconPaths.inactive,
              key: ValueKey('${item.name}_inactive'),
              width: 24,
              height: 24,
            ),
    );
  }

  Widget _buildActiveItem(NavItem item, String iconPath) {
    return Container(
      key: ValueKey('${item.name}_active'),
      constraints: const BoxConstraints(minWidth: 92),
      height: ResponsiveHelper.responsiveHeight(42, context),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _getNavLabel(context, item),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.0,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNavLabel(BuildContext context, NavItem item) {
    final l10n = AppLocalizations.of(context)!;

    switch (item) {
      case NavItem.home:
        return l10n.bottom_nav_home;
      case NavItem.history:
        return l10n.bottom_nav_history;
      case NavItem.settings:
        return l10n.bottom_nav_settings;
    }
  }

  _IconPaths _getIconPaths(NavItem item) {
    switch (item) {
      case NavItem.home:
        return _IconPaths(
          active: AppConstants.homeActiveIcon,
          inactive: AppConstants.homeIcon,
        );
      case NavItem.history:
        return _IconPaths(
          active: AppConstants.recordActiveIcon,
          inactive: AppConstants.recordIcon,
        );
      case NavItem.settings:
        return _IconPaths(
          active: AppConstants.settingsActiveIcon,
          inactive: AppConstants.settingsIcon,
        );
    }
  }
}

class _IconPaths {
  final String active;
  final String inactive;

  const _IconPaths({
    required this.active,
    required this.inactive,
  });
}
*/