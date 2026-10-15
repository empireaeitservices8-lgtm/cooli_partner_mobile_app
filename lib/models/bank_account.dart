class BankAccount {
  final String id;
  final String accountHolderName;
  final String bankName;
  final String accountNumber; // Masked for display: e.g. •••• 4521
  final String fullAccountNumber;
  final String ifscCode;
  final bool isVerified;
  final bool isPrimary;

  const BankAccount({
    required this.id,
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    required this.fullAccountNumber,
    required this.ifscCode,
    this.isVerified = true,
    this.isPrimary = true,
  });

  String get maskedDisplay {
    if (fullAccountNumber.length >= 4) {
      return '•••• ${fullAccountNumber.substring(fullAccountNumber.length - 4)}';
    }
    return accountNumber;
  }
}
