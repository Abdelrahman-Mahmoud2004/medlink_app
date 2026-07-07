import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

class SupportAdminChatScreen extends StatefulWidget {
  const SupportAdminChatScreen({super.key});

  @override
  State<SupportAdminChatScreen> createState() => _SupportAdminChatScreenState();
}

class _SupportAdminChatScreenState extends State<SupportAdminChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final ValueNotifier<List<_SupportMessage>> _messagesNotifier =
      ValueNotifier<List<_SupportMessage>>(
    const [
      _SupportMessage(
        text: 'Hello, MedLink support is here. How can we help?',
        isMine: false,
      ),
    ],
  );

  @override
  void dispose() {
    _messageController.dispose();
    _messagesNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.welcome);
  }

  void _send() {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    final messages = List<_SupportMessage>.of(_messagesNotifier.value)
      ..add(_SupportMessage(text: text, isMine: true));

    _messagesNotifier.value = messages;
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Admin Support Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _EmergencyNote(),
            Expanded(
              child: ValueListenableBuilder<List<_SupportMessage>>(
                valueListenable: _messagesNotifier,
                builder: (context, messages, _) {
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: messages.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return _SupportBubble(message: messages[index]);
                    },
                  );
                },
              ),
            ),
            _Composer(
              controller: _messageController,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportMessage {
  final String text;
  final bool isMine;

  const _SupportMessage({
    required this.text,
    required this.isMine,
  });
}

class _EmergencyNote extends StatelessWidget {
  const _EmergencyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningOrange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.warningOrange.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.support_agent_rounded,
            color: AppColors.warningOrange,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Use this chat for urgent booking, payment, visit, or account issues.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warningOrange,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportBubble extends StatelessWidget {
  final _SupportMessage message;

  const _SupportBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final color = message.isMine ? AppColors.primaryBlue : AppColors.white;
    final textColor = message.isMine ? AppColors.white : AppColors.textDark;

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: message.isMine
                ? null
                : Border.all(color: AppColors.borderGray),
          ),
          child: Text(
            message.text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.borderGray)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: AppColors.bgGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 48,
            height: 48,
            child: FilledButton(
              onPressed: onSend,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.send_rounded),
            ),
          ),
        ],
      ),
    );
  }
}