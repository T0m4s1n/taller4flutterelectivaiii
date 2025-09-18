import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/message.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'chat_app.db';
  static const int _dbVersion = 1;

  // Table names
  static const String _usersTable = 'users';
  static const String _messagesTable = 'messages';
  static const String _chatsTable = 'chats';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE $_usersTable (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        avatar_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create chats table
    await db.execute('''
      CREATE TABLE $_chatsTable (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $_usersTable (id) ON DELETE CASCADE
      )
    ''');

    // Create messages table
    await db.execute('''
      CREATE TABLE $_messagesTable (
        id TEXT PRIMARY KEY,
        chat_id TEXT NOT NULL,
        text TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        sender_name TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        is_from_user INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (chat_id) REFERENCES $_chatsTable (id) ON DELETE CASCADE,
        FOREIGN KEY (sender_id) REFERENCES $_usersTable (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_messages_chat_id ON $_messagesTable (chat_id)');
    await db.execute('CREATE INDEX idx_messages_timestamp ON $_messagesTable (timestamp)');
    await db.execute('CREATE INDEX idx_chats_user_id ON $_chatsTable (user_id)');
  }

  // User operations
  static Future<String?> registerUser({
    required String email,
    required String name,
    required String password,
    String? avatarUrl,
  }) async {
    final db = await database;
    
    // Check if user already exists
    final existingUser = await db.query(
      _usersTable,
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (existingUser.isNotEmpty) {
      throw Exception('User with this email already exists');
    }

    // Hash password
    final passwordHash = _hashPassword(password);
    final userId = _generateId();
    final now = DateTime.now().toIso8601String();

    await db.insert(_usersTable, {
      'id': userId,
      'email': email,
      'name': name,
      'password_hash': passwordHash,
      'avatar_url': avatarUrl,
      'created_at': now,
      'updated_at': now,
    });

    return userId;
  }

  static Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await database;
    
    final result = await db.query(
      _usersTable,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isEmpty) {
      return null;
    }

    final userData = result.first;
    final storedHash = userData['password_hash'] as String;
    
    if (!_verifyPassword(password, storedHash)) {
      return null;
    }

    return User.fromDatabaseMap(userData);
  }

  static Future<User?> getUserById(String userId) async {
    final db = await database;
    
    final result = await db.query(
      _usersTable,
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isEmpty) {
      return null;
    }

    return User.fromDatabaseMap(result.first);
  }

  // Chat operations
  static Future<String> createChat({
    required String userId,
    required String title,
  }) async {
    final db = await database;
    final chatId = _generateId();
    final now = DateTime.now().toIso8601String();

    await db.insert(_chatsTable, {
      'id': chatId,
      'user_id': userId,
      'title': title,
      'created_at': now,
      'updated_at': now,
    });

    return chatId;
  }

  static Future<List<Map<String, dynamic>>> getUserChats(String userId) async {
    final db = await database;
    
    return await db.query(
      _chatsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
  }

  static Future<void> deleteChat(String chatId) async {
    final db = await database;
    await db.delete(_chatsTable, where: 'id = ?', whereArgs: [chatId]);
  }

  static Future<void> updateChatTitle(String chatId, String newTitle) async {
    final db = await database;
    await db.update(
      _chatsTable,
      {
        'title': newTitle,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }

  // Message operations
  static Future<void> insertMessage(Message message, String chatId) async {
    final db = await database;
    
    await db.insert(_messagesTable, {
      'id': message.id,
      'chat_id': chatId,
      'text': message.text,
      'sender_id': message.senderId,
      'sender_name': message.senderName,
      'timestamp': message.timestamp.toIso8601String(),
      'is_from_user': message.isFromUser ? 1 : 0,
    });

    // Update chat's updated_at timestamp
    await db.update(
      _chatsTable,
      {'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }

  static Future<List<Message>> getChatMessages(String chatId) async {
    final db = await database;
    
    final result = await db.query(
      _messagesTable,
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp ASC',
    );

    return result.map((map) => Message.fromDatabaseMap(map)).toList();
  }

  static Future<void> deleteMessage(String messageId) async {
    final db = await database;
    await db.delete(_messagesTable, where: 'id = ?', whereArgs: [messageId]);
  }

  static Future<void> clearChatMessages(String chatId) async {
    final db = await database;
    await db.delete(_messagesTable, where: 'chat_id = ?', whereArgs: [chatId]);
  }

  // Utility methods
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool _verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }

  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (1000 + (999 * (DateTime.now().microsecond / 1000000))).floor().toString();
  }

  // Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
