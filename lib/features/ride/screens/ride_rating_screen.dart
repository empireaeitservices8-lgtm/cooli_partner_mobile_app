import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/cooli_text_fields.dart';
import '../../../core/widgets/selection_widgets.dart';
import '../../../providers/providers.dart';

class RideRatingScreen extends ConsumerStatefulWidget {
  const RideRatingScreen({super.key});

  @override
  ConsumerState<RideRatingScreen> createState() => _RideRatingScreenState();
}

class _RideRatingScreenState extends ConsumerState<RideRatingScreen> {
  int _selectedStars = 5;
  final TextEditingController _commentController = TextEditingController();
  final Set<String> _selectedFeedback = {'Punctual', 'Polite'};

  final List<String> _feedbackOptions = const [
    'Punctual',
    'Polite',
    'Clear Directions',
    'Respectful',
    'Fast Boarding',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitRating() async {
    await ref.read(rideNotifierProvider.notifier).ratePassenger(
          _selectedStars.toDouble(),
          _commentController.text.trim(),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating submitted! Thank you.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideState = ref.watch(rideNotifierProvider);
    final passengerName = rideState.ride?.passengerName ?? 'Passenger';

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Rate Your Passenger',
              style: AppTextStyles.headline.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'How was your trip with $passengerName?',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 32),

            // Star Rating Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starNumber = index + 1;
                final isFilled = starNumber <= _selectedStars;
                return IconButton(
                  iconSize: 42,
                  icon: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFilled ? const Color(0xFFF59E0B) : AppColors.cardBorder,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedStars = starNumber;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              _getRatingDescription(_selectedStars),
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.accentOrangeDark,
              ),
            ),
            const SizedBox(height: 28),

            // Feedback Tag Chips
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'What went well?',
                style: AppTextStyles.captionBold.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _feedbackOptions.map((tag) {
                final isSelected = _selectedFeedback.contains(tag);
                return FilterChipWidget(
                  label: tag,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedFeedback.remove(tag);
                      } else {
                        _selectedFeedback.add(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Comments
            CooliTextField(
              controller: _commentController,
              label: 'Additional Comments (Optional)',
              hintText: 'Share more about your experience...',
              maxLines: 3,
            ),
            const SizedBox(height: 36),

            CooliPrimaryButton(
              label: 'SUBMIT FEEDBACK',
              icon: Icons.check_rounded,
              onPressed: _submitRating,
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingDescription(int stars) {
    switch (stars) {
      case 5:
        return 'Excellent Passenger!';
      case 4:
        return 'Good Experience';
      case 3:
        return 'Average';
      case 2:
        return 'Could Be Better';
      case 1:
        return 'Poor Experience';
      default:
        return '';
    }
  }
}
