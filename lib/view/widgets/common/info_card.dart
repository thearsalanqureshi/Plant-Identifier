// lib/view/widgets/common/info_card.dart
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final Widget? customContent;

  const InfoCard({
    Key? key,
    required this.title,
    required this.content,
    this.customContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 343,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF589C68).withOpacity(0.2)),
      ),
      child: customContent ?? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF1E1F24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Color(0xFF80828D),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}