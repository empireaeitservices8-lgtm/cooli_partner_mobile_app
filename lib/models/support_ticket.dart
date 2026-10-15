enum SupportTicketStatus {
  open,
  inProgress,
  resolved,
  closed,
}

enum SupportCategory {
  account,
  jobs,
  payments,
  vehicle,
  documents,
  technical,
}

class SupportMessage {
  final String id;
  final String sender; // 'user' or 'support'
  final String text;
  final DateTime timestamp;

  const SupportMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
  });
}

class SupportTicket {
  final String id;
  final String ticketNumber; // e.g. "TCK-84920"
  final String subject;
  final SupportCategory category;
  final SupportTicketStatus status;
  final List<SupportMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupportTicket({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    required this.category,
    required this.status,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });
}
