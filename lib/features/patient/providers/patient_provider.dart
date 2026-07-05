import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/booking_model.dart';
import '../data/models/notification_model.dart';
import '../data/models/payment_method_model.dart';

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

  PatientProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? imageUrl,
    int? totalBookings,
    int? upcomingBookings,
  }) {
    return PatientProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      totalBookings: totalBookings ?? this.totalBookings,
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
    );
  }
}

const PatientProfile _mockPatientProfile = PatientProfile(
  name: 'Fatima Zahra',
  email: 'fatima@example.com',
  phone: '+20 1012345678',
  imageUrl: 'https://i.pravatar.cc/150?img=49',
  totalBookings: 12,
  upcomingBookings: 2,
);

class PatientProfileNotifier extends StateNotifier<PatientProfile> {
  PatientProfileNotifier() : super(_mockPatientProfile);

  void updatePersonalInformation({
    required String name,
    required String email,
    required String phone,
  }) {
    final cleanName = name.trim();
    final cleanEmail = email.trim();
    final cleanPhone = phone.trim();

    final hasNoChanges = state.name == cleanName &&
        state.email == cleanEmail &&
        state.phone == cleanPhone;

    if (hasNoChanges) {
      return;
    }

    state = state.copyWith(
      name: cleanName,
      email: cleanEmail,
      phone: cleanPhone,
    );
  }

  void updateImageUrl(String imageUrl) {
    final cleanImageUrl = imageUrl.trim();

    if (state.imageUrl == cleanImageUrl) {
      return;
    }

    state = state.copyWith(
      imageUrl: cleanImageUrl,
    );
  }
}

final patientProfileProvider =
    StateNotifierProvider<PatientProfileNotifier, PatientProfile>(
  (ref) => PatientProfileNotifier(),
);
// -----------------------------------------------------------------------------
// Bookings
// -----------------------------------------------------------------------------

final List<BookingModel> _mockBookings = List.unmodifiable(
  _buildMockBookings(),
);

List<BookingModel> _buildMockBookings() {
  final now = DateTime.now();

  final bookings = [
    BookingModel(
      id: '1',
      nurseName: 'Sara Ahmed',
      nurseImage: 'https://i.pravatar.cc/150?img=11',
      serviceType: 'Post-Surgery Care',
      dateTime: now.add(const Duration(days: 1)),
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
      dateTime: now.add(const Duration(days: 3)),
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
      dateTime: now.subtract(const Duration(days: 10)),
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
      dateTime: now.subtract(const Duration(days: 20)),
      address: 'Giza, Egypt',
      status: 'cancelled',
      amount: 200.0,
      specialty: 'Geriatric Care',
    ),
  ];

  bookings.sort(_compareBookingsForDefaultView);

  return bookings;
}

final allBookingsProvider = Provider<List<BookingModel>>((ref) {
  return _mockBookings;
});

final upcomingBookingsProvider = Provider<List<BookingModel>>((ref) {
  final bookings = ref.watch(allBookingsProvider);

  final upcoming = bookings.where((booking) => booking.isActive).toList()
    ..sort(_compareBookingDateAscending);

  return List.unmodifiable(upcoming);
});

int _compareBookingsForDefaultView(BookingModel a, BookingModel b) {
  final aPriority = _bookingPriority(a);
  final bPriority = _bookingPriority(b);

  if (aPriority != bPriority) {
    return aPriority.compareTo(bPriority);
  }

  if (a.isActive && b.isActive) {
    return _compareBookingDateAscending(a, b);
  }

  return _compareBookingDateDescending(a, b);
}

int _bookingPriority(BookingModel booking) {
  if (booking.isActive) {
    return 0;
  }

  if (booking.isCompleted) {
    return 1;
  }

  if (booking.isCancelled) {
    return 2;
  }

  return 3;
}

int _compareBookingDateAscending(BookingModel a, BookingModel b) {
  final dateCompare = a.dateTime.compareTo(b.dateTime);

  if (dateCompare != 0) {
    return dateCompare;
  }

  return a.id.compareTo(b.id);
}

int _compareBookingDateDescending(BookingModel a, BookingModel b) {
  final dateCompare = b.dateTime.compareTo(a.dateTime);

  if (dateCompare != 0) {
    return dateCompare;
  }

  return a.id.compareTo(b.id);
}

// -----------------------------------------------------------------------------
// Notifications
// -----------------------------------------------------------------------------

class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationsNotifier() : super(_initialNotifications);

  void markAsRead(String id) {
    final index = state.indexWhere((notification) => notification.id == id);

    if (index == -1) {
      return;
    }

    final current = state[index];

    if (current.isRead) {
      return;
    }

    final updated = List<NotificationModel>.from(state);
    updated[index] = current.copyWith(isRead: true);

    state = List.unmodifiable(updated);
  }

  void markAllAsRead() {
    final hasUnread = state.any((notification) => !notification.isRead);

    if (!hasUnread) {
      return;
    }

    state = List.unmodifiable(
      state.map((notification) {
        if (notification.isRead) {
          return notification;
        }

        return notification.copyWith(isRead: true);
      }).toList(),
    );
  }

  void delete(String id) {
    final exists = state.any((notification) => notification.id == id);

    if (!exists) {
      return;
    }

    state = List.unmodifiable(
      state.where((notification) => notification.id != id).toList(),
    );
  }

  void restore(NotificationModel notification) {
    final exists = state.any((item) => item.id == notification.id);

    if (exists) {
      return;
    }

    final updated = [
      notification,
      ...state,
    ]..sort(_compareNotificationsNewestFirst);

    state = List.unmodifiable(updated);
  }

  void clearAll() {
    if (state.isEmpty) {
      return;
    }

    state = const [];
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
  (ref) => NotificationsNotifier(),
);

final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);

  var count = 0;

  for (final notification in notifications) {
    if (!notification.isRead) {
      count++;
    }
  }

  return count;
});

final List<NotificationModel> _initialNotifications = List.unmodifiable(
  _buildMockNotifications(),
);

List<NotificationModel> _buildMockNotifications() {
  final now = DateTime.now();

  final notifications = [
    NotificationModel(
      id: '1',
      type: NotificationType.booking,
      title: 'Booking Confirmed',
      body: 'Your booking with Sara Ahmed is confirmed.',
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: '2',
      type: NotificationType.payment,
      title: 'Payment Successful',
      body: 'Your payment of EGP 250 was processed successfully.',
      createdAt: now.subtract(const Duration(hours: 3)),
    ),
    NotificationModel(
      id: '3',
      type: NotificationType.reminder,
      title: 'Appointment Tomorrow',
      body: 'Reminder: Sara Ahmed will visit tomorrow at 10:00 AM.',
      createdAt: now.subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationModel(
      id: '4',
      type: NotificationType.system,
      title: 'Welcome to MedLink!',
      body: 'Start by browsing available nurses in your area.',
      createdAt: now.subtract(const Duration(days: 7)),
      isRead: true,
    ),
  ];

  notifications.sort(_compareNotificationsNewestFirst);

  return notifications;
}

int _compareNotificationsNewestFirst(
  NotificationModel a,
  NotificationModel b,
) {
  final dateCompare = b.createdAt.compareTo(a.createdAt);

  if (dateCompare != 0) {
    return dateCompare;
  }

  return a.id.compareTo(b.id);
}

// -----------------------------------------------------------------------------
// Saved Payment Methods
// -----------------------------------------------------------------------------

class SavedCardsNotifier extends StateNotifier<List<SavedCard>> {
  SavedCardsNotifier() : super(_mockSavedCards);

  void addCard(SavedCard card) {
    final exists = state.any((item) => item.id == card.id);

    if (exists) {
      return;
    }

    state = List.unmodifiable([
      ...state,
      card,
    ]);
  }

  void removeCard(String id) {
    final exists = state.any((card) => card.id == id);

    if (!exists) {
      return;
    }

    state = List.unmodifiable(
      state.where((card) => card.id != id).toList(),
    );
  }

  void setDefault(String id) {
    final exists = state.any((card) => card.id == id);

    if (!exists) {
      return;
    }

    final alreadyDefault = state.any(
      (card) => card.id == id && card.isDefault,
    );

    if (alreadyDefault) {
      return;
    }

    state = List.unmodifiable(
      state.map((card) {
        return card.copyWith(isDefault: card.id == id);
      }).toList(),
    );
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