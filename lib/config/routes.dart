import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/constants.dart';
import '../config/strings.dart';
import '../config/theme.dart';

import '../features/auth/data/services/storage_service.dart';

import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/screens/role_selection_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/language_selection_screen.dart';
import '../features/auth/presentation/screens/permissions_screen.dart';
import '../features/auth/presentation/screens/nurse_verification_screen.dart';

import '../features/nurse/presentation/screens/earnings_analytics_screen.dart';
import '../features/nurse/presentation/screens/my_schedule_screen.dart';
import '../features/nurse/presentation/screens/nurse_home_screen.dart';
import '../features/nurse/presentation/screens/vital_signs_screen.dart';
import '../features/nurse/presentation/screens/wallet_screen.dart';

import '../features/nurse/presentation/screens/new_requests_screen.dart';
import '../features/nurse/presentation/screens/request_details_screen.dart';
import '../features/nurse/presentation/screens/gps_navigation_screen.dart';
import '../features/nurse/presentation/screens/progress_notes_screen.dart';
import '../features/nurse/presentation/screens/complete_visit_screen.dart';
import '../features/nurse/presentation/screens/nurse_active_visit_screen.dart';
import '../features/nurse/presentation/screens/withdrawal_screen.dart';
import '../features/nurse/presentation/screens/transaction_history_screen.dart';
import '../features/nurse/presentation/screens/nurse_messages_screen.dart';
import '../features/nurse/presentation/screens/nurse_chat_detail_screen.dart';
import '../features/nurse/presentation/screens/nurse_profile_settings_screen.dart';
import '../features/nurse/presentation/screens/my_expertise_pricing_screen.dart';
import '../features/nurse/presentation/screens/documents_upload_kyc_screen.dart';
import '../features/nurse/presentation/screens/under_review_screen.dart';
import '../features/nurse/presentation/screens/nurse_notifications_center_screen.dart';
import '../features/nurse/presentation/screens/nurse_help_support_screen.dart';
import '../features/nurse/presentation/screens/nurse_terms_privacy_screen.dart';
import '../features/nurse/presentation/screens/bank_account_screen.dart';
import '../features/nurse/presentation/screens/visit_report_screen.dart';
import '../features/nurse/presentation/screens/report_issue_screen.dart';

import '../features/patient/data/models/address_model.dart';
import '../features/patient/data/models/booking_model.dart';
import '../features/patient/data/models/family_member_model.dart';
import '../features/patient/data/models/medical_record_model.dart';
import '../features/patient/data/models/medication_model.dart';
import '../features/patient/data/models/nurse_model.dart';
import '../features/patient/data/models/request_model.dart';
import '../features/patient/data/models/review_model.dart';
import '../features/patient/data/models/visit_model.dart';
import '../features/patient/data/models/vital_signs_model.dart';

import '../features/patient/presentation/screens/active_visit_screen.dart';
import '../features/patient/presentation/screens/add_edit_address_screen.dart';
import '../features/patient/presentation/screens/add_edit_family_member_screen.dart';
import '../features/patient/presentation/screens/add_edit_medication_screen.dart';
import '../features/patient/presentation/screens/address_manager_screen.dart';
import '../features/patient/presentation/screens/about_app_screen.dart';
import '../features/patient/presentation/screens/booking_confirmation_screen.dart';
import '../features/patient/presentation/screens/booking_details_screen.dart';
import '../features/patient/presentation/screens/booking_history_screen.dart';
import '../features/patient/presentation/screens/booking_summary_screen.dart';
import '../features/patient/presentation/screens/change_password_screen.dart';
import '../features/patient/presentation/screens/chat_screen.dart';
import '../features/patient/presentation/screens/detailed_invoice_screen.dart';
import '../features/patient/presentation/screens/discovery_screen.dart';
import '../features/patient/presentation/screens/emergency_sos_screen.dart';
import '../features/patient/presentation/screens/family_members_screen.dart';
import '../features/patient/presentation/screens/help_support_screen.dart';
import '../features/patient/presentation/screens/medical_history_screen.dart';
import '../features/patient/presentation/screens/medical_record_details_screen.dart';
import '../features/patient/presentation/screens/medication_schedule_screen.dart';
import '../features/patient/presentation/screens/notifications_center_screen.dart';
import '../features/patient/presentation/screens/nurse_profile_screen.dart';
import '../features/patient/presentation/screens/patient_home_screen.dart';
import '../features/patient/presentation/screens/patient_messages_screen.dart';
import '../features/patient/presentation/screens/patient_profile_screen.dart';
import '../features/patient/presentation/screens/patient_settings_screen.dart';
import '../features/patient/presentation/screens/patient_wallet_screen.dart';
import '../features/patient/presentation/screens/payment_method_screen.dart';
import '../features/patient/presentation/screens/payment_success_screen.dart';
import '../features/patient/presentation/screens/personal_information_screen.dart';
import '../features/patient/presentation/screens/rating_review_screen.dart';
import '../features/patient/presentation/screens/reviews_full_list_screen.dart';
import '../features/patient/presentation/screens/select_address_screen.dart';
import '../features/patient/presentation/screens/select_datetime_screen.dart';
import '../features/patient/presentation/screens/support_ticket_screen.dart';
import '../features/patient/presentation/screens/terms_privacy_screen.dart';

final class AppRoutes {
  AppRoutes._();

  // ---------------------------------------------------------------------------
  // Auth Routes
  // ---------------------------------------------------------------------------

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String roleSelection = '/role-selection';

  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static const String language = '/language';
  static const String permissions = '/permissions';
  static const String nurseVerification = '/nurse-verification';

  // ---------------------------------------------------------------------------
  // Patient Main Routes
  // ---------------------------------------------------------------------------

  static const String patientHome = '/patient/home';
  static const String patientDiscovery = '/patient/discovery';
  static const String patientBookings = '/patient/bookings';
  static const String patientWallet = '/patient/wallet';
  static const String patientMessages = '/patient/messages';
  static const String patientProfile = '/patient/profile';
  static const String patientActiveVisit = '/patient/active-visit';

  /// Backward compatibility for old patient-side calls.
  /// If any old patient code uses AppRoutes.activeVisit, it will still work.
  static const String activeVisit = patientActiveVisit;

  // ---------------------------------------------------------------------------
  // Patient Booking Flow
  // ---------------------------------------------------------------------------

  static const String nurseProfile = '/nurse-profile';
  static const String selectDateTime = '/select-date-time';
  static const String selectAddress = '/select-address';
  static const String bookingSummary = '/booking-summary';
  static const String paymentMethod = '/payment-method';
  static const String paymentSuccess = '/payment-success';
  static const String bookingConfirmation = '/booking-confirmation';
  static const String bookingDetails = '/booking-details';
  static const String bookingHistory = '/booking-history';
  static const String detailedInvoice = '/detailed-invoice';

  // ---------------------------------------------------------------------------
  // Patient Profile / Account
  // ---------------------------------------------------------------------------

  static const String personalInformation = '/patient/personal-information';
  static const String addressManager = '/patient/addresses';
  static const String addEditAddress = '/patient/addresses/edit';
  static const String familyMembers = '/patient/family-members';
  static const String addEditFamilyMember = '/patient/family-members/edit';

  // ---------------------------------------------------------------------------
  // Patient Medical
  // ---------------------------------------------------------------------------

  static const String medicalHistory = '/patient/medical-history';
  static const String medicalRecordDetails = '/patient/medical-record-details';
  static const String medicationSchedule = '/patient/medication-schedule';
  static const String addEditMedication = '/patient/medication-schedule/edit';

  // ---------------------------------------------------------------------------
  // Patient Interaction / Support
  // ---------------------------------------------------------------------------

  static const String notificationsCenter = '/notifications-center';
  static const String chat = '/chat';
  static const String ratingReview = '/patient/rating-review';
  static const String reviewsFullList = '/patient/reviews';
  static const String emergencySos = '/patient/emergency-sos';

  static const String patientSettings = '/patient/settings';
  static const String changePassword = '/patient/change-password';
  static const String helpSupport = '/patient/help-support';
  static const String supportTicket = '/patient/support-ticket';
  static const String termsPrivacy = '/patient/terms-privacy';
  static const String aboutApp = '/patient/about-app';

  // ---------------------------------------------------------------------------
  // Nurse Routes
  // ---------------------------------------------------------------------------

  static const String nurseHome = '/nurse/home';
  static const String nurseSchedule = '/nurse/schedule';
  static const String nurseWallet = '/nurse/wallet';
  static const String nurseEarningsAnalytics = '/nurse/earnings-analytics';

  static const String nurseSettings = '/nurse/settings';
  static const String nurseEditProfile = '/nurse/edit-profile';
  static const String nurseChangePassword = '/nurse/change-password';
  static const String nursePrivacyPolicy = '/nurse/privacy-policy';
  static const String nurseTermsOfService = '/nurse/terms-of-service';
  static const String nurseHelpCenter = '/nurse/help-center';
  static const String nurseContactUs = '/nurse/contact-us';

  static const String vitalSigns = '/vital-signs';
  static const String nurseVitalSigns = '/nurse/vital-signs';
  static const String nurseNewRequests = '/nurse/new-requests';
  static const String nurseRequestDetails = '/nurse/request-details';
  static const String nurseGpsNavigation = '/nurse/gps-navigation';
  static const String nurseProgressNotes = '/nurse/progress-notes';
  static const String nurseCompleteVisit = '/nurse/complete-visit';
  static const String nurseWithdrawal = '/nurse/withdrawal';
  static const String nurseTransactionHistory = '/nurse/transaction-history';
  static const String nurseActiveVisit = '/nurse/active-visit';
  static const String nurseMessages = '/nurse/messages';
  static const String nurseChatDetail = '/nurse/chat-detail';
  static const String nurseProfileSettings = '/nurse/profile-settings';
  static const String nurseExpertisePricing = '/nurse/expertise-pricing';
  static const String nurseDocumentsKyc = '/nurse/documents-kyc';
  static const String nurseUnderReview = '/nurse/under-review';
  static const String nurseNotifications = '/nurse/notifications';
  static const String nurseHelpSupport = '/nurse/help-support';
  static const String nurseTermsPrivacy = '/nurse/terms-privacy';
  static const String nurseBankAccount = '/nurse/bank-account';
  static const String nurseVisitReport = '/nurse/visit-report';
  static const String nurseReportIssue = '/nurse/report-issue';

  // ---------------------------------------------------------------------------
  // Shared Routes
  // ---------------------------------------------------------------------------

  static const String settings = '/settings';
  static const String profile = '/profile';

  // ---------------------------------------------------------------------------
  // Optional Payment States
  // ---------------------------------------------------------------------------

  static const String bookingPayment = '/booking-payment';
  static const String bookingPaymentSuccess = '/booking-payment-success';
  static const String bookingPaymentFailed = '/booking-payment-failed';
  static const String bookingPaymentCancelled = '/booking-payment-cancelled';
  static const String bookingPaymentRefunded = '/booking-payment-refunded';
}

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: false,
  errorBuilder: (context, state) => _RouteNotFoundScreen(
    route: state.uri.toString(),
  ),
  routes: [
    // -------------------------------------------------------------------------
    // Auth Routes
    // -------------------------------------------------------------------------

    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),

    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),

    GoRoute(
      path: AppRoutes.roleSelection,
      builder: (context, state) => const RoleSelectionScreen(),
    ),

    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) {
        final userType = _extractUserType(state.extra);

        return LoginScreen(
          userType: userType,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) {
        final userType = _extractUserType(state.extra);

        return SignUpScreen(
          userType: userType,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        final data = _extractOtpData(state.extra);

        return OTPScreen(
          data: data,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    GoRoute(
      path: AppRoutes.resetPassword,
      builder: (context, state) {
        final token = state.extra is String ? state.extra as String : null;

        return ResetPasswordScreen(
          token: token,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.language,
      builder: (context, state) => LanguageSelectionScreen(
        initialLanguageCode: StorageService.instance.languageCode,
        onLanguageChanged: (languageCode) {
          unawaited(
            StorageService.instance.setLanguageCode(languageCode),
          );
        },
      ),
    ),

    GoRoute(
      path: AppRoutes.permissions,
      builder: (context, state) => const PermissionsScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseVerification,
      builder: (context, state) => const NurseVerificationScreen(),
    ),

    // -------------------------------------------------------------------------
    // Patient Main Routes
    // -------------------------------------------------------------------------

    GoRoute(
      path: AppRoutes.patientHome,
      builder: (context, state) => const PatientHomeScreen(),
    ),

    GoRoute(
      path: AppRoutes.patientDiscovery,
      builder: (context, state) => const DiscoveryScreen(),
    ),

    GoRoute(
      path: AppRoutes.patientBookings,
      builder: (context, state) => const BookingHistoryScreen(),
    ),

    GoRoute(
      path: AppRoutes.patientWallet,
      builder: (context, state) => const PatientWalletScreen(),
    ),

    GoRoute(
      path: AppRoutes.patientMessages,
      builder: (context, state) => const PatientMessagesScreen(),
    ),

    GoRoute(
      path: AppRoutes.patientProfile,
      builder: (context, state) => const PatientProfileScreen(),
    ),

    GoRoute(
      path: AppRoutes.patientActiveVisit,
      builder: (context, state) {
        final visit = _extractVisit(state.extra);

        if (visit == null) {
          return const _PlaceholderScreen(
            title: 'Active Visit',
          );
        }

        return ActiveVisitScreen(
          visit: visit,
        );
      },
    ),

    // -------------------------------------------------------------------------
    // Patient Booking Flow
    // -------------------------------------------------------------------------

    GoRoute(
      path: AppRoutes.nurseProfile,
      builder: (context, state) {
        final nurse = _extractNurse(state.extra);

        if (nurse == null) {
          return const _MissingNurseScreen();
        }

        return NurseProfileScreen(
          nurse: nurse,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.selectDateTime,
      builder: (context, state) {
        final nurse = _extractNurse(state.extra);

        if (nurse == null) {
          return const _MissingNurseScreen();
        }

        return SelectDateTimeScreen(
          nurse: nurse,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.selectAddress,
      builder: (context, state) => const SelectAddressScreen(),
    ),

    GoRoute(
      path: AppRoutes.bookingSummary,
      builder: (context, state) => const BookingSummaryScreen(),
    ),

    GoRoute(
      path: AppRoutes.paymentMethod,
      builder: (context, state) {
        final bookingData = _extractDynamicMap(state.extra);
        final amount = _extractPaymentAmount(state.extra);

        return PaymentMethodScreen(
          amount: amount,
          bookingData: bookingData,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.paymentSuccess,
      builder: (context, state) {
        final data = _extractDynamicMap(state.extra);

        return PaymentSuccessScreen(
          bookingData: data,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.bookingConfirmation,
      builder: (context, state) {
        final data = _extractDynamicMap(state.extra);

        return BookingConfirmationScreen(
          bookingData: data,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.bookingHistory,
      builder: (context, state) => const BookingHistoryScreen(),
    ),

    GoRoute(
      path: AppRoutes.bookingDetails,
      builder: (context, state) {
        final booking = _extractBooking(state.extra);

        if (booking == null) {
          return const _PlaceholderScreen(
            title: 'Booking Details',
          );
        }

        return BookingDetailsScreen(
          booking: booking,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.detailedInvoice,
      builder: (context, state) {
        final booking = _extractBooking(state.extra);
        final invoiceData = _extractDynamicMap(state.extra);

        return DetailedInvoiceScreen(
          booking: booking,
          invoiceData: invoiceData,
        );
      },
    ),

    // -------------------------------------------------------------------------
    // Patient Account / Family / Addresses
    // -------------------------------------------------------------------------

    GoRoute(
      path: AppRoutes.personalInformation,
      builder: (context, state) => const PersonalInformationScreen(),
    ),

    GoRoute(
      path: AppRoutes.addressManager,
      builder: (context, state) => const AddressManagerScreen(),
    ),

    GoRoute(
      path: AppRoutes.addEditAddress,
      builder: (context, state) {
        final address = _extractAddress(state.extra);

        return AddEditAddressScreen(
          address: address,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.familyMembers,
      builder: (context, state) => const FamilyMembersScreen(),
    ),

    GoRoute(
      path: AppRoutes.addEditFamilyMember,
      builder: (context, state) {
        final member = _extractFamilyMember(state.extra);

        return AddEditFamilyMemberScreen(
          member: member,
        );
      },
    ),

    // -------------------------------------------------------------------------
    // Patient Medical
    // -------------------------------------------------------------------------

    GoRoute(
      path: AppRoutes.medicalHistory,
      builder: (context, state) => const MedicalHistoryScreen(),
    ),

    GoRoute(
      path: AppRoutes.medicalRecordDetails,
      builder: (context, state) {
        final record = _extractMedicalRecord(state.extra);

        if (record == null) {
          return const _PlaceholderScreen(
            title: 'Medical Record Details',
          );
        }

        return MedicalRecordDetailsScreen(
          record: record,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.medicationSchedule,
      builder: (context, state) => const MedicationScheduleScreen(),
    ),

    GoRoute(
      path: AppRoutes.addEditMedication,
      builder: (context, state) {
        final medication = _extractMedication(state.extra);

        return AddEditMedicationScreen(
          medication: medication,
        );
      },
    ),

    // -------------------------------------------------------------------------
    // Patient Communication / Support / Utility
    // -------------------------------------------------------------------------

    GoRoute(
      path: AppRoutes.notificationsCenter,
      builder: (context, state) => const NotificationsCenterScreen(),
    ),

    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) {
        final data = _extractStringMap(state.extra);

        if (data == null) {
          return const _PlaceholderScreen(
            title: 'Chat',
          );
        }

        return ChatScreen(
          nurseName: data['nurseName'] ?? '',
          nurseImage: data['nurseImage'] ?? '',
          nurseId: data['nurseId'] ?? '',
        );
      },
    ),

    GoRoute(
      path: AppRoutes.ratingReview,
      builder: (context, state) {
        final booking = _extractBooking(state.extra);
        final nurse = _extractNurse(state.extra);

        return RatingReviewScreen(
          booking: booking,
          nurse: nurse,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.reviewsFullList,
      builder: (context, state) {
        final data = _extractDynamicMap(state.extra);
        final reviews = _extractReviews(state.extra);

        return ReviewsFullListScreen(
          title: data['title']?.toString() ?? 'Reviews',
          reviews: reviews,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.emergencySos,
      builder: (context, state) => const EmergencySosScreen(),
    ),

    GoRoute(
      path: AppRoutes.patientSettings,
      builder: (context, state) => const PatientSettingsScreen(),
    ),

    GoRoute(
      path: AppRoutes.changePassword,
      builder: (context, state) => const ChangePasswordScreen(),
    ),

    GoRoute(
      path: AppRoutes.helpSupport,
      builder: (context, state) => const HelpSupportScreen(),
    ),

    GoRoute(
      path: AppRoutes.supportTicket,
      builder: (context, state) => const SupportTicketScreen(),
    ),

    GoRoute(
      path: AppRoutes.termsPrivacy,
      builder: (context, state) => const TermsPrivacyScreen(),
    ),

    GoRoute(
      path: AppRoutes.aboutApp,
      builder: (context, state) => const AboutAppScreen(),
    ),

    // -------------------------------------------------------------------------
    // Nurse Routes
    // -------------------------------------------------------------------------

    GoRoute(
      path: AppRoutes.nurseHome,
      builder: (context, state) => const NurseHomeScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseSchedule,
      builder: (context, state) => const MyScheduleScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseWallet,
      builder: (context, state) => const WalletScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseEarningsAnalytics,
      builder: (context, state) => const EarningsAnalyticsScreen(),
    ),

    GoRoute(
      path: AppRoutes.vitalSigns,
      builder: (context, state) => const VitalSignsScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseVitalSigns,
      builder: (context, state) => const VitalSignsScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseNewRequests,
      builder: (context, state) => const NewRequestsScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseRequestDetails,
      builder: (context, state) {
        final request = state.extra is RequestModel
            ? state.extra as RequestModel
            : null;

        return RequestDetailsScreen(
          request: request,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.nurseGpsNavigation,
      builder: (context, state) {
        final request = state.extra is RequestModel
            ? state.extra as RequestModel
            : null;

        return GpsNavigationScreen(
          request: request,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.nurseProgressNotes,
      builder: (context, state) {
        final initialNotes =
            state.extra is String ? state.extra as String : null;

        return ProgressNotesScreen(
          initialNotes: initialNotes,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.nurseCompleteVisit,
      builder: (context, state) {
        if (state.extra is Map) {
          final data = Map<String, dynamic>.from(state.extra as Map);

          return CompleteVisitScreen(
            patientName: data['patientName']?.toString(),
            serviceType: data['serviceType']?.toString(),
            amount: data['amount'] is num
                ? (data['amount'] as num).toDouble()
                : null,
            startTime: data['startTime'] is DateTime
                ? data['startTime'] as DateTime
                : null,
            endTime: data['endTime'] is DateTime
                ? data['endTime'] as DateTime
                : null,
            initialNotes: data['notes']?.toString(),
            vitals: data['vitals'] is VitalSignsModel
                ? data['vitals'] as VitalSignsModel
                : null,
          );
        }

        return const CompleteVisitScreen();
      },
    ),

    GoRoute(
      path: AppRoutes.nurseActiveVisit,
      builder: (context, state) {
        return NurseActiveVisitScreen(
          payload: state.extra,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.nurseWithdrawal,
      builder: (context, state) => const WithdrawalScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseTransactionHistory,
      builder: (context, state) => const TransactionHistoryScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseMessages,
      builder: (context, state) => const NurseMessagesScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseChatDetail,
      builder: (context, state) {
        final data = state.extra is Map
            ? Map<String, dynamic>.from(state.extra as Map)
            : const <String, dynamic>{};

        return NurseChatDetailScreen(
          patientName: data['patientName']?.toString() ?? 'Patient',
          serviceType: data['serviceType']?.toString() ?? 'Home Visit',
        );
      },
    ),

    GoRoute(
      path: AppRoutes.nurseProfileSettings,
      builder: (context, state) => const NurseProfileSettingsScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseExpertisePricing,
      builder: (context, state) => const MyExpertisePricingScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseDocumentsKyc,
      builder: (context, state) => const DocumentsUploadKycScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseUnderReview,
      builder: (context, state) => const UnderReviewScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseNotifications,
      builder: (context, state) => const NurseNotificationsCenterScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseHelpSupport,
      builder: (context, state) => const NurseHelpSupportScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseTermsPrivacy,
      builder: (context, state) => const NurseTermsPrivacyScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseBankAccount,
      builder: (context, state) => const BankAccountScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseVisitReport,
      builder: (context, state) => VisitReportScreen(
        payload: state.extra,
      ),
    ),

    GoRoute(
      path: AppRoutes.nurseReportIssue,
      builder: (context, state) => const ReportIssueScreen(),
    ),

    // -------------------------------------------------------------------------
    // Nurse Legacy / Alias Routes
    // -------------------------------------------------------------------------

    GoRoute(
      path: AppRoutes.nurseSettings,
      builder: (context, state) => const NurseProfileSettingsScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseEditProfile,
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Edit Nurse Profile',
      ),
    ),

    GoRoute(
      path: AppRoutes.nurseChangePassword,
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Change Password',
      ),
    ),

    GoRoute(
      path: AppRoutes.nursePrivacyPolicy,
      builder: (context, state) => const NurseTermsPrivacyScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseTermsOfService,
      builder: (context, state) => const NurseTermsPrivacyScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseHelpCenter,
      builder: (context, state) => const NurseHelpSupportScreen(),
    ),

    GoRoute(
      path: AppRoutes.nurseContactUs,
      builder: (context, state) => const NurseHelpSupportScreen(),
    ),
  ],
);

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

UserType? _extractUserType(Object? extra) {
  if (extra is UserType) {
    return extra;
  }

  if (extra is String) {
    return UserType.fromJson(extra);
  }

  if (extra is Map) {
    final value = extra['userType'] ?? extra['user_type'];

    if (value is UserType) {
      return value;
    }

    if (value is String) {
      return UserType.fromJson(value);
    }
  }

  return null;
}

Map<String, dynamic> _extractOtpData(Object? extra) {
  if (extra is Map<String, dynamic>) {
    return Map<String, dynamic>.from(extra);
  }

  if (extra is Map) {
    return Map<String, dynamic>.from(extra);
  }

  if (extra is String) {
    return {
      'email': extra,
      'userType': null,
    };
  }

  return const {
    'email': '',
    'userType': null,
  };
}

NurseModel? _extractNurse(Object? extra) {
  if (extra is NurseModel) {
    return extra;
  }

  if (extra is Map) {
    final nurse = extra['nurse'];

    if (nurse is NurseModel) {
      return nurse;
    }
  }

  return null;
}

BookingModel? _extractBooking(Object? extra) {
  if (extra is BookingModel) {
    return extra;
  }

  if (extra is Map) {
    final booking = extra['booking'];

    if (booking is BookingModel) {
      return booking;
    }
  }

  return null;
}

VisitModel? _extractVisit(Object? extra) {
  if (extra is VisitModel) {
    return extra;
  }

  if (extra is Map) {
    final visit = extra['visit'];

    if (visit is VisitModel) {
      return visit;
    }
  }

  return null;
}

AddressModel? _extractAddress(Object? extra) {
  if (extra is AddressModel) {
    return extra;
  }

  if (extra is Map) {
    final address = extra['address'];

    if (address is AddressModel) {
      return address;
    }
  }

  return null;
}

FamilyMemberModel? _extractFamilyMember(Object? extra) {
  if (extra is FamilyMemberModel) {
    return extra;
  }

  if (extra is Map) {
    final member = extra['member'];

    if (member is FamilyMemberModel) {
      return member;
    }
  }

  return null;
}

MedicalRecordModel? _extractMedicalRecord(Object? extra) {
  if (extra is MedicalRecordModel) {
    return extra;
  }

  if (extra is Map) {
    final record = extra['record'];

    if (record is MedicalRecordModel) {
      return record;
    }
  }

  return null;
}

MedicationModel? _extractMedication(Object? extra) {
  if (extra is MedicationModel) {
    return extra;
  }

  if (extra is Map) {
    final medication = extra['medication'];

    if (medication is MedicationModel) {
      return medication;
    }
  }

  return null;
}

List<ReviewModel> _extractReviews(Object? extra) {
  if (extra is List<ReviewModel>) {
    return extra;
  }

  if (extra is Map) {
    final reviews = extra['reviews'];

    if (reviews is List<ReviewModel>) {
      return reviews;
    }

    if (reviews is List) {
      return reviews.whereType<ReviewModel>().toList();
    }
  }

  return const [];
}

double _extractPaymentAmount(Object? extra) {
  if (extra is double) {
    return extra;
  }

  if (extra is int) {
    return extra.toDouble();
  }

  if (extra is num) {
    return extra.toDouble();
  }

  if (extra is Map) {
    final amount = extra['amount'] ?? extra['total'] ?? extra['totalAmount'];

    if (amount is num) {
      return amount.toDouble();
    }

    if (amount is String) {
      return double.tryParse(amount) ?? 0.0;
    }
  }

  if (extra is String) {
    return double.tryParse(extra) ?? 0.0;
  }

  return 0.0;
}

Map<String, dynamic> _extractDynamicMap(Object? extra) {
  if (extra is Map<String, dynamic>) {
    return Map<String, dynamic>.from(extra);
  }

  if (extra is Map) {
    return Map<String, dynamic>.from(extra);
  }

  return const {};
}

Map<String, String>? _extractStringMap(Object? extra) {
  if (extra is Map<String, String>) {
    return extra;
  }

  if (extra is Map<String, dynamic>) {
    return extra.map(
      (key, value) => MapEntry(
        key,
        value?.toString() ?? '',
      ),
    );
  }

  if (extra is Map) {
    return extra.map(
      (key, value) => MapEntry(
        key.toString(),
        value?.toString() ?? '',
      ),
    );
  }

  return null;
}

// -----------------------------------------------------------------------------
// Error Screens
// -----------------------------------------------------------------------------

class _RouteNotFoundScreen extends StatelessWidget {
  final String route;

  const _RouteNotFoundScreen({
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(AppStrings.pageNotFound),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.errorRed,
                  size: 46,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '404',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.routeNotFound,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textLight,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                route,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => context.go(AppRoutes.welcome),
                child: const Text(AppStrings.goHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissingNurseScreen extends StatelessWidget {
  const _MissingNurseScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(AppStrings.nurseNotFound),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_off_rounded,
                  size: 46,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppStrings.nurseDataMissing,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.selectNurseAgain,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textLight,
                      height: 1.4,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => context.go(AppRoutes.patientDiscovery),
                child: const Text(AppStrings.selectNurse),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  color: AppColors.primaryBlue,
                  size: 44,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.comingSoon,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textLight,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}