import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../controllers/background_controller.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/animated_background.dart';
import '../widgets/debug_state_indicator.dart';
import '../widgets/state_test_controls.dart';
import '../widgets/connection_status.dart';
import '../widgets/command_helper.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize BackgroundController first
    Get.put(BackgroundController(), tag: 'background');
    
    final ChatController chatController = Get.put(ChatController());
    final TextEditingController textController = TextEditingController();

    return AnimatedBackground(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('AI Chat'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              actions: [
                IconButton(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Clear Chat'),
                        content: const Text('Are you sure you want to clear all messages?'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              chatController.clearMessages();
                              Get.back();
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.clear_all),
                ),
              ],
            ),
            body: Column(
              children: [
                // Messages List
                Expanded(
                  child: Obx(() {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: chatController.messages.length + 
                          (chatController.isTyping.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chatController.messages.length && 
                            chatController.isTyping.value) {
                          return const TypingIndicator();
                        }
                        
                        final message = chatController.messages[index];
                        return MessageBubble(message: message);
                      },
                    );
                  }),
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
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (text) {
                            if (text.trim().isNotEmpty) {
                              chatController.sendMessage(text);
                              textController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(() {
                        return FloatingActionButton(
                          onPressed: chatController.isLoading.value
                              ? null
                              : () {
                                  if (textController.text.trim().isNotEmpty) {
                                    chatController.sendMessage(textController.text);
                                    textController.clear();
                                  }
                                },
                          mini: true,
                          child: chatController.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                        );
                      }),
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