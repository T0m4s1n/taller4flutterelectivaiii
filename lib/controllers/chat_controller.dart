import 'package:get/get.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/mistral_service.dart';
import 'background_controller.dart';

class ChatController extends GetxController {
  // Observable lists for reactive UI updates
  final RxList<Message> messages = <Message>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isTyping = false.obs;
  
  // Current user
  final User currentUser = User(
    id: 'user_1',
    name: 'You',
  );
  
  // AI user (for demo purposes)
  final User aiUser = User(
    id: 'ai_1',
    name: 'AI Assistant',
  );

  // Background controller reference
  BackgroundController? _backgroundController;

  @override
  void onInit() {
    super.onInit();
    // Initialize background controller
    _backgroundController = Get.find<BackgroundController>(tag: 'background');
    // Add welcome message
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: 'Hello! I\'m your AI assistant powered by Mistral. How can I help you today?',
      senderId: aiUser.id,
      senderName: aiUser.name,
      timestamp: DateTime.now(),
      isFromUser: false,
    );
    messages.add(welcomeMessage);
  }

  // Test API connection
  Future<bool> testAPIConnection() async {
    return await MistralService.testConnection();
  }

  // Send a message
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // Check for special commands first
    if (_handleSpecialCommands(text.trim())) {
      return;
    }

    // Change background state to user typing
    _backgroundController?.changeState(BackgroundState.userTyping);

    // Add user message
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      senderId: currentUser.id,
      senderName: currentUser.name,
      timestamp: DateTime.now(),
      isFromUser: true,
    );
    
    messages.add(userMessage);
    
    // Change background state to AI typing
    _backgroundController?.changeState(BackgroundState.aiTyping);
    
    // Get AI response
    _simulateAIResponse(text.trim());
  }

  // Handle special commands
  bool _handleSpecialCommands(String text) {
    final lowerText = text.toLowerCase();
    
    // Check for color change commands
    if (lowerText.contains('cambia el color') || lowerText.contains('change color') || 
        lowerText.contains('cambiar color') || lowerText.contains('cambiar fondo')) {
      _handleColorChangeCommand(text);
      return true;
    }
    
    // Check for new chat commands
    if (lowerText.contains('nuevo chat') || lowerText.contains('new chat') || 
        lowerText.contains('iniciar chat') || lowerText.contains('start chat') ||
        lowerText.contains('limpiar chat') || lowerText.contains('clear chat')) {
      _handleNewChatCommand();
      return true;
    }
    
    // Check for theme commands
    if (lowerText.contains('tema') || lowerText.contains('theme')) {
      _handleThemeCommand(text);
      return true;
    }
    
    return false;
  }

  // Handle color change commands
  void _handleColorChangeCommand(String text) {
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
      );
      messages.add(confirmationMessage);
      
      // Change background state to message received
      _backgroundController?.changeState(BackgroundState.messageReceived);
      
      // Return to idle state after a delay
      Future.delayed(const Duration(seconds: 2), () {
        _backgroundController?.changeState(BackgroundState.idle);
      });
    }
  }

  // Handle new chat commands
  void _handleNewChatCommand() {
    // Clear all messages
    messages.clear();
    
    // Add welcome message
    _addWelcomeMessage();
    
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
  void _handleThemeCommand(String text) {
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
      );
      messages.add(themeMessage);
      
      // Change background state to message received
      _backgroundController?.changeState(BackgroundState.messageReceived);
      
      // Return to idle state after a delay
      Future.delayed(const Duration(seconds: 2), () {
        _backgroundController?.changeState(BackgroundState.idle);
      });
    }
  }

  // Get AI response from Mistral API
  void _simulateAIResponse(String userMessage) {
    isLoading.value = true;
    isTyping.value = true;
    
    // Call Mistral API
    MistralService.sendMessage(userMessage).then((aiResponse) {
      isTyping.value = false;
      
      final aiMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: aiResponse,
        senderId: aiUser.id,
        senderName: aiUser.name,
        timestamp: DateTime.now(),
        isFromUser: false,
      );
      
      messages.add(aiMessage);
      isLoading.value = false;
      
      // Change background state to message received
      _backgroundController?.changeState(BackgroundState.messageReceived);
      
      // Return to idle state after a delay
      Future.delayed(const Duration(seconds: 2), () {
        _backgroundController?.changeState(BackgroundState.idle);
      });
    }).catchError((error) {
      // Handle API error
      isTyping.value = false;
      isLoading.value = false;
      
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Sorry, I encountered an error. Please try again.',
        senderId: aiUser.id,
        senderName: aiUser.name,
        timestamp: DateTime.now(),
        isFromUser: false,
      );
      
      messages.add(errorMessage);
      
      // Change background state to error
      _backgroundController?.changeState(BackgroundState.error);
      
      // Return to idle state after a delay
      Future.delayed(const Duration(seconds: 3), () {
        _backgroundController?.changeState(BackgroundState.idle);
      });
    });
  }


  // Clear all messages
  void clearMessages() {
    messages.clear();
    _addWelcomeMessage();
  }

  // Get message count
  int get messageCount => messages.length;

  // Check if there are any messages
  bool get hasMessages => messages.isNotEmpty;
}
