// Superior version - Just need more testing
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../app/navigation/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../../app/theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/responsive_helper.dart';
import '../../view_models/home_view_model.dart';
import '../../data/services/analytics_service.dart';
import '../widgets/common/app_bar.dart';
import '../widgets/common/feature_card.dart';
import 'history_screen.dart';
import 'light_meter_screen.dart';
import 'settings_screen.dart';

enum NavItem { home, history, settings }

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  NavItem _selectedIndex = NavItem.home;

  // Remove HomeScreen from pages, add content directly
  final Map<NavItem, Widget> _pages = {
    NavItem.home: const _HomeContent(), // New widget
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

  // ... (keep your existing bottom navigation bar code)

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

// NEW: Home content widget (moved from HomeScreen)
class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView(screenName: 'Home');
  }

  void _handleFeatureTap(String featureId, BuildContext context) {
    final viewModel = context.read<HomeViewModel>();
    final validatedFeature = viewModel.validateFeatureAccess(featureId);

    switch (validatedFeature) {
      case 'identify':
        Navigator.pushNamed(
          context,
          AppRoutes.scanner,
          arguments: {'mode': 'identify'},
        );
        break;
      case 'diagnose':
        Navigator.pushNamed(
          context,
          AppRoutes.scanner,
          arguments: {'mode': 'diagnose'},
        );
        break;
      case 'water':
        Navigator.pushNamed(
          context,
          AppRoutes.scanner,
          arguments: {'mode': 'water'},
        );
        break;
      case 'light':
        _openLightMeter(context);
        break;
      default:
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.home_feature_not_available(featureId))),
        );
    }
  }

  void _openLightMeter(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LightMeterScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;
    final horizontalPadding = isTablet ? 24.0 : 16.0;
    final maxContentWidth = isTablet ? 980.0 : 560.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              children: [
                HomeAppBar(
                  onPremiumPressed: () {
                    final viewModel = context.read<HomeViewModel>();
                    viewModel.handlePremiumAccess();
                    Navigator.pushNamed(context, AppRoutes.premium);
                  },
                ),
                Expanded(
                  child: Consumer<HomeViewModel>(
                    builder: (context, viewModel, _) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          isTablet ? 14 : 12,
                          horizontalPadding,
                          20,
                        ),
                        child: Column(
                          children: [
                            ..._buildLargeFeatures(context, viewModel, isTablet),
                            SizedBox(height: isTablet ? 10 : 8),
                            _buildSmallFeatures(context, viewModel, isTablet),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLargeFeatures(
      BuildContext context,
      HomeViewModel viewModel,
      bool isTablet,
      ) {
    final l10n = AppLocalizations.of(context)!;

    return viewModel.largeFeatures.map((feature) {
      String title;
      String subtitle;

      switch (feature.id) {
        case 'identify':
          title = l10n.identify;
          subtitle = l10n.home_identify_subtitle;
          break;
        case 'diagnose':
          title = l10n.diagnose;
          subtitle = l10n.home_diagnose_subtitle;
          break;
        default:
          title = feature.title;
          subtitle = feature.subtitle;
      }

      return Padding(
        padding: EdgeInsets.only(bottom: isTablet ? 14 : 12),
        child: FeatureCard(
          title: title,
          subtitle: subtitle,
          size: feature.size,
          type: feature.type,
          onTap: () => _handleFeatureTap(feature.id, context),
        ),
      );
    }).toList();
  }

  Widget _buildSmallFeatures(
      BuildContext context,
      HomeViewModel viewModel,
      bool isTablet,
      ) {
    final l10n = AppLocalizations.of(context)!;

    final cards = viewModel.smallFeatures.map((feature) {
      String title;
      String subtitle;

      switch (feature.id) {
        case 'water':
          title = l10n.water_calculator;
          subtitle = l10n.home_water_subtitle;
          break;
        case 'light':
          title = l10n.light_meter_title;
          subtitle = l10n.home_light_subtitle;
          break;
        default:
          title = feature.title;
          subtitle = feature.subtitle;
      }

      return Expanded(
        child: FeatureCard(
          title: title,
          subtitle: subtitle,
          size: feature.size,
          type: feature.type,
          onTap: () => _handleFeatureTap(feature.id, context),
        ),
      );
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        cards.first,
        SizedBox(width: isTablet ? 14 : 10),
        cards.last,
      ],
    );
  }
}