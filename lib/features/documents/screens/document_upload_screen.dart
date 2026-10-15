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

class DocumentUploadScreen extends ConsumerStatefulWidget {
  final PartnerDocument? existingDocument;

  const DocumentUploadScreen({super.key, this.existingDocument});

  @override
  ConsumerState<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  late DocumentType _selectedType;
  late final TextEditingController _docNumberController;
  bool _hasFrontPhoto = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.existingDocument?.type ?? DocumentType.drivingLicense;
    _docNumberController = TextEditingController(
      text: widget.existingDocument?.documentNumber ?? '',
    );
    _hasFrontPhoto = widget.existingDocument != null;
  }

  @override
  void dispose() {
    _docNumberController.dispose();
    super.dispose();
  }

  void _onUpload() async {
    final docNum = _docNumberController.text.trim();
    if (docNum.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the document number.')),
      );
      return;
    }

    final success = await ref.read(documentNotifierProvider.notifier).uploadDocument(
          type: _selectedType,
          title: _selectedType.name,
          documentNumber: docNum,
          issueDate: DateTime.now().subtract(const Duration(days: 180)),
          expiryDate: DateTime.now().add(const Duration(days: 365 * 3)),
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document uploaded! Audit team will verify within 12 hours.'),
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
        title: widget.existingDocument != null ? 'Update Document' : 'Upload Document',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Category',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
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
                child: DropdownButton<DocumentType>(
                  isExpanded: true,
                  value: _selectedType,
                  items: DocumentType.values.map((d) {
                    String label;
                    switch (d) {
                      case DocumentType.drivingLicense:
                        label = 'Driving License (DL)';
                        break;
                      case DocumentType.rcBook:
                        label = 'Vehicle RC Book';
                        break;
                      case DocumentType.insurancePolicy:
                        label = 'Commercial Vehicle Insurance';
                        break;
                      case DocumentType.permit:
                        label = 'Commercial Goods Permit';
                        break;
                      case DocumentType.fitnessCertificate:
                        label = 'Fitness Certificate (FC)';
                        break;
                      case DocumentType.pollutionCertificate:
                        label = 'Pollution Under Control (PUC)';
                        break;
                      case DocumentType.aadhaarCard:
                        label = 'Aadhaar Card';
                        break;
                      case DocumentType.panCard:
                        label = 'PAN Card';
                        break;
                    }
                    return DropdownMenuItem(value: d, child: Text(label, style: AppTextStyles.body));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            CooliTextField(
              controller: _docNumberController,
              label: 'Document Identification Number',
              hintText: 'e.g. KL-07-2015-0049210',
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
            const SizedBox(height: 20),

            Text(
              'Document Scanned Image',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: () {
                setState(() {
                  _hasFrontPhoto = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document photo captured from camera.')),
                );
              },
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: _hasFrontPhoto ? const Color(0xFFF0FDF4) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _hasFrontPhoto ? AppColors.success : AppColors.cardBorder,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _hasFrontPhoto ? Icons.check_circle_rounded : Icons.add_a_photo_outlined,
                        size: 40,
                        color: _hasFrontPhoto ? AppColors.success : AppColors.primaryBlue,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _hasFrontPhoto ? 'Document Scanned & Ready' : 'Tap to Capture or Upload Document Front',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _hasFrontPhoto ? AppColors.success : AppColors.primaryBlue,
                        ),
                      ),
                      if (!_hasFrontPhoto) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Ensure all 4 corners and text are clearly visible.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            CooliCard(
              backgroundColor: const Color(0xFFEFF6FF),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.security_rounded, color: AppColors.primaryBlue, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'All uploaded documents are encrypted and cross-referenced with national transport databases.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            CooliPrimaryButton(
              label: 'SUBMIT FOR VERIFICATION',
              icon: Icons.upload_file_rounded,
              onPressed: _onUpload,
            ),
          ],
        ),
      ),
    );
  }
}
