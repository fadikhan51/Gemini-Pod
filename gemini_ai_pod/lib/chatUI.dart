import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  ChatUser myself = ChatUser(id: '1', firstName: 'GuestUser');
  ChatUser gemini = ChatUser(id: '2', firstName: 'Gemini');

  final targetURL =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyDmkcO9mHjejFFWNPSx5sXYSuQZApcc5tU';
  final headers = {'Content-Type': 'application/json'};

  List<ChatMessage> allMessages = [];
  List<ChatUser> currentlyTyping = [];

  void insertIntoMessages(ChatMessage m) async {
    setState(() {
      currentlyTyping.add(gemini);
      allMessages.insert(0, m);
    });

    var query = {
      "contents": [
        {
          "parts": [
            {"text": m.text}
          ]
        }
      ]
    };

    await http
        .post(Uri.parse(targetURL), headers: headers, body: jsonEncode(query))
        .then((value) {
      if (value.statusCode == 200) {
        var result = jsonDecode(value.body);
        // print(result['candidates'][0]['content']['parts'][0]['text']);

        ChatMessage response = ChatMessage(
            text: result['candidates'][0]['content']['parts'][0]['text'],
            user: gemini,
            createdAt: DateTime.now());
          allMessages.insert(0, response);
      } else {
        ChatMessage response = ChatMessage(
            text: "Sorry, there was an error getting the response back. Please send your query again : )",
            user: gemini,
            createdAt: DateTime.now());
        allMessages.insert(0, response);
        print("Error in getting the response back");
      }
    }).catchError((error) {
      ChatMessage response = ChatMessage(
          text: "Sorry, there was an error getting the response back. Please send your query again : )",
          user: gemini,
          createdAt: DateTime.now());
      allMessages.insert(0, response);
      print("Error in getting the response back");
    });

    setState(() {
      currentlyTyping.remove(gemini);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DashChat(
        typingUsers: currentlyTyping,
        currentUser: myself,
        onSend: (ChatMessage message) {
          insertIntoMessages(message);
        },
        messages: allMessages,
      ),
    );
  }
}
