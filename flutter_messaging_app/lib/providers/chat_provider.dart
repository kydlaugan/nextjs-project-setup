import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/message_service.dart';

class ChatProvider with ChangeNotifier {
  final MessageService _messageService = MessageService();
  final Uuid _uuid = const Uuid();

  List<Message> _messages = [];
  List<User> _contacts = [];
  User? _currentUser;
  User? _selectedContact;
  bool _isLoading = false;
  bool _isTyping = false;

  List<Message> get messages => _messages;
  List<User> get contacts => _contacts;
  User? get currentUser => _currentUser;
  User? get selectedContact => _selectedContact;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;

  List<Message> get currentChatMessages {
    if (_selectedContact == null || _currentUser == null) return [];
    return _messages.where((message) =>
      (message.senderId == _currentUser!.id && message.receiverId == _selectedContact!.id) ||
      (message.senderId == _selectedContact!.id && message.receiverId == _currentUser!.id)
    ).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // Initialize current user
    _currentUser = User(
      id: 'current_user',
      name: 'Moi',
      email: 'moi@example.com',
      isOnline: true,
    );

    // Load sample contacts
    _contacts = [
      User(
        id: 'user_1',
        name: 'Alice Martin',
        email: 'alice@example.com',
        isOnline: true,
      ),
      User(
        id: 'user_2',
        name: 'Bob Dupont',
        email: 'bob@example.com',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      User(
        id: 'user_3',
        name: 'Claire Bernard',
        email: 'claire@example.com',
        isOnline: true,
      ),
      User(
        id: 'user_4',
        name: 'David Moreau',
        email: 'david@example.com',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    // Load messages from storage
    await _loadMessages();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadMessages() async {
    try {
      _messages = await _messageService.loadMessages();
    } catch (e) {
      debugPrint('Erreur lors du chargement des messages: $e');
      _messages = [];
    }
  }

  Future<void> sendMessage(String content) async {
    if (_selectedContact == null || _currentUser == null || content.trim().isEmpty) {
      return;
    }

    final message = Message(
      id: _uuid.v4(),
      senderId: _currentUser!.id,
      receiverId: _selectedContact!.id,
      content: content.trim(),
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      isMe: true,
    );

    _messages.add(message);
    notifyListeners();

    // Save to storage
    await _messageService.saveMessage(message);

    // Simulate message delivery
    await Future.delayed(const Duration(milliseconds: 500));
    _updateMessageStatus(message.id, MessageStatus.delivered);

    // Simulate auto-reply after 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    await _simulateReply();
  }

  Future<void> _simulateReply() async {
    if (_selectedContact == null || _currentUser == null) return;

    final replies = [
      'Salut ! Comment ça va ?',
      'Merci pour ton message !',
      'Je suis d\'accord avec toi.',
      'Intéressant, dis-moi en plus.',
      'À bientôt !',
      'Parfait, on se parle plus tard.',
    ];

    final reply = Message(
      id: _uuid.v4(),
      senderId: _selectedContact!.id,
      receiverId: _currentUser!.id,
      content: replies[DateTime.now().millisecond % replies.length],
      timestamp: DateTime.now(),
      status: MessageStatus.delivered,
      isMe: false,
    );

    _messages.add(reply);
    notifyListeners();

    await _messageService.saveMessage(reply);
  }

  void _updateMessageStatus(String messageId, MessageStatus status) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(status: status);
      notifyListeners();
    }
  }

  void selectContact(User contact) {
    _selectedContact = contact;
    notifyListeners();
  }

  void setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  void markMessagesAsRead() {
    if (_selectedContact == null || _currentUser == null) return;

    bool hasChanges = false;
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].senderId == _selectedContact!.id &&
          _messages[i].receiverId == _currentUser!.id &&
          _messages[i].status != MessageStatus.read) {
        _messages[i] = _messages[i].copyWith(status: MessageStatus.read);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  User? getLastMessageSender(User contact) {
    final chatMessages = _messages.where((message) =>
      (message.senderId == _currentUser!.id && message.receiverId == contact.id) ||
      (message.senderId == contact.id && message.receiverId == _currentUser!.id)
    ).toList();

    if (chatMessages.isEmpty) return null;
    
    chatMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final lastMessage = chatMessages.first;
    
    return lastMessage.senderId == _currentUser!.id ? _currentUser : contact;
  }

  String? getLastMessageContent(User contact) {
    final chatMessages = _messages.where((message) =>
      (message.senderId == _currentUser!.id && message.receiverId == contact.id) ||
      (message.senderId == contact.id && message.receiverId == _currentUser!.id)
    ).toList();

    if (chatMessages.isEmpty) return null;
    
    chatMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return chatMessages.first.content;
  }

  DateTime? getLastMessageTime(User contact) {
    final chatMessages = _messages.where((message) =>
      (message.senderId == _currentUser!.id && message.receiverId == contact.id) ||
      (message.senderId == contact.id && message.receiverId == _currentUser!.id)
    ).toList();

    if (chatMessages.isEmpty) return null;
    
    chatMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return chatMessages.first.timestamp;
  }
}
