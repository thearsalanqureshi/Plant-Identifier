// Superior version - Just need more testing
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../app/navigation/ad_navigation_helper.dart';
import '../../app/navigation/app_routes.dart';
import '../../app/navigation/camera_route.dart';
import '../../l10n/app_localizations.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/ad_config_model.dart';
import '../../utils/constants.dart';
import '../../utils/responsive_helper.dart';
import '../../view_models/ad_config_view_model.dart';
import '../../view_models/home_view_model.dart';
import '../../data/services/analytics_service.dart';
import '../widgets/common/app_bar.dart';
import '../widgets/common/feature_card.dart';
import '../widgets/ads/admob_native_ad_widget.dart';
import '../widgets/ads/adaptive_banner_ad_widget.dart';
import '../widgets/ads/native_ad_factory_ids.dart';
import 'scanner_screen.dart';
import 'history_screen.dart';
import 'light_meter_screen.dart';
import 'settings_screen.dart';

enum NavItem { home, history, settings }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

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
    final navHeight = ResponsiveHelper.responsiveHeight(80, context);

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: navHeight,
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.lightGray, width: 1),
              ),
            ),
            child: Row(children: NavItem.values.map(_buildNavItem).toList()),
          ),
          const AdaptiveBannerAdWidget(),
          if (bottomInset > 0) SizedBox(height: bottomInset),
        ],
      ),
    );
  }

  Widget _buildNavItem(NavItem item) {
    final bool isActive = _selectedIndex == item;

    return Expanded(
      child: InkWell(
        onTap: () => _handleNavItemTap(item),
        child: Center(child: _buildAnimatedIcon(item, isActive)),
      ),
    );
  }

  Future<void> _handleNavItemTap(NavItem item) async {
    if (_selectedIndex == item) {
      return;
    }

    await runWithShiftInterstitial(
      context: context,
      isExcludedButton: item == NavItem.settings,
      placementName: 'shift_interstitial_${item.name}_tab',
      action: () {
        if (!mounted) {
          return;
        }

        setState(() => _selectedIndex = item);
      },
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
      height: ResponsiveHelper.responsiveHeight(40, context),
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

  const _IconPaths({required this.active, required this.inactive});
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

  Future<void> _handleFeatureTap(String featureId, BuildContext context) async {
    final viewModel = context.read<HomeViewModel>();
    final validatedFeature = viewModel.validateFeatureAccess(featureId);

    switch (validatedFeature) {
      case 'identify':
        await runWithShiftInterstitial(
          context: context,
          placementName: 'shift_interstitial_identify',
          action: () {
            Navigator.of(context).push(
              CameraRoute.blackFade(
                routeName: AppRoutes.scanner,
                child: const ScannerScreen(),
                arguments: {'mode': 'identify'},
              ),
            );
          },
        );
        break;
      case 'diagnose':
        await runWithShiftInterstitial(
          context: context,
          placementName: 'shift_interstitial_diagnose',
          action: () {
            Navigator.of(context).push(
              CameraRoute.blackFade(
                routeName: AppRoutes.scanner,
                child: const ScannerScreen(),
                arguments: {'mode': 'diagnose'},
              ),
            );
          },
        );
        break;
      case 'water':
        await runWithShiftInterstitial(
          context: context,
          placementName: 'shift_interstitial_water',
          action: () {
            Navigator.of(context).push(
              CameraRoute.blackFade(
                routeName: AppRoutes.scanner,
                child: const ScannerScreen(),
                arguments: {'mode': 'water'},
              ),
            );
          },
        );
        break;
      case 'light':
        await _openLightMeter(context);
        break;
      default:
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.home_feature_not_available(featureId))),
        );
    }
  }

  Future<void> _openLightMeter(BuildContext context) async {
    await runWithShiftInterstitial(
      context: context,
      placementName: 'shift_interstitial_light_meter',
      action: () {
        Navigator.of(context).push(
          CameraRoute.blackFade(
            routeName: AppRoutes.lightMeter,
            child: const LightMeterScreen(),
          ),
        );
      },
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
        top: true,
        bottom: false,
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
                            ..._buildLargeFeatures(
                              context,
                              viewModel,
                              isTablet,
                            ),
                            SizedBox(height: isTablet ? 2 : 0),
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
    final l10n = AppLocalizations.of(context);

    final widgets = <Widget>[];

    for (final feature in viewModel.largeFeatures) {
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

      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: isTablet ? 14 : 12),
          child: FeatureCard(
            title: title,
            subtitle: subtitle,
            size: feature.size,
            type: feature.type,
            onTap: () => _handleFeatureTap(feature.id, context),
          ),
        ),
      );

      if (feature.id == 'identify') {
        widgets.add(
          _HomeNativeAdSlot(
            placementName: 'home_native_1_identify',
            isFirstPosition: true,
            isTablet: isTablet,
          ),
        );
      } else if (feature.id == 'diagnose') {
        widgets.add(
          _HomeNativeAdSlot(
            placementName: 'home_native_2_diagnose',
            isFirstPosition: false,
            isTablet: isTablet,
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildSmallFeatures(
    BuildContext context,
    HomeViewModel viewModel,
    bool isTablet,
  ) {
    final l10n = AppLocalizations.of(context);

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

class _HomeNativeAdSlot extends StatelessWidget {
  final String placementName;
  final bool isFirstPosition;
  final bool isTablet;

  const _HomeNativeAdSlot({
    required this.placementName,
    required this.isFirstPosition,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final config = context.select<AdConfigViewModel, AdConfigModel>(
      (viewModel) => viewModel.config,
    );

    final isEnabled =
        config.isAdsMasterEnabled &&
        (isFirstPosition
            ? config.homeNative1Enabled
            : config.homeNative2Enabled);
    final adUnitId =
        (isFirstPosition ? config.homeNative1AdId : config.homeNative2AdId)
            .trim();

    if (!isEnabled || adUnitId.isEmpty) {
      return const SizedBox.shrink();
    }

    final configuredVariant = isFirstPosition
        ? config.homeNative1Variant
        : config.homeNative2Variant;
    final defaultFactoryId = NativeAdFactoryIds.fromVariant(
      config.nativeVariantDefault,
      fallback: NativeAdFactoryIds.native6b,
    );
    final factoryId = NativeAdFactoryIds.fromVariant(
      configuredVariant,
      fallback: defaultFactoryId,
    );

    return _LoadedHomeNativeAdSlot(
      key: ValueKey(
        '$placementName|$adUnitId|$factoryId|'
        '${config.nativeCtaColor}|${config.nativeTextColor}',
      ),
      adUnitId: adUnitId,
      factoryId: factoryId,
      variant: factoryId,
      placementName: placementName,
      ctaColor: config.nativeCtaColor,
      textColor: config.nativeTextColor,
      height: isTablet ? 240 : 220,
      bottomSpacing: isTablet ? 14 : 12,
    );
  }
}

class _LoadedHomeNativeAdSlot extends StatefulWidget {
  final String adUnitId;
  final String factoryId;
  final String variant;
  final String placementName;
  final String ctaColor;
  final String textColor;
  final double height;
  final double bottomSpacing;

  const _LoadedHomeNativeAdSlot({
    super.key,
    required this.adUnitId,
    required this.factoryId,
    required this.variant,
    required this.placementName,
    required this.ctaColor,
    required this.textColor,
    required this.height,
    required this.bottomSpacing,
  });

  @override
  State<_LoadedHomeNativeAdSlot> createState() =>
      _LoadedHomeNativeAdSlotState();
}

class _LoadedHomeNativeAdSlotState extends State<_LoadedHomeNativeAdSlot> {
  bool _isAdLoaded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdMobNativeAdWidget(
            adUnitId: widget.adUnitId,
            factoryId: widget.factoryId,
            placementName: widget.placementName,
            height: widget.height,
            customOptions: {
              'ctaColor': widget.ctaColor,
              'textColor': widget.textColor,
              'variant': widget.variant,
            },
            onAdLoaded: _showLoadedSlot,
            onAdFailedToLoad: (_) => _hideLoadedSlot(),
          ),
          if (_isAdLoaded) SizedBox(height: widget.bottomSpacing),
        ],
      ),
    );
  }

  void _showLoadedSlot() {
    if (!mounted || _isAdLoaded) {
      return;
    }

    setState(() {
      _isAdLoaded = true;
    });
  }

  void _hideLoadedSlot() {
    if (!mounted || !_isAdLoaded) {
      return;
    }

    setState(() {
      _isAdLoaded = false;
    });
  }
}
