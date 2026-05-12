import 'package:flutter/material.dart';

import 'ad_design_tokens.dart';
import 'ad_loader_widget.dart';
import 'native_ad_variant_1a.dart';
import 'native_ad_variant_1a_ad_placement.dart';
import 'native_ad_variant_1a_no_media.dart';
import 'native_ad_variant_2a.dart';
import 'native_ad_variant_3a.dart';
import 'native_ad_variant_3b.dart';
import 'native_ad_variant_5a.dart';
import 'native_ad_variant_6b.dart';
import 'native_ad_variant_6c.dart';
import 'native_ad_variant_7b.dart';
import 'native_ad_variant_8f.dart';
import 'native_ad_variant_9.dart';

class AdDesignPreviewScreen extends StatelessWidget {
  const AdDesignPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_PreviewItem>[
      const _PreviewItem(
        label: '1(a) No Media',
        child: NativeAdVariant1aNoMedia(),
      ),
      const _PreviewItem(
        label: '1(a) Ad Placement Changes',
        child: NativeAdVariant1aAdPlacement(),
      ),
      const _PreviewItem(label: '1(a)', child: NativeAdVariant1a()),
      const _PreviewItem(label: '2(a)', child: NativeAdVariant2a()),
      const _PreviewItem(label: '3(a)', child: NativeAdVariant3a()),
      const _PreviewItem(label: '3(b)', child: NativeAdVariant3b()),
      const _PreviewItem(label: '5(a)', child: NativeAdVariant5a()),
      const _PreviewItem(label: '6(b)', child: NativeAdVariant6b()),
      const _PreviewItem(label: '6(c)', child: NativeAdVariant6c()),
      const _PreviewItem(label: '7(b)', child: NativeAdVariant7b()),
      const _PreviewItem(label: '8(f)', child: NativeAdVariant8f()),
      const _PreviewItem(label: '9', child: NativeAdVariant9()),
      const _PreviewItem(label: 'Loader: Showing Ad', child: AdLoaderWidget()),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Ad Design Preview'),
        backgroundColor: AdDesignTokens.white,
        foregroundColor: AdDesignTokens.mainText,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            final item = items[index];
            return _PreviewSection(item: item);
          },
        ),
      ),
    );
  }
}

class _PreviewItem {
  final String label;
  final Widget child;

  const _PreviewItem({required this.label, required this.child});
}

class _PreviewSection extends StatelessWidget {
  final _PreviewItem item;

  const _PreviewSection({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: const TextStyle(
            color: AdDesignTokens.mainText,
            fontFamily: AdDesignTokens.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        Center(child: item.child),
      ],
    );
  }
}
