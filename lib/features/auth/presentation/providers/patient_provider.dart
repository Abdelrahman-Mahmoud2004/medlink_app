import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../patient/data/models/booking_model.dart';
import '../../../patient/data/models/notification_model.dart';
import '../../../patient/data/models/payment_method_model.dart';

// -----------------------------------------------------------------------------
// Patient Profile
// -----------------------------------------------------------------------------

class PatientProfile {
  final String name;
  final String email;
  final String phone;
  final String imageUrl;
  final int totalBookings;
  final int upcomingBookings;

  const PatientProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.imageUrl,
    required this.totalBookings,
    required this.upcomingBookings,
  });
}

final patientProfileProvider = Provider<PatientProfile>((ref) {
  return const PatientProfile(
    name: 'Fatima Zahra',
    email: 'fatima@example.com',
    phone: '+20 1012345678',
    imageUrl: 'https://i.pravatar.cc/150?img=49',
    totalBookings: 12,
    upcomingBookings: 2,
  );
});

// -----------------------------------------------------------------------------
// Bookings
// -----------------------------------------------------------------------------

final allBookingsProvider = Provider<List<BookingModel>>((ref) {
  return [
    BookingModel(
      id: '1',
      nurseName: 'Sara Ahmed',
      nurseImage: 'https://i.pravatar.cc/150?img=11',
      serviceType: 'Post-Surgery Care',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      address: 'Cairo, Egypt',
      status: 'confirmed',
      amount: 250.0,
      specialty: 'ICU Specialist',
    ),
    BookingModel(
      id: '2',
      nurseName: 'Layla Mahmoud',
      nurseImage: 'https://i.pravatar.cc/150?img=5',
      serviceType: 'Home Care',
      dateTime: DateTime.now().add(const Duration(days: 3)),
      address: 'Giza, Egypt',
      status: 'pending',
      amount: 180.0,
      specialty: 'Pediatric Nurse',
    ),
    BookingModel(
      id: '3',
      nurseName: 'Fatima Al-Sayed',
      nurseImage: 'https://i.pravatar.cc/150?img=1',
      serviceType: 'ICU Care',
      dateTime: DateTime.now().subtract(const Duration(days: 10)),
      address: 'Cairo, Egypt',
      status: 'completed',
      amount: 320.0,
      specialty: 'ICU Specialist',
    ),
    BookingModel(
      id: '4',
      nurseName: 'Ahmed Hassan',
      nurseImage: 'https://i.pravatar.cc/150?img=3',
      serviceType: 'Geriatric Care',
      dateTime: DateTime.now().subtract(const Duration(days: 20)),
      address: 'Giza, Egypt',
      status: 'cancelled',
      amount: 200.0,
      specialty: 'Geriatric Care',
    ),
  ];
});

final upcomingBookingsProvider = Provider<List<BookingModel>>((ref) {
  final bookings = ref.watch(allBookingsProvider);

  return bookings.where((booking) => booking.isActive).toList();
});

// -----------------------------------------------------------------------------
// Notifications
// -----------------------------------------------------------------------------

class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationsNotifier() : super(_mockNotifications);

  void markAsRead(String id) {
    state = state.map((notification) {
      if (notification.id == id) {
        return notification.copyWith(isRead: true);
      }

      return notification;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((notification) {
      return notification.copyWith(isRead: true);
    }).toList();
  }

  void delete(String id) {
    state = state.where((notification) => notification.id != id).toList();
  }

  void clearAll() {
    state = const [];
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
  (ref) => NotificationsNotifier(),
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((item) => !item.isRead).length;
});

final List<NotificationModel> _mockNotifications = [
  NotificationModel(
    id: '1',
    type: NotificationType.booking,
    title: 'Booking Confirmed',
    body: 'Your booking with Sara Ahmed is confirmed.',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  NotificationModel(
    id: '2',
    type: NotificationType.payment,
    title: 'Payment Successful',
    body: 'Your payment of EGP 250 was processed successfully.',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  NotificationModel(
    id: '3',
    type: NotificationType.reminder,
    title: 'Appointment Tomorrow',
    body: 'Reminder: Sara Ahmed will visit tomorrow at 10:00 AM.',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
  ),
  NotificationModel(
    id: '4',
    type: NotificationType.system,
    title: 'Welcome to MedLink!',
    body: 'Start by browsing available nurses in your area.',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    isRead: true,
  ),
];

// -----------------------------------------------------------------------------
// Saved Payment Methods
// -----------------------------------------------------------------------------

class SavedCardsNotifier extends StateNotifier<List<SavedCard>> {
  SavedCardsNotifier() : super(_mockSavedCards);

  void addCard(SavedCard card) {
    state = [
      ...state,
      card,
    ];
  }

  void removeCard(String id) {
    state = state.where((card) => card.id != id).toList();
  }

  void setDefault(String id) {
    state = state.map((card) {
      return card.copyWith(isDefault: card.id == id);
    }).toList();
  }
}

final savedCardsProvider =
    StateNotifierProvider<SavedCardsNotifier, List<SavedCard>>(
  (ref) => SavedCardsNotifier(),
);

const List<SavedCard> _mockSavedCards = [
  SavedCard(
    id: '1',
    last4: '4242',
    brand: 'Visa',
    expiry: '12/26',
    isDefault: true,
  ),
  SavedCard(
    id: '2',
    last4: '5555',
    brand: 'MasterCard',
    expiry: '08/25',
  ),
];