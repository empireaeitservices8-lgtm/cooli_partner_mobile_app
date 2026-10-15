import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'app_providers.dart';

class DocumentState {
  final List<PartnerDocument> documents;
  final bool isLoading;
  final String? error;

  const DocumentState({
    this.documents = const [],
    this.isLoading = false,
    this.error,
  });

  DocumentState copyWith({
    List<PartnerDocument>? documents,
    bool? isLoading,
    String? error,
  }) {
    return DocumentState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DocumentNotifier extends StateNotifier<DocumentState> {
  final Ref ref;

  DocumentNotifier(this.ref) : super(const DocumentState()) {
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(documentRepositoryProvider);
      final docs = await repo.getDocuments();
      state = state.copyWith(documents: docs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Could not load documents.');
    }
  }

  Future<bool> uploadDocument({
    required DocumentType type,
    required String title,
    required String documentNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(documentRepositoryProvider).uploadDocument(
            type: type,
            title: title,
            documentNumber: documentNumber,
            issueDate: issueDate,
            expiryDate: expiryDate,
          );
      await loadDocuments();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Upload failed.');
      return false;
    }
  }
}

final documentNotifierProvider = StateNotifierProvider<DocumentNotifier, DocumentState>((ref) {
  return DocumentNotifier(ref);
});
