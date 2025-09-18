import 'dart:convert';
import 'package:http/http.dart' as http;

class MistralService {
  static const String _baseUrl = 'https://api.mistral.ai/v1';
  static const String _apiKey = 'HrFeGigJieGKMsPcw81lYUtEEvPI4CZn';
  
  // Mistral model to use
  static const String _model = 'mistral-tiny';

  /// Send a message to Mistral AI and get a response
  static Future<String> sendMessage(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': '''You are a helpful AI assistant with special capabilities. You can:

1. Change background colors when users ask (commands like "cambia el color", "change color", "cambiar fondo")
2. Start new chats when users ask (commands like "nuevo chat", "new chat", "iniciar chat", "limpiar chat")
3. Show available themes when users ask about "temas" or "themes"

Available color themes: Ocean, Sunset, Forest, Purple, Pink, Blue, Green, Fire, Night, Aurora, Galaxy, Default

When users ask about colors or themes, mention that they can say "cambia el color a [tema]" to change the background.
When users want to start fresh, mention they can say "nuevo chat" to clear the conversation.

Respond in a friendly and conversational manner. Keep responses concise but informative.'''
            },
            {
              'role': 'user',
              'content': userMessage,
            }
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'Sorry, I couldn\'t generate a response.';
      } else {
        print('Mistral API Error: ${response.statusCode} - ${response.body}');
        return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      print('Mistral API Exception: $e');
      return _getFallbackResponse(userMessage);
    }
  }

  /// Fallback response when API fails
  static String _getFallbackResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('hello') || message.contains('hi')) {
      return 'Hello! I\'m your AI assistant. How can I help you today?';
    } else if (message.contains('how are you')) {
      return 'I\'m doing great, thank you for asking! How are you feeling today?';
    } else if (message.contains('weather')) {
      return 'I don\'t have access to real-time weather data, but I can help you with many other topics!';
    } else if (message.contains('help')) {
      return 'I\'m here to help! You can ask me about various topics, or we can just have a conversation.';
    } else if (message.contains('bye') || message.contains('goodbye')) {
      return 'Goodbye! It was nice chatting with you. Feel free to come back anytime!';
    } else {
      return 'That\'s interesting! Tell me more about that. I\'m here to listen and help.';
    }
  }

  /// Test the API connection
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Mistral API Connection Test Failed: $e');
      return false;
    }
  }
}

