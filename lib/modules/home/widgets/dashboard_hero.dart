import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../shared/widgets/design_components.dart';

/// A high contrast editorial hero with its own light illustration surface.
class DashboardHero extends StatelessWidget {
  final VoidCallback onLearn, onSigns;
  const DashboardHero({
    super.key,
    required this.onLearn,
    required this.onSigns,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 780;
      final text = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.accentGold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Eyebrow(
                  'your_road_starts'.tr,
                  color: const Color(0xFFF8D978),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'hero_title'.tr,
            style: AppTextStyles.headline1.copyWith(
              color: const Color(0xFFFAFCF6),
              fontSize: wide ? 43 : 30,
              height: 1.3,
              letterSpacing: -.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'hero_description'.tr,
            style: AppTextStyles.body1.copyWith(
              fontSize: wide ? 16 : 15,
              color: const Color(0xFFD3E0D5),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: onLearn,
                icon: const Icon(Icons.arrow_forward_rounded, size: 19),
                label: Text('start_learning'.tr),
              ),
              OutlinedButton.icon(
                onPressed: onSigns,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF81988A)),
                ),
                icon: const Icon(Icons.traffic_outlined, size: 19),
                label: Text((wide ? 'explore_signs' : 'nav_sign').tr),
              ),
            ],
          ),
          if (wide) ...[
            const SizedBox(height: 25),
            Text(
              'hero_support'.tr,
              style: AppTextStyles.body2.copyWith(
                color: const Color(0xFFC3D2C6),
              ),
            ),
          ],
        ],
      );
      final illustration = Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFF6EAC5),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: wide ? 290 : 140,
              child: const RoadIllustration(),
            ),
            if (wide)
              Positioned(
                top: 18,
                left: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCF0),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.explore_outlined,
                        size: 18,
                        color: AppColors.accentGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'guided_learning'.tr,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
      return Container(
        padding: EdgeInsets.all(wide ? 34 : 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.heroTop, AppColors.heroBottom],
          ),
        ),
        child: wide
            ? Row(
                children: [
                  Expanded(flex: 6, child: text),
                  const SizedBox(width: 30),
                  Expanded(flex: 4, child: illustration),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [text, const SizedBox(height: 22), illustration],
              ),
      );
    },
  );
}
