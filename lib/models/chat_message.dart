// ignore_for_file: public_member_api_docs, sort_constructors_first
class ChatMessage {
  ChatMessage({
    required this.from,
    required this.to,
    required this.msg,
    required this.fromUsername,
    required this.imgUrl,
    required this.timestamp,
  });
  final String from;
  final String to;
  final String msg;
  final String fromUsername;
  final String imgUrl; 
  final int timestamp;
}
