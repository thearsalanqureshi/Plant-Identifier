import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/ad_view_model.dart';
import 'ad_loader_widget.dart';

class AdLoaderOverlay extends StatelessWidget {
  const AdLoaderOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AdViewModel, bool>(
      selector: (_, viewModel) => viewModel.isAdLoaderVisible,
      builder: (context, isVisible, child) {
        if (!isVisible) {
          return const SizedBox.shrink();
        }

        return AbsorbPointer(
          child: ColoredBox(
            color: const Color(0x14000000),
            child: Center(child: child),
          ),
        );
      },
      child: const AdLoaderWidget(),
    );
  }
}
