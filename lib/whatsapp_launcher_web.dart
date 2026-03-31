// whatsapp_launcher_web.dart
import 'dart:html' as html;

void launchWhatsApp(String url) {
  html.window.open(url, '_blank');
}
