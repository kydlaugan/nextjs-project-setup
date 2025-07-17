import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class MessageService {
  static const String _messagesKey = 'messages';

  Future<List<Message>> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey);
      
      if (messagesJson == null) return [];
      
      final List<dynamic> messagesList = json.decode(messagesJson);
      return messagesList.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      print('Erreur lors du chargement des messages: $e');
      return [];
    }
  }

  Future<void> saveMessage(Message message) async {
    try {
      final messages = await loadMessages();
      messages.add(message);
      await _saveAllMessages(messages);
    } catch (e) {
      print('Erreur lors de la sauvegarde du message: $e');
    }
  }

  Future<void> _saveAllMessages(List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = json.encode(messages.map((m) => m.toJson()).toList());
      await prefs.setString(_messagesKey, messagesJson);
    } catch (e) {
      print('Erreur lors de la sauvegarde de tous les messages: $e');
    }
  }

  Future<void> clearAllMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_messagesKey);
    } catch (e) {
      print('Erreur lors de la suppression des messages: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final messages = await loadMessages();
      messages.removeWhere((message) => message.id == messageId);
      await _saveAllMessages(messages);
    } catch (e) {
      print('Erreur lors de la suppression du message: $e');
    }
  }

  Future<List<Message>> getMessagesForChat(String userId1, String userId2) async {
    try {
      final allMessages = await loadMessages();
      return allMessages.where((message) =>
        (message.senderId == userId1 && message.receiverId == userId2) ||
        (message.senderId == userId2 && message.receiverId == userId1)
      ).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      print('Erreur lors de la récupération des messages du chat: $e');
      return [];
    }
  }
}
