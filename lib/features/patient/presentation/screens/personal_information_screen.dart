import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../providers/patient_provider.dart';

class PersonalInformationScreen extends ConsumerStatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  ConsumerState<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends ConsumerState<PersonalInformationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  late final ValueNotifier<bool> _isSavingNotifier;

  static final RegExp _emailRegex = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
  );

  bool get _isSaving => _isSavingNotifier.value;

  @override
  void initState() {
    super.initState();

    final profile = ref.read(patientProfileProvider);

    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);

    _isSavingNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _isSavingNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_isSaving) {
      return;
    }

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientProfile);
  }

  String? _requiredValidator(String? value) {
    final clean = value?.trim() ?? '';

    if (clean.isEmpty) {
      return 'Required';
    }

    return null;
  }

  String? _emailValidator(String? value) {
    final clean = value?.trim() ?? '';

    if (clean.isEmpty) {
      return 'Required';
    }

    if (!_emailRegex.hasMatch(clean)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    final clean = value?.trim() ?? '';

    if (clean.isEmpty) {
      return 'Required';
    }

    final digitsOnly = clean.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 10) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  Future<void> _saveChanges() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid || _isSaving) {
      return;
    }

    FocusScope.of(context).unfocus();

    _isSavingNotifier.value = true;

    try {
      await Future<void>.delayed(const Duration(milliseconds: 650));

      if (!mounted) {
        return;
      }

      ref.read(patientProfileProvider.notifier).updatePersonalInformation(
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
          );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Personal information updated'),
            backgroundColor: AppColors.successGreen,
          ),
        );

      if (context.canPop()) {
        context.pop();
      }
    } finally {
      if (mounted) {
        _isSavingNotifier.value = false;
      }
    }
  }

  void _showChangePhotoComingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Change photo coming soon'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        _goBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: const Text('Personal Information'),
          leading: ValueListenableBuilder<bool>(
            valueListenable: _isSavingNotifier,
            builder: (context, isSaving, _) {
              return IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: isSaving ? null : _goBack,
              );
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _ProfileHeader(
                          onChangePhotoTap: _showChangePhotoComingSoon,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [
                            AutofillHints.name,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: _requiredValidator,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.email,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: _emailValidator,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [
                            AutofillHints.telephoneNumber,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: _phoneValidator,
                          onFieldSubmitted: (_) => _saveChanges(),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        const _InfoNotice(),
                      ],
                    ),
                  ),
                ),
              ),
              _BottomSaveBar(
                isSavingListenable: _isSavingNotifier,
                onSavePressed: _saveChanges,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Profile header
// -----------------------------------------------------------------------------

class _ProfileHeader extends ConsumerWidget {
  final VoidCallback onChangePhotoTap;

  const _ProfileHeader({
    required this.onChangePhotoTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ref.watch(
      patientProfileProvider.select(
        (profile) => profile.imageUrl.trim(),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.bgGray,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _ProfileAvatar(
                imageUrl: imageUrl,
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onChangePhotoTap,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Update your account information',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String imageUrl;

  const _ProfileAvatar({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheSize = (104 * pixelRatio).round();

    return CircleAvatar(
      radius: 52,
      backgroundColor: AppColors.lightBlue,
      child: ClipOval(
        child: imageUrl.isEmpty
            ? const _AvatarFallback()
            : Image.network(
                imageUrl,
                width: 104,
                height: 104,
                fit: BoxFit.cover,
                cacheWidth: cacheSize,
                cacheHeight: cacheSize,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => const _AvatarFallback(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const _AvatarLoading();
                },
              ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 104,
      height: 104,
      child: Icon(
        Icons.person_rounded,
        color: AppColors.primaryBlue,
        size: 54,
      ),
    );
  }
}

class _AvatarLoading extends StatelessWidget {
  const _AvatarLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 104,
      height: 104,
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Info notice
// -----------------------------------------------------------------------------

class _InfoNotice extends StatelessWidget {
  const _InfoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Some account information may require verification before it is updated permanently.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryBlue,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Bottom save bar
// -----------------------------------------------------------------------------

class _BottomSaveBar extends StatelessWidget {
  final ValueNotifier<bool> isSavingListenable;
  final VoidCallback onSavePressed;

  const _BottomSaveBar({
    required this.isSavingListenable,
    required this.onSavePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderGray),
        ),
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: isSavingListenable,
        builder: (context, isSaving, _) {
          return CustomButton(
            label: 'Save Changes',
            isLoading: isSaving,
            onPressed: isSaving ? null : onSavePressed,
          );
        },
      ),
    );
  }
}