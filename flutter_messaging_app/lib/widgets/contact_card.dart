import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';

class ContactCard extends StatelessWidget {
  final User contact;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final VoidCallback onTap;
  final bool isSelected;

  const ContactCard({
    Key? key,
    required this.contact,
    this.lastMessage,
    this.lastMessageTime,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isSelected ? Colors.blue[600]! : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[300],
              backgroundImage: contact.avatarUrl != null 
                  ? NetworkImage(contact.avatarUrl!) 
                  : null,
              child: contact.avatarUrl == null
                  ? Text(
                      contact.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    )
                  : null,
            ),
            if (contact.isOnline)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          contact.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isSelected ? Colors.blue[700] : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lastMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                lastMessage!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ] else if (!contact.isOnline && contact.lastSeen != null) ...[
              const SizedBox(height: 4),
              Text(
                'Vu ${_formatLastSeen(contact.lastSeen!)}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ] else if (contact.isOnline) ...[
              const SizedBox(height: 4),
              Text(
                'En ligne',
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (lastMessageTime != null) ...[
              Text(
                _formatMessageTime(lastMessageTime!),
                style: TextStyle(
                  color: isSelected ? Colors.blue[600] : Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
            ],
            if (isSelected)
              Icon(
                Icons.chevron_right,
                color: Colors.blue[600],
                size: 20,
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'à l\'instant';
    } else if (difference.inHours < 1) {
      return 'il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'il y a ${difference.inDays}j';
    } else {
      return DateFormat('dd/MM/yyyy').format(lastSeen);
    }
  }

  String _formatMessageTime(DateTime messageTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(messageTime.year, messageTime.month, messageTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(messageTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hier';
    } else if (now.difference(messageTime).inDays < 7) {
      return DateFormat('E', 'fr_FR').format(messageTime);
    } else {
      return DateFormat('dd/MM').format(messageTime);
    }
  }
}
