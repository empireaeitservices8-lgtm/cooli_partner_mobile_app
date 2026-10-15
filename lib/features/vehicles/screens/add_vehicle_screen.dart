import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/cooli_buttons.dart';
import '../../../core/widgets/cooli_text_fields.dart';
import '../../../core/widgets/cooli_card.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  VehicleType _selectedType = VehicleType.miniTruck;
  String _fuelType = 'Diesel';
  final _modelController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _capacityController = TextEditingController(text: '1.5 Ton');
  final _rcController = TextEditingController();

  @override
  void dispose() {
    _modelController.dispose();
    _regNumberController.dispose();
    _capacityController.dispose();
    _rcController.dispose();
    super.dispose();
  }

  void _onSaveVehicle() async {
    final model = _modelController.text.trim();
    final reg = _regNumberController.text.trim();
    final cap = _capacityController.text.trim();

    if (model.isEmpty || reg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete model name and registration number.')),
      );
      return;
    }

    final newVeh = Vehicle(
      id: 'veh-${DateTime.now().millisecondsSinceEpoch % 10000}',
      partnerId: 'CP10245',
      type: _selectedType,
      makeModel: model,
      registrationNumber: reg.toUpperCase(),
      capacity: cap,
      fuelType: _fuelType,
      verificationState: VehicleVerificationState.pending,
      rcNumber: _rcController.text.trim().isEmpty ? 'KL07TEMP${DateTime.now().millisecond}' : _rcController.text.trim(),
      insuranceExpiry: DateTime.now().add(const Duration(days: 365)),
      fitnessExpiry: DateTime.now().add(const Duration(days: 730)),
    );

    final success = await ref.read(vehicleNotifierProvider.notifier).addVehicle(newVeh);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle added successfully! Submitted for RTO verification.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: BackHeader(
        title: 'Add New Vehicle',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vehicle Category',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder, width: 1.2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<VehicleType>(
                    isExpanded: true,
                    value: _selectedType,
                    items: VehicleType.values.map((v) {
                      String label;
                      switch (v) {
                        case VehicleType.miniTruck:
                          label = 'Mini Truck (Tata Ace, Dost)';
                          break;
                        case VehicleType.pickupTruck:
                          label = 'Pickup Truck (Mahindra Bolero)';
                          break;
                        case VehicleType.heavyTruck:
                          label = 'Heavy Commercial Truck (10-16 Ton)';
                          break;
                        case VehicleType.auto:
                          label = '3-Wheeler Cargo Auto';
                          break;
                        case VehicleType.bike:
                          label = '2-Wheeler Delivery Bike';
                          break;
                        case VehicleType.container:
                          label = 'Closed Container Truck';
                          break;
                      }
                      return DropdownMenuItem(value: v, child: Text(label, style: AppTextStyles.body));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              CooliTextField(
                controller: _modelController,
                label: 'Make & Model Name',
                hintText: 'e.g. Tata Ace Gold, Bolero Maxi Truck',
                prefixIcon: const Icon(Icons.local_shipping_outlined),
              ),
              const SizedBox(height: 16),

              CooliTextField(
                controller: _regNumberController,
                label: 'Registration Number',
                hintText: 'e.g. KL 07 AB 1234',
                prefixIcon: const Icon(Icons.confirmation_number_outlined),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CooliTextField(
                      controller: _capacityController,
                      label: 'Payload Capacity',
                      hintText: 'e.g. 1.5 Ton, 750 kg',
                      prefixIcon: const Icon(Icons.scale_rounded),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fuel Type',
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 54,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder, width: 1.2),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _fuelType,
                              items: ['Diesel', 'EV', 'CNG', 'Petrol'].map((f) {
                                return DropdownMenuItem(value: f, child: Text(f, style: AppTextStyles.body));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _fuelType = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CooliTextField(
                controller: _rcController,
                label: 'RC Book Number',
                hintText: 'e.g. KL07AB12349012',
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
              const SizedBox(height: 24),

              CooliCard(
                backgroundColor: const Color(0xFFEFF6FF),
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'After adding your vehicle, please upload scanned RC & Insurance copies from the Documents dashboard.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.primaryBlue, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              CooliPrimaryButton(
                label: 'REGISTER VEHICLE',
                icon: Icons.check_circle_rounded,
                onPressed: _onSaveVehicle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
