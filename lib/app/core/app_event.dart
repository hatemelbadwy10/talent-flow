abstract class AppEvent {
  Object? arguments;
  AppEvent({this.arguments});
}

class Follow extends AppEvent {
  Follow({super.arguments});
}

class UnFollow extends AppEvent {
  UnFollow({super.arguments});
}

class Block extends AppEvent {
  Block({super.arguments});
}

class UnBlock extends AppEvent {
  UnBlock({super.arguments});
}

class Track extends AppEvent {
  Track({super.arguments});
}

class Join extends AppEvent {
  Join({super.arguments});
}

class Leave extends AppEvent {
  Leave({super.arguments});
}

class Click extends AppEvent {
  Click({super.arguments});
}



class Accept extends AppEvent {
  Accept({super.arguments});
}

class Confirm extends AppEvent {
  Confirm({super.arguments});
}

class Reject extends AppEvent {
  Reject({super.arguments});
}

class Resend extends AppEvent {
  Resend({super.arguments});
}

class Remember extends AppEvent {
  Remember({super.arguments});
}

class Get extends AppEvent {
  Get({super.arguments});
}

class Read extends AppEvent {
  Read({super.arguments});
}

class Send extends AppEvent {
  Send({super.arguments});
}

class Hide extends AppEvent {
  Hide({super.arguments});
}

class Show extends AppEvent {
  Show({super.arguments});
}

class Add extends AppEvent {
  Add({super.arguments});
}

class Init extends AppEvent {
  Init({super.arguments});
}

class Delete extends AppEvent {
  Delete({super.arguments});
}

class Clear extends AppEvent {
  Clear({super.arguments});
}

class Update extends AppEvent {
  Update({super.arguments});
}

class Turn extends AppEvent {
  Turn({super.arguments});
}

class Search extends AppEvent {
  Search({super.arguments});
}

class Open extends AppEvent {
  Open({super.arguments});
}

class Scroll extends AppEvent {
  Scroll({super.arguments});
}

class SendMessage extends AppEvent {
  SendMessage({super.arguments});
}

class Typing extends AppEvent {
  Typing({super.arguments});
}

class UpdateMessage extends AppEvent {
  UpdateMessage({super.arguments});
}

class ReceiveMessage extends AppEvent {
  final Object message;

  ReceiveMessage({required this.message, super.arguments});
}
