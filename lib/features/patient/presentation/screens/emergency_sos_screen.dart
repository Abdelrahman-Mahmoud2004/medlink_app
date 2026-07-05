import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen> {
  bool _isSending = false;
  bool _countdownActive = false;
  int _secondsLeft = 5;
  Timer? _timer;

  final List<_EmergencyContact> _contacts = const [
    _EmergencyContact(
      title: 'Ambulance',
      subtitle: 'Emergency medical services',
      phone: '123',
      icon: Icons.local_hospital_rounded,
      color: AppColors.errorRed,
    ),
    _EmergencyContact(
      title: 'MedLink Support',
      subtitle: 'Urgent support line',
      phone: '+20 100 000 0000',
      icon: Icons.support_agent_rounded,
      color: AppColors.primaryBlue,
    ),
    _EmergencyContact(
      title: 'Family Contact',
      subtitle: 'Primary family emergency contact',
      phone: '+20 101 234 5678',
      icon: Icons.family_restroom_rounded,
      color: AppColors.successGreen,
    ),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goBack() {
    if (_isSending || _countdownActive) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientHome);
  }

  void _startSosCountdown() {
    if (_countdownActive || _isSending) return;

    setState(() {
      _countdownActive = true;
      _secondsLeft = 5;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_secondsLeft <= 1) {
        timer.cancel();
        _sendEmergencyAlert();
        return;
      }

      setState(() => _secondsLeft--);
    });
  }

  void _cancelCountdown() {
    _timer?.cancel();

    setState(() {
      _countdownActive = false;
      _secondsLeft = 5;
    });
  }

  Future<void> _sendEmergencyAlert() async {
    if (_isSending) return;

    setState(() {
      _countdownActive = false;
      _isSending = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isSending = false);

    _showAlertSentDialog();
  }

  void _showAlertSentDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('SOS Alert Sent'),
          content: const Text(
            'Your emergency alert has been sent. Emergency contacts and MedLink support will be notified.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                dialogContext.pop();

                if (!mounted) return;

                context.go(AppRoutes.patientHome);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _showCallMessage(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $phone feature coming soon'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonLabel = _countdownActive
        ? 'Sending in $_secondsLeft seconds...'
        : _isSending
            ? 'Sending SOS...'
            : 'Hold to Send SOS';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: (_isSending || _countdownActive) ? null : _goBack,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: AppColors.errorRed.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _countdownActive ? 132 : 118,
                    height: _countdownActive ? 132 : 118,
                    decoration: BoxDecoration(
                      color: AppColors.errorRed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.errorRed.withValues(alpha: 0.28),
                          blurRadius: _countdownActive ? 38 : 24,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isSending
                          ? const CircularProgressIndicator(
                              color: AppColors.white,
                            )
                          : Text(
                              _countdownActive ? '$_secondsLeft' : 'SOS',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'Emergency Assistance',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'Use SOS only in urgent situations. Your emergency contacts and support team will be notified.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLight,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  CustomButton(
                    label: buttonLabel,
                    isLoading: _isSending,
                    onPressed: _isSending ? null : _startSosCountdown,
                  ),

                  if (_countdownActive) ...[
                    const SizedBox(height: AppSpacing.md),
                    CustomButton(
                      label: 'Cancel SOS',
                      isOutlined: true,
                      onPressed: _cancelCountdown,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Text(
              'Emergency Contacts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),

            const SizedBox(height: AppSpacing.lg),

            ..._contacts.map(
              (contact) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _EmergencyContactTile(
                  contact: contact,
                  onCall: () => _showCallMessage(contact.phone),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.warningOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: AppColors.warningOrange.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warningOrange,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'If there is immediate danger, contact local emergency services directly.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textDark,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyContact {
  final String title;
  final String subtitle;
  final String phone;
  final IconData icon;
  final Color color;

  const _EmergencyContact({
    required this.title,
    required this.subtitle,
    required this.phone,
    required this.icon,
    required this.color,
  });
}

class _EmergencyContactTile extends StatelessWidget {
  final _EmergencyContact contact;
  final VoidCallback onCall;

  const _EmergencyContactTile({
    required this.contact,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: contact.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              contact.icon,
              color: contact.color,
              size: 27,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  contact.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  contact.phone,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: contact.color,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCall,
            icon: Icon(
              Icons.phone_rounded,
              color: contact.color,
            ),
          ),
        ],
      ),
    );
  }
}