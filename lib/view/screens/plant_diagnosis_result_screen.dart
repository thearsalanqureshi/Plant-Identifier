import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/diagnosis_view_model.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../view/widgets/common/diagnosis_widgets.dart';
import '../../data/models/diagnosis_model.dart';
import '../../l10n/app_localizations.dart';

class PlantDiagnosisResultScreen extends StatefulWidget {
  const PlantDiagnosisResultScreen({super.key});

  @override
  State<PlantDiagnosisResultScreen> createState() => _PlantDiagnosisResultScreenState();
}

class _PlantDiagnosisResultScreenState extends State<PlantDiagnosisResultScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint('💣 ${runtimeType} INIT STATE');
  }

  void _initializeScreen() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      final viewModel = Provider.of<DiagnosisViewModel>(context, listen: false);

      // TWO DISTINCT FLOWS:

      // FLOW 1: New diagnosis from camera/gallery
      if (args['imageFile'] != null) {
        final imageFile = args['imageFile'] as File?;
        if (imageFile != null) {
          viewModel.setImageFile(imageFile);
          viewModel.diagnosePlant(imageFile);
        }
      }

      // FLOW 2: Loading from history
      else if (args['scanData'] != null) {
        final scanData = args['scanData'] as Map<String, dynamic>;
        final imagePath = args['imagePath'] as String?;
        viewModel.loadFromHistory(scanData, imagePath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('💣 ${runtimeType} BUILD CALLED');

    final screenHeight = MediaQuery.of(context).size.height;

    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
          _initializeScreen();
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Consumer<DiagnosisViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.error.isNotEmpty) {
            return _buildErrorState(viewModel.error);
          }

          if (viewModel.diagnosis == null) {
            return _buildErrorState(AppLocalizations.of(context).diagnosis_no_data);
          }

          return _buildSuccessState(viewModel, screenHeight);
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.mediumGray,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.diagnosis_error_title,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).diagnosis_try_again,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(DiagnosisViewModel viewModel, double screenHeight) {
    final diagnosis = viewModel.diagnosis!;
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          toolbarHeight: 50,
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            l10n.diagnosis_result,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: AppColors.languageAppBarText,
            ),
          ),
          centerTitle: true,
          pinned: true,
        ),

        // Content
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 16),

            // Plant Image
            _buildPlantImage(),
            const SizedBox(height: 16),

            // Plant & Disease Info
            _buildPlantDiseaseInfo(diagnosis),
            const SizedBox(height: 16),

            // Severity Card
            _buildSeverityCard(diagnosis),
            const SizedBox(height: 12),

            // Immediate Actions Card
            _buildImmediateActionsCard(diagnosis),
            const SizedBox(height: 12),

            // Treatment Plan Card
            _buildTreatmentPlanCard(diagnosis),
            const SizedBox(height: 12),

            // Daily Monitoring Card
            _buildDailyMonitoringCard(diagnosis),
            const SizedBox(height: 12),

            // Expected Recovery Card
            _buildExpectedRecoveryCard(diagnosis),
            const SizedBox(height: 12),

            // Action Buttons
            _buildActionButtons(),
            const SizedBox(height: 32),
          ]),
        ),
      ],
    );
  }

  Widget _buildPlantImage() {
    final viewModel = Provider.of<DiagnosisViewModel>(context, listen: false);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.22,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: viewModel.imageFile != null
            ? DecorationImage(
          image: FileImage(viewModel.imageFile!),
          fit: BoxFit.cover,
        )
            : null,
        color: AppColors.lightGreenBg,
      ),
      child: viewModel.imageFile == null
          ? Center(
        child: Icon(
          Icons.photo,
          color: AppColors.mediumGray,
          size: 48,
        ),
      )
          : null,
    );
  }

  Widget _buildPlantDiseaseInfo(Diagnosis diagnosis) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            diagnosis.plantName,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.languageAppBarText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            diagnosis.diseaseName,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityCard(Diagnosis diagnosis) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DiagnosisCard(
        title: AppLocalizations.of(context).diagnosis_severity_assessment,
        content: SeverityIndicator(
          severityLevel: diagnosis.severityLevel,
          symptoms: diagnosis.symptoms,
        ),
      ),
    );
  }

  Widget _buildImmediateActionsCard(Diagnosis diagnosis) {
    final actionsList = diagnosis.getImmediateActionsList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DiagnosisCard(
        title: AppLocalizations.of(context).diagnosis_immediate_actions,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: actionsList.map((action) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      action.trim(),
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.darkGray,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTreatmentPlanCard(Diagnosis diagnosis) {
    final treatmentItems = diagnosis.getTreatmentItems();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DiagnosisCard(
        title: AppLocalizations.of(context).diagnosis_treatment_plan,
        content: Column(
          children: [
            if (treatmentItems.isNotEmpty) ...[
              ...treatmentItems.map((item) => TreatmentItem(
                treatment: item['treatment']!,
                duration: item['duration']!,
                frequency: item['frequency']!,
              )),
            ] else ...[
              Text(
                diagnosis.treatmentPlan,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.darkGray,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDailyMonitoringCard(Diagnosis diagnosis) {
    final monitoringItems = diagnosis.getMonitoringChecklist();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DiagnosisCard(
        title: AppLocalizations.of(context).diagnosis_daily_monitoring,
        content: Column(
          children: [
            if (monitoringItems.isNotEmpty) ...[
              ...monitoringItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ChecklistItem(text: item.trim()),
              )),
            ] else ...[
              Text(
                diagnosis.dailyMonitoring,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.darkGray,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpectedRecoveryCard(Diagnosis diagnosis) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightGreenBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).diagnosis_expected_recovery,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.languageAppBarText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              diagnosis.expectedRecovery,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppColors.darkGray,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Diagnose Another Plant Button
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.scanner,
                  (route) => route.isFirst,
              arguments: {'mode': 'diagnose'},
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).diagnosis_diagnose_another,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.white,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Back To Home Button
          OutlinedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
                  (route) => route.isFirst,
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: AppColors.primaryGreen,
                width: 1,
              ),
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).diagnosis_back_home,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}