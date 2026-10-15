import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/cooli_cards_specialized.dart';
import '../../../core/widgets/cooli_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

class DocumentsDashboardScreen extends ConsumerWidget {
  const DocumentsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docState = ref.watch(documentNotifierProvider);
    final docs = docState.documents;

    final verifiedCount = docs.where((d) => d.status == DocumentStatus.verified).length;
    final totalCount = docs.length;

    return AppScaffold(
      header: BackHeader(
        title: 'Document Compliance',
        onBack: () => context.pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryBlue),
            tooltip: 'Upload Document',
            onPressed: () => context.push('/documents/upload'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compliance Overview Card
            CooliCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.verified_user_rounded, color: AppColors.success, size: 30),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$verifiedCount of $totalCount Verified',
                          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'All mandatory commercial permits and licenses are active.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Text(
              'Required Partner Credentials',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            const SizedBox(height: 12),

            if (docState.isLoading)
              const LoadingState(message: 'Verifying credentials...')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  return CooliDocumentCard(
                    document: doc,
                    onUploadOrView: () {
                      context.push('/documents/upload', extra: doc);
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
