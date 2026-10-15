import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/cooli_card.dart';
import '../../../core/widgets/cooli_text_fields.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

class PartnerRegistrationScreen extends ConsumerStatefulWidget {
  const PartnerRegistrationScreen({super.key});

  @override
  ConsumerState<PartnerRegistrationScreen> createState() =>
      _PartnerRegistrationScreenState();
}

class _PartnerRegistrationScreenState
    extends ConsumerState<PartnerRegistrationScreen> {
  int _currentStep = 0; // 0 to 6 (7 steps total)
  bool _isSubmitting = false;

  // Step 1: Partner Role & Personal (Rider, Porter, Truck Driver, Fleet Owner)
  PartnerRole _selectedRole = PartnerRole.rider;
  final _nameController = TextEditingController();
  String _selectedGender = 'Male';

  // Step 2: Contact
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _altPhoneController = TextEditingController();

  // Step 3: Address
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Step 4: Vehicle
  String _vehicleType = 'Cab / Taxi (Dzire)';
  final _vehicleRegController = TextEditingController();
  final _vehicleModelController = TextEditingController();

  // Step 5: Documents
  final _dlNumberController = TextEditingController();
  final _rcNumberController = TextEditingController();

  // Step 6: Bank
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final pending = ref.read(authNotifierProvider).pendingPhone;
    final phoneClean = (pending != null && pending.isNotEmpty)
        ? pending.replaceAll(RegExp(r'^\+91\s*'), '').replaceAll(RegExp(r'\s+'), '').trim()
        : '9847012345';

    _nameController.text = 'Rahul Kumar';
    _phoneController.text = phoneClean.length == 10 ? phoneClean : '9847012345';
    _emailController.text = 'rahul.kumar@gmail.com';
    _altPhoneController.text = '9447120984';
    _cityController.text = 'Kochi';
    _pincodeController.text = '682016';
    _vehicleRegController.text = 'KL 07 AB 1234';
    _vehicleModelController.text = 'Maruti Dzire Tour';
    _dlNumberController.text = 'KL-07-2015-0049210';
    _rcNumberController.text = 'KL07AB12349012';
    _bankNameController.text = 'HDFC Bank Ltd.';
    _accountNumberController.text = '50100452189245';
    _ifscController.text = 'HDFC0001248';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: BackHeader(
        title: 'Partner Registration',
        onBack: _onBack,
      ),
      body: Column(
        children: [
          // Step Progress Bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentStep + 1} of 7: ${_getStepTitle(_currentStep)}',
                      style: AppTextStyles.captionBold
                          .copyWith(color: AppColors.primaryBlue),
                    ),
                    Text(
                      '${((_currentStep + 1) / 7 * 100).toInt()}%',
                      style: AppTextStyles.captionBold
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / 7,
                    minHeight: 6,
                    backgroundColor: AppColors.cardBorder,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
          ),

          // Wizard Page Content
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: _buildStepContent(),
            ),
          ),

          // Sticky Bottom Actions
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0 && _currentStep < 6) ...[
                  Expanded(
                    flex: 1,
                    child: CooliSecondaryButton(
                      label: 'BACK',
                      height: 50,
                      onPressed: _onBack,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: CooliPrimaryButton(
                    label: _currentStep == 6
                        ? 'VIEW VERIFICATION STATUS'
                        : _currentStep == 5
                            ? 'SUBMIT REGISTRATION'
                            : 'NEXT STEP',
                    icon: _currentStep == 6
                        ? Icons.pending_actions_rounded
                        : Icons.arrow_forward_rounded,
                    height: 50,
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _onNext,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _altPhoneController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _vehicleRegController.dispose();
    _vehicleModelController.dispose();
    _dlNumberController.dispose();
    _rcNumberController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  Widget _buildStep1Personal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Partner Category',
            style: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(
            '4 user categories can use the COOLI PARTNER app. Select your category:',
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 14),

        // 4 Role Cards
        ...PartnerRole.values.map((role) {
          final isSelected = _selectedRole == role;
          IconData icon;
          Color roleColor;
          switch (role) {
            case PartnerRole.rider:
              icon = Icons.local_taxi_rounded;
              roleColor = AppColors.primaryBlue;
              break;
            case PartnerRole.porter:
              icon = Icons.inventory_2_rounded;
              roleColor = const Color(0xFFD97706);
              break;
            case PartnerRole.truckDriver:
              icon = Icons.local_shipping_rounded;
              roleColor = AppColors.secondaryPurple;
              break;
            case PartnerRole.fleetOwner:
              icon = Icons.domain_rounded;
              roleColor = const Color(0xFF059669);
              break;
          }

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedRole = role;
                switch (role) {
                  case PartnerRole.rider:
                    _vehicleType = 'Cab / Taxi (Dzire) / Auto';
                    _vehicleModelController.text = 'Maruti Dzire Tour';
                    break;
                  case PartnerRole.porter:
                    _vehicleType = 'Mini Truck (Tata Ace)';
                    _vehicleModelController.text = 'Tata Ace Gold Plus';
                    break;
                  case PartnerRole.truckDriver:
                    _vehicleType = 'Heavy Truck (Ashok Leyland 16T)';
                    _vehicleModelController.text = 'Ashok Leyland 16T Freight';
                    break;
                  case PartnerRole.fleetOwner:
                    _vehicleType = 'Commercial Fleet (5+ Vehicles)';
                    _vehicleModelController.text =
                        'Commercial Fleet Multi-Truck';
                    break;
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? roleColor.withOpacity(0.08) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? roleColor : AppColors.cardBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? roleColor : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon,
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                        size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          role.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color:
                                isSelected ? roleColor : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          role.description,
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded,
                        color: roleColor, size: 20),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 12),
        const Divider(height: 20),
        Text('Personal Information',
            style: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Enter your legal full name matching your government ID card.',
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 16),
        CooliTextField(
          controller: _nameController,
          label: 'Full Legal Name',
          hintText: 'e.g. Rahul Kumar',
          prefixIcon: const Icon(Icons.person_outline_rounded),
        ),
        const SizedBox(height: 16),
        Text('Gender',
            style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Row(
          children: ['Male', 'Female', 'Other'].map((gender) {
            final isSelected = _selectedGender == gender;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = gender),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.infoLight : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.cardBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      gender,
                      style: AppTextStyles.captionBold.copyWith(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2Contact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Information',
            style: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(
            'Add your mobile number and email for verification and payout updates.',
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 20),
        CooliTextField(
          controller: _emailController,
          label: 'Email Address',
          hintText: 'e.g. rahul@domain.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
        ),
        const SizedBox(height: 16),
        CooliTextField(
          controller: _phoneController,
          label: 'Mobile Number',
          hintText: '10-digit mobile number',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          prefixIcon: const Icon(Icons.phone_android_rounded),
        ),
        const SizedBox(height: 16),
        CooliTextField(
          controller: _altPhoneController,
          label: 'Alternative Contact Number',
          hintText: 'e.g. 94471 20984',
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined),
        ),
      ],
    );
  }

  Widget _buildStep3Address() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Operating Location',
            style: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Select your primary operating city in Kerala / South India.',
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 20),
        CooliTextField(
          controller: _cityController,
          label: 'Primary Operating City',
          hintText: 'e.g. Kochi, Thrissur, Kozhikode',
          prefixIcon: const Icon(Icons.location_city_rounded),
        ),
        const SizedBox(height: 16),
        CooliTextField(
          controller: _pincodeController,
          label: 'Residential PIN Code',
          hintText: 'e.g. 682016',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.pin_drop_outlined),
        ),
      ],
    );
  }

  Widget _buildStep4Vehicle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vehicle Registration',
            style: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Add your initial vehicle for rides, goods delivery, or freight.',
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 20),
        Text('Vehicle Category',
            style:
                AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder, width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _vehicleType,
              items: [
                'Commercial Fleet (5+ Vehicles)',
                'Mini Truck (Tata Ace)',
                'Pickup Truck (Bolero)',
                'Heavy Truck (Ashok Leyland 16T)',
                'Cab / Taxi (Dzire)',
                'Two-Wheeler (Bike / Scooter)',
                'Auto (3-Wheeler Cargo)',
                'Heavy Commercial Truck',
                'Sedan / Hatchback (Ride)',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: AppTextStyles.body),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _vehicleType = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        CooliTextField(
          controller: _vehicleModelController,
          label: 'Make & Model',
          hintText: 'e.g. Tata Ace Gold Plus',
          prefixIcon: const Icon(Icons.local_shipping_outlined),
        ),
        const SizedBox(height: 16),
        CooliTextField(
          controller: _vehicleRegController,
          label: 'Vehicle Registration Number',
          hintText: 'e.g. KL 07 AB 1234',
          prefixIcon: const Icon(Icons.confirmation_number_outlined),
        ),
      ],
    );
  }

  Widget _buildStep5Documents() {
    final isFleetOwner = _selectedRole == PartnerRole.fleetOwner;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isFleetOwner ? 'Fleet Documents' : 'Official Documents',
          style:
              AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          isFleetOwner
              ? 'Enter the registration number for a vehicle in your fleet.'
              : 'Enter your verification license and registration numbers.',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 20),
        if (!isFleetOwner) ...[
          CooliTextField(
            controller: _dlNumberController,
            label: 'Driving License (DL) Number',
            hintText: 'e.g. KL-07-2015-0049210',
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
          const SizedBox(height: 16),
        ],
        CooliTextField(
          controller: _rcNumberController,
          label: 'RC Book Registration Number',
          hintText: 'e.g. KL07AB12349012',
          prefixIcon: const Icon(Icons.description_outlined),
        ),
        const SizedBox(height: 20),
        CooliCard(
          backgroundColor: const Color(0xFFF0FDF4),
          border: Border.all(color: const Color(0xFF86EFAC)),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined,
                  color: AppColors.success, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auto-verification Enabled',
                        style: AppTextStyles.captionBold
                            .copyWith(color: AppColors.success)),
                    Text(
                      'Government Sarathi & Vahan database checks are automatically processed.',
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep6Bank() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bank Settlement Account',
            style: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(
            'Your daily trip earnings and freight bids will be deposited here.',
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 20),
        CooliTextField(
          controller: _bankNameController,
          label: 'Bank Name',
          hintText: 'e.g. HDFC Bank Ltd.',
          prefixIcon: const Icon(Icons.account_balance_outlined),
        ),
        const SizedBox(height: 16),
        CooliTextField(
          controller: _accountNumberController,
          label: 'Account Number',
          hintText: 'e.g. 50100452189245',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.credit_card_outlined),
        ),
        const SizedBox(height: 16),
        CooliTextField(
          controller: _ifscController,
          label: 'Bank IFSC Code',
          hintText: 'e.g. HDFC0001248',
          prefixIcon: const Icon(Icons.domain_verification_outlined),
        ),
      ],
    );
  }

  Widget _buildStep7Verification() {
    final partner = ref.watch(authNotifierProvider).partner;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 54),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Registration Submitted!',
          style: AppTextStyles.titleMedium
              .copyWith(fontWeight: FontWeight.w900, fontSize: 22),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Your ${_selectedRole.title} application${partner == null ? '' : ' ID: ${partner.id}'} has been received. Our verification team will review your details.',
          style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Policy: Partner dashboard login is enabled only after verification process is completed.',
                  style: AppTextStyles.caption.copyWith(color: const Color(0xFF92400E), fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CooliCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Application Status', style: AppTextStyles.bodyMedium),
                  StatusBadge.pending('Pending Review (24 hrs)'),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Partner Category', style: AppTextStyles.bodyMedium),
                  StatusBadge.verified(_selectedRole.title),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () async {
            final p = ref.read(authNotifierProvider).partner;
            if (p != null) {
              final verified = await ref.read(authNotifierProvider.notifier).completeVerification(p.phone);
              if (verified != null && mounted) {
                await ref.read(partnerNotifierProvider.notifier).switchPartner(verified);
                ref.read(jobsNotifierProvider.notifier).setFilter(_selectedRole.associatedJobType);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ Verification completed! Welcome to COOLI.'), backgroundColor: AppColors.success),
                );
                context.go('/home');
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
          label: const Text('INSTANT APPROVE & OPEN DASHBOARD (TEST)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Personal();
      case 1:
        return _buildStep2Contact();
      case 2:
        return _buildStep3Address();
      case 3:
        return _buildStep4Vehicle();
      case 4:
        return _buildStep5Documents();
      case 5:
        return _buildStep6Bank();
      case 6:
        return _buildStep7Verification();
      default:
        return const SizedBox();
    }
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Personal Details';
      case 1:
        return 'Contact Details';
      case 2:
        return 'Address';
      case 3:
        return 'Vehicle Setup';
      case 4:
        return 'Documents';
      case 5:
        return 'Bank Details';
      case 6:
        return 'Verification Pending';
      default:
        return '';
    }
  }

  void _onBack() {
    if (_currentStep == 6) {
      context.go('/login');
      return;
    }
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      context.pop();
    }
  }

  Future<void> _onNext() async {
    if (_currentStep == 6) {
      final phone = ref.read(authNotifierProvider).partner?.phone ?? _phoneController.text.trim();
      context.go('/verification-status', extra: phone);
      return;
    }

    if (!_validateCurrentStep()) return;

    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await ref.read(authNotifierProvider.notifier).register(
          name: _nameController.text.trim(),
          phone: '+91 ${_phoneController.text.trim()}',
          email: _emailController.text.trim(),
          city: _cityController.text.trim(),
          role: _selectedRole,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!success) {
      final error = ref.read(authNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error ?? 'Registration failed. Please try again.')),
      );
      return;
    }

    final registeredPartner = ref.read(authNotifierProvider).partner;
    if (registeredPartner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Registration finished, but partner profile could not be loaded.')),
      );
      return;
    }
    ref.read(partnerNotifierProvider.notifier).switchPartner(registeredPartner);
    ref
        .read(jobsNotifierProvider.notifier)
        .setFilter(_selectedRole.associatedJobType);
    setState(() => _currentStep = 6);
  }

  bool _validateCurrentStep() {
    String? message;
    switch (_currentStep) {
      case 0:
        if (_nameController.text.trim().isEmpty) {
          message = 'Enter your full legal name to continue.';
        }
        break;
      case 1:
        final phone = _phoneController.text.trim();
        final email = _emailController.text.trim();
        if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
          message = 'Enter a valid 10-digit mobile number.';
        } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
          message = 'Enter a valid email address.';
        }
        break;
      case 2:
        if (_cityController.text.trim().isEmpty ||
            !RegExp(r'^\d{6}$').hasMatch(_pincodeController.text.trim())) {
          message = 'Enter your operating city and a valid 6-digit PIN code.';
        }
        break;
      case 3:
        if (_vehicleModelController.text.trim().isEmpty ||
            _vehicleRegController.text.trim().isEmpty) {
          message = 'Enter your vehicle model and registration number.';
        }
        break;
      case 4:
        if (_rcNumberController.text.trim().isEmpty ||
            (_selectedRole != PartnerRole.fleetOwner &&
                _dlNumberController.text.trim().isEmpty)) {
          message = _selectedRole == PartnerRole.fleetOwner
              ? 'Enter the registration number for a vehicle in your fleet.'
              : 'Enter your driving license and vehicle RC numbers.';
        }
        break;
      case 5:
        if (_bankNameController.text.trim().isEmpty ||
            _accountNumberController.text.trim().isEmpty ||
            _ifscController.text.trim().isEmpty) {
          message =
              'Complete all bank settlement details to submit your application.';
        }
        break;
    }

    if (message == null) return true;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    return false;
  }
}
