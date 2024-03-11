import 'package:flutter/material.dart';
import 'chatUI.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text("Personal Gemini"),
        leading: Icon(Icons.stadium_sharp),
      ),
      body: Chatbot(),
    ),
  ));
}

