import '../models/models.dart';
import '../services/mock_data.dart';

abstract class DocumentRepository {
  Future<List<PartnerDocument>> getDocuments();
  Future<PartnerDocument> uploadDocument({
    required DocumentType type,
    required String title,
    required String documentNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
  });
}

class MockDocumentRepository implements DocumentRepository {
  final List<PartnerDocument> _docs = List.from(MockData.documents);

  @override
  Future<List<PartnerDocument>> getDocuments() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.from(_docs);
  }

  @override
  Future<PartnerDocument> uploadDocument({
    required DocumentType type,
    required String title,
    required String documentNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newDoc = PartnerDocument(
      id: 'doc-${DateTime.now().millisecondsSinceEpoch % 10000}',
      partnerId: MockData.currentPartner.id,
      type: type,
      title: title,
      documentNumber: documentNumber,
      status: DocumentStatus.pending,
      issueDate: issueDate,
      expiryDate: expiryDate,
      updatedAt: DateTime.now(),
    );

    final existingIndex = _docs.indexWhere((d) => d.type == type);
    if (existingIndex != -1) {
      _docs[existingIndex] = newDoc;
    } else {
      _docs.add(newDoc);
    }
    return newDoc;
  }
}
