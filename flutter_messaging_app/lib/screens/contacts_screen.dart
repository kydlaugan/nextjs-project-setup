import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/contact_card.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final contacts = chatProvider.contacts.where((contact) {
          if (_searchQuery.isEmpty) return true;
          return contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 contact.email.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        // Sort contacts: online first, then by last message time
        contacts.sort((a, b) {
          // Online contacts first
          if (a.isOnline && !b.isOnline) return -1;
          if (!a.isOnline && b.isOnline) return 1;

          // Then by last message time
          final aLastTime = chatProvider.getLastMessageTime(a);
          final bLastTime = chatProvider.getLastMessageTime(b);
          
          if (aLastTime != null && bLastTime != null) {
            return bLastTime.compareTo(aLastTime);
          } else if (aLastTime != null) {
            return -1;
          } else if (bLastTime != null) {
            return 1;
          }
          
          // Finally by name
          return a.name.compareTo(b.name);
        });

        return Scaffold(
          appBar: AppBar(
            elevation: 1,
            backgroundColor: Colors.white,
            title: const Text(
              'Messages',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black87),
                onPressed: () {
                  _showSearchDialog(context);
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black87),
                onSelected: (value) {
                  switch (value) {
                    case 'new_chat':
                      _showNewChatDialog(context);
                      break;
                    case 'settings':
                      _showSettingsDialog(context);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'new_chat',
                    child: Row(
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Nouvelle conversation'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, size: 20),
                        SizedBox(width: 12),
                        Text('Paramètres'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              if (_searchQuery.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Résultats pour "$_searchQuery"',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                        child: const Text('Effacer'),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: chatProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : contacts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchQuery.isNotEmpty
                                      ? Icons.search_off
                                      : Icons.people_outline,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Aucun résultat'
                                      : 'Aucun contact',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Essayez avec d\'autres mots-clés'
                                      : 'Vos conversations apparaîtront ici',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await chatProvider.initialize();
                            },
                            child: ListView.separated(
                              itemCount: contacts.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: Colors.grey[200],
                                indent: 76,
                              ),
                              itemBuilder: (context, index) {
                                final contact = contacts[index];
                                final lastMessage = chatProvider.getLastMessageContent(contact);
                                final lastMessageTime = chatProvider.getLastMessageTime(contact);
                                final isSelected = chatProvider.selectedContact?.id == contact.id;

                                return ContactCard(
                                  contact: contact,
                                  lastMessage: lastMessage,
                                  lastMessageTime: lastMessageTime,
                                  isSelected: isSelected,
                                  onTap: () {
                                    chatProvider.selectContact(contact);
                                    chatProvider.markMessagesAsRead();
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showNewChatDialog(context);
            },
            backgroundColor: Colors.blue[600],
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Nom ou email...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value;
            });
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = _searchController.text;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Rechercher'),
          ),
        ],
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle conversation'),
        content: const Text(
          'Cette fonctionnalité permettra d\'ajouter de nouveaux contacts et de démarrer de nouvelles conversations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité à venir !'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paramètres'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité à venir !'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Mode sombre'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité à venir !'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Langue'),
              subtitle: const Text('Français'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité à venir !'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
