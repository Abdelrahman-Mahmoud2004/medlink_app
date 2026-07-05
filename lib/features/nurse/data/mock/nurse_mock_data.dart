import 'package:medlink_app/features/patient/data/models/earning_model.dart';
import 'package:medlink_app/features/patient/data/models/request_model.dart';

/// Single source of truth for this feature's placeholder data.
///
/// The original screens each had their own `_initializeDummyData()` with
/// copy-pasted entries — the earnings list, for example, was duplicated
/// verbatim between the home screen and the wallet screen. Centralizing it
/// here means every screen shows consistent numbers, and swapping this for
/// a real repository later only touches one file.
class NurseMockData {
  NurseMockData._();

  static final DateTime _today = DateTime.now();

  static DateTime _at(int hour, int minute, [int dayOffset = 0]) {
    final d = _today.add(Duration(days: dayOffset));
    return DateTime(d.year, d.month, d.day, hour, minute);
  }

  static final RequestModel scheduledBloodTest = RequestModel(
    id: 'req_3',
    patientName: 'Mariam Hassan',
    patientImage: 'https://via.placeholder.com/150',
    serviceType: 'Blood Sample Collection',
    specialty: 'Blood Tests',
    calculatedPay: 120.0,
    distance: 0.9,
    duration: 0.5,
    status: RequestStatus.scheduled,
    requestedTime: _at(10, 0),
    location: 'Giza, Dokki',
    notes: 'Fasting blood test',
  );

  /// Requests shown on the nurse home dashboard.
  static List<RequestModel> get activeRequests => [
        RequestModel(
          id: 'req_1',
          patientName: 'Amira El-Sayed',
          patientImage: 'https://via.placeholder.com/150',
          serviceType: 'Post-Surgery Care',
          specialty: 'Post-Surgery Care',
          calculatedPay: 250.0,
          distance: 2.8,
          duration: 1.5,
          status: RequestStatus.active,
          requestedTime: _today,
          location: 'Giza, Al Haram',
          notes: 'Patient needs post-op wound care',
        ),
        RequestModel(
          id: 'req_2',
          patientName: 'Khaled Ibrahim',
          patientImage: 'https://via.placeholder.com/150',
          serviceType: 'Physiotherapy Session',
          specialty: 'Physiotherapy',
          calculatedPay: 400.0,
          distance: 4.2,
          duration: 2.0,
          status: RequestStatus.active,
          requestedTime: _today,
          location: 'Cairo, Downtown',
          notes: 'Needs shoulder mobility exercises',
        ),
        scheduledBloodTest,
      ];

  /// Requests shown in "My Schedule" for today.
  static List<RequestModel> get todaysAppointments => [
        scheduledBloodTest,
        RequestModel(
          id: 'req_4',
          patientName: 'Omar Hassan',
          patientImage: 'https://via.placeholder.com/150',
          serviceType: 'Routine Checkup',
          specialty: 'Home Care',
          calculatedPay: 180.0,
          distance: 2.1,
          duration: 1.0,
          status: RequestStatus.scheduled,
          requestedTime: _at(14, 30),
          location: 'Cairo, Helwan',
          notes: 'Regular health checkup',
        ),
      ];

  /// Calendar marker events, keyed by day at midnight. table_calendar always
  /// looks days up this way (see AppDateFormatters.dateOnly) — un-normalized
  /// keys here would simply never match, which is why the markers never
  /// used to show up.
  static Map<DateTime, List<String>> get calendarEvents {
    DateTime d(int offset) {
      final date = _today.add(Duration(days: offset));
      return DateTime(date.year, date.month, date.day);
    }

    return {
      d(0): const ['Blood Test - 10:00 AM', 'Checkup - 2:30 PM'],
      d(1): const ['Surgery Care - 9:00 AM'],
      d(3): const ['Physiotherapy - 11:00 AM', 'Wound Care - 3:00 PM'],
    };
  }

  /// All earnings — completed, pending, and (eventually) withdrawn.
  static List<EarningModel> get earnings => [
        EarningModel(
          id: 'earn_1',
          description: 'Mr. Ahmed - Home Visit',
          amount: 800.0,
          serviceCharge: 680.0,
          platformFee: 120.0,
          netAmount: 680.0,
          date: _today.subtract(const Duration(days: 1)),
          status: EarningStatus.completed,
        ),
        EarningModel(
          id: 'earn_2',
          description: 'Mrs. Smith - Wound Care',
          amount: 1200.0,
          serviceCharge: 1020.0,
          platformFee: 180.0,
          netAmount: 1020.0,
          date: _today.subtract(const Duration(days: 2)),
          status: EarningStatus.completed,
        ),
        EarningModel(
          id: 'earn_3',
          description: 'Ahmed Mansour - Routine Checkup',
          amount: 450.0,
          serviceCharge: 382.5,
          platformFee: 67.5,
          netAmount: 382.5,
          date: _today.subtract(const Duration(days: 3)),
          status: EarningStatus.completed,
        ),
        EarningModel(
          id: 'earn_4',
          description: 'Physiotherapy Session',
          amount: 600.0,
          serviceCharge: 510.0,
          platformFee: 90.0,
          netAmount: 510.0,
          date: _today,
          status: EarningStatus.pending,
        ),
      ];

  // Dashboard summary numbers. In production these should come from a
  // backend aggregation endpoint rather than being hand-maintained here.
  static const double dailyEarnings = 1450.0;
  static const int completedVisits = 142;
  static const double rating = 4.9;
  static const double totalEarnings = 45230.0;
  static const double availableBalance = 15670.0;
  static const double pendingBalance = 5430.0;
}