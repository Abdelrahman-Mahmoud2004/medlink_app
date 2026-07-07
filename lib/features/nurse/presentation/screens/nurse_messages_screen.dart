import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

class NurseMessagesScreen extends StatefulWidget {
  const NurseMessagesScreen({super.key});

  @override
  State<NurseMessagesScreen> createState() => _NurseMessagesScreenState();
}

class _NurseMessagesScreenState extends State<NurseMessagesScreen> {
  final ValueNotifier<String> _queryNotifier = ValueNotifier<String>('');

  static final List<_MessageThread> _threads = [
    const _MessageThread(
      patientName: 'Amira El-Sayed',
      serviceType: 'Post-Surgery Care',
      lastMessage: 'Please bring wound dressing supplies.',
      time: '09:45',
      unreadCount: 2,
    ),
    const _MessageThread(
      patientName: 'Khaled Ibrahim',
      serviceType: 'Physiotherapy',
      lastMessage: 'The address is near the pharmacy.',
      time: 'Yesterday',
      unreadCount: 0,
    ),
    const _MessageThread(
      patientName: 'Mariam Hassan',
      serviceType: 'Blood Sample Collection',
      lastMessage: 'I am fasting as requested.',
      time: 'Mon',
      unreadCount: 1,
    ),
  ];

  @override
  void dispose() {
    _queryNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.nurseHome);
  }

  List<_MessageThread> _filtered(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return _threads;

    return _threads
        .where(
          (thread) =>
              thread.patientName.toLowerCase().contains(clean) ||
              thread.serviceType.toLowerCase().contains(clean),
        )
        .toList(growable: false);
  }

  void _openChat(_MessageThread thread) {
    context.push(
      AppRoutes.nurseChatDetail,
      extra: {
        'patientName': thread.patientName,
        'serviceType': thread.serviceType,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Messages'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed(
                  [
                    _SearchBox(
                      onChanged: (value) => _queryNotifier.value = value,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ValueListenableBuilder<String>(
                      valueListenable: _queryNotifier,
                      builder: (context, query, _) {
                        final threads = _filtered(query);

                        if (threads.isEmpty) {
                          return const _EmptyMessages();
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: threads.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final thread = threads[index];

                            return _MessageTile(
                              thread: thread,
                              onTap: () => _openChat(thread),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageThread {
  final String patientName;
  final String serviceType;
  final String lastMessage;
  final String time;
  final int unreadCount;

  const _MessageThread({
    required this.patientName,
    required this.serviceType,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
  });
}

class _SearchBox extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchBox({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search messages...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.borderGray),
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final _MessageThread thread;
  final VoidCallback onTap;

  const _MessageTile({
    required this.thread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = thread.unreadCount > 0;

    return RepaintBoundary(
      child: Container(
        decoration: _Decorations.card(),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.lightBlue,
                    child: Text(
                      thread.patientName.characters.first,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          thread.patientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          thread.serviceType,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          thread.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textLight,
                                    fontWeight: hasUnread
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        thread.time,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.textLight,
                              fontSize: 10,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (hasUnread)
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${thread.unreadCount}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: _Decorations.card(),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: AppColors.textLight.withValues(alpha: 0.75),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No messages found',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

final class _Decorations {
  const _Decorations._();

  static BoxDecoration card() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: AppColors.borderGray),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}