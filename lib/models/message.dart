class Message {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final bool isFromUser;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    required this.isFromUser,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      timestamp: DateTime.parse(json['timestamp']),
      isFromUser: json['isFromUser'],
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
    };
  }
}

