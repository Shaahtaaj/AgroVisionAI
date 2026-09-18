import 'package:flutter/material.dart';

import '../core/app_fonts.dart';
import '../core/app_scope.dart';
import '../core/app_theme.dart';

class InfoSection extends StatelessWidget {
  const InfoSection({
    required this.title,
    required this.items,
    required this.icon,
    super.key,
  });

  final String title;
  final List<String> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final language = AppScope.of(context).language;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(
        color: Colors.white,
        borderColor: AppColors.border,
        borderRadius: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.mintLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppFonts.heading(language),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.forest,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontFamily: AppFonts.body(language),
                        height: 1.45,
                        fontSize: 13.5,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
