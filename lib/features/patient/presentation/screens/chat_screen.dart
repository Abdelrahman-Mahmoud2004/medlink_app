import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../data/models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String nurseName;
  final String nurseImage;
  final String nurseId;

  const ChatScreen({
    super.key,
    required this.nurseName,
    required this.nurseImage,
    required this.nurseId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;

  late final List<MessageModel> _messages;

  final String _currentUserId = 'patient_123';

  bool _hasText = false;
  bool _isSending = false;
  Timer? _replyTimer;

  @override
  void initState() {
    super.initState();

    _messageController = TextEditingController();
    _scrollController = ScrollController();

    _messageController.addListener(_handleTextChanged);

    _messages = _buildDummyMessages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animated: false);
    });
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    _messageController.removeListener(_handleTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<MessageModel> _buildDummyMessages() {
    return [
      MessageModel(
        id: '1',
        senderId: widget.nurseId,
        senderName: widget.nurseName,
        senderImage: widget.nurseImage,
        content: 'Hello! How can I help you today?',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isRead: true,
      ),
      MessageModel(
        id: '2',
        senderId: _currentUserId,
        senderName: 'You',
        senderImage: 'https://via.placeholder.com/150',
        content:
            'Hi! I wanted to ask about the booking tomorrow at 10 AM. Is that time still available?',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        isRead: true,
      ),
      MessageModel(
        id: '3',
        senderId: widget.nurseId,
        senderName: widget.nurseName,
        senderImage: widget.nurseImage,
        content: 'Yes, the 10 AM slot is available. I will be there on time.',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: true,
      ),
      MessageModel(
        id: '4',
        senderId: widget.nurseId,
        senderName: widget.nurseName,
        senderImage: widget.nurseImage,
        content:
            'Please make sure the patient is comfortable and has any medications ready.',
        type: MessageType.text,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        isRead: true,
      ),
    ];
  }

  void _handleTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;

    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientMessages);
  }

  void _handleCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Call feature coming soon'),
      ),
    );
  }

  void _handleAttachment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attachment feature coming soon'),
      ),
    );
  }

  void _handleSendMessage() {
    final text = _messageController.text.trim();

    if (text.isEmpty || _isSending) {
      return;
    }

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId,
      senderName: 'You',
      senderImage: 'https://via.placeholder.com/150',
      content: text,
      type: MessageType.text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _isSending = true;
      _messages.add(newMessage);
    });

    _messageController.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;

      setState(() => _isSending = false);
      _simulateNurseReply();
    });
  }

  void _simulateNurseReply() {
    _replyTimer?.cancel();

    _replyTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        _messages.add(
          MessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: widget.nurseId,
            senderName: widget.nurseName,
            senderImage: widget.nurseImage,
            content: 'Got it! Thank you for letting me know.',
            type: MessageType.text,
            timestamp: DateTime.now(),
            isRead: true,
          ),
        );
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom({bool animated = true}) {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted || !_scrollController.hasClients) return;

      final target = _scrollController.position.maxScrollExtent;

      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  String _displayName() {
    final cleanName = widget.nurseName.trim();

    if (cleanName.isEmpty) {
      return 'Healthcare Provider';
    }

    return cleanName;
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();

    if (_isSameDay(now, time)) {
      return DateFormat.Hm().format(time);
    }

    if (_isSameDay(now.subtract(const Duration(days: 1)), time)) {
      return 'Yesterday ${DateFormat.Hm().format(time)}';
    }

    return DateFormat('MMM d, HH:mm').format(time);
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            _AvatarImage(
              imageUrl: widget.nurseImage,
              size: 42,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayName(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        color: AppColors.successGreen,
                        size: 8,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Active now',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: GestureDetector(
              onTap: _handleCall,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildMessagesList(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isCurrentUser = message.senderId == _currentUserId;

        final showSenderHeader = !isCurrentUser &&
            (index == 0 || _messages[index - 1].senderId != message.senderId);

        return _MessageBubble(
          message: message,
          isCurrentUser: isCurrentUser,
          showSenderHeader: showSenderHeader,
          formattedTime: _formatMessageTime(message.timestamp),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderGray),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSendMessage(),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: AppColors.bgGray,
                prefixIcon: IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: _handleAttachment,
                  color: AppColors.primaryBlue,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  borderSide: const BorderSide(color: AppColors.borderGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  borderSide: const BorderSide(color: AppColors.borderGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: _hasText && !_isSending ? _handleSendMessage : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _hasText && !_isSending
                    ? AppColors.primaryBlue
                    : AppColors.borderGray,
                shape: BoxShape.circle,
                boxShadow: _hasText && !_isSending
                    ? [
                        BoxShadow(
                          color:
                              AppColors.primaryBlue.withValues(alpha: 0.20),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [],
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final bool showSenderHeader;
  final String formattedTime;

  const _MessageBubble({
    required this.message,
    required this.isCurrentUser,
    required this.showSenderHeader,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showSenderHeader) ...[
            Row(
              children: [
                _AvatarImage(
                  imageUrl: message.senderImage,
                  size: 34,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    message.senderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.74,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? AppColors.primaryBlue
                        : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppRadius.lg),
                      topRight: const Radius.circular(AppRadius.lg),
                      bottomLeft: Radius.circular(
                        isCurrentUser ? AppRadius.lg : AppRadius.sm,
                      ),
                      bottomRight: Radius.circular(
                        isCurrentUser ? AppRadius.sm : AppRadius.lg,
                      ),
                    ),
                    border: isCurrentUser
                        ? null
                        : Border.all(color: AppColors.borderGray),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.035),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isCurrentUser
                                  ? AppColors.white
                                  : AppColors.textDark,
                              height: 1.45,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formattedTime,
                            style:
                                Theme.of(context).textTheme.labelLarge?.copyWith(
                                      fontSize: 10,
                                      color: isCurrentUser
                                          ? AppColors.white
                                              .withValues(alpha: 0.72)
                                          : AppColors.textLight,
                                    ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 6),
                            Icon(
                              message.isRead
                                  ? Icons.done_all_rounded
                                  : Icons.done_rounded,
                              size: 14,
                              color: AppColors.white.withValues(alpha: 0.72),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  final String imageUrl;
  final double size;

  const _AvatarImage({
    required this.imageUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white,
          width: 2,
        ),
      ),
      child: cleanUrl.isEmpty
          ? Icon(
              Icons.person_rounded,
              color: AppColors.primaryBlue,
              size: size * 0.55,
            )
          : Image.network(
              cleanUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.person_rounded,
                color: AppColors.primaryBlue,
                size: size * 0.55,
              ),
            ),
    );
  }
}