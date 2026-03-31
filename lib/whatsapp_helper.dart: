// lib/whatsapp_helper.dart
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'whatsapp_launcher.dart'; // if you made a separate launcher for web

Future<void> sendWhatsAppRequest(String number, String message) async {
  number = number.replaceAll('+', '');
  String url = 'https://wa.me/$number?text=${Uri.encodeComponent(message)}';
  
  if (kIsWeb) {
    launchWhatsApp(url); // Web version opens in a new tab
  } else {
    await launchWhatsApp(url); // Mobile version uses url_launcher
  }
}
