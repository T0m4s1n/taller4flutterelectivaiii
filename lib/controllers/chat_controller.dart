import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/mistral_service.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'background_controller.dart';

class ChatController extends ChangeNotifier {
  // Observable lists for reactive UI updates
  final List<Message> _messages = <Message>[];
  bool _isLoading = false;
  bool _isTyping = false;
  final List<Map<String, dynamic>> _chats = <Map<String, dynamic>>[];
  String? _currentChatId;
  
  // AI user (for demo purposes)
  final User aiUser = User(
    id: 'ai_1',
    name: 'AI Assistant',
    email: 'ai@assistant.com',
  );

  // Background controller reference
  BackgroundController? _backgroundController;

  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  List<Map<String, dynamic>> get chats => _chats;
  String? get currentChatId => _currentChatId;

  // Get current user from auth service
  User? get currentUser {
    try {
      return AuthService.instance.currentUser;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  void initialize() {
    // Initialize background controller
    try {
      // We'll handle background controller separately since it's not critical
      print('Chat controller initialized');
    } catch (e) {
      print('Background controller not found: $e');
    }
    // Load user chats and start new chat if needed
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      if (currentUser != null) {
        await loadUserChats();
        if (_chats.isEmpty) {
          await createNewChat();
        } else {
          // Load the most recent chat
          _currentChatId = _chats.first['id'];
          await loadChatMessages(_currentChatId!);
        }
      } else {
        // Add welcome message for non-authenticated users
        _addWelcomeMessage();
      }
    } catch (e) {
      print('Error initializing chat: $e');
      // Fallback: just add welcome message
      _addWelcomeMessage();
    }
  }

  void _addWelcomeMessage() {
    final welcomeMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: 'Hello! I\'m your AI assistant powered by Mistral. How can I help you today?',
      senderId: aiUser.id,
      senderName: aiUser.name,
      timestamp: DateTime.now(),
      isFromUser: false,
      chatId: _currentChatId,
    );
    _messages.add(welcomeMessage);
    notifyListeners();
  }

  // Database operations
  Future<void> loadUserChats() async {
    if (currentUser != null) {
      final userChats = await DatabaseService.getUserChats(currentUser!.id);
      _chats.clear();
      _chats.addAll(userChats);
      notifyListeners();
    }
  }

  Future<void> createNewChat({String? title}) async {
    if (currentUser != null) {
      final chatTitle = title ?? 'New Chat - ${DateTime.now().day}/${DateTime.now().month}';
      final chatId = await DatabaseService.createChat(
        userId: currentUser!.id,
        title: chatTitle,
      );
      _currentChatId = chatId;
      _messages.clear();
      _addWelcomeMessage();
      await loadUserChats(); // Refresh chat list
      
      // Save welcome message to database
      if (_messages.isNotEmpty) {
        await DatabaseService.insertMessage(_messages.last, chatId);
      }
      notifyListeners();
    }
  }

  Future<void> loadChatMessages(String chatId) async {
    _currentChatId = chatId;
    final chatMessages = await DatabaseService.getChatMessages(chatId);
    _messages.clear();
    _messages.addAll(chatMessages);
    notifyListeners();
  }

  Future<void> switchToChat(String chatId) async {
    await loadChatMessages(chatId);
  }

  Future<void> deleteChat(String chatId) async {
    await DatabaseService.deleteChat(chatId);
    await loadUserChats();
    
    if (_currentChatId == chatId) {
      if (_chats.isNotEmpty) {
        await switchToChat(_chats.first['id']);
      } else {
        await createNewChat();
      }
    }
    notifyListeners();
  }

  Future<void> renameChatTitle(String chatId, String newTitle) async {
    await DatabaseService.updateChatTitle(chatId, newTitle);
    await loadUserChats();
    notifyListeners();
  }

  // Test API connection
  Future<bool> testAPIConnection() async {
    return await MistralService.testConnection();
  }

  // Send a message
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || currentUser == null) return;

    // Ensure we have a current chat
    if (_currentChatId == null) {
      await createNewChat();
    }

    // Check for special commands first
    if (await _handleSpecialCommands(text.trim())) {
      return;
    }

    // Change background state to user typing
    _backgroundController?.changeState(BackgroundState.userTyping);

    // Add user message
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      senderId: currentUser!.id,
      senderName: currentUser!.name,
      timestamp: DateTime.now(),
      isFromUser: true,
      chatId: _currentChatId,
    );
    
    _messages.add(userMessage);
    notifyListeners();
    
    // Save user message to database
    if (_currentChatId != null) {
      await DatabaseService.insertMessage(userMessage, _currentChatId!);
    }
    
    // Change background state to AI typing
    _backgroundController?.changeState(BackgroundState.aiTyping);
    
    // Get AI response
    _simulateAIResponse(text.trim());
  }

  // Handle special commands
  Future<bool> _handleSpecialCommands(String text) async {
    final lowerText = text.toLowerCase();
    
    // Check for color change commands
    if (lowerText.contains('cambia el color') || lowerText.contains('change color') || 
        lowerText.contains('cambiar color') || lowerText.contains('cambiar fondo')) {
      await _handleColorChangeCommand(text);
      return true;
    }
    
    // Check for new chat commands
    if (lowerText.contains('nuevo chat') || lowerText.contains('new chat') || 
        lowerText.contains('iniciar chat') || lowerText.contains('start chat') ||
        lowerText.contains('limpiar chat') || lowerText.contains('clear chat')) {
      await _handleNewChatCommand();
      return true;
    }
    
    // Check for theme commands
    if (lowerText.contains('tema') || lowerText.contains('theme')) {
      await _handleThemeCommand(text);
      return true;
    }
    
    return false;
  }

  // Handle color change commands
  Future<void> _handleColorChangeCommand(String text) async {
    final lowerText = text.toLowerCase();
    String? selectedTheme;
    
    // Check for specific theme mentions
    if (lowerText.contains('azul') || lowerText.contains('blue')) {
      selectedTheme = 'Blue';
    } else if (lowerText.contains('verde') || lowerText.contains('green')) {
      selectedTheme = 'Green';
    } else if (lowerText.contains('rosa') || lowerText.contains('pink')) {
      selectedTheme = 'Pink';
    } else if (lowerText.contains('morado') || lowerText.contains('purple')) {
      selectedTheme = 'Purple';
    } else if (lowerText.contains('océano') || lowerText.contains('ocean')) {
      selectedTheme = 'Ocean';
    } else if (lowerText.contains('atardecer') || lowerText.contains('sunset')) {
      selectedTheme = 'Sunset';
    } else if (lowerText.contains('bosque') || lowerText.contains('forest')) {
      selectedTheme = 'Forest';
    } else if (lowerText.contains('fuego') || lowerText.contains('fire')) {
      selectedTheme = 'Fire';
    } else if (lowerText.contains('noche') || lowerText.contains('night')) {
      selectedTheme = 'Night';
    } else if (lowerText.contains('aurora') || lowerText.contains('aurora')) {
      selectedTheme = 'Aurora';
    } else if (lowerText.contains('galaxia') || lowerText.contains('galaxy')) {
      selectedTheme = 'Galaxy';
    } else {
      // Default to a random theme
      final themes = _backgroundController?.availableThemes.keys.toList() ?? [];
      if (themes.isNotEmpty) {
        selectedTheme = themes[DateTime.now().millisecondsSinceEpoch % themes.length];
      }
    }
    
    if (selectedTheme != null) {
      _backgroundController?.applyTheme(selectedTheme);
      
      // Add confirmation message
      final confirmationMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '¡Perfecto! He cambiado el color del fondo al tema "$selectedTheme". ¿Te gusta cómo se ve?',
        senderId: aiUser.id,
        senderName: aiUser.name,
        timestamp: DateTime.now(),
        isFromUser: false,
        chatId: _currentChatId,
      );
      _messages.add(confirmationMessage);
      
      // Save message to database
      if (_currentChatId != null) {
        await DatabaseService.insertMessage(confirmationMessage, _currentChatId!);
      }
      
      // Change background state to message received
      _backgroundController?.changeState(BackgroundState.messageReceived);
      
      notifyListeners();
      
      // Return to idle state after a delay
      Future.delayed(const Duration(seconds: 2), () {
        _backgroundController?.changeState(BackgroundState.idle);
      });
    }
  }

  // Handle new chat commands
  Future<void> _handleNewChatCommand() async {
    await createNewChat();
    
    // Reset background colors to default
    _backgroundController?.resetColors();
    
    // Change background state to message received
    _backgroundController?.changeState(BackgroundState.messageReceived);
    
    // Return to idle state after a delay
    Future.delayed(const Duration(seconds: 2), () {
      _backgroundController?.changeState(BackgroundState.idle);
    });
  }

  // Handle theme commands
  Future<void> _handleThemeCommand(String text) async {
    final themes = _backgroundController?.availableThemes.keys.toList() ?? [];
    if (themes.isNotEmpty) {
      final themeList = themes.join(', ');
      final themeMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Temas disponibles: $themeList\n\nPuedes decir "cambia el color a [tema]" para cambiar el fondo.',
        senderId: aiUser.id,
        senderName: aiUser.name,
        timestamp: DateTime.now(),
        isFromUser: false,
        chatId: _currentChatId,
      );
      _messages.add(themeMessage);
      
      // Save message to database
      if (_currentChatId != null) {
        await DatabaseService.insertMessage(themeMessage, _currentChatId!);
      }
      
      // Change background state to message received
      _backgroundController?.changeState(BackgroundState.messageReceived);
      
      notifyListeners();
      
      // Return to idle state after a delay
      Future.delayed(const Duration(seconds: 2), () {
        _backgroundController?.changeState(BackgroundState.idle);
      });
    }
  }

  // Get AI response from Mistral API
  void _simulateAIResponse(String userMessage) {
    _isLoading = true;
    _isTyping = true;
    notifyListeners();
    
    // Call Mistral API
    MistralService.sendMessage(userMessage).then((aiResponse) {
      _isTyping = false;
      
      final aiMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: aiResponse,
        senderId: aiUser.id,
        senderName: aiUser.name,
        timestamp: DateTime.now(),
        isFromUser: false,
        chatId: _currentChatId,
      );
      
      _messages.add(aiMessage);
      _isLoading = false;
      
      // Save AI message to database
      if (_currentChatId != null) {
        DatabaseService.insertMessage(aiMessage, _currentChatId!);
      }
      
      // Change background state to message received
      _backgroundController?.changeState(BackgroundState.messageReceived);
      
      notifyListeners();
      
      // Return to idle state after a delay
      Future.delayed(const Duration(seconds: 2), () {
        _backgroundController?.changeState(BackgroundState.idle);
      });
    }).catchError((error) {
      // Handle API error
      _isTyping = false;
      _isLoading = false;
      
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Sorry, I encountered an error. Please try again.',
        senderId: aiUser.id,
        senderName: aiUser.name,
        timestamp: DateTime.now(),
        isFromUser: false,
        chatId: _currentChatId,
      );
      
      _messages.add(errorMessage);
      
      // Save error message to database
      if (_currentChatId != null) {
        DatabaseService.insertMessage(errorMessage, _currentChatId!);
      }
      
      // Change background state to error
      _backgroundController?.changeState(BackgroundState.error);
      
      notifyListeners();
      
      // Return to idle state after a delay
      Future.delayed(const Duration(seconds: 3), () {
        _backgroundController?.changeState(BackgroundState.idle);
      });
    });
  }

  // Clear all messages
  void clearMessages() {
    _messages.clear();
    _addWelcomeMessage();
    notifyListeners();
  }

  // Get message count
  int get messageCount => _messages.length;

  // Check if there are any messages
  bool get hasMessages => _messages.isNotEmpty;
}