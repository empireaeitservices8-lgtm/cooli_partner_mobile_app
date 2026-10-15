import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/backgrounds.dart';

class OnboardingSlide {
  final String imageAsset;
  final String title;
  final String description;
  final Color accentColor;

  const OnboardingSlide({
    required this.imageAsset,
    required this.title,
    required this.description,
    required this.accentColor,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      imageAsset: 'assets/images/onboarding_driver.jpg',
      title: 'Drive. Deliver. Earn.',
      description: 'Find flexible work opportunities around you with zero idle wait times.',
      accentColor: AppColors.primaryBlue,
    ),
    OnboardingSlide(
      imageAsset: 'assets/images/onboarding_truck.jpg',
      title: 'More Jobs. More Opportunities.',
      description: 'Combine passenger rides, Porter packages, and heavy truck freight on a single platform.',
      accentColor: AppColors.accentOrangeDark,
    ),
    OnboardingSlide(
      imageAsset: 'assets/images/onboarding_earnings.jpg',
      title: 'Track Your Earnings',
      description: 'Transparent commission rates and direct daily payouts straight to your bank account.',
      accentColor: AppColors.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.push('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Stack(
        children: [
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CityIllustrationBackground(height: 100),
          ),
          Column(
            children: [
              // Skip Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => context.push('/login'),
                    child: Text(
                      'SKIP',
                      style: AppTextStyles.captionBold.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

              // Page View Slides
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 240,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.asset(
                                slide.imageAsset,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: slide.accentColor.withOpacity(0.12),
                                  child: Icon(
                                    Icons.local_shipping_rounded,
                                    size: 68,
                                    color: slide.accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            slide.title,
                            style: AppTextStyles.displayMedium.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            slide.description,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              height: 1.45,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  final isSelected = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBlue : AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // Bottom Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  children: [
                    CooliPrimaryButton(
                      label: _currentIndex == _slides.length - 1 ? 'GET STARTED' : 'CONTINUE',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _onNext,
                    ),
                    const SizedBox(height: 12),
                    CooliSecondaryButton(
                      label: 'I ALREADY HAVE AN ACCOUNT',
                      onPressed: () => context.push('/login'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
