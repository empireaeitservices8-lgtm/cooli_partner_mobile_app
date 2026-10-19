library;

/// Wallet, Earnings, Loads, and Notifications API Models

class WalletApiModel {
  final dynamic id;
  final double balance;
  final String currency;
  final double totalWithdrawn;
  final Map<String, dynamic>? raw;

  WalletApiModel({
    this.id,
    this.balance = 0.0,
    this.currency = '₹',
    this.totalWithdrawn = 0.0,
    this.raw,
  });

  factory WalletApiModel.fromJson(Map<String, dynamic> json) {
    return WalletApiModel(
      id: json['id'],
      balance: double.tryParse(json['balance']?.toString() ?? '0.0') ?? 0.0,
      currency: json['currency']?.toString() ?? '₹',
      totalWithdrawn: double.tryParse(json['total_withdrawn']?.toString() ?? '0.0') ?? 0.0,
      raw: json,
    );
  }
}

class WalletTransactionModel {
  final dynamic id;
  final double amount;
  final String transactionType; // 'credit', 'debit', 'withdrawal'
  final String status; // 'completed', 'pending', 'failed'
  final String description;
  final String? createdAt;

  WalletTransactionModel({
    this.id,
    required this.amount,
    required this.transactionType,
    this.status = 'completed',
    this.description = '',
    this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'],
      amount: double.tryParse(json['amount']?.toString() ?? '0.0') ?? 0.0,
      transactionType: json['transaction_type']?.toString() ?? 'credit',
      status: json['status']?.toString() ?? 'completed',
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }
}

class EarningsSummaryModel {
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final double totalEarnings;
  final int completedTrips;

  EarningsSummaryModel({
    this.todayEarnings = 0.0,
    this.weeklyEarnings = 0.0,
    this.monthlyEarnings = 0.0,
    this.totalEarnings = 0.0,
    this.completedTrips = 0,
  });

  factory EarningsSummaryModel.fromJson(Map<String, dynamic> json) {
    return EarningsSummaryModel(
      todayEarnings: double.tryParse(json['today_earnings']?.toString() ?? json['today']?.toString() ?? '0.0') ?? 0.0,
      weeklyEarnings: double.tryParse(json['weekly_earnings']?.toString() ?? json['weekly']?.toString() ?? '0.0') ?? 0.0,
      monthlyEarnings: double.tryParse(json['monthly_earnings']?.toString() ?? json['monthly']?.toString() ?? '0.0') ?? 0.0,
      totalEarnings: double.tryParse(json['total_earnings']?.toString() ?? json['total']?.toString() ?? '0.0') ?? 0.0,
      completedTrips: int.tryParse(json['completed_trips']?.toString() ?? json['trips']?.toString() ?? '0') ?? 0,
    );
  }
}

class LoadApiModel {
  final dynamic id;
  final String pickupLocation;
  final double? pickupLat;
  final double? pickupLng;
  final String deliveryLocation;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? pickupDate;
  final String? deliveryDate;
  final String loadType;
  final String weight;
  final int quantity;
  final String vehicleRequirement;
  final String bodyType;
  final String? specialRequirements;
  final double expectedPrice;

  LoadApiModel({
    this.id,
    required this.pickupLocation,
    this.pickupLat,
    this.pickupLng,
    required this.deliveryLocation,
    this.deliveryLat,
    this.deliveryLng,
    this.pickupDate,
    this.deliveryDate,
    required this.loadType,
    required this.weight,
    this.quantity = 1,
    required this.vehicleRequirement,
    this.bodyType = 'Open',
    this.specialRequirements,
    this.expectedPrice = 0.0,
  });

  factory LoadApiModel.fromJson(Map<String, dynamic> json) {
    return LoadApiModel(
      id: json['id'],
      pickupLocation: json['pickup_location']?.toString() ?? '',
      pickupLat: json['pickup_lat'] != null ? double.tryParse(json['pickup_lat'].toString()) : null,
      pickupLng: json['pickup_lng'] != null ? double.tryParse(json['pickup_lng'].toString()) : null,
      deliveryLocation: json['delivery_location']?.toString() ?? '',
      deliveryLat: json['delivery_lat'] != null ? double.tryParse(json['delivery_lat'].toString()) : null,
      deliveryLng: json['delivery_lng'] != null ? double.tryParse(json['delivery_lng'].toString()) : null,
      pickupDate: json['pickup_date']?.toString(),
      deliveryDate: json['delivery_date']?.toString(),
      loadType: json['load_type']?.toString() ?? 'General Goods',
      weight: json['weight']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      vehicleRequirement: json['vehicle_requirement']?.toString() ?? '',
      bodyType: json['body_type']?.toString() ?? 'Open',
      specialRequirements: json['special_requirements']?.toString(),
      expectedPrice: double.tryParse(json['expected_price']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'pickup_location': pickupLocation,
        'pickup_lat': pickupLat?.toString(),
        'pickup_lng': pickupLng?.toString(),
        'delivery_location': deliveryLocation,
        'delivery_lat': deliveryLat?.toString(),
        'delivery_lng': deliveryLng?.toString(),
        'pickup_date': pickupDate,
        'delivery_date': deliveryDate,
        'load_type': loadType,
        'weight': weight,
        'quantity': quantity,
        'vehicle_requirement': vehicleRequirement,
        'body_type': bodyType,
        'special_requirements': specialRequirements,
        'expected_price': expectedPrice.toString(),
      };
}

class QuotationApiModel {
  final dynamic id;
  final dynamic loadId;
  final double quotedPrice;
  final String status;
  final String? createdAt;

  QuotationApiModel({
    this.id,
    required this.loadId,
    required this.quotedPrice,
    this.status = 'submitted',
    this.createdAt,
  });

  factory QuotationApiModel.fromJson(Map<String, dynamic> json) {
    return QuotationApiModel(
      id: json['id'],
      loadId: json['load'] ?? json['load_id'],
      quotedPrice: double.tryParse(json['quoted_price']?.toString() ?? '0.0') ?? 0.0,
      status: json['status']?.toString() ?? 'submitted',
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'load': loadId,
        'quoted_price': quotedPrice.toString(),
      };
}

class NotificationApiModel {
  final dynamic id;
  final String title;
  final String message;
  final bool isRead;
  final String? createdAt;

  NotificationApiModel({
    this.id,
    required this.title,
    required this.message,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    return NotificationApiModel(
      id: json['id'],
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? json['body']?.toString() ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at']?.toString(),
    );
  }
}
