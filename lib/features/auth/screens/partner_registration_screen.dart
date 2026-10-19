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
import '../../../models/api/api_models.dart';
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
  String _vehicleType = 'Car';
  List<RideVehicleType> _rideVehicleTypes = RideVehicleType.dummyVehicleTypes;
  bool _isLoadingVehicleTypes = false;
  bool _hasLoadedVehicleTypes = false;
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

  Future<void> _loadRideVehicleTypes({bool force = false}) async {
    if (_hasLoadedVehicleTypes && !force) return;
    setState(() => _isLoadingVehicleTypes = true);
    try {
      final types =
          await ref.read(driverApiRepositoryProvider).getRideVehicleTypes();
      if (mounted && types.isNotEmpty) {
        setState(() {
          _rideVehicleTypes = types;
          _hasLoadedVehicleTypes = true;
          if (_selectedRole == PartnerRole.rider) {
            _vehicleType = types.any((t) => t.name == 'Car')
                ? 'Car'
                : types.first.name;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _rideVehicleTypes = RideVehicleType.dummyVehicleTypes;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingVehicleTypes = false);
      }
    }
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
                    _vehicleType = _rideVehicleTypes.any((t) => t.name == 'Car')
                        ? 'Car'
                        : (_rideVehicleTypes.isNotEmpty
                            ? _rideVehicleTypes.first.name
                            : 'Car');
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

  void _onSelectVehicleType(RideVehicleType type) {
    setState(() {
      _vehicleType = type.name;
      final lower = type.name.toLowerCase();
      if (lower.contains('bike')) {
        _vehicleModelController.text = 'Hero Splendor / Honda Activa';
      } else if (lower.contains('auto')) {
        _vehicleModelController.text = 'Bajaj RE Auto Rickshaw';
      } else if (lower.contains('bmw')) {
        _vehicleModelController.text = 'BMW 5 Series VIP';
      } else if (lower.contains('premium')) {
        _vehicleModelController.text = 'Toyota Innova Crysta';
      } else if (lower.contains('car') || lower.contains('dzire')) {
        _vehicleModelController.text = 'Maruti Dzire Tour';
      }
    });
  }

  Future<void> _showVehicleTypeBottomSheet() async {
    // Call the ride vehicle-types API if not loaded yet
    if (!_hasLoadedVehicleTypes) {
      await _loadRideVehicleTypes();
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Vehicle Type',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'GET api/ride/vehicle-types/',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w700,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded,
                        color: AppColors.primaryBlue),
                    tooltip: 'Refresh from API',
                    onPressed: () async {
                      await _loadRideVehicleTypes(force: true);
                      (ctx as Element).markNeedsBuild();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._rideVehicleTypes.map((type) {
                final isSelected = _vehicleType
                        .toLowerCase()
                        .contains(type.name.toLowerCase()) ||
                    _vehicleType == type.name;

                IconData iconData;
                final lower = type.name.toLowerCase();
                if (lower.contains('bike')) {
                  iconData = Icons.two_wheeler_rounded;
                } else if (lower.contains('auto')) {
                  iconData = Icons.electric_rickshaw_rounded;
                } else if (lower.contains('bmw')) {
                  iconData = Icons.auto_awesome_rounded;
                } else if (lower.contains('premium')) {
                  iconData = Icons.car_rental_rounded;
                } else {
                  iconData = Icons.directions_car_rounded;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue.withOpacity(0.08)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.cardBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        iconData,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        size: 22,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          type.name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ID ${type.id}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      type.description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primaryBlue)
                        : const Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: AppColors.textTertiary),
                    onTap: () {
                      _onSelectVehicleType(type);
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep4Vehicle() {
    // Load vehicle types when viewing the vehicle category step if not loaded yet
    if (!_hasLoadedVehicleTypes && !_isLoadingVehicleTypes) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasLoadedVehicleTypes && !_isLoadingVehicleTypes) {
          _loadRideVehicleTypes();
        }
      });
    }

    // Current display title for the selected vehicle
    final displayCategory = _vehicleType.isNotEmpty
        ? (_vehicleType.toLowerCase().contains('cab') ||
                _vehicleType.toLowerCase().contains('taxi')
            ? _vehicleType
            : 'Cab / Taxi ($_vehicleType)')
        : 'Cab / Taxi (Dzire)';

    final matchedType = _rideVehicleTypes
        .cast<RideVehicleType?>()
        .firstWhere((vt) =>
            vt != null &&
            (_vehicleType.toLowerCase().contains(vt.name.toLowerCase()) ||
                _vehicleType == vt.name),
            orElse: () => null);

    IconData displayIcon = Icons.directions_car_rounded;
    final lower = _vehicleType.toLowerCase();
    if (lower.contains('bike')) {
      displayIcon = Icons.two_wheeler_rounded;
    } else if (lower.contains('auto')) {
      displayIcon = Icons.electric_rickshaw_rounded;
    } else if (lower.contains('bmw')) {
      displayIcon = Icons.auto_awesome_rounded;
    } else if (lower.contains('premium')) {
      displayIcon = Icons.car_rental_rounded;
    } else if (lower.contains('mini truck') || lower.contains('ace')) {
      displayIcon = Icons.airport_shuttle_rounded;
    } else if (lower.contains('truck') || lower.contains('16t')) {
      displayIcon = Icons.local_shipping_rounded;
    }

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Vehicle Category',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600)),
            if (_isLoadingVehicleTypes)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // ── Clickable Box that calls API & opens vehicle types picker ──
        InkWell(
          onTap: _showVehicleTypeBottomSheet,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(displayIcon,
                      size: 20, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayCategory,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        matchedType?.description ??
                            'Tap to call api/ride/vehicle-types/ & choose',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoadingVehicleTypes)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.textSecondary,
                    size: 28,
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ── Direct Quick-Select Chips from api/ride/vehicle-types/ ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Ride Type (from API)',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            InkWell(
              onTap: _showVehicleTypeBottomSheet,
              child: Text(
                'View All (${_rideVehicleTypes.length})',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _rideVehicleTypes.map((vt) {
              final isSelected = _vehicleType
                      .toLowerCase()
                      .contains(vt.name.toLowerCase()) ||
                  _vehicleType == vt.name;

              IconData chipIcon;
              final l = vt.name.toLowerCase();
              if (l.contains('bike')) {
                chipIcon = Icons.two_wheeler_rounded;
              } else if (l.contains('auto')) {
                chipIcon = Icons.electric_rickshaw_rounded;
              } else if (l.contains('bmw')) {
                chipIcon = Icons.auto_awesome_rounded;
              } else if (l.contains('premium')) {
                chipIcon = Icons.car_rental_rounded;
              } else {
                chipIcon = Icons.directions_car_rounded;
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  avatar: Icon(
                    chipIcon,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.primaryBlue,
                  ),
                  label: Text(vt.name),
                  backgroundColor:
                      isSelected ? AppColors.primaryBlue : Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.cardBorder,
                      width: 1.2,
                    ),
                  ),
                  onPressed: () => _onSelectVehicleType(vt),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),
        CooliTextField(
          controller: _vehicleModelController,
          label: 'Make & Model',
          hintText: 'e.g. Maruti Dzire Tour',
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
      context.go('/home');
      return;
    }

    if (!_validateCurrentStep()) return;

    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
      if (_currentStep == 3 && !_hasLoadedVehicleTypes) {
        _loadRideVehicleTypes();
      }
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await ref.read(authNotifierProvider.notifier).register(
          name: _nameController.text.trim(),
          phone: '+91 ${_phoneController.text.trim()}',
          email: _emailController.text.trim(),
          city: _cityController.text.trim(),
          role: _selectedRole,
          drivingLicence: _dlNumberController.text.trim(),
          idProof: _rcNumberController.text.trim(),
          bankAccountNumber: _accountNumberController.text.trim(),
          bankName: _bankNameController.text.trim(),
          ifscCode: _ifscController.text.trim(),
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
    final activePartner = registeredPartner.copyWith(status: PartnerStatus.active);
    await ref.read(partnerNotifierProvider.notifier).switchPartner(activePartner);
    ref
        .read(jobsNotifierProvider.notifier)
        .setFilter(_selectedRole.associatedJobType);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Registration successful! Welcome to COOLI Partner.'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
    context.go('/home');
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
