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
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex.index,
          children: _pages.values.toList(),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: ResponsiveHelper.responsiveHeight(83, context),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: NavItem.values.map(_buildNavItem).toList(),
      ),
    );
  }

  Widget _buildNavItem(NavItem item) {
    final bool isActive = _selectedIndex == item;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _selectedIndex = item);
      },
      child: Container(
        width: ResponsiveHelper.responsiveWidth(120, context),
        height: double.infinity,
        alignment: Alignment.center,
        child: _buildAnimatedIcon(item, isActive),
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
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      key: ValueKey('${item.name}_active'),
      height: ResponsiveHelper.responsiveHeight(45, context),
      padding: const EdgeInsets.symmetric(horizontal: 16), // FIXED: 16px padding
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
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 4), // FIXED: 4px spacing (not percentage)
          Flexible(
            child: Text(
              _getNavLabel(context, item),
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
    final l10n = AppLocalizations.of(context)!; // FIXED: Added !

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



/*// ------- Localized (working) Green Navbar --------
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
    return Container(
      height: ResponsiveHelper.responsiveHeight(83, context),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: NavItem.values.map(_buildNavItem).toList(),
      ),
    );
  }

  Widget _buildNavItem(NavItem item) {
    final bool isActive = _selectedIndex == item;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _selectedIndex = item);
      },
      child: SizedBox(
        width: ResponsiveHelper.responsiveWidth(120, context),
        height: double.infinity,
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
              width: ResponsiveHelper.responsiveWidth(24, context),
              height: ResponsiveHelper.responsiveWidth(24, context),
            ),
    );
  }

  Widget _buildActiveItem(NavItem item, String iconPath) {
    return Container(
      key: ValueKey('${item.name}_active'),
      height: ResponsiveHelper.responsiveHeight(44, context),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.responsiveWidth(12, context),
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            width: ResponsiveHelper.responsiveWidth(22, context),
            height: ResponsiveHelper.responsiveWidth(22, context),
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: ResponsiveHelper.responsiveWidth(8, context)),
          Text(
            _getNavLabel(context, item),
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              height: 1.0,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getNavLabel(BuildContext context, NavItem item) {
  final l10n = AppLocalizations.of(context);

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
}*/

/*
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
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

  final Map<NavItem, Widget> _pages = const {
    NavItem.home: HomeScreen(),
    NavItem.history: HistoryScreen(),
    NavItem.settings: SettingsScreen(),
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

  // =======================
  // Bottom Navigation Bar
  // =======================

  Widget _buildBottomNavBar() {
    return Container(
      height: 83,
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: NavItem.values.map(_buildNavItem).toList(),
      ),
    );
  }

  Widget _buildNavItem(NavItem item) {
    final bool isActive = _selectedIndex == item;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_selectedIndex != item) {
          setState(() => _selectedIndex = item);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isActive
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _iconFor(item),
              size: 22,
              color: isActive
                  ? AppColors.white
                  : AppColors.mediumGray,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                _labelFor(item),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =======================
  // Helpers
  // =======================

  IconData _iconFor(NavItem item) {
    switch (item) {
      case NavItem.home:
        return Icons.home_filled;
      case NavItem.history:
        return Icons.inventory_2_outlined;
      case NavItem.settings:
        return Icons.settings;
    }
  }

  String _labelFor(NavItem item) {
    switch (item) {
      case NavItem.home:
        return 'Home';
      case NavItem.history:
        return 'Recents';
      case NavItem.settings:
        return 'Settings';
    }
  }
}
*/



/*-------- First Priority --------
import 'package:flutter/material.dart';
import '../widgets/common/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'history_screen.dart';
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
      bottomNavigationBar: BottomNavBar(
        currentIndex: _convertToBottomNavItem(_selectedIndex),
        onItemSelected: (bottomItem) {
          setState(() {
            _selectedIndex = _convertToNavItem(bottomItem);
          });
        },
      ),
    );
  }

  BottomNavItem _convertToBottomNavItem(NavItem item) {
    switch (item) {
      case NavItem.home:
        return BottomNavItem.home;
      case NavItem.history:
        return BottomNavItem.history;
      case NavItem.settings:
        return BottomNavItem.settings;
    }
  }

  NavItem _convertToNavItem(BottomNavItem item) {
    switch (item) {
      case BottomNavItem.home:
        return NavItem.home;
      case BottomNavItem.history:
        return NavItem.history;
      case BottomNavItem.settings:
        return NavItem.settings;
    }
  }
}
*/


/* ---------  2nd Priority ------------
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import '../../generated/l10n/app_localizations.dart';
import '../../app/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/constants.dart';
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
    return BottomNavigationBar(
      currentIndex: _selectedIndex.index,
      onTap: (index) {
        setState(() {
          _selectedIndex = NavItem.values[index];
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primaryGreen, // Active color
      unselectedItemColor: AppColors.darkGray,     // Inactive color
      selectedFontSize: 12,
      unselectedFontSize: 12,
      iconSize: 24,
      elevation: 0,
      items: [
        _buildNavItem(
          label: AppLocalizations.of(context).bottom_nav_home,
          activeIcon: AppConstants.homeActiveIcon,
          inactiveIcon: AppConstants.homeIcon,
        ),
        _buildNavItem(
          label: AppLocalizations.of(context).bottom_nav_history,
          activeIcon: AppConstants.recordActiveIcon,
          inactiveIcon: AppConstants.recordIcon,
        ),
        _buildNavItem(
          label: AppLocalizations.of(context).bottom_nav_settings,
          activeIcon: AppConstants.settingsActiveIcon,
          inactiveIcon: AppConstants.settingsIcon,
        ),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required String label,
    required String activeIcon,
    required String inactiveIcon,
  }) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        inactiveIcon,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          AppColors.darkGray,
          BlendMode.srcIn,
        ),
      ),
      activeIcon: SvgPicture.asset(
        activeIcon,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          AppColors.primaryGreen,
          BlendMode.srcIn,
        ),
      ),
      label: label,
    );
  }
}
*/


/*
// ------------ Original -------------
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plant_identifier_app/l10n/app_localizations.dart';
import '../../view/screens/home_screen.dart';
import '../../view/screens/history_screen.dart';
import '../../view/screens/settings_screen.dart';
import '../../utils/responsive_helper.dart';
import '../../app/theme/app_colors.dart';
import '../../utils/constants.dart';

enum NavItem { home, history, settings }

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
   @override
  void initState() {
    super.initState();
    debugPrint('💣 ${widget.runtimeType} INIT STATE CALLED');
  }
  
  NavItem _selectedIndex = NavItem.home;
  
  final Map<NavItem, Widget> _pages = {
    NavItem.home: const HomeScreen(),
    NavItem.history: const HistoryScreen(),
    NavItem.settings: const SettingsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    debugPrint('💣 ${runtimeType} BUILD CALLED');

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex.index,
        children: _pages.values.toList(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      width: double.infinity,
      height: ResponsiveHelper.responsiveHeight(83, context),
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
          _buildNavItem(NavItem.home),
          _buildNavItem(NavItem.history),
          _buildNavItem(NavItem.settings),
        ],
      ),
    );
  }

  Widget _buildNavItem(NavItem item) {
    final bool isActive = _selectedIndex == item;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = item;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
         width: isActive 
          ? ResponsiveHelper.responsiveWidth(130, context)  
          : ResponsiveHelper.responsiveWidth(110, context),
      height: isActive 
          ? ResponsiveHelper.responsiveHeight(130, context) 
          : ResponsiveHelper.responsiveHeight(110, context),
        alignment: Alignment.center,
        child: _buildAnimatedIcon(item, isActive),
      ),
    );
  }

  Widget _buildAnimatedIcon(NavItem item, bool isActive) {
    // Different sizes for active vs inactive
    final activeIconSize = ResponsiveHelper.responsiveWidth(64, context);
    final inactiveIconSize = ResponsiveHelper.responsiveWidth(24, context);
    

    final iconPaths = _getIconPaths(item);
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutBack,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: SvgPicture.asset(
        isActive ? iconPaths.active : iconPaths.inactive,
        width: isActive ? activeIconSize : inactiveIconSize,
        height: isActive ? activeIconSize : inactiveIconSize,
        key: ValueKey('${item.name}_${isActive}'), 
      ),
    );
  }

  // Helper method to get icon paths
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

// Helper class to store icon paths
class _IconPaths {
  final String active;
  final String inactive;

  const _IconPaths({
    required this.active,
    required this.inactive,
  });
}
*/
