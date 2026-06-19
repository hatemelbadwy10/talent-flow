import 'package:flutter_test/flutter_test.dart';
import 'package:talent_flow/features/home/model/chat_model.dart';
import 'package:talent_flow/features/setting/model/chats_model.dart';

void main() {
  test('conversations sort newest first', () {
    final chats = [
      _chat(id: 1, date: '2026-06-10T10:00:00Z'),
      _chat(id: 3, date: '2026-06-12T10:00:00Z'),
      _chat(id: 2, date: '2026-06-11T10:00:00Z'),
    ]..sort(ChatsModel.compareNewestFirst);

    expect(chats.map((chat) => chat.id), [3, 2, 1]);
  });

  test('conversations without dates use newest id first', () {
    final chats = [
      _chat(id: 1),
      _chat(id: 3),
      _chat(id: 2),
    ]..sort(ChatsModel.compareNewestFirst);

    expect(chats.map((chat) => chat.id), [3, 2, 1]);
  });

  test('conversations sort by Arabic last-message relative time', () {
    final chats = [
      _chat(id: 1, since: 'منذ شهر'),
      _chat(id: 2, since: 'منذ يوم'),
      _chat(id: 3, since: 'منذ شهرين'),
      _chat(id: 4, since: 'منذ 3 أسابيع'),
    ]..sort(ChatsModel.compareNewestFirst);

    expect(chats.map((chat) => chat.id), [2, 4, 1, 3]);
  });

  test('conversation uses nested last-message timestamp', () {
    final chats = [
      ChatsModel.fromJson({
        'id': 1,
        'last_message': {'created_at': '2026-06-10T10:00:00Z'},
      }),
      ChatsModel.fromJson({
        'id': 2,
        'last_message': {'created_at': '2026-06-12T10:00:00Z'},
      }),
    ]..sort(ChatsModel.compareNewestFirst);

    expect(chats.map((chat) => chat.id), [2, 1]);
  });

  test('messages sort oldest to newest for chat rendering', () {
    final messages = [
      _message(id: 3, createdAt: '2026-06-12T10:00:00Z'),
      _message(id: 1, createdAt: '2026-06-10T10:00:00Z'),
      _message(id: 2, createdAt: '2026-06-11T10:00:00Z'),
    ]..sort(Message.compareChronologically);

    expect(messages.map((message) => message.id), [1, 2, 3]);
  });
}

ChatsModel _chat({required int id, String? date, String? since}) {
  return ChatsModel.fromJson({
    'id': id,
    if (date != null) 'date': date,
    if (since != null) 'since': since,
  });
}

Message _message({required int id, required String createdAt}) {
  return Message.fromJson({
    'id': id,
    'message': 'Message $id',
    'created_at': createdAt,
  });
}
