import 'package:flutter/material.dart';

import '../core/app_fonts.dart';
import '../core/app_language.dart';
import '../core/app_theme.dart';
import '../models/disease.dart';
import 'smart_image.dart';

class MedicineTile extends StatelessWidget {
  const MedicineTile({
    required this.medicine,
    required this.language,
    super.key,
  });

  final Medicine medicine;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card(
        color: Colors.white,
        borderColor: AppColors.border,
        borderRadius: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.mintLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: medicine.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SmartImage(
                      source: medicine.image,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.medication_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.localizedName(language),
                  style: TextStyle(
                    fontFamily: AppFonts.heading(language),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppColors.forest,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.science_outlined,
                        size: 14,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          medicine.localizedDose(language),
                          style: TextStyle(
                            fontFamily: AppFonts.body(language),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.forest,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
