library;

/// Booking and Trip API Models matching CoolieDriver Backend

class BookingApiModel {
  final dynamic id;
  final String status;
  final String pickupLocation;
  final String deliveryLocation;
  final double? pickupLat;
  final double? pickupLng;
  final double? deliveryLat;
  final double? deliveryLng;
  final double fareAmount;
  final String customerName;
  final String customerPhone;
  final String? createdAt;
  final Map<String, dynamic>? raw;

  BookingApiModel({
    this.id,
    required this.status,
    required this.pickupLocation,
    required this.deliveryLocation,
    this.pickupLat,
    this.pickupLng,
    this.deliveryLat,
    this.deliveryLng,
    this.fareAmount = 0.0,
    this.customerName = '',
    this.customerPhone = '',
    this.createdAt,
    this.raw,
  });

  factory BookingApiModel.fromJson(Map<String, dynamic> json) {
    return BookingApiModel(
      id: json['id'],
      status: json['status']?.toString() ?? 'pending',
      pickupLocation: json['pickup_location']?.toString() ?? json['pickup_address']?.toString() ?? 'Pickup Location',
      deliveryLocation: json['delivery_location']?.toString() ?? json['drop_address']?.toString() ?? 'Delivery Location',
      pickupLat: json['pickup_lat'] != null ? double.tryParse(json['pickup_lat'].toString()) : null,
      pickupLng: json['pickup_lng'] != null ? double.tryParse(json['pickup_lng'].toString()) : null,
      deliveryLat: json['delivery_lat'] != null ? double.tryParse(json['delivery_lat'].toString()) : null,
      deliveryLng: json['delivery_lng'] != null ? double.tryParse(json['delivery_lng'].toString()) : null,
      fareAmount: double.tryParse(json['fare_amount']?.toString() ?? json['fare']?.toString() ?? '0.0') ?? 0.0,
      customerName: json['customer_name']?.toString() ?? json['customer']?.toString() ?? 'Customer',
      customerPhone: json['customer_phone']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'status': status,
        'pickup_location': pickupLocation,
        'delivery_location': deliveryLocation,
        'fare_amount': fareAmount,
        'customer_name': customerName,
        'customer_phone': customerPhone,
      };
}

class TripApiModel {
  final dynamic id;
  final dynamic bookingId;
  final String status;
  final double? currentLat;
  final double? currentLng;
  final double distanceTravelled;
  final double remainingDistance;
  final String? deliveryPhoto;
  final String? invoiceDocument;
  final String? lrDocument;
  final String? receiverSignature;
  final String? otpConfirmation;
  final Map<String, dynamic>? raw;

  TripApiModel({
    this.id,
    this.bookingId,
    required this.status,
    this.currentLat,
    this.currentLng,
    this.distanceTravelled = 0.0,
    this.remainingDistance = 0.0,
    this.deliveryPhoto,
    this.invoiceDocument,
    this.lrDocument,
    this.receiverSignature,
    this.otpConfirmation,
    this.raw,
  });

  factory TripApiModel.fromJson(Map<String, dynamic> json) {
    return TripApiModel(
      id: json['id'],
      bookingId: json['booking'] ?? json['booking_id'],
      status: json['status']?.toString() ?? 'started',
      currentLat: json['current_lat'] != null ? double.tryParse(json['current_lat'].toString()) : null,
      currentLng: json['current_lng'] != null ? double.tryParse(json['current_lng'].toString()) : null,
      distanceTravelled: double.tryParse(json['distance_travelled']?.toString() ?? '0.0') ?? 0.0,
      remainingDistance: double.tryParse(json['remaining_distance']?.toString() ?? '0.0') ?? 0.0,
      deliveryPhoto: json['delivery_photo']?.toString(),
      invoiceDocument: json['invoice_document']?.toString(),
      lrDocument: json['lr_document']?.toString(),
      receiverSignature: json['receiver_signature']?.toString(),
      otpConfirmation: json['otp_confirmation']?.toString(),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'status': status,
        'current_lat': currentLat?.toString(),
        'current_lng': currentLng?.toString(),
        'distance_travelled': distanceTravelled.toString(),
        'remaining_distance': remainingDistance.toString(),
        if (deliveryPhoto != null) 'delivery_photo': deliveryPhoto,
        if (invoiceDocument != null) 'invoice_document': invoiceDocument,
        if (lrDocument != null) 'lr_document': lrDocument,
        if (receiverSignature != null) 'receiver_signature': receiverSignature,
        if (otpConfirmation != null) 'otp_confirmation': otpConfirmation,
      };
}
