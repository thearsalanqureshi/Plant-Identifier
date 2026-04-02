// lib/view/widgets/common/detail_item.dart
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const DetailItem({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
     final localizations = AppLocalizations.of(context);
     
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            child: Text(
            //  label,
              _getLocalizedLabel(localizations, label),
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF1E1F24),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF80828D),
              ),
            ),
          ),
        ],
      ),
    );
  }
   String _getLocalizedLabel(AppLocalizations l10n, String labelKey) {
    // Map your label keys to ARB keys
    switch (labelKey) {
      case 'Temperature': return l10n.result_temperature;
      case 'Light': return l10n.result_light;
      case 'Soil': return l10n.result_soil;
      case 'Humidity': return l10n.result_humidity;
      case 'Watering': return l10n.result_watering;
      case 'Fertilizing': return l10n.result_fertilizing;
      default: return labelKey;
    }
  }
}