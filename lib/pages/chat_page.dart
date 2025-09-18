import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/chat_controller.dart';
import '../controllers/background_controller.dart';
import '../controllers/theme_controller.dart';
import '../services/auth_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/animated_background.dart';
import '../widgets/debug_state_indicator.dart';
import '../widgets/state_test_controls.dart';
import '../widgets/connection_status.dart';
import '../widgets/command_helper.dart';
import '../widgets/chat_sidebar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            drawer: const ChatSidebar(),
            appBar: AppBar(
              title: Consumer<AuthService>(
                builder: (context, authService, child) => Text(
                  authService.currentUser?.name != null 
                      ? 'AI Chat - ${authService.currentUser!.name}'
                      : 'AI Chat'
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    final chatController = Provider.of<ChatController>(context, listen: false);
                    final themeController = Provider.of<ThemeController>(context, listen: false);
                    final authService = Provider.of<AuthService>(context, listen: false);
                    
                    switch (value) {
                      case 'new_chat':
                        await chatController.createNewChat();
                        break;
                      case 'clear_chat':
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Clear Chat'),
                            content: const Text('Are you sure you want to clear all messages?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  chatController.clearMessages();
                                  Navigator.pop(context);
                                },
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        );
                        break;
                      case 'dark_mode':
                        await themeController.toggleTheme();
                        break;
                      case 'logout':
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await authService.logout();
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'new_chat',
                      child: Row(
                        children: [
                          Icon(Icons.add_comment),
                          SizedBox(width: 8),
                          Text('New Chat'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'clear_chat',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all),
                          SizedBox(width: 8),
                          Text('Clear Chat'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'dark_mode',
                      child: Consumer<ThemeController>(
                        builder: (context, themeController, child) => Row(
                          children: [
                            Icon(themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                            const SizedBox(width: 8),
                            Text(themeController.isDarkMode ? 'Light Mode' : 'Dark Mode'),
                          ],
                        ),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Logout', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: Column(
              children: [
                // Messages List
                Expanded(
                  child: Consumer<ChatController>(
                    builder: (context, chatController, child) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: chatController.messages.length + 
                          (chatController.isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chatController.messages.length && 
                            chatController.isTyping) {
                          return const TypingIndicator();
                        }
                        
                        final message = chatController.messages[index];
                        return MessageBubble(message: message);
                      },
                    );
                  },),
                ),
                
                // Message Input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (text) {
                            if (text.trim().isNotEmpty) {
                              final chatController = Provider.of<ChatController>(context, listen: false);
                              chatController.sendMessage(text);
                              _textController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Consumer<ChatController>(
                        builder: (context, chatController, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            onPressed: chatController.isLoading
                                ? null
                                : () {
                                    if (_textController.text.trim().isNotEmpty) {
                                      chatController.sendMessage(_textController.text);
                                      _textController.clear();
                                    }
                                  },
                            icon: chatController.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Icon(
                                    Icons.send,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                          ),
                        );
                      },),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const DebugStateIndicator(),
          const ConnectionStatus(),
          const StateTestControls(),
          const CommandHelper(),
        ],
      ),
    );
  }
}