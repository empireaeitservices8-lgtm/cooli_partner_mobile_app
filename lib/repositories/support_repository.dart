import '../models/models.dart';
import '../services/mock_data.dart';

abstract class SupportRepository {
  Future<List<SupportTicket>> getTickets();
  Future<SupportTicket> createTicket(String subject, SupportCategory category, String message);
  Future<SupportTicket> replyToTicket(String ticketId, String message);
}

class MockSupportRepository implements SupportRepository {
  final List<SupportTicket> _tickets = List.from(MockData.supportTickets);

  @override
  Future<List<SupportTicket>> getTickets() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_tickets);
  }

  @override
  Future<SupportTicket> createTicket(String subject, SupportCategory category, String message) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newTicket = SupportTicket(
      id: 'tck-${DateTime.now().millisecondsSinceEpoch % 10000}',
      ticketNumber: 'TCK-${(DateTime.now().millisecondsSinceEpoch % 90000) + 10000}',
      subject: subject,
      category: category,
      status: SupportTicketStatus.open,
      messages: [
        SupportMessage(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
          sender: 'user',
          text: message,
          timestamp: DateTime.now(),
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _tickets.insert(0, newTicket);
    return newTicket;
  }

  @override
  Future<SupportTicket> replyToTicket(String ticketId, String message) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      final ticket = _tickets[index];
      final updatedMessages = List<SupportMessage>.from(ticket.messages)
        ..add(SupportMessage(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
          sender: 'user',
          text: message,
          timestamp: DateTime.now(),
        ));
      final updatedTicket = SupportTicket(
        id: ticket.id,
        ticketNumber: ticket.ticketNumber,
        subject: ticket.subject,
        category: ticket.category,
        status: SupportTicketStatus.inProgress,
        messages: updatedMessages,
        createdAt: ticket.createdAt,
        updatedAt: DateTime.now(),
      );
      _tickets[index] = updatedTicket;
      return updatedTicket;
    }
    throw Exception('Ticket not found');
  }
}
