import 'dart:math';
// import 'dart:developer' as developer;
import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../../view_models/history_view_model.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/navigation/app_routes.dart';
import '../../data/models/history_model.dart';
import '../../data/services/analytics_service.dart';
// import '../../data/services/history_service.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/history/history_card.dart';
import '../widgets/history/history_tabs.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:hive_flutter/hive_flutter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _buildCount = 0;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    print('📱 HISTORY SCREEN INIT - Simple load');

    // Log screen view
    AnalyticsService.logScreenView(screenName: 'History');
    debugPrint('📊 Analytics: History screen viewed');

    // SINGLE load when screen starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadHistory();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load history when screen becomes active
    final route = ModalRoute.of(context);
    if (route?.isCurrent == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final viewModel = Provider.of<HistoryViewModel>(context, listen: false);
        if (!viewModel.isLoading && viewModel.allHistory.isEmpty) {
          viewModel.loadHistory();
        }
      });
    }
  }

  void _loadHistory() {
    if (_hasLoaded) return; // Prevent duplicate loads

    print('🔄 Loading history');
    final viewModel = Provider.of<HistoryViewModel>(context, listen: false);
    viewModel.loadHistory();
    _hasLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🚨🚨🚨 HISTORY SCREEN BUILD CALLED');
    debugPrint('   Build timestamp: ${DateTime.now().millisecondsSinceEpoch}');
    debugPrint('   Build count: ${_buildCount++}');

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildScreenTitle(),

            const SizedBox(height: 15),

            _buildTabs(),

            Expanded(child: _buildContent(screenHeight, screenWidth)),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenTitle() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Center(
        child: Text(
          AppLocalizations.of(context).history_title,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.0,
            letterSpacing: -0.17,
            color: Color(0xFF1B3B1C),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: min(constraints.maxWidth, 400),
            ),
            child: Consumer<HistoryViewModel>(
              builder: (context, viewModel, child) {
                return HistoryTabs(
                  showMyPlants: viewModel.showMyPlants,
                  myPlantsCount: viewModel.myPlantsCount,
                  historyCount: viewModel.historyCount,
                  onTabChanged: (showMyPlants) {
                    viewModel.toggleView(showMyPlants);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(double screenHeight, double screenWidth) {
    return Consumer<HistoryViewModel>(
      builder: (context, viewModel, child) {
        print('📊 UI State: ${viewModel.allHistory.length} scans, loading: ${viewModel.isLoading}');

        if (viewModel.isLoading) {
          return _buildLoadingState();
        }

        if (viewModel.allHistory.isEmpty) {
          return _buildEmptyState(viewModel.showMyPlants, screenHeight, screenWidth);
        }

        final currentList = viewModel.showMyPlants
            ? viewModel.myPlants
            : viewModel.allHistory;

        return _buildHistoryList(currentList, viewModel, screenHeight, screenWidth);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(color: AppColors.primaryGreen),
    );
  }

  Widget _buildEmptyState(bool showMyPlants, double screenHeight, double screenWidth) {
    final title = showMyPlants
        ? AppLocalizations.of(context).history_empty_my_plants
        : AppLocalizations.of(context).history_empty_history;

    final description = showMyPlants
        ? AppLocalizations.of(context).history_empty_my_plants_desc
        : AppLocalizations.of(context).history_empty_history_desc;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // SVG Image
        SvgPicture.asset(
          'assets/images/empty_history.svg',
          width: screenWidth * 0.3,
          height: screenWidth * 0.3,
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.black,
          ),
        ),

        const SizedBox(height: 8),

        // Description
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: AppColors.darkGray,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(
      List<ScanHistory> scans,
      HistoryViewModel viewModel,
      double screenHeight,
      double screenWidth,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView.builder(
        itemCount: scans.length,
        itemBuilder: (context, index) {
          final scan = scans[index];
          return HistoryCard(
            scan: scan,
            onTap: () {
              _handleCardTap(scan);
            },
            onMorePressed: () {
              _showActionSheet(context, scan, viewModel, screenHeight, screenWidth);
            },
          );
        },
      ),
    );
  }

  void _handleCardTap(ScanHistory scan) {
    debugPrint(' DEBUG SCAN RESULT DATA ');
    debugPrint('Plant Name: ${scan.plantName}');
    debugPrint('Scan Type: ${scan.type}');
    debugPrint('Scan ID: ${scan.id}');
    debugPrint('Has Result Data: ${scan.resultData != null}');

    if (scan.resultData != null) {
      debugPrint('Result Data Keys: ${scan.resultData!.keys.join(", ")}');
      debugPrint('Result Data Full: ${scan.resultData}');

      if (scan.type == 'diagnose') {
        debugPrint('Diagnosis Plant: ${scan.resultData!['plantName']}');
        debugPrint('Disease: ${scan.resultData!['diseaseName']}');
        debugPrint('Severity: ${scan.resultData!['severityLevel']}');
      }
    } else {
      debugPrint(' WARNING: resultData is NULL!');
    }
    debugPrint(' END DEBUG ');

    switch (scan.type) {
      case 'identify':
        Navigator.pushNamed(
          context,
          AppRoutes.plantIdentificationResult,
          arguments: {
            'scanData': scan.resultData,
            'imagePath': scan.imagePath,
            'fromHistory': true,
            'scanId': scan.id,
          },
        );
        break;
      case 'diagnose':
        Navigator.pushNamed(
          context,
          AppRoutes.plantDiagnosisResult,
          arguments: {
            'scanData': scan.resultData,
            'imagePath': scan.imagePath,
          },
        );
        break;
      case 'water':
        Navigator.pushNamed(
          context,
          AppRoutes.waterResult,
          arguments: {'scanData': scan.resultData},
        );
        break;
      case 'light':
        // Navigate to light meter result
        _showLightMeterResult(context, scan);
        break;
    }
  }

  void _showLightMeterResult(BuildContext context, ScanHistory scan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).history_light_dialog_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppLocalizations.of(context).history_light_level} ${scan.resultData?['luxValue']?.round() ?? 0} ${AppLocalizations.of(context).history_lux_unit}'),
            Text('${AppLocalizations.of(context).history_status} ${scan.resultData?['lightStatus'] ?? 'Unknown'}'),
            Text('${AppLocalizations.of(context).history_optimal_range} ${scan.resultData?['optimalRange'] ?? '1000-10000 LUX'}'),
            Text('${AppLocalizations.of(context).history_time} ${_formatTimestamp(scan.timestamp)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).history_close),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  void _showActionSheet(
      BuildContext context,
      ScanHistory scan,
      HistoryViewModel viewModel,
      double screenHeight,
      double screenWidth,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return _buildActionSheetContent(context, scan, viewModel, screenHeight, screenWidth);
      },
    );
  }

  Widget _buildActionSheetContent(
      BuildContext context,
      ScanHistory scan,
      HistoryViewModel viewModel,
      double screenHeight,
      double screenWidth,
      ) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Save/Unsave Option
          _buildActionOption(
            context: context,
            icon: scan.isSaved ? Icons.bookmark_remove : Icons.bookmark_add,
            title: scan.isSaved
                ? AppLocalizations.of(context).history_remove_from_my_plants
                : AppLocalizations.of(context).history_save_to_my_plants,
            onTap: () {
              Navigator.pop(context);
              viewModel.toggleSaveStatus(scan.id);
            },
          ),

          // Divider
          Container(
            width: screenWidth * 0.9,
            height: 1,
            color: const Color(0xFFD9D9D9),
          ),

          // Delete Option
          _buildActionOption(
            context: context,
            icon: Icons.delete_outline,
            title: AppLocalizations.of(context).history_delete_button,
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, scan, viewModel, screenHeight, screenWidth);
            },
            isDelete: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDelete = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDelete ? Colors.red : AppColors.black,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: isDelete ? Colors.red : AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context,
      ScanHistory scan,
      HistoryViewModel viewModel,
      double screenHeight,
      double screenWidth,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 38,
            bottom: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Text(
                AppLocalizations.of(context)!.history_delete_title,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  height: 1.2,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                AppLocalizations.of(context)!.history_delete_confirmation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 1.4,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          viewModel.deleteScan(scan.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF589C68),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: const BorderSide(
                              color: Color(0xFF589C68),
                              width: 1,
                            ),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          AppLocalizations.of(context).history_delete_button,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFFD1D5DB),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context).history_cancel_button,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
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

  void _shareScan(ScanHistory scan) {
    // Implement share functionality
    print('Sharing scan: ${scan.plantName}');
  }

  Future getApplicationDocumentsDirectory() async {}
}


/* ------- Correct but unresonsive  ---------
import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../../view_models/history_view_model.dart';
import '../../../utils/responsive_helper.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/navigation/app_routes.dart';
import '../../data/models/history_model.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/history_service.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/history/history_card.dart';
import '../widgets/history/history_tabs.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
int _buildCount = 0;
 bool _hasLoaded = false;


  @override
  void initState() {
    super.initState();
    print('📱 HISTORY SCREEN INIT - Simple load');


   // Log screen view
  AnalyticsService.logScreenView(screenName: 'History');
  debugPrint('📊 Analytics: History screen viewed');

    
    // SINGLE load when screen starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadHistory();
      }
    });
  }


 @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

     // Load history when screen becomes active
  final route = ModalRoute.of(context);
  if (route?.isCurrent == true) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<HistoryViewModel>(context, listen: false);
      if (!viewModel.isLoading && viewModel.allHistory.isEmpty) {
        viewModel.loadHistory();
      }
    });
  }
  }
  
  void _loadHistory() {
    if (_hasLoaded) return; // Prevent duplicate loads
    
    print('🔄 Loading history');
    final viewModel = Provider.of<HistoryViewModel>(context, listen: false);
    viewModel.loadHistory();
    _hasLoaded = true;
  }


  @override
Widget build(BuildContext context) {
  debugPrint('🚨🚨🚨 HISTORY SCREEN BUILD CALLED');
  debugPrint('   Build timestamp: ${DateTime.now().millisecondsSinceEpoch}');
  debugPrint('   Build count: ${_buildCount++}');

  return Scaffold(
    backgroundColor: AppColors.white,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          
          _buildScreenTitle(),
          
          SizedBox(height: ResponsiveHelper.responsiveHeight(15, context)),
          
          _buildTabs(),

          
          Expanded(child: _buildContent()),
        ],
      ),
    ),
    
    /*
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.blue,
      onPressed: () async {
       // final box = await Hive.openBox<ScanHistory>('scanHistory');

        final viewModel = Provider.of<HistoryViewModel>(context, listen: false);
          await viewModel.loadHistory();
        
        final testId = 'live_test_${DateTime.now().millisecondsSinceEpoch}';
        final testScan = ScanHistory(
      
          id: testId,
          type: 'test',
          plantName: 'Live Test Plant',
          timestamp: DateTime.now(),
          imagePath: null,
          isSaved: false,
          hasAbnormality: false,
          resultData: {},
        );
       
       
         // Save via HistoryService (not direct Hive)
    await HistoryService().saveScan(testScan);
       
        viewModel.loadHistory();
      },
      child: Icon(Icons.add, color: Colors.white),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    */
  );
}


  
Widget _buildScreenTitle() {
  return Container(
 margin: EdgeInsets.only(top: ResponsiveHelper.responsiveHeight(20, context)),
    child: Center( 
      child: Text(
      //  'Scan History',
      AppLocalizations.of(context).history_title, 
        style: TextStyle(
          fontFamily: 'DMSans',
          fontWeight: FontWeight.w700,
          fontSize: ResponsiveHelper.responsiveFontSize(20, context),
          height: 1.0,
          letterSpacing: -0.17,
          color: const Color(0xFF1B3B1C),
        ),
      ),
    ),
  );
}

  Widget _buildTabs() {
  return LayoutBuilder(
    builder: (context, constraints) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.responsiveWidth(16, context),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: min(constraints.maxWidth, 400), 
          ),
          child: Consumer<HistoryViewModel>(
            builder: (context, viewModel, child) {
              return HistoryTabs(
                showMyPlants: viewModel.showMyPlants,
                myPlantsCount: viewModel.myPlantsCount,
                historyCount: viewModel.historyCount,
                onTabChanged: (showMyPlants) {
                  viewModel.toggleView(showMyPlants);
                },
              );
            },
          ),
        ),
      );
    },
  );
}


 Widget _buildContent() {
    return Consumer<HistoryViewModel>(
      builder: (context, viewModel, child) {
        print('📊 UI State: ${viewModel.allHistory.length} scans, loading: ${viewModel.isLoading}');
        
        if (viewModel.isLoading) {
          return _buildLoadingState();
        }

        if (viewModel.allHistory.isEmpty) {
          return _buildEmptyState(viewModel.showMyPlants);
        }

        final currentList = viewModel.showMyPlants
            ? viewModel.myPlants
            : viewModel.allHistory;

        return _buildHistoryList(currentList, viewModel);
      },
    );
  }



  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(color: AppColors.primaryGreen),
    );
  }

  Widget _buildEmptyState(bool showMyPlants) {
  final title = showMyPlants 
 // ? 'No Saved Plants' 
 // : 'Nothing to show';

  ? AppLocalizations.of(context).history_empty_my_plants  
  : AppLocalizations.of(context).history_empty_history;  
  
  final description = showMyPlants
//   ? 'Save plants from scan history to see them here'
//   : 'All your scans will appear here';

    ? AppLocalizations.of(context).history_empty_my_plants_desc 
    : AppLocalizations.of(context).history_empty_history_desc;  

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // SVG Image
      SvgPicture.asset(
        'assets/images/empty_history.svg',
        width: ResponsiveHelper.responsiveWidth(120, context),
        height: ResponsiveHelper.responsiveHeight(120, context),
      ),
      SizedBox(height: ResponsiveHelper.responsiveHeight(16, context)),
      
      // Title
      Text(
        title,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontWeight: FontWeight.w700,
          fontSize: ResponsiveHelper.responsiveFontSize(18, context),
          color: AppColors.black,
        ),
      ),
      
      SizedBox(height: ResponsiveHelper.responsiveHeight(8, context)),
      
      // Description
      Text(
        description,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontWeight: FontWeight.w400,
          fontSize: ResponsiveHelper.responsiveFontSize(14, context),
          color: AppColors.darkGray,
        ),
      ),
    ],
  );
}

  Widget _buildHistoryList(
    List<ScanHistory> scans,
    HistoryViewModel viewModel,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.responsiveWidth(16, context),
        vertical: ResponsiveHelper.responsiveHeight(12, context),
      ),
      child: ListView.builder(
        itemCount: scans.length,
        itemBuilder: (context, index) {
          final scan = scans[index];
          return HistoryCard(
            scan: scan,
            onTap: () {
              _handleCardTap(scan);
            },
            onMorePressed: () {
              _showActionSheet(context, scan, viewModel);
            },
          );
        },
      ),
    );
  }

  void _handleCardTap(ScanHistory scan) {
    

  debugPrint(' DEBUG SCAN RESULT DATA ');
  debugPrint('Plant Name: ${scan.plantName}');
  debugPrint('Scan Type: ${scan.type}');
  debugPrint('Scan ID: ${scan.id}');
  debugPrint('Has Result Data: ${scan.resultData != null}');
  
  if (scan.resultData != null) {
    debugPrint('Result Data Keys: ${scan.resultData!.keys.join(", ")}');
    debugPrint('Result Data Full: ${scan.resultData}');
    
    
    if (scan.type == 'diagnose') {
      debugPrint('Diagnosis Plant: ${scan.resultData!['plantName']}');
      debugPrint('Disease: ${scan.resultData!['diseaseName']}');
      debugPrint('Severity: ${scan.resultData!['severityLevel']}');
    }
  } else {
    debugPrint(' WARNING: resultData is NULL!');
  }
  debugPrint(' END DEBUG ');


    switch (scan.type) {
      case 'identify':
        Navigator.pushNamed(
          context,
          AppRoutes.plantIdentificationResult,
          arguments: {
          'scanData': scan.resultData, 
           'imagePath': scan.imagePath,
           'fromHistory': true,  
          'scanId': scan.id, 
    },
        );
        break;
      case 'diagnose':
        Navigator.pushNamed(
          context,
          AppRoutes.plantDiagnosisResult,
          arguments: {
            'scanData': scan.resultData,
             'imagePath': scan.imagePath,
       //      'fromHistory': true,
       //       'scanId': scan.id, 
    },
        );
        break;
      case 'water':
        Navigator.pushNamed(
          context,
          AppRoutes.waterResult,
          arguments: {'scanData': scan.resultData},
        );
        break;
      case 'light':
        // Navigate to light meter result
         _showLightMeterResult(context, scan);
        break;
    }
  }

void _showLightMeterResult(BuildContext context, ScanHistory scan) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
    //  title: Text('Light Measurement Result'),
    title: Text(AppLocalizations.of(context).history_light_dialog_title),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*
          Text('Light Level: ${scan.resultData?['luxValue']?.round() ?? 0} LUX'),
          SizedBox(height: 8),
          Text('Status: ${scan.resultData?['lightStatus'] ?? 'Unknown'}'),
          SizedBox(height: 8),
          Text('Optimal Range: ${scan.resultData?['optimalRange'] ?? '1000-10000 LUX'}'),
          SizedBox(height: 8),
          Text('Time: ${_formatTimestamp(scan.timestamp)}'),
          */

          Text('${AppLocalizations.of(context).history_light_level} ${scan.resultData?['luxValue']?.round() ?? 0} ${AppLocalizations.of(context).history_lux_unit}'),
          Text('${AppLocalizations.of(context).history_status} ${scan.resultData?['lightStatus'] ?? 'Unknown'}'),
          Text('${AppLocalizations.of(context).history_optimal_range} ${scan.resultData?['optimalRange'] ?? '1000-10000 LUX'}'),
          Text('${AppLocalizations.of(context).history_time} ${_formatTimestamp(scan.timestamp)}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
        // child: Text('Close'),
        child: Text(AppLocalizations.of(context).history_close),
        ),
      ],
    ),
  );
}

String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';


/*
if (difference.inMinutes < 1) return AppLocalizations.of(context)!.history_timestamp_just_now;
if (difference.inMinutes < 60) return '${difference.inMinutes} ${AppLocalizations.of(context)!.history_timestamp_min_ago}';
if (difference.inHours < 24) return '${difference.inHours} ${AppLocalizations.of(context)!.history_timestamp_hours_ago}';
if (difference.inDays < 7) return '${difference.inDays} ${AppLocalizations.of(context)!.history_timestamp_days_ago}';
    */
  }


  void _showActionSheet(
    BuildContext context,
    ScanHistory scan,
    HistoryViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return _buildActionSheetContent(context, scan, viewModel);
      },
    );
  }

  Widget _buildActionSheetContent(
    BuildContext context,
    ScanHistory scan,
    HistoryViewModel viewModel,
  ) {
    return Container(
      height: ResponsiveHelper.responsiveHeight(160, context),
      padding: EdgeInsets.all(ResponsiveHelper.responsiveWidth(16, context)),
      child: Column(
        children: [
       

       /*
          // Share Option
          _buildActionOption(
            context: context,
            icon: Icons.share,
            title: 'Share',
            onTap: () {
              Navigator.pop(context);
              _shareScan(scan);
            },
          ),

          // Divider
          Container(
            width: ResponsiveHelper.responsiveWidth(343, context),
            height: 1,
            color: const Color(0xFFD9D9D9),
          ),
          */


          // Save/Unsave Option
          _buildActionOption(
            context: context,
            icon: scan.isSaved ? Icons.bookmark_remove : Icons.bookmark_add,
            title: scan.isSaved 
            
         //   ? 'Remove from My Plants' 
         //   : 'Save to My Plants',

          ? AppLocalizations.of(context).history_remove_from_my_plants
          : AppLocalizations.of(context).history_save_to_my_plants,


            onTap: () {
              Navigator.pop(context);
              viewModel.toggleSaveStatus(scan.id);
            },
          ),

          // Divider
          Container(
            width: ResponsiveHelper.responsiveWidth(343, context),
            height: 1,
            color: const Color(0xFFD9D9D9),
          ),

          // Delete Option
          _buildActionOption(
            context: context,
            icon: Icons.delete_outline,
          //  title: 'Delete',
          title: AppLocalizations.of(context).history_delete_button,

            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, scan, viewModel);
            },
            isDelete: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDelete = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: ResponsiveHelper.responsiveHeight(60, context),
          padding: EdgeInsets.all(
            ResponsiveHelper.responsiveWidth(16, context),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDelete ? Colors.red : AppColors.black,
                size: ResponsiveHelper.responsiveWidth(24, context),
              ),
              SizedBox(width: ResponsiveHelper.responsiveWidth(16, context)),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveHelper.responsiveFontSize(18, context),
                  color: isDelete ? Colors.red : AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
  BuildContext context,
  ScanHistory scan,
  HistoryViewModel viewModel,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
    isDismissible: true,
    enableDrag: true,
    builder: (context) {
      return Container(
        padding: EdgeInsets.only(
          left: ResponsiveHelper.responsiveWidth(20, context),
          right: ResponsiveHelper.responsiveWidth(20, context),
          top: ResponsiveHelper.responsiveHeight(38, context),
          bottom: ResponsiveHelper.responsiveHeight(32, context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Text(
             // 'Delete ?',  
             AppLocalizations.of(context)!.history_delete_title,

              style: TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w700,
                fontSize: ResponsiveHelper.responsiveFontSize(20, context),
                height: 1.2,
                color: const Color(0xFF111827), 
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.responsiveHeight(8, context)),
            
            // Description
            Text(
            //  'Are you sure you want to delete this ?', 
            AppLocalizations.of(context)!.history_delete_confirmation,

              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w400,
                fontSize: ResponsiveHelper.responsiveFontSize(14, context),
                height: 1.4,
                color: const Color(0xFF6B7280), 
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.responsiveHeight(24, context)),
            
     
            Row(
              children: [
              
                Expanded(
                  child: SizedBox(
                    height: ResponsiveHelper.responsiveHeight(55, context),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        viewModel.deleteScan(scan.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF589C68), 
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(
                            color: const Color(0xFF589C68),
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                       // 'Delete',
                       AppLocalizations.of(context).history_delete_button,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveHelper.responsiveFontSize(16, context),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: ResponsiveHelper.responsiveWidth(12, context)),
                
                
                Expanded(
                  child: SizedBox(
                    height: ResponsiveHelper.responsiveHeight(55, context),
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: const Color(0xFFD1D5DB), 
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                       // 'Cancel',
                       AppLocalizations.of(context).history_cancel_button,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveHelper.responsiveFontSize(16, context),
                          color: const Color(0xFF374151), 
                        ),
                      ),
                    ),
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

  void _shareScan(ScanHistory scan) {
    // Implement share functionality
    print('Sharing scan: ${scan.plantName}');
  }
  
  Future getApplicationDocumentsDirectory() async {}
}*/