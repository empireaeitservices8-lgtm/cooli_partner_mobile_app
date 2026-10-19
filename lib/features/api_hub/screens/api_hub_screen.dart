import 'dart:convert';
import 'package:cooli_partner/core/network/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_logger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/api/api_models.dart';
import '../view_model/api_hub_view_model.dart';

class ApiHubScreen extends ConsumerStatefulWidget {
  const ApiHubScreen({super.key});

  @override
  ConsumerState<ApiHubScreen> createState() => _ApiHubScreenState();
}

class _ApiHubScreenState extends ConsumerState<ApiHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for testing
  final _mobileController = TextEditingController(text: '9876543210');
  final _otpController = TextEditingController(text: '123456');
  final _usernameController = TextEditingController(text: 'driver_ravi');
  final _emailController =
      TextEditingController(text: 'ravi.driver@example.com');
  final _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiState = ref.watch(apiHubViewModelProvider);
    final viewModel = ref.read(apiHubViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'COOLI API LIVE HUB',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              ApiEndpoints.baseUrl,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white70, size: 20),
            tooltip: 'Refresh Profile & Dashboard',
            onPressed: () {
              viewModel.fetchDashboard();
              viewModel.fetchProfile();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryYellow,
          indicatorWeight: 3,
          labelColor: AppColors.primaryYellow,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.send_rounded, size: 18), text: 'API Calls'),
            Tab(
                icon: Icon(Icons.data_object_rounded, size: 18),
                text: 'Model State'),
            Tab(
                icon: Icon(Icons.terminal_rounded, size: 18),
                text: 'Console Logs'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Global Token & Status Header Bar
          _buildStatusBar(apiState, viewModel),

          // Main Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildApiCallsTab(apiState, viewModel),
                _buildModelStateTab(apiState),
                _buildConsoleLogsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(ApiHubState state, ApiHubViewModel viewModel) {
    final hasToken = state.accessToken != null && state.accessToken!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(bottom: BorderSide(color: Color(0xFF334155))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  hasToken ? const Color(0xFF065F46) : const Color(0xFF7F1D1D),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasToken
                      ? Icons.verified_user_rounded
                      : Icons.gpp_bad_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Text(
                  hasToken ? 'Bearer Active' : 'No Token',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => _showTokenDialog(context, viewModel),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Set Token',
              style: TextStyle(color: AppColors.primaryYellow, fontSize: 12),
            ),
          ),
          const Spacer(),
          // Online Toggle
          Row(
            children: [
              Text(
                state.isOnline ? 'ONLINE' : 'OFFLINE',
                style: TextStyle(
                  color:
                      state.isOnline ? const Color(0xFF10B981) : Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: state.isOnline,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (val) {
                    viewModel.toggleOnline(val);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApiCallsTab(ApiHubState state, ApiHubViewModel viewModel) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (state.isLoading)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3B82F6)),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Calling ${state.activeEndpoint}... Check Console!',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

        // Section: Authentication
        _buildSectionHeader('1. Authentication Endpoints', Icons.key_rounded),
        _buildActionCard(
          title: 'Send OTP',
          endpoint: 'POST /api/send-otp/',
          description: 'Requests an SMS OTP to mobile number',
          color: const Color(0xFF3B82F6),
          inputs: [
            _buildInputField('Mobile Number', _mobileController),
          ],
          onExecute: () {
            viewModel.sendOtp(mobile: _mobileController.text.trim());
            _tabController.animateTo(1);
          },
        ),

        _buildActionCard(
          title: 'Verify OTP (Login)',
          endpoint: 'POST /api/verify-otp/',
          description: 'Submits 6-digit OTP and retrieves Bearer Tokens',
          color: const Color(0xFF10B981),
          inputs: [
            _buildInputField('Mobile Number', _mobileController),
            _buildInputField('6-Digit OTP', _otpController),
          ],
          onExecute: () {
            viewModel.verifyOtp(
              mobile: _mobileController.text.trim(),
              otp: _otpController.text.trim(),
            );
            _tabController.animateTo(1);
          },
        ),

        _buildActionCard(
          title: 'Driver Registration',
          endpoint: 'POST /api/register/driver/',
          description: 'Registers new driver profile with KYC and bank info',
          color: const Color(0xFF8B5CF6),
          inputs: [
            _buildInputField('Username', _usernameController),
            _buildInputField('Email', _emailController),
          ],
          onExecute: () {
            final req = DriverRegisterRequest(
              username: _usernameController.text.trim(),
              email: _emailController.text.trim(),
              mobile: _mobileController.text.trim(),
              drivingLicence: 'https://cooli.in/docs/dl_sample.png',
              idProof: 'https://cooli.in/docs/aadhaar_sample.png',
              bankAccountNumber: '987654321001',
              bankName: 'HDFC Bank',
              ifscCode: 'HDFC0001234',
            );
            viewModel.registerDriver(req);
            _tabController.animateTo(1);
          },
        ),

        const SizedBox(height: 12),
        // Section: Driver Management
        _buildSectionHeader(
            '2. Driver Profile & Live Operations', Icons.person_rounded),
        _buildActionCard(
          title: 'Get Driver Profile',
          endpoint: 'GET /api/drivers/',
          description: 'Fetches verified profile details from server',
          color: const Color(0xFF0EA5E9),
          onExecute: () {
            viewModel.fetchProfile();
            _tabController.animateTo(1);
          },
        ),

        _buildActionCard(
          title: 'Update Location Ping',
          endpoint: 'POST /api/drivers/update_location/',
          description:
              'Broadcasts GPS lat/lng coordinates (Chennai / Kochi hub)',
          color: const Color(0xFF06B6D4),
          onExecute: () {
            viewModel.updateLocation(13.0827, 80.2707);
            _tabController.animateTo(1);
          },
        ),

        _buildActionCard(
          title: 'Driver Dashboard',
          endpoint: 'GET /api/drivers/dashboard/',
          description:
              'Fetches driver metrics, total trips, and pending counts',
          color: const Color(0xFFEC4899),
          onExecute: () {
            viewModel.fetchDashboard();
            _tabController.animateTo(1);
          },
        ),

        const SizedBox(height: 12),
        // Section: Vehicles
        _buildSectionHeader(
            '3. Fleet & Vehicles', Icons.local_shipping_rounded),
        _buildActionCard(
          title: 'Get All Vehicles',
          endpoint: 'GET /api/vehicles/',
          description: 'Lists all vehicles associated with driver account',
          color: const Color(0xFFF59E0B),
          onExecute: () {
            viewModel.fetchVehicles();
            _tabController.animateTo(1);
          },
        ),

        _buildActionCard(
          title: 'Add New Vehicle',
          endpoint: 'POST /api/vehicles/',
          description: 'Registers vehicle with RC and insurance details',
          color: const Color(0xFFD97706),
          onExecute: () {
            final veh = VehicleApiModel(
              vehicleNumber:
                  'KL07CD${DateTime.now().millisecondsSinceEpoch % 10000}',
              vehicleType: 'mini_truck',
              brand: 'Tata',
              model: 'Ace Gold',
              capacity: '1.2 Ton',
              fuelType: 'Diesel',
              rcDocument: 'https://cooli.in/docs/rc.pdf',
              insuranceDocument: 'https://cooli.in/docs/ins.pdf',
              fitnessCertificate: 'https://cooli.in/docs/fitness.pdf',
              status: 'available',
            );
            viewModel.addVehicle(veh);
            _tabController.animateTo(1);
          },
        ),

        const SizedBox(height: 12),
        // Section: Bookings & Trips
        _buildSectionHeader('4. Bookings & Trips', Icons.location_on_rounded),
        _buildActionCard(
          title: 'Pending Booking Requests',
          endpoint: 'GET /api/bookings/pending_requests/',
          description: 'Checks for new incoming rides & delivery dispatches',
          color: const Color(0xFF10B981),
          onExecute: () {
            viewModel.fetchPendingBookings();
            _tabController.animateTo(1);
          },
        ),

        _buildActionCard(
          title: 'Get All Trips',
          endpoint: 'GET /api/trips/',
          description: 'Fetches active and historic trips',
          color: const Color(0xFF6366F1),
          onExecute: () {
            viewModel.fetchTrips();
            _tabController.animateTo(1);
          },
        ),

        const SizedBox(height: 12),
        // Section: Wallet & Loads
        _buildSectionHeader('5. Wallet, Earnings & Loads',
            Icons.account_balance_wallet_rounded),
        _buildActionCard(
          title: 'Get Driver Wallet',
          endpoint: 'GET /api/wallets/my_wallet/',
          description: 'Queries live wallet balance and pending payouts',
          color: const Color(0xFF14B8A6),
          onExecute: () {
            viewModel.fetchWallet();
            _tabController.animateTo(1);
          },
        ),

        _buildActionCard(
          title: 'Get Marketplace Loads',
          endpoint: 'GET /api/loads/',
          description:
              'Lists open freight loads available for quotation bidding',
          color: const Color(0xFFF97316),
          onExecute: () {
            viewModel.fetchLoads();
            _tabController.animateTo(1);
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryYellow, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 3),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.primaryYellow),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String endpoint,
    required String description,
    required Color color,
    required VoidCallback onExecute,
    List<Widget> inputs = const [],
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Text(
                    endpoint.split(' ').first,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              endpoint,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            if (inputs.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...inputs,
            ],
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: onExecute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 14),
                label: const Text(
                  'Call API',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelStateTab(ApiHubState state) {
    String formattedJson = 'No API called yet. Run any API from the Calls tab.';
    if (state.lastData != null) {
      try {
        formattedJson =
            const JsonEncoder.withIndent('  ').convert(state.lastData);
      } catch (_) {
        formattedJson = state.lastData.toString();
      }
    } else if (state.errorMessage != null) {
      formattedJson = 'Error:\n${state.errorMessage}';
    }

    final isSuccess = state.lastStatusCode != null &&
        state.lastStatusCode! >= 200 &&
        state.lastStatusCode! < 300;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSuccess
                      ? const Color(0xFF065F46)
                      : (state.lastStatusCode != null
                          ? const Color(0xFF7F1D1D)
                          : const Color(0xFF334155)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  state.lastStatusCode != null
                      ? 'Status: ${state.lastStatusCode}'
                      : 'Idle',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (state.lastDurationMs != null)
                Text(
                  '⏱ ${state.lastDurationMs} ms',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy_rounded,
                    color: Colors.white70, size: 18),
                tooltip: 'Copy Payload',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: formattedJson));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Response copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Endpoint label
        if (state.activeEndpoint != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Endpoint: ${state.activeEndpoint}',
              style: TextStyle(
                color: AppColors.primaryYellow,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),

        // Code Viewer
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF020617),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: state.errorMessage != null
                  ? Colors.red.withOpacity(0.4)
                  : const Color(0xFF334155),
            ),
          ),
          child: SelectableText(
            formattedJson,
            style: TextStyle(
              color: state.errorMessage != null
                  ? const Color(0xFFF87171)
                  : const Color(0xFF38BDF8),
              fontSize: 12,
              fontFamily: 'monospace',
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConsoleLogsTab() {
    return ValueListenableBuilder<List<ApiLogEntry>>(
      valueListenable: ApiLogBuffer.logsNotifier,
      builder: (context, logs, child) {
        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.terminal_rounded,
                    size: 48, color: Colors.white.withOpacity(0.3)),
                const SizedBox(height: 12),
                const Text(
                  'No API Logs Captured Yet',
                  style: TextStyle(color: Colors.white60, fontSize: 15),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Make any request from the "API Calls" tab to see live logs.',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Controls bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  Text(
                    '${logs.length} Log Entries',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => ApiLogBuffer.clear(),
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 14, color: Colors.white70),
                    label: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Log items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return _buildLogCard(log);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogCard(ApiLogEntry log) {
    Color typeColor = const Color(0xFF3B82F6);
    IconData icon = Icons.arrow_outward_rounded;

    if (log.type == 'RESPONSE') {
      typeColor =
          log.isSuccess ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
      icon = Icons.arrow_downward_rounded;
    } else if (log.type == 'ERROR') {
      typeColor = const Color(0xFFEF4444);
      icon = Icons.error_outline_rounded;
    }

    String formattedPayload = '';
    if (log.body != null) {
      try {
        formattedPayload = const JsonEncoder.withIndent('  ').convert(log.body);
      } catch (_) {
        formattedPayload = log.body.toString();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: typeColor.withOpacity(0.3)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: typeColor, size: 16),
        ),
        title: Row(
          children: [
            Text(
              log.method,
              style: TextStyle(
                color: typeColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            if (log.statusCode != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${log.statusCode}',
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Spacer(),
            if (log.durationMs != null)
              Text(
                '${log.durationMs}ms',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
          ],
        ),
        subtitle: Text(
          log.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        children: [
          if (log.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Error: ${log.errorMessage}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          if (formattedPayload.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(6),
              ),
              child: SelectableText(
                formattedPayload,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showTokenDialog(BuildContext context, ApiHubViewModel viewModel) {
    final token = ref.read(apiHubViewModelProvider).accessToken ?? '';
    _tokenController.text = token;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Set Bearer Token',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste a valid JWT access token or use the Postman sample token for authenticated calls:',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tokenController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Postman sample token from collection
                _tokenController.text =
                    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzkxMjA0NjMxLCJpYXQiOjE3OTEyMDEwMzEsImp0aSI6ImM2YmVmOTFjNDE5NjRkZjE5MmRjZjIyYzUxOGM2MGRiIiwidXNlcl9pZCI6IjEifQ.K_h73ixQ-hfYyA1BqgkfLKotkqqyc7f95nO3omOe2-w';
              },
              child: Text(
                'Paste Postman Sample Token',
                style: TextStyle(color: AppColors.primaryYellow, fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.setManualToken(_tokenController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Bearer Token updated successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow),
            child:
                const Text('Save Token', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
