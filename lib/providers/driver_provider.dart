import 'package:flutter/foundation.dart';

enum DriverDutyStatus { offline, goingOnline, online }

class DriverProvider extends ChangeNotifier {
  DriverDutyStatus _status = DriverDutyStatus.online;
  int _todayEarnings = 2480;
  int _completedTrips = 12;
  String _onlineHours = '7h 20m';
  bool _rideEnabled = true;
  bool _porterEnabled = true;
  bool _truckEnabled = false;

  // Getters
  DriverDutyStatus get status => _status;
  bool get isOnline => _status == DriverDutyStatus.online;
  int get todayEarnings => _todayEarnings;
  int get completedTrips => _completedTrips;
  String get onlineHours => _onlineHours;
  bool get rideEnabled => _rideEnabled;
  bool get porterEnabled => _porterEnabled;
  bool get truckEnabled => _truckEnabled;

  // Toggle duty state with simulated GPS initialization
  void toggleDuty() {
    if (_status == DriverDutyStatus.online) {
      _status = DriverDutyStatus.offline;
      notifyListeners();
    } else {
      _status = DriverDutyStatus.goingOnline;
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 600), () {
        _status = DriverDutyStatus.online;
        notifyListeners();
      });
    }
  }

  void addEarnings(int amount) {
    _todayEarnings += amount;
    _completedTrips += 1;
    notifyListeners();
  }

  void toggleService(String serviceType) {
    if (serviceType == 'ride') _rideEnabled = !_rideEnabled;
    if (serviceType == 'porter') _porterEnabled = !_porterEnabled;
    if (serviceType == 'truck') _truckEnabled = !_truckEnabled;
    notifyListeners();
  }
}
