import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

class PatientMessagesScreen extends StatefulWidget {
  const PatientMessagesScreen({super.key});

  @override
  State<PatientMessagesScreen> createState() => _PatientMessagesScreenState();
}

class _PatientMessagesScreenState extends State<PatientMessagesScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  final List<_ChatPreview> _chats = const [
    _ChatPreview(
      nurseId: '1',
      nurseName: 'Sara Ahmed',
      nurseImage: 'https://i.pravatar.cc/150?img=11',
      lastMessage: 'I will arrive on time tomorrow.',
      time: '10:35 AM',
      unreadCount: 2,
      isOnline: true,
    ),
    _ChatPreview(
      nurseId: '2',
      nurseName: 'Layla Mahmoud',
      nurseImage: 'https://i.pravatar.cc/150?img=5',
      lastMessage: 'Please prepare the medication list.',
      time: 'Yesterday',
      unreadCount: 0,
      isOnline: false,
    ),
    _ChatPreview(
      nurseId: '3',
      nurseName: 'Ahmed Hassan',
      nurseImage: 'https://i.pravatar.cc/150?img=3',
      lastMessage: 'Your next session is confirmed.',
      time: 'Jun 20',
      unreadCount: 1,
      isOnline: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ChatPreview> get _filteredChats {
    final cleanQuery = _query.trim().toLowerCase();

    if (cleanQuery.isEmpty) {
      return _chats;
    }

    return _chats.where((chat) {
      return chat.nurseName.toLowerCase().contains(cleanQuery) ||
          chat.lastMessage.toLowerCase().contains(cleanQuery);
    }).toList();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientHome);
  }

  void _openChat(_ChatPreview chat) {
    context.push(
      AppRoutes.chat,
      extra: {
        'nurseName': chat.nurseName,
        'nurseImage': chat.nurseImage,
        'nurseId': chat.nurseId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chats = _filteredChats;

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
        child: Column(
          children: [
            _buildSearchBar(),

            Expanded(
              child: chats.isEmpty
                  ? const _EmptyMessagesState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: chats.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final chat = chats[index];

                        return _ChatPreviewTile(
                          chat: chat,
                          onTap: () => _openChat(chat),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.bgGray,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _query = value);
        },
        decoration: InputDecoration(
          hintText: 'Search conversations',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textLight,
          ),
          suffixIcon: _query.trim().isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textLight,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            borderSide: const BorderSide(color: AppColors.borderGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            borderSide: const BorderSide(color: AppColors.borderGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            borderSide: const BorderSide(
              color: AppColors.primaryBlue,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Models
// -----------------------------------------------------------------------------

class _ChatPreview {
  final String nurseId;
  final String nurseName;
  final String nurseImage;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;

  const _ChatPreview({
    required this.nurseId,
    required this.nurseName,
    required this.nurseImage,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
  });
}

// -----------------------------------------------------------------------------
// Widgets
// -----------------------------------------------------------------------------

class _ChatPreviewTile extends StatelessWidget {
  final _ChatPreview chat;
  final VoidCallback onTap;

  const _ChatPreviewTile({
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = chat.nurseImage.trim();

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.lightBlue,
                    child: ClipOval(
                      child: imageUrl.isEmpty
                          ? const Icon(
                              Icons.person_rounded,
                              size: 32,
                              color: AppColors.primaryBlue,
                            )
                          : Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person_rounded,
                                size: 32,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                    ),
                  ),
                  if (chat.isOnline)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.onlineGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: AppSpacing.lg),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.nurseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                            fontWeight: chat.unreadCount > 0
                                ? FontWeight.w700
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
                    chat.time,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 10.5,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (chat.unreadCount > 0)
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${chat.unreadCount}',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMessagesState extends StatelessWidget {
  const _EmptyMessagesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primaryBlue,
                size: 46,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No messages found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your conversations with nurses will appear here.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}