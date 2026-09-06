import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:test_app_new/tasbeeh_section/logic/tasbeeh_cubit.dart';

/// Reset and "change target" controls for the Tasbeeh counter.
class TasbeehActions extends StatelessWidget {
  final bool isDark;

  const TasbeehActions({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TasbeehCubit>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.refresh_rounded,
          label: 'إعادة تعيين',
          isDark: isDark,
          onTap: cubit.reset,
        ),
        const SizedBox(width: 16),
        _ActionButton(
          icon: Icons.flag_outlined,
          label: 'تغيير الهدف',
          isDark: isDark,
          onTap: () => _showTargetDialog(context, cubit),
        ),
      ],
    );
  }

  void _showTargetDialog(BuildContext context, TasbeehCubit cubit) {
    final controller = TextEditingController(text: '${cubit.state.target}');
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.bgCardDark : AppColors.bgCard,
          title: Text('تغيير الهدف', style: GoogleFonts.ibmPlexSansArabic()),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: GoogleFonts.ibmPlexSansArabic(
              color: isDark ? AppColors.textLight : AppColors.textPrimary,
            ),
            decoration: const InputDecoration(hintText: 'العدد المستهدف'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('إلغاء', style: GoogleFonts.ibmPlexSansArabic()),
            ),
            TextButton(
              onPressed: () {
                final target = int.tryParse(controller.text.trim());
                if (target != null && target > 0) {
                  cubit.changeTarget(target);
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(
                'حفظ',
                style: GoogleFonts.ibmPlexSansArabic(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCardDark : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accentLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 13,
                color: isDark ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
