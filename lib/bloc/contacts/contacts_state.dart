import 'package:chat_app/models/chat_user.dart';
import 'package:equatable/equatable.dart';

class ContactsState extends Equatable {
  ContactsState({
    required this.contacts,
    this.failed = false
  });

  final Map<String, ChatUser> contacts; // uid to Contact
  late final bool failed;

  factory ContactsState.initial() {
    return ContactsState(contacts: const {},);
  }
  
  ContactsState copyWith({
    Map<String, ChatUser>? contacts,
    bool? failed,
  }) {
    return ContactsState(
      contacts: contacts ?? this.contacts,
      failed: failed ?? false,
    );
  }

  @override
  List<Object?> get props => [contacts, failed];

  Map<String, dynamic> toMap() {
    final r = contacts.entries.map((entry) => MapEntry(entry.key, entry.value.toMap()));

    final res = {'contacts': Map<String, dynamic>.fromEntries(r)};
    return res;
  }

  factory ContactsState.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> contactsMap = map['contacts'];

    final r = contactsMap.entries.map((entry) => MapEntry(entry.key, ChatUser.fromMap(entry.value)));
    final res = ContactsState(
      contacts: Map<String, ChatUser>.fromEntries(r),
    );

    return res;
  }
}
