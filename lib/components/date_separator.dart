import 'package:flutter/material.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/config/themes/app_typography.dart';
import 'package:rumour/utilities/date_formatter.dart';

class DateSeparator extends StatelessWidget {
  final DateTime date;

  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: colors.datePillBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          DateFormatter.formatDateSeparator(date),
          style: AppTypography.labelSmall.copyWith(color: colors.textSecondary),
        ),
      ),
    );
  }
}
