/// Centralized API Endpoints for COOLI Driver & Partner Backend
class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://cooliedriver.pythonanywhere.com';

  // Authentication
  static const String registerDriver = '/api/register/driver/';
  static const String sendOtp = '/api/send-otp/';
  static const String verifyOtp = '/api/verify-otp/';
  static const String checkApprovalStatus = '/api/check-approval-status/';
  static const String refreshToken = '/api/token/refresh/';
  static String approveDriver(dynamic driverId) =>
      '/api/admin/drivers/$driverId/approve/';
  static String rejectDriver(dynamic driverId) =>
      '/api/admin/drivers/$driverId/reject/';

  // Driver Management
  static const String drivers = '/api/drivers/';
  static String driverById(dynamic id) => '/api/drivers/$id/';
  static const String updateLocation = '/api/drivers/update_location/';
  static const String toggleOnline = '/api/drivers/toggle_online/';
  static const String driverDashboard = '/api/drivers/dashboard/';
  static String matchDrivers(dynamic bookingId) =>
      '/api/drivers/match_drivers/?booking_id=$bookingId';

  // Vehicle Management
  static const String vehicles = '/api/vehicles/';
  static const String rideVehicleTypes = '/api/ride/vehicle-types/';
  static String vehicleById(dynamic id) => '/api/vehicles/$id/';
  static String updateVehicleStatus(dynamic id) =>
      '/api/vehicles/$id/update_status/';

  // Booking Management
  static const String pendingBookings = '/api/bookings/pending_requests/';
  static const String bookings = '/api/bookings/';
  static String bookingById(dynamic id) => '/api/bookings/$id/';
  static String acceptBooking(dynamic id) => '/api/bookings/$id/accept/';
  static String rejectBooking(dynamic id) => '/api/bookings/$id/reject/';
  static String updateBookingStatus(dynamic id) =>
      '/api/bookings/$id/update_status/';

  // Trip Management
  static const String trips = '/api/trips/';
  static String tripById(dynamic id) => '/api/trips/$id/';
  static String updateTripStatus(dynamic id) => '/api/trips/$id/update_status/';
  static String uploadPod(dynamic id) => '/api/trips/$id/upload_pod/';

  // Earnings & Wallet
  static const String earnings = '/api/earnings/';
  static const String earningsSummary = '/api/earnings/summary/';
  static const String myWallet = '/api/wallets/my_wallet/';
  static const String withdrawWallet = '/api/wallets/withdraw/';
  static const String walletTransactions = '/api/wallet-transactions/';

  // Notifications
  static const String notifications = '/api/notifications/';
  static String markNotificationRead(dynamic id) =>
      '/api/notifications/$id/mark_read/';
  static const String markAllNotificationsRead =
      '/api/notifications/mark_all_read/';

  // Load & Quotations
  static const String loads = '/api/loads/';
  static String searchLoads({
    required String pickup,
    required String delivery,
    required String vehicleType,
  }) =>
      '/api/loads/search/?pickup_location=${Uri.encodeComponent(pickup)}&delivery_location=${Uri.encodeComponent(delivery)}&vehicle_type=${Uri.encodeComponent(vehicleType)}';
  static const String quotations = '/api/quotations/';
  static String acceptQuotation(dynamic id) => '/api/quotations/$id/accept/';

  // Support Tickets
  static const String supportTickets = '/api/support-tickets/';
  static String supportTicketById(dynamic id) => '/api/support-tickets/$id/';

  // Ratings
  static const String ratings = '/api/ratings/';

  // Fleet Management
  static const String fleetManagement = '/api/fleet-management/';
  static const String myFleet = '/api/fleet-management/my_fleet/';
  static String assignDriverToVehicle(dynamic id) =>
      '/api/fleet-management/$id/assign_driver/';

  // Commission & Cancellation & Offers
  static const String commissionConfig = '/api/commission-config/';
  static String activeCommissionConfig(String serviceType) =>
      '/api/commission-config/active_config/?service_type=$serviceType';
  static const String cancellationRules = '/api/cancellation-rules/';
  static String calculateCancellationCharge({
    required String serviceType,
    required String cancellerType,
    required dynamic fareAmount,
  }) =>
      '/api/cancellation-rules/calculate_charge/?service_type=$serviceType&canceller_type=$cancellerType&fare_amount=$fareAmount';
  static const String offers = '/api/offers/';
  static const String activeOffers = '/api/offers/active_offers/';
  static const String validatePromo = '/api/offers/validate_promo/';
}
