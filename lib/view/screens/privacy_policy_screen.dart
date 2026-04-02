import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../app/theme/app_colors.dart';
import '../../app/navigation/navigation_service.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    debugPrint('💣 ${widget.runtimeType} INIT STATE CALLED');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          debugPrint('Loading: $progress%');
        },
        onPageFinished: (String url) {
          debugPrint('Page loaded: $url');
        },
      ))
      ..loadRequest(Uri.parse(
        'https://docs.google.com/document/d/e/2PACX-1vQyde-pEspsxh1UxOYshNh2yLRy8HWTlB4FzabeRdXXghCB8iHAE7kw7KFMMZZUzDRYwnDtdqOg17Sd/pub'
      ));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('💣 ${runtimeType} BUILD CALLED');

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).privacy_policy_title,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF1E1F24),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1F24)),
          onPressed: () {
            final navigationService = context.read<NavigationService>();
            navigationService.pop();
          },
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

/* ------- Correct but unresponsive ---------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/responsive_helper.dart';
import '../../app/theme/app_colors.dart';
import '../../app/navigation/navigation_service.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    debugPrint('💣 ${widget.runtimeType} INIT STATE CALLED');
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          debugPrint('Loading: $progress%');
        },
        onPageFinished: (String url) {
          debugPrint('Page loaded: $url');
        },
      ))
      ..loadRequest(Uri.parse(
        'https://docs.google.com/document/d/e/2PACX-1vQyde-pEspsxh1UxOYshNh2yLRy8HWTlB4FzabeRdXXghCB8iHAE7kw7KFMMZZUzDRYwnDtdqOg17Sd/pub'
      ));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('💣 ${runtimeType} BUILD CALLED');

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
        //  'Privacy Policy',
        AppLocalizations.of(context).privacy_policy_title,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w700,
            fontSize: ResponsiveHelper.responsiveFontSize(20, context),
            color: const Color(0xFF1E1F24),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1F24)),
          onPressed: () {
            final navigationService = context.read<NavigationService>();
            navigationService.pop();
          },
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}*/