import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

class NurseChatDetailScreen extends StatefulWidget {
  final String patientName;
  final String serviceType;

  const NurseChatDetailScreen({
    super.key,
    required this.patientName,
    required this.serviceType,
  });

  @override
  State<NurseChatDetailScreen> createState() => _NurseChatDetailScreenState();
}

class _NurseChatDetailScreenState extends State<NurseChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();

  final ValueNotifier<List<_ChatMessage>> _messagesNotifier =
      ValueNotifier<List<_ChatMessage>>(
    const [
      _ChatMessage(text: 'Hello, I am on the way.', isMine: true),
      _ChatMessage(text: 'Thank you. The building is next to the pharmacy.', isMine: false),
      _ChatMessage(text: 'Got it. I will arrive shortly.', isMine: true),
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
    context.go(AppRoutes.nurseMessages);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final messages = List<_ChatMessage>.of(_messagesNotifier.value)
      ..add(_ChatMessage(text: text, isMine: true));

    _messagesNotifier.value = messages;
    _messageController.clear();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 19,
              backgroundColor: AppColors.lightBlue,
              child: Icon(Icons.person_rounded, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.patientName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    widget.serviceType,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textLight,
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showComingSoon('Call'),
            icon: const Icon(Icons.phone_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<List<_ChatMessage>>(
                valueListenable: _messagesNotifier,
                builder: (context, messages, _) {
                  return ListView.separated(
                    reverse: false,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: messages.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return _MessageBubble(message: messages[index]);
                    },
                  );
                },
              ),
            ),
            _Composer(
              controller: _messageController,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMine;

  const _ChatMessage({
    required this.text,
    required this.isMine,
  });
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final alignment =
        message.isMine ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isMine ? AppColors.primaryBlue : AppColors.white;
    final textColor = message.isMine ? AppColors.white : AppColors.textDark;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppRadius.lg),
              topRight: const Radius.circular(AppRadius.lg),
              bottomLeft: Radius.circular(
                message.isMine ? AppRadius.lg : AppRadius.sm,
              ),
              bottomRight: Radius.circular(
                message.isMine ? AppRadius.sm : AppRadius.lg,
              ),
            ),
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
                hintText: 'Type a message...',
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
                backgroundColor: AppColors.primaryBlue,
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