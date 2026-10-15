import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/cooli_bottom_navigation.dart';
import 'driver_home_screen.dart';
import '../../jobs/screens/jobs_dashboard_screen.dart';
import '../../earnings/screens/earnings_dashboard_screen.dart';
import '../../vehicles/screens/vehicles_list_screen.dart';
import '../../profile/screens/profile_screen.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const MainShellScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  final List<Widget> _pages = const [
    DriverHomeScreen(),
    JobsDashboardScreen(),
    EarningsDashboardScreen(),
    VehiclesListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CooliBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      extendBody: true,
    );
  }
}
