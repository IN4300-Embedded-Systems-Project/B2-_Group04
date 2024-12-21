import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  String welcomeMessage = "Welcome to the Homepage!";

  void updateMessage(String newMessage) {
    welcomeMessage = newMessage;
    notifyListeners();
  }
}
