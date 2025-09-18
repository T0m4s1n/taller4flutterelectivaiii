class Message {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final bool isFromUser;
  final String? chatId;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    required this.isFromUser,
    this.chatId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      timestamp: DateTime.parse(json['timestamp']),
      isFromUser: json['isFromUser'],
      chatId: json['chatId'],
    );
  }

  factory Message.fromDatabaseMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      text: map['text'],
      senderId: map['sender_id'],
      senderName: map['sender_name'],
      timestamp: DateTime.parse(map['timestamp']),
      isFromUser: map['is_from_user'] == 1,
      chatId: map['chat_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp.toIso8601String(),
      'isFromUser': isFromUser,
      'chatId': chatId,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'text': text,
      'sender_id': senderId,
      'sender_name': senderName,
      'timestamp': timestamp.toIso8601String(),
      'is_from_user': isFromUser ? 1 : 0,
      'chat_id': chatId,
    };
  }
}

