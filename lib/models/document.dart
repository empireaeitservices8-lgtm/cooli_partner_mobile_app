enum DocumentType {
  drivingLicense,
  rcBook,
  insurancePolicy,
  permit,
  fitnessCertificate,
  pollutionCertificate,
  aadhaarCard,
  panCard,
}

enum DocumentStatus {
  verified,
  pending,
  rejected,
  expired,
}

class PartnerDocument {
  final String id;
  final String partnerId;
  final DocumentType type;
  final String title;
  final String documentNumber;
  final DocumentStatus status;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? frontImageUrl;
  final String? backImageUrl;
  final String? rejectionReason;
  final DateTime updatedAt;

  const PartnerDocument({
    required this.id,
    required this.partnerId,
    required this.type,
    required this.title,
    required this.documentNumber,
    required this.status,
    this.issueDate,
    this.expiryDate,
    this.frontImageUrl,
    this.backImageUrl,
    this.rejectionReason,
    required this.updatedAt,
  });

  String get typeName {
    switch (type) {
      case DocumentType.drivingLicense:
        return 'Driving License';
      case DocumentType.rcBook:
        return 'Vehicle RC Book';
      case DocumentType.insurancePolicy:
        return 'Vehicle Insurance';
      case DocumentType.permit:
        return 'Commercial Goods Permit';
      case DocumentType.fitnessCertificate:
        return 'Fitness Certificate (FC)';
      case DocumentType.pollutionCertificate:
        return 'Pollution Under Control (PUC)';
      case DocumentType.aadhaarCard:
        return 'Aadhaar Card';
      case DocumentType.panCard:
        return 'PAN Card';
    }
  }

  PartnerDocument copyWith({
    String? id,
    String? partnerId,
    DocumentType? type,
    String? title,
    String? documentNumber,
    DocumentStatus? status,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? frontImageUrl,
    String? backImageUrl,
    String? rejectionReason,
    DateTime? updatedAt,
  }) {
    return PartnerDocument(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      type: type ?? this.type,
      title: title ?? this.title,
      documentNumber: documentNumber ?? this.documentNumber,
      status: status ?? this.status,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      frontImageUrl: frontImageUrl ?? this.frontImageUrl,
      backImageUrl: backImageUrl ?? this.backImageUrl,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
