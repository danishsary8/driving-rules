import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/themes/app_theme.dart';
import '../../shared/widgets/design_components.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) Get.offNamed(AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 500;
          return Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(compact ? 16 : 30),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(
                        milliseconds: MediaQuery.disableAnimationsOf(context)
                            ? 0
                            : 650,
                      ),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 16 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: compact ? 92 : 132,
                            height: compact ? 92 : 132,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: compact ? 92 : 132,
                                  height: compact ? 92 : 132,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accentGold.withValues(
                                      alpha: .07,
                                    ),
                                    border: Border.all(
                                      color: AppColors.accentGold.withValues(
                                        alpha: .25,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: compact ? 76 : 108,
                                  height: compact ? 76 : 108,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accentGold.withValues(
                                      alpha: .10,
                                    ),
                                  ),
                                ),
                                BrandMark(size: compact ? 60 : 82),
                              ],
                            ),
                          ),
                          SizedBox(height: compact ? 16 : 25),
                          Text(
                            'Driving Rules',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(fontSize: compact ? 32 : 42),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'splash_tagline'.tr,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: compact ? 20 : 40),
                          SizedBox(
                            width: 100,
                            child: LinearProgressIndicator(
                              value: MediaQuery.disableAnimationsOf(context)
                                  ? 1
                                  : null,
                              minHeight: 3,
                              color: AppColors.accentGreen,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 30,
                child: Column(
                  children: [
                    Eyebrow('made_for_cambodia'.tr),
                    const SizedBox(height: 8),
                    Text(
                      'LEARN. PRACTICE. DRIVE.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        letterSpacing: 2,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
